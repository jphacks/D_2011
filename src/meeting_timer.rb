# frozen_string_literal: true

# ミーティングのタイマー管理のクラス
class MeetingTimer
  def initialize
    @thread = nil
    @methods = []
    @time_limit = 0
  end

  def start_meeting
    start_agenda
  end

  # アジェンダを開始
  def start_agenda
    return puts 'アジェンダが未登録です' if @methods.empty?

    @time_limit = Time.now.to_i + @methods.first[:time]
    @thread = Thread.new do
      sleep 1 while Time.now.to_i < @time_limit
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
    @methods.shift
    return if @methods.empty?

    start_agenda
  end

  # アジェンダを延長する
  def delay(time)
    @time_limit += time
  end

  # アジェンダを強制終了させる
  def terminate
    @thread.kill
    next_agenda
  end

  def finish_meeting
    return if @thread.nil?

    @thread.kill
  end
end
