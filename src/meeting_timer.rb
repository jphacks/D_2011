# frozen_string_literal: true

# ミーティングのタイマー管理のクラス
class MeetingTimer
  def initialize
    @thread = nil
    @methods = []
    @time = 0
  end

  def reserve_meeting(time)
    @time = time
    @thread = Thread.new do
      while Time.now.to_i <= @time
        sleep(1)
        p 'tick'
      end
      puts 'ミーティング開始！'
      start_agenda
    end
  end

  def start_agenda
    @methods.first[:method].call
    @time += @methods.first[:time]
    @thread = Thread.new do
      while Time.now.to_i <= @time
        p 'agenda'
        sleep(1)
      end
      next_agenda
    end
  end

  def enqueue_agenda(time, &method)
    @methods << {
      time: time,
      method: method
    }
  end

  def next_agenda
    p @methods
    @methods.pop(1)
    if @methods.empty?
      p 'meeting finished!'
      return
    end
    start_agenda
  end

  def delay(time)
    @time += time
    @thread.kill
    while Time.now.to_i <= @time
      p '延長'
      sleep(1)
    end
    next_agenda
  end

  def terminate
    p 'terminate'
    @thread.kill
    next_agenda
  end
end
