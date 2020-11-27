# frozen_string_literal: true

# ミーティングのタイマー管理のクラス
class MeetingTimer
  def initialize
    @thread = nil
    @methods = []
    @time = 0
    @duration = 0
    # 次のアジェンダまでの時間
    @time_up_to_next_agenda = 0
  end

  def start_meeting
    @time = Time.now.to_i
    start_agenda
  end

  # アジェンダを開始
  def start_agenda
    return puts 'アジェンダが未登録です' if @methods.empty?
    @time_up_to_next_agenda = @methods.first[:time]
    @thread = Thread.new do
      while Time.now.to_i < @time + @methods.first[:time]
        @duration += 1
        sleep(1)
      end
      @methods.first[:method].call
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
  def next_agenda
    @time += @duration
    @duration = 0
    @methods.shift
    return if @methods.empty?

    start_agenda
  end

  # アジェンダを延長する
  def delay(time)
    @thread.kill
    @time_up_to_next_agenda = @duration + time
    @time += @duration + time
    @duration = 0
    @thread = Thread.new do
      while Time.now.to_i <= @time
        @duration += 1
        sleep(1)
      end
      @methods.first[:method].call
      next_agenda
    end
  end

  # アジェンダを強制終了させる
  def terminate
    @thread.kill
    next_agenda
  end

  def finish_meeting
    return if @thread == nil

    @thread.kill
    p 'ミーティングが終了しました。'
  end

  # 次の議題までの時間を返す
  def current_duration
    Time.at(@time_up_to_next_agenda - @duration).strftime('%M:%S')
  end
end
