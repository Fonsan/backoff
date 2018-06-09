RSpec.describe Backoff do
  let(:object) { double(:object) }
  let(:logger) { spy(:logger) }
  let(:sleeper) { spy(:sleeper) }
  class FakeError < StandardError; end
  let(:exception_classes) { [StandardError, FakeError] }
  subject { Backoff.wrap(object, exception_classes, logger, sleeper: sleeper) }

  it 'retries if StandardError' do
    times = 0
    allow(object).to receive(:foo) do |args|
      times += 1
      if times < 3
        raise StandardError
      end
    end
    subject.foo
    expect(logger).to have_received(:error).with("Got StandardError, sleeping 1").once
    expect(logger).to have_received(:error).with("Got StandardError, sleeping 2").once
  end

  it 'calls with correct parameters' do
    block = lambda { }
    expect(object).to receive(:derp) do |*args, &received_block|
      expect(args).to eq([1])
      expect(received_block).to eq(block)
    end.once
    subject.derp(1, &block)
  end

  it 'returns original value' do
    allow(object).to receive(:derp).and_return(:value)
    expect(subject.derp).to eq(:value)
  end

  it 'sleeps with correct exponential backoff if FakeError' do
    times = 0
    allow(object).to receive(:bar) do |args|
      times += 1
      if times < 5
        raise FakeError
      end
    end
    subject.bar
    expect(sleeper).to have_received(:call).with(1).once
    expect(sleeper).to have_received(:call).with(2).once
    expect(sleeper).to have_received(:call).with(4).once
    expect(sleeper).to have_received(:call).with(8).once
  end
end
