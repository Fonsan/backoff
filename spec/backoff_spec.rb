RSpec.describe Backoff do
  let(:object) { double(:object) }
  let(:initial_backoff) { nil }
  let(:multiplier) { nil }
  let(:logger) { spy(:logger) }
  let(:sleeper) { spy(:sleeper) }
  let(:random) { Random.new(1234) }
  class FakeError < StandardError; end
  let(:exception_classes) { [StandardError, FakeError] }
  subject do
    Backoff.wrap(
      object,
      exception_classes,
      logger,
      sleeper: sleeper,
      random: random,
      initial_backoff: initial_backoff,
      multiplier: multiplier,
    )
  end

  it 'retries if StandardError' do
    times = 0
    allow(object).to receive(:foo) do |args|
      times += 1
      if times < 3
        raise StandardError
      end
    end
    subject.foo
    expect(logger).to have_received(:error).with("Got StandardError, sleeping 0.19151945027934003").once
    expect(logger).to have_received(:error).with("Got StandardError, sleeping 1.244217533067725").once
  end

  context 'with higher initial backoff' do
    let(:initial_backoff) { 2 }

    it 'retries if StandardError' do
      times = 0
      allow(object).to receive(:foo) do |args|
        times += 1
        if times < 3
          raise StandardError
        end
      end
      subject.foo
      expect(logger).to have_received(:error).with("Got StandardError, sleeping 0.38303890055868006").once
      expect(logger).to have_received(:error).with("Got StandardError, sleeping 2.48843506613545").once
    end
  end

  context 'with higher multiplier' do
    let(:multiplier) { 3 }

    it 'retries if StandardError' do
      times = 0
      allow(object).to receive(:foo) do |args|
        times += 1
        if times < 3
          raise StandardError
        end
      end
      subject.foo
      expect(logger).to have_received(:error).with("Got StandardError, sleeping 0.19151945027934003").once
      expect(logger).to have_received(:error).with("Got StandardError, sleeping 1.8663262996015875").once
    end
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
