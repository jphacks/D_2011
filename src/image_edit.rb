require 'mini_magick'
require 'securerandom'

before do
  @base_image_path = "public/assets/img/bg.jpg"
  @font = "public/assets/fonts/unifont-11.0.01.ttf".freeze
  @color = "white"
  @topic_indention_count = 10
  @topic_row_limit = 8
end

# ----------------------------
# 画像の書き出し
# ----------------------------
# アジェンダ用の画像生成(アプリへの送信用にJSONに変換)（タイトル , 内容）
def agendaWrite(title,time_text,content_text)
  # 画像の生成（タイトル）
  @image = MiniMagick::Image.open("public/assets/img/bg.jpg")
  configuration(title,'North',80,"0,50")
  # 画像の生成（時間）
  configuration(time_text,'NorthWest',60,"100,200")
  # 画像の生成（内容）
  configuration(content_text,'NorthWest',60,"300,200")
  return @image.to_blob
end

# Zoomの仮想カメラ用の画像生成(テキスト , イメージ名)
def topicWrite(print_text,image_name)
  # 画像の生成
  text = topic_prepare_text(print_text)
  @image = MiniMagick::Image.open("public/assets/img/bg.jpg")
  configuration(print_text,'center',100,'0,0')
  # 画像の書き出し
  image_name = image_name + ".png"
  @image.write image_name
  binary_data = File.read(image_name)
  FileUtils.mv(image_name,"public/assets/img/tmp/"+image_name)
  return "public/assets/img/tmp/"+image_name
end

def ogpWrite(title,time_text)
  @image = MiniMagick::Image.open("public/assets/img/bg.jpg")
  configuration(title,'center',100,'0,-20')
  configuration(time_text,'center',80,'0,10')
  return @image.to_blob
end

private

# ----------------------------
# 文字オーバーしない用に調整して文字列を返却
# ----------------------------
# Zoomの仮想カメラ用の画像生成
def topic_prepare_text(print_text)
  print_text.scan(/.{1,#{@topic_indention_count}}/)[0...@topic_row_limit].join("\n")
end

# ----------------------------
# 共通処理
# ----------------------------
# 設定関連を代入 & 文字列を合成(位置は任意のもの)
def configuration(text,gravity,pointsize,text_position)
  @image.combine_options do |config|
    config.fill @color
    config.font "public/assets/fonts/unifont-11.0.01.ttf"
    config.gravity gravity
    config.pointsize pointsize.to_i
    config.draw "text #{text_position} '#{text}'"
  end
end

# uniqなファイル名を返却
def uniq_file_name
  "#{SecureRandom.hex}.png"
end