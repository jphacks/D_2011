require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'json'
require 'date'
require 'rack/contrib'
require 'base64'
require 'pry'
require 'timers'
require 'open3'
require './image_edit.rb'
require './zoom_client.rb'
require 'grape'
require "sinatra/json"

zoom = nil
use Rack::PostBodyContentTypeParser

# def timer(array, start)
#   timers = Timers::Group.new
#   # UNIX時間を生成
#   current_time = Time.new.to_i
#   loop do
#     break if start <= current_time
#     sleep 1
#   end
#   array.each do |agenda|
#     topic_image = topicWrite(agenda["title"]+"\n("+"#{agenda["duration"]}"+"分)")
#     # Zoom Clientのメソッドを起動する

#     #
#     timer = timers.after(agenda["duration"]) {

#     }
#     # timer = timers.after(agenda["duration"] * 60) {
#       # Zoom Clientでカメラを落とすなどする(?)

#       #
#     # }
#     timers.wait
#   end
# end

# post '/test' do
#   Thread.new { timer(params[:agenda], params[:start]) }
#   meeting_id = SecureRandom.hex
#   time = Time.at(params[:start])
#   meeting = Meeting.create(
#     random_num: meeting_id,
#     start: time,
#     link: params[:link],
#     title: params[:title]
#   )

#   params["agenda"].each do |agenda|
#     agenda = Agenda.create(
#       meeting_id: meeting.id,
#       title: agenda[:title],
#       duration: agenda[:duration]
#     )
#   end

#   return {
#     "agenda"=> agendaphoto(params[:title],params[:start].to_i,JSON.parse(params[:agenda].to_json)),
#     "url" => "https://aika.lit-kansai-mentors.com/agenda/#{meeting.random_num}",
#     "id" => meeting.random_num
#   }.to_json
# end

get '/' do
  'Hello World!'
  SecureRandom.hex
end

# ----------
# アジェンダページの表示
# ----------
get '/agenda/:id' do
  hoge = Meeting.last
  # 本番はこれを使う
  @meeting = Meeting.find_by(random_num: params[:id])
  @agenda_times = []
  agenda_starting_time = @meeting.start
  @meeting.agendas.each do |agenda|
    agenda_starting_time += agenda.duration * 60
    @agenda_times.append(Time.at(agenda_starting_time).strftime("%H:%M"))
  end
  p @agenda_times
  @start_time =  Time.at(@meeting.start).strftime("%Y.%m.%d %H:%M~")
  erb :invite
end

# ----------
# ミーティング中のアクション
# ----------
post '/meetingaction' do
  request = params[:request]
  if request == "start" # ミーティングの開始(成功通知など何かしらのリスポンス)
    return startMeeting(params[:id],params[:duration],params[:title])

  elsif request == "next" #議題の変更(リターンは特になくてもOK)
    changePhoto(params[:id],params[:title],params[:duration].to_i)

  elsif request == "finish" #ミーティングの終了(成功通知など何かしらのリスポンスが欲しい)
    return finishMeeting(params[:id])

  elsif request == "create" #ミーティングの作成(Base64の写真データと招待ページのURLをJSONで欲しい)
    return createMeeting(params[:title],params[:start],params[:link],params[:agenda])

  elsif request == "mute"
    muteAllPeople()
  end
end

# ----------
# ミーティングの開始
# ----------
def startMeeting(id,duration,title)
  begin
    zoom = ZoomClient.new
    zoom.changeImage(topicWrite(title+"\n("+duration+"分)",id))
    data = { status: "success" }
    json data
  rescue => e
    print (e)
    data = { status: "error" }
    json data
  end
end

# ----------
# 議題の変更（アプリからの通信）
# ----------
def changePhoto(id,title,duration)
  begin
    File.delete("public/assets/img/tmp/"+id+".png")
  rescue => e
    print(e)
  end
  zoom.changeImage(topicWrite(title+"\n("+duration+"分)",id))
end

# ----------
# ミーティングの終了
# ----------
def finishMeeting(id)
  begin
    File.delete("public/assets/img/tmp/"+id+".png")
    data = { status: "success" }
    json data
  # メモ：Zoomビデオを切れたらここに！
  rescue => e
    print(e)
    data = { status: "error" }
    json data
  end
end

# ----------
# ミーティングの作成
# ----------
def createMeeting(titleAPI,startTimeAPI,linkAPI,agendaAPI)
  Thread.new { timer(agendaAPI, startTimeAPI) }
  meeting_id = SecureRandom.hex
  time = Time.at(startTimeAPI)
  meeting = Meeting.create(
    random_num: meeting_id,
    start: time,
    link: linkAPI,
    title: titleAPI
  )

  agendaAPI.each do |agenda|
    agenda = Agenda.create(
      meeting_id: meeting.id,
      title: titleAPI,
      duration: agenda[:duration]
    )
  end

  # return {
  #   "agenda"=> agendaphoto(titleAPI,startTimeAPI.to_i,JSON.parse(agendaAPI.to_json)),
  #   "url" => "https://aika.lit-kansai-mentors.com/agenda/#{meeting.random_num}",
  #   "id" => meeting.random_num
  # }.to_json
  data = { agenda: agendaphoto(titleAPI,startTimeAPI.to_i,JSON.parse(agendaAPI.to_json)) , url: "https://aika.lit-kansai-mentors.com/agenda/#{meeting.random_num}" , id: meeting.random_num }
  json data
end

# ----------
# ミュートにする
# ----------
def muteAllPeople()
  begin
    # ミュート処理をする
    data = { status: "success" }
    json data
  rescue => e
    data = { status: "error" }
    json data
  end
end

# ----------
# 仮想カメラ用の画像生成
# ----------
# post '/topicphoto' do
#   content = params[:content]
#   duration = params[:duration]
#   data = { photo: topicWrite(content+"\n("+duration+"分)") }
#   json data
# end

# ----------
# アジェンダ用の画像生成
# ----------
# post '/agendaphoto' do
#   return agendaphoto(params[:title],params[:start].to_i,JSON.parse(params[:agenda].to_json))
# end

# ----------
# アジェンダ画像生成（タイトル(String),開始時間(UNIX時間),アジェンダのリスト(連想配列)）
# ----------
def agendaphoto(title,startTime,agendas)
  @startTime = startTime
  agendaList = agendas.each_slice(7).to_a
  # p agendaList
  returnText = []
  agendaList.each_with_index do | a , i |
    text = {photo : agendaSheetPhoto(title,a,i+1,agendaList.length)}
    returnText = returnText.push(text)
  end
  return returnText.to_json
end

# ----------
# アジェンダ画像生成（タイトル(String),アジェンダのリスト(連想配列),何個目の画像か(Int),全体の数(int)）
# ----------
def agendaSheetPhoto(title,agendas,num,length)
  if title.length >= 14
    title = title.delete("\n").slice(0 ,14) + "…"
  end
  title = title + "(" + num.to_s + "/" + length.to_s + ")"
  text = ""
  agendas.each do |a|
    start = Time.at(@startTime).strftime("%H:%M") # このアジェンダシートの開始時刻
    duration = (a["duration"]/60).ceil
    if a["title"].length >= 12
      titleA = a["title"].delete("\n").slice(0 ,12) + "…"
    else
      titleA = a["title"].delete("\n")
    end
    text = text + start + " " + duration.to_s + "m " + titleA + "\n"
    @startTime = @startTime + a["duration"]
  end
  return agendaWrite(title,text)
end

# ----------
# 仮想カメラの制御
# ----------
# Zoomに接続
get '/api/zoom/connect' do
  zoom = ZoomClient.new("83465557585", "Z5jTwT")
  zoom.requestCoHost
  'ok'
end
# 画像変更
get '/api/zoom/change' do
  zoom.changeImage('test2.jpeg')
  'ok'
end
# 参加者一覧取得
get '/api/zoom/attendees' do
  zoom.getAttendeesList.to_s
end
# 参加者一覧取得
get '/api/zoom/mute' do
  zoom.mute(params[:userid], params[:mute])
end

# ----------
# ffmpegの実行
# ----------
def viewTopicPhoto(content,duration)
  topicBuild(content+"\n("+duration+"分)")
  image_name = uniq_file_name
  @image.write image_name
  cmd = "sudo ffmpeg -re -i "+ image_name +" -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0"
  stdout, stderr, status = Open3.capture3(cmd)
  p stdout
  p stderr
  p status
end

# ----------
# 検証コード
# ----------
post '/test' do
  data = { foo: params[:test] }
  json data
end


# get '/aaa' do
#   erb:invitation
# end

# get '/cmdtest' do
#   viewTopicPhoto("print_text","10")
# end

# get '/topic/:time/:title' do |time,title|
#   @time = time
#   @title = title
#   erb :topic
# end

# post '/aaaa' do
#   return { "status" => topicWrite("print_text","image_name")}.to_json
# end

# post '/hoge' do
#   title = params[:params]
#   start = Time.at(params[:start].to_i)
#   link = params[:link]
#   agenda = JSON.parse(params[:agenda].to_json)
#   p agenda.to_s
# end

# post '/test' do
#   # body = env['api.request.body']
#   # return body # Response BodyにそのままRequest Bodyを返す
#   api = nil
#   api = API.new
#   api.user("test")
# end

# run Rack::URLMap.new("/api" => Api.new)