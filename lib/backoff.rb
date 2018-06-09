require "delegate"
class Backoff < Delegator
  def self.wrap(object, exception_classes, logger, options)
    return object if object.is_a?(self.class)
    new(object, exception_classes, logger, options)
  end

  def initialize(object, exception_classes, logger, options = {})
    @exception_classes = exception_classes
    @delegate_sd_obj = object
    @logger = logger
    @sleeper = options[:sleeper] || Kernel.method(:sleep)
    @initial_backoff = options[:initial_backoff] || 1
    @multiplier = options[:multiplier] || 2
  end

  def __getobj__
    @delegate_sd_obj
  end

  def method_missing(sym, *args, &block)
    _with_backoff { super }
  end

  def _with_backoff(backoff = @initial_backoff)
    yield
  rescue *@exception_classes => e
    @logger.error "Got #{e.class}, sleeping #{backoff}"
    @sleeper.call(backoff)
    @logger.info "Woke up after #{e.class} retrying again"
    backoff *= @multiplier
    retry
  end
end
