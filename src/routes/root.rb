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
    # @meeting = Meeting.last
    @meeting = Meeting.find_by(meeting_id: params[:id])
    @start_time = Time.at(@meeting.start_time).strftime('%Y年%m月%d日 %H:%M')
    erb :invite
  end
end
