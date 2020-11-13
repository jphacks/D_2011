# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'json'
require 'date'
# require 'rack/contrib'
require 'base64'
require 'pry'
require 'timers'
require 'open3'
require './image_edit'
require './zoom_client'
require 'sinatra/json'

# set :server, :puma
# set :logging, false

zoom = nil
# use Rack::JSONBodyParser

# # ----------
# # アジェンダページの表示
# # ----------
# get '/agenda/:id' do
#   @meeting = Meeting.last
#   # @meeting = Meeting.find_by(random_num: params[:id])
#   @agenda_times = []
#   agenda_starting_time = @meeting.start
#   @meeting.agendas.each do |agenda|
#     @agenda_times.append(Time.at(agenda_starting_time).strftime('%H:%M'))
#     agenda_starting_time += agenda.duration
#   end
#   @start_time = Time.at(@meeting.start).strftime('%Y.%m.%d %H:%M~')
#   erb :invite
# end

# # ----------
# # ミーティング中のアクション
# # ----------
# post '/meetingaction' do
#   request = params[:request]
#   id = params[:id]
#   duration = params[:duration]
#   title = params[:title]
#   meetingid = params[:meetingid]
#   meetingpass = params[:meetingpass]
#   start = params[:start]
#   link = params[:link]
#   agenda = params[:agenda]

#   case request
#   when 'start' # POST /api/meeting/start
#     start_meeting(id, duration, title, meetingid, meetingpass)
#   when 'next' # POST /api/meeting/finish
#     changePhoto(id, title, duration.to_i)
#   when 'finish' # POST /api/meeting/finish
#     finishMeeting(id)
#   when 'create' # POST /api/meeting
#     createMeeting(title, start, link, agenda)
#   when 'mute' # POST /api/meeting/mute
#     muteAllPeople
#   end
# end

# # ----------
# # ミーティングの開始
# # ----------
# def start_meeting(id, duration, title, meeting_id, meeting_pass)
#   zoom = ZoomClient.connect_with_number(meeting_id, meeting_pass)
#   return json({ status: 'error', why: 'zoom connection error' }) unless zoom

#   Thread.new do
#     zoom.enable_video # カメラを有効化
#     zoom.request_co_host
#     zoom.change_image(topicWrite("#{title}\n(#{duration}分)", id))
#   end
#   json({ status: 'success' })
# rescue StandardError => e
#   print(e)
#   json({ status: 'error', why: e.to_s })
# end

# # ----------
# # 議題の変更（アプリからの通信）
# # ----------
# def changePhoto(id, title, duration)
#   begin
#     File.delete("public/assets/img/tmp/#{id}.png")
#   rescue StandardError => e
#     print(e)
#   end
#   zoom.changeImage(topicWrite("#{title}\n(#{duration}分)", id))
# end

# # ----------
# # ミーティングの終了
# # ----------
# def finishMeeting(id)
#   begin
#     File.delete("public/assets/img/tmp/#{id}.png")
#     # data = { status: "success" }
#     # json data
#     zoom.leaveMeeting
#   rescue StandardError => e
#     print(e)
#     # data = { status: "error" }
#     # json data
#   end
#   data = { status: 'success' }
#   json data
# end

# # ----------
# # ミーティングの作成
# # ----------
# def createMeeting(titleAPI, startTimeAPI, linkAPI, agendaAPI)
#   meeting_id = SecureRandom.hex
#   time = Time.at(startTimeAPI)
#   meeting = Meeting.create(
#     random_num: meeting_id,
#     start: time,
#     link: linkAPI,
#     title: titleAPI
#   )

#   agendaAPI.each do |agenda|
#     agenda = Agenda.create(
#       meeting_id: meeting.id,
#       title: titleAPI,
#       duration: agenda[:duration]
#     )
#   end

#   data = { agenda: agendaphoto(titleAPI, startTimeAPI.to_i, JSON.parse(agendaAPI.to_json)), url: "https://aika.lit-kansai-mentors.com/agenda/#{meeting.random_num}", id: meeting.random_num }
#   json data
# end

# # ----------
# # ミュートにする && アンミュートの通知表示
# # ----------
# def muteAllPeople
#   zoom.muteAll
#   zoom.reqyest_unmute_all
#   data = { status: 'success' }
#   json data
# rescue StandardError => e
#   data = { status: 'error', why: e.to_s }
#   json data
# end

# # ----------
# # アジェンダ画像生成（タイトル(String),開始時間(UNIX時間),アジェンダのリスト(連想配列)）
# # ----------
# def agendaphoto(title, startTime, agendas)
#   @startTime = startTime
#   agendaList = agendas.each_slice(7).to_a
#   # p agendaList
#   returnText = []
#   agendaList.each_with_index do |a, i|
#     text = { photo: agendaSheetPhoto(title, a, i + 1, agendaList.length) }
#     returnText = returnText.push(text)
#   end
#   returnText.to_json
# end

# # ----------
# # アジェンダ画像生成（タイトル(String),アジェンダのリスト(連想配列),何個目の画像か(Int),全体の数(int)）
# # ----------
# def agendaSheetPhoto(title, agendas, num, length)
#   title = "#{title.delete("\n").slice(0, 14)}…" if title.length >= 14
#   title += "(#{num}/#{length})"
#   text = ''
#   agendas.each do |a|
#     start = Time.at(@startTime).strftime('%H:%M') # このアジェンダシートの開始時刻
#     duration = (a['duration'] / 60).ceil
#     titleA = if a['title'].length >= 12
#                "#{a['title'].delete("\n").slice(0, 12)}…"
#              else
#                a['title'].delete("\n")
#              end
#     text += "#{start} #{duration}分 #{titleA}\n"
#     @startTime += a['duration']
#   end
#   agendaWrite(title, text)
# end

# ----------
# 仮想カメラの制御
# ----------
# Zoomに接続
get '/api/zoom/connect' do
  zoom = ZoomClient.connect_with_url(params[:url])
  return 'failed' unless zoom

  Thread.new do
    zoom.enable_video # カメラを有効化
    zoom.request_co_host
  end
  'ok'
end
# 画像変更
get '/api/zoom/change' do
  zoom.change_image('test1.png')
  'ok'
end
get '/api/zoom/change2' do
  zoom.change_image('test2.png')
  'ok'
end
# 参加者一覧取得
get '/api/zoom/attendees' do
  zoom.attendeesList.to_s
end
# ミュート
get '/api/zoom/mute' do
  zoom.mute(params[:userid])
end
# アンミュート（リクエスト）
get '/api/zoom/unmute' do
  zoom.request_unmute(params[:userid])
end
# 全ミュート
get '/api/zoom/muteall' do
  zoom.muteAll
end
# 全アンミュート
get '/api/zoom/muteall' do
  zoom.reqyest_unmute_all
end
