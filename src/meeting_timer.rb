# ミーティングのタイマー管理のクラス

class MeetingTimer

  def initialize()
    @thread = nil
    @methods = []
    @time = 0
    @duration = 0
  end

  # @param [Integer] time ミーティングを開始したい時間
  def start_meeting(time)
    @time = Time.now.to_i
    start_agenda
  end


  # アジェンダを開始
  def start_agenda()
    if @methods.length == 0
      p 'アジェンダを登録してください'
      return
    end
    @methods.first[:method].call
    @thread = Thread.new do
      while Time.now.to_i <= @time + @methods.first[:time]
        @duration += 1
        sleep(1)
      end
      next_agenda
    end
  end

  # アジェンダを登録
  def enqueue_agenda(time, &method)
    @methods << {
      time: time,
      method: method
    }
  end

  # 次のアジェンダへ
  def next_agenda()
    @time += @duration
    @duration = 0
    @methods.pop(1)
    if @methods.empty?
      return
    end
    start_agenda
  end
  
  # アジェンダを延長する
  def delay(time)
    @thread.kill
    @time += @duration
    @duration = 0
    begin
      while Time.now.to_i <= @time + time
        @duration += 1
        sleep(1)
      end
      next_agenda
    end
  end

  # アジェンダを強制終了させる
  def terminate
    @thread.kill
    next_agenda
  end
end