require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'active_support/all'
require 'active_support/core_ext'
require 'mini_magick'
require 'securerandom'

before do
  @base_image_path = "public/assets/img/bg.jpg".freeze
  @font = "public/assets/fonts/unifont-11.0.01.ttf".freeze
  @color = "white"
  @text_position = '0,0'.freeze
  @topic_indention_count = 10
  @topic_row_limit = 8
end

# ----------------------------
# アジェンダ用の画像生成(アプリへの送信用にJSONに変換)
# ----------------------------
# 画像の生成（タイトル）
def agendaTitleBuild(print_text)
  @image = MiniMagick::Image.open(@base_image_path)
  agendaTitleConfiguration(print_text)
end

# 画像の生成（内容）
def agendaContentsBuild(print_text)
  agendaContentsConfiguration(print_text)
end

# 画像の書き出し（タイトル & 内容）
def agendaWrite(title,contents)
  agendaTitleBuild(title)
  agendaContentsBuild(contents)
  image_name = uniq_file_name
  @image.write image_name
  binary_data = File.read(image_name)
  json_data = Base64.strict_encode64(binary_data)
  File.delete(image_name)
  return json_data
end

# ----------------------------
# Zoomの仮想カメラ用の画像生成
# ----------------------------
# 画像の生成
def topicBuild(print_text)
  text = topic_prepare_text(print_text)
  @image = MiniMagick::Image.open(@base_image_path)
  topicConfiguration(text)
end

# 画像の書き出し（削除なし）
def topicWrite(print_text,image_name)
  topicBuild(print_text)
  image_name = image_name + ".png"
  @image.write image_name
  binary_data = File.read(image_name)
  FileUtils.mv(image_name,"public/assets/img/tmp/"+image_name)
  return "public/assets/img/tmp/"+image_name
  # json_data = Base64.strict_encode64(binary_data)
  # return json_data
end

# 画像の書き出し（削除あり）
def topicWriteWithDelete(print_text)
  topicBuild(print_text)
  image_name = uniq_file_name
  @image.write image_name
  binary_data = File.read(image_name)
  json_data = Base64.strict_encode64(binary_data)
  File.delete(image_name)
  return json_data
end

private
# uniqなファイル名を返却
def uniq_file_name
  "#{SecureRandom.hex}.png"
end

# ----------------------------
# アジェンダ用の画像生成(アプリへの送信用にJSONに変換)
# ----------------------------
# 設定関連を代入 & タイトルの文字列を合成
def agendaTitleConfiguration(text)
  @image.combine_options do |config|
    config.fill @color
    config.font @font
    config.gravity 'North'
    config.pointsize 80
    config.draw "text 0,50 '#{text}'"
  end
end

# 設定関連を代入 & 内容の文字列を合成
def agendaContentsConfiguration(text)
  @image.combine_options do |config|
    config.fill @color
    config.font @font
    config.gravity 'NorthWest'
    config.pointsize 60
    config.draw "text 100,200 '#{text}'"
  end
end

# 文字オーバーしない用に調整して文字列を返却
def agenda_title_prepare_text(print_text)
  if print_text.length >= 14
    print_text = print_text.delete("\n").slice(0 ,14) + "…"
  end
  return print_text
end

# ----------------------------
# Zoomの仮想カメラ用の画像生成
# ----------------------------
# 設定関連を代入 & 文字列を合成
def topicConfiguration(text)
  # 固定ベース画像（水色フレーム）に文字を合成
  @image.combine_options do |config|
    config.fill @color
    config.font @font
    config.gravity 'center'
    config.pointsize 100
    config.draw "text #{@text_position} '#{text}'"
  end
end

# 文字オーバーしない用に調整して文字列を返却
def topic_prepare_text(print_text)
  print_text.scan(/.{1,#{@topic_indention_count}}/)[0...@topic_row_limit].join("\n")
end