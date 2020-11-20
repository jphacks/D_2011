# frozen_string_literal: true

# ミーティングのタイマー管理のクラス
#
# こんな感じで使って~
# meeting = Meeting.first
# timer = MeetingTimer.new(meeting, meeting.agendas.order('id'))
#
# メソッド毎の説明は後でやります。
class MeetingTimer
  attr_accessor :meeting, :agendas

  def initialize(meeting, agendas)
    @meeting = meeting
    @agendas = agendas
    @thread = nil
    @current_agenda_count = 0

    @time = meeting.start_time # Unix時間
    create_meeting
  end

  def create_meeting
    @thread = Thread.new do
      sleep 1 while Time.now.to_i <= @time
      start_agenda(@agendas[@current_agenda_count])
    end
  end

  def start_agenda(agenda)
    @time += agenda.duration
    @thread = Thread.new do
      sleep(1) while Time.now.to_i <= @time
      finish_agenda
    end
  end

  def delay_agenda(time)
    @time += time
    @thread.kill
    @thread = Thread.new do
      sleep(1) while Time.now.to_i <= @time
      finish_agenda
    end
    start_agenda(@agendas[@current_agenda_count])
  end

  def terminate_agenda
    @thread.kill
    finish_agenda
  end

  def finish_agenda
    @current_agenda_count += 1
    return puts 'meeting ended' if @current_agenda_count == @agendas.length

    start_agenda(@agendas[@current_agenda_count])
  end

  def finish_meeting(thread)
    return puts 'Thread is not created' if thread.nil?

    thread.kill
  end
end
