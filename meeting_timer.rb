# ミーティングのタイマー管理のクラス

# こんな感じで使って~
# meeting = Meeting.first
# timer = MeetingTimer.new(meeting, meeting.agendas.order('id'))

# メソッド毎の説明は後でやります。

class MeetingTimer

  attr_accessor :meeting, :agendas

  def initialize(meeting, agendas)
    @meeting = meeting
    @agendas = agendas
    @thread = nil
    @current_agenda_count = 0
    # Unix時間
    @time = meeting.start
    self.create_meeting()
  end

  def create_meeting()
    @thread = Thread.new do
      begin
        while Time.now.to_i <= @time
          sleep(1)
        end
        self.start_agenda(@agendas[@current_agenda_count])
      end
    end
  end

  def start_agenda(agenda)
    @time += agenda.duration
    @thread = Thread.new do
      begin
        while Time.now.to_i <= @time
          sleep(1)
        end
        finish_agenda()
      end
    end
  end
  
  def delay_agenda(time)
    @time += time
    @thread.kill
    @thread = Thread.new do
      begin
        while Time.now.to_i <= @time
          sleep(1)
        end
        finish_agenda()
      end
    end
    self.start_agenda(@agendas[@current_agenda_count])
  end
  
  def terminate_agenda
    @thread.kill
    finish_agenda()
  end

  def finish_agenda
    @current_agenda_count += 1
    if @current_agenda_count == @agendas.length
      p 'meeting ended'
    else
      self.start_agenda(@agendas[@current_agenda_count])
    end
  end
  
  
  def finish_meeting(thread)
    if thread
      thread.kill
    else
      p 'Thread is not created'
    end
  end
end