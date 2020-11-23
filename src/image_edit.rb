# frozen_string_literal: true

require 'mini_magick'
require 'securerandom'

class ImageEdit
  @assets_path = 'public/assets'
  @img_path = "#{@assets_path}/img"
  @font = 'public/assets/fonts/unifont-11.0.01.ttf'
  @color = 'white'
  @topic_indention_count = 10
  @topic_row_limit = 8

  # ----------------------------
  # 画像の書き出し
  # ----------------------------

  # アジェンダ用の画像生成(アプリへの送信用にJSONに変換)（タイトル , 内容）
  def self.agenda_write(title, time_text, content_text)
    @image = MiniMagick::Image.open("#{@img_path}/bg.jpg")

    configuration(title, 'North', 80, '0,50') # 画像の生成（タイトル）
    configuration(time_text, 'NorthWest', 60, '100,200') # 画像の生成（時間）
    configuration(content_text, 'NorthWest', 60, '300,200') # 画像の生成（内容）

    @image.to_blob
  end

  # Zoomの仮想カメラ用の画像生成(テキスト , イメージ名)
  def self.topic_write(print_text)
    @image = MiniMagick::Image.open("#{@img_path}/bg.jpg")

    configuration(print_text, 'center', 100, '0,0')

    @image.to_blob
  end

  # OGP用の画像生成
  def self.ogp_write(title, time_text)
    @image = MiniMagick::Image.open("#{@img_path}/ogp_bg.png")

    configuration(title, 'center', 80, '0,-30')
    configuration(time_text, 'center', 40, '0,40')

    @image.to_blob
  end

  # ----------------------------
  # 文字オーバーしない用に調整して文字列を返却
  # ----------------------------
  # Zoomの仮想カメラ用の画像生成
  def self.topic_prepare_text(print_text)
    print_text.scan(/.{1,#{@topic_indention_count}}/)[0...@topic_row_limit].join("\n")
  end

  # ----------------------------
  # 共通処理
  # ----------------------------
  # 設定関連を代入 & 文字列を合成(位置は任意のもの)
  def self.configuration(text, gravity, pointsize, text_position)
    @image.combine_options do |config|
      config.fill @color
      config.font @font
      config.gravity gravity
      config.pointsize pointsize.to_i
      config.draw "text #{text_position} '#{text}'"
    end
  end

  # uniqなファイル名を返却
  def self.uniq_file_name
    "#{SecureRandom.hex}.png"
  end

  private_class_method :topic_prepare_text, :configuration, :uniq_file_name
end
