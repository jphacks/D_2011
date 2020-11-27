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

  #アジェンダの編集ページ
  get '/agenda/:id/edit' do
    @meeting = Meeting.find_by(meeting_id: params[:id])
    @start_time = Time.at(@meeting.start_time).strftime('%Y年%m月%d日 %H:%M')
    erb :edit
  end

  post '/agenda/:id/edit' do
    @meeting = Meeting.find_by(meeting_id: params[:id])
    @start_time = Time.at(@meeting.start_time).strftime('%Y年%m月%d日 %H:%M')

    agenda.duration = params[:duration]
    agenda.title = params[:title]
    agenda.save
    redirect "/agenda/:id"
  end
end
