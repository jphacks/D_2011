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
  @gravity = 'center'.freeze
  @text_position = '0,0'.freeze
  @font = "public/assets/fonts/unifont-11.0.01.ttf".freeze
  @font_size = 100
  @indention_count = 10
  @row_limit = 8
  @color = "white"
end

# 合成後のFileClassを生成
def build(print_text)
  text = prepare_text(print_text)
  @image = MiniMagick::Image.open(@base_image_path)
  configuration(text)
end

  # 合成後のFileの書き出し
def write(print_text)
  print("do write")
  build(print_text)
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

# 設定関連の値を代入
def configuration(text)
  # 固定ベース画像（水色フレーム）に文字を合成
  @image.combine_options do |config|
    config.fill @color
    config.font @font
    config.gravity @gravity
    config.pointsize @font_size
    config.draw "text #{@text_position} '#{text}'"
  end
end


# 背景にいい感じに収まるように文字を調整して返却
def prepare_text(print_text)
  print_text.scan(/.{1,#{@indention_count}}/)[0...@row_limit].join("\n")
end