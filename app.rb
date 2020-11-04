require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'json'
require 'date'
require 'rack/contrib'

use Rack::PostBodyContentTypeParser

get '/show' do
  article = {
      id: 1,
      title: "today's dialy",
      content: "It's a sunny day."
  }
  print("get show")
  article.to_json
end

post '/hoge' do
  title = params[:params]
  start = Time.at(params[:start].to_i)
  link = params[:link]
  agenda = JSON.parse(params[:agenda].to_json)

  p agenda[0]["title"]
end



# ----------
# 時間の演算
# ----------
def stringToDateTime(s)
  inputTime = s.split(':') #入力された数字をHourとminitusに分離 -> ["12","00"]
  if inputTime[0].is_a?(Integer)
    time = DateTime.new(2020,4,5,inputTime[0],inputTime[1]) #DateTimeオブジェクトに変換
  else
    time = DateTime.new(2020,4,5,inputTime[0].to_i,inputTime[1].to_i) #DateTimeオブジェクトに変換
  end
  return time
end

get '/' do
  'Hello world!'
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

get '/test' do
  '
  <form method="POST" action="/upload" enctype="multipart/form-data">
    <input type="file" name="file">
    <input type="submit" value="Upload">
  </form>
  '
end