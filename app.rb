require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require "date"
require "google/cloud/storage"

Dotenv.load
storage = Google::Cloud::Storage.new project: ENV["GOOGLE_PROJECT_ID"], keyfile: ENV["GOOGLE_CLOUD_API_KEY_PATH"]
bucket  = storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]

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

post '/upload' do
  file_path = params[:file][:tempfile].path
  file_name = params[:file][:filename]

  # Upload file to Google Cloud Storage bucket
  file = bucket.create_file file_path, file_name
  # The public URL can be used to directly access the uploaded file via HTTP
  file.public_url
end