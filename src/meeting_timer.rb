# ミーティングのタイマー管理のクラス

class MeetingTimer

  def initialize()
    @thread = nil
    @methods = []
    @time = 0
  end

  # @param [Integer] time ミーティングを開始したい時間
  def start_meeting(time)
    @time = Time.now.to_i
    start_agenda
  end

  def start_agenda()
    if @methods.length == 0
      p 'アジェンダを登録してください'
    end
    @methods.first[:method].call
    @time += @methods.first[:time]
    @thread = Thread.new do
      while Time.now.to_i <= @time
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

  def next_agenda()
    @methods.pop(1)
    if @methods.empty?
      return
    end
    start_agenda
  end
  
  def delay(time)
    @time += time
    @thread.kill
    begin
      while Time.now.to_i <= @time
        sleep(1)
      end
      next_agenda
    end
  end

  def terminate
    @thread.kill
    next_agenda
  end
end