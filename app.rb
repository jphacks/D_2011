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

use Rack::PostBodyContentTypeParser

def timer(array)
  timers = Timers::Group.new
  array.each do |agenda|
    p agenda["title"]
    p agenda["duration"]
    topic_image = topicWrite(agenda["title"]+"\n("+"#{agenda["duration"]}"+"分)")
    # Zoom Clientのメソッドを起動する

    #
    timer = timers.after(agenda["duration"]) {

    }
    # timer = timers.after(agenda["duration"] * 60) {
      # Zoom Clientでカメラを落とすなどする(?)

      #
    # }
    timers.wait
  end
end

post '/test' do
  Thread.new { timer(params["agenda"]) }
  meeting_id = SecureRandom.hex
  meeting = Meeting.create(
    random_num: meeting_id,
    start: Time.at(params[:start]),
    link: params["link"],
  )

  params["agenda"].each do |agenda|
    Agenda.create(
      meeting_id: meeting_id,
      title: agenda["title"],
      duration: agenda["duration"]
    )
  end

  return {
    "agenda"=> agendaphoto(params[:title],params[:start].to_i,JSON.parse(params[:agenda].to_json)),
    "url" => "https://aika.lit-kansai-mentors.com/#{meeting.random_num}"
  }.to_json
end

get '/' do
  'Hello World!'
  SecureRandom.hex
end

post '/hoge' do
  title = params[:params]
  start = Time.at(params[:start].to_i)
  link = params[:link]
  agenda = JSON.parse(params[:agenda].to_json)

  p agenda.to_s
end

# ----------
# 仮想カメラ用の画像生成
# ----------
post '/topicphoto' do
  content = params[:content]
  duration = params[:duration]
  return {"photo"=>topicWrite(content+"\n("+duration+"分)")}.to_json
end

# ----------
# アジェンダ用の画像生成
# ----------
post '/agendaphoto' do
  return agendaphoto(params[:title],params[:start].to_i,JSON.parse(params[:agenda].to_json))
end

# ----------
# アジェンダ画像生成（タイトル(String),開始時間(UNIX時間),アジェンダのリスト(連想配列)）
# ----------
def agendaphoto(title,startTime,agendas)
  @startTime = startTime
  agendaList = agendas.each_slice(7).to_a
  # p agendaList
  returnText = []
  agendaList.each_with_index do | a , i |
    text = {"photo"=>agendaSheetPhoto(title,a,i+1,agendaList.length)}
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

get '/cmdtest' do
  viewTopicPhoto("print_text")
end

# ----------
# ffmpegの実行
# ----------
def viewTopicPhoto(print_text)
  topicBuild(print_text)
  image_name = uniq_file_name
  @image.write image_name
  cmd = "sudo ffmpeg -re -i "+ image_name +" -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0"
  stdout, stderr, status = Open3.capture3(cmd)
  p stdout
  p stderr
  p status
end
