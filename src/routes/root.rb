# frozen_string_literal: true

require './src/routes/api/api'

# Root Router
class RootRouter < Base
  use ApiRouter

  get '/' do
    erb :index
  end

  # アジェンダページの表示
  get '/agenda/:id' do
    @meeting = Meeting.last
    # @meeting = Meeting.find_by(meeting_id: params[:id])
    @agenda_times = []
    agenda_starting_time = @meeting.start
    @meeting.agendas.each do |agenda|
      @agenda_times.append(Time.at(agenda_starting_time).strftime('%H:%M'))
      agenda_starting_time += agenda.duration
    end
    @start_time = Time.at(@meeting.start).strftime('%Y.%m.%d %H:%M~')
    erb :invite
  end
end
