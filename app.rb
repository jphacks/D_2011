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
require './image_edit.rb'
  



use Rack::PostBodyContentTypeParser

post '/test' do
  timers = Timers::Group.new
  hash = JSON.parse(params)
  
  hash["agenda"].each do |agenda|
    topic_image = topicWrite(agenda["title"]+"\n("+duration+"分)")
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

get '/' do
  'Hello World!'
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

post '/agendaphoto' do
  title = params[:title]
  @startTime = params[:start].to_i
  agendas = JSON.parse(params[:agenda].to_json)
  agendaList = agendas.each_slice(7).to_a
  p agendaList
  returnText = []
  agendaList.each_with_index do | a , i |
    text = {"photo"=>agendaSheetPhoto(title,a,i+1,agendaList.length)}
    returnText = returnText.push(text)
  end
  return returnText.to_json
end

# 7個まで
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

get '/sheet/:title/:start/:content' do |t, s, c|
  @title = t
  # ----------
  # 配列に入れていく
  # ----------
  time = ""
  @contents = []
  inputContent = c.split('=') # 1つ1つのアジェンダに分離
  inputContent.each do |t|
    content = t.split('-') # アジェンダを所要時間と内容に分離 -> [所要時間,内容]
    content[0] = content[0].to_i #所要時間をintに変換

    if time.empty?
      time = [stringToDateTime(s).strftime("%H:%M")] # 何も値がないときは最初の初期時間を表示
    else
      time = stringToDateTime(@contents.last[0])
      time = time + Rational(@contents.last[1], 24 * 60)
      time = [time.strftime("%H:%M")]
    end
    content = time.push(content)
    content.flatten!
    @contents.push(content)
  end

  # ----------
  # 出力する文字列の個数を5個以内
  # ----------
  if @contents.length >= 5
    @contents.slice!(5,@contents.length-5)
  end
  erb :sheet
end

get '/topic/:time/:title' do |time,title|
  @time = time
  @title = title
  erb :topic
end