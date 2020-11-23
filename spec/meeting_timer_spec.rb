# frozen_string_literal: true

require 'timeout'

def wait
  q = Queue.new
  yield proc { |res| q.push res }
  q.pop
end

RSpec.describe 'meeting_timer.rb' do
  describe '待機処理' do
    before(:all) do
      @timer = MeetingTimer.new
      @time = Time.now.to_i
      @q = Queue.new
      @timer.enqueue_agenda(1) { @q.enq 1 }
      @timer.enqueue_agenda(2) { @q.enq 2 }
      @timer.start_meeting
      @res = []
    end
    example('1秒待機') do
      @res << @q.deq
      expect(@res.sum).to eq(Time.now.to_i - @time)
    end
    example('2秒待機') do
      @res << @q.deq
      expect(@res.sum).to eq(Time.now.to_i - @time)
    end
  end

  describe '延長処理' do
    before(:all) do
      @timer = MeetingTimer.new
      @time = Time.now.to_i
      @q = Queue.new
      @timer.enqueue_agenda(1) { @q.enq 1 }
      @timer.start_meeting
    end
    example('1秒+1秒待機') do
      Timeout.timeout(4) do
        @timer.delay(1)
        @q.deq
        expect(2).to eq(Time.now.to_i - @time)
      end
    end
  end

  describe 'スキップ処理' do
    before(:all) do
      @timer = MeetingTimer.new
      @time = Time.now.to_i
      @q = Queue.new
      @timer.enqueue_agenda(10) { @q.enq 10 }
      @timer.enqueue_agenda(1) { @q.enq 1 }
      @timer.start_meeting
    end
    example('10秒待機を取り消して1秒待機') do
      Timeout.timeout(4) do
        @timer.terminate
        expect(@q.deq).to eq(Time.now.to_i - @time)
      end
    end
  end
end
