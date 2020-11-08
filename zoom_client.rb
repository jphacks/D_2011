# frozen_string_literal: true

require 'selenium-webdriver'
require 'json'
require 'logger'

# Zoomと接続して映像を表示するクラス
# TODO: 複数仮想カメラ対応
# メモ: 承認待機やカメラ有効化などのフローがイケてない
class ZoomClient
  private_class_method :new

  # パスワード付きURLの内容に基づいてZoomミーティングに接続します
  #
  # @param [String] meeting_url パスワード付きミーティングURL
  # @return [ZoomClient] インスタンス
  # @return [nil] ミーティングに参加する事が出来なかった場合はnil
  def self.connect_with_url(meeting_url)
    meeting_number = meeting_url.match(%r{^https://us02web\.zoom\.us/j/(\d+)}) # ミーティング情報を整理
    mn = meeting_number[1] unless meeting_number.nil?
    meeting_password = meeting_url.match(%r{^https://us02web\.zoom\.us/j/\d+\?pwd=(.+)$})
    mp = meeting_password[1] unless meeting_password.nil?
    return nil unless mn && mp

    zoom = __send__(:new, mn, mp) # ミーティングに接続
    unless zoom.connect # 失敗したらnilを返す
      zoom.close
      return nil
    end

    zoom
  end

  # ミーティング番号とパスワードに基づいてZoomミーティングに接続します
  # @param [String] meeting_number ミーティング番号
  # @param [String] meeting_password ミーティングパスワード
  # @return [ZoomClient] インスタンス
  # @return [nil] ミーティングに参加する事が出来なかった場合はnil
  def self.connect_with_number(meeting_number, meeting_password)
    return nil unless meeting_number.match(/^\d{9,12}$/) # ミーティング情報を整理

    zoom = __send__(:new, meeting_number, meeting_password) # ミーティングに接続
    unless zoom.connect # 失敗したらnilを返す
      zoom.close
      return nil
    end

    @wait.until { @driver.execute_script 'return canEnableVideo()' }

    zoom
  end

  def connect
    return false if @driver.nil?

    @log.info('[Zoom] Connecting...')
    @driver.execute_script "initialize('#{@mn}', '#{@mp}')"
    begin
      @wait.until { @driver.execute_script 'return getStatus() >= 2' }
      @log.info('[Zoom] Connected')
      true
    rescue StandardError => e
      @log.error('[Zoom] Failed connect')
      @log.error e
      false
    end
  end

  # Zoomの映像を有効化します
  def enable_video
    return if @driver.nil?

    sleep 1 until @driver.execute_script 'return canEnableVideo()'
    return if @driver.execute_script 'return isEnabledVideo()'

    @log.info('[Zoom] Enable video')
    click_video_btn
    sleep 5
  end

  # Zoomの映像を無効化します
  # def disable_video
  #   return if @driver.nil?

  #   return unless @driver.execute_script 'return isEnabledVideo()'

  #   @log.info('[Zoom] Disable video')
  #   click_video_btn
  # end

  # ブラウザを起動してZoom用のページを開きます
  def start_browser
    @log.info('[Firefox] Starting Firefox...')
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    options.add_preference('permissions.default.microphone', 1)
    options.add_preference('permissions.default.camera', 1)
    options.add_preference('media.navigator.permission.disabled', true)

    @driver = Selenium::WebDriver.for :firefox, options: options
    @driver.get "http://localhost:#{ENV['PORT']}/zoom/index.html"
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
    @log.info('[Firefox] Started Firefox')
  end

  # 指定されたファイルをZoomに表示します
  # @param [String] filename 表示する画像のパス
  def change_image(filename)
    return if @driver.nil?

    start_ffmpeg filename
  end

  # 共同ホスト権限を要求します
  def request_co_host
    return if @driver.nil?

    @log.info('[Zoom] Request Co-host...')
    change_image('public/assets/img/request_co_host.jpg')
    sleep 1 until @driver.execute_script 'return isCoHost()'
    @log.info('[Zoom] Done')
    change_image('public/assets/img/aika.jpg')
  end

  # ミーティングに参加している参加者の一覧を配列で取得します
  def attendees_list
    return if @driver.nil?

    @driver.execute_script 'updateAttendeesList()'
    (@driver.execute_script 'return getAttendeesList() || {}').to_json
  end

  # ミーティングに参加しているBotのユーザ情報を取得します
  def current_user
    return if @driver.nil?

    @driver.execute_script 'updateCurrentUser()'
    (@driver.execute_script 'return getCurrentUser()').to_json
  end

  # 指定されたファイルをFFmpegで映像デバイスに流し込みます
  # 現在のクライアント用にFFmpegが動いている場合は先に停止します
  # @param [String] filename 流し込む画像のパス
  def start_ffmpeg(filename)
    return if @driver.nil?

    stop_ffmpeg

    @log.info('[FFmpeg] Starting FFmpeg...')
    Process.spawn("nohup ffmpeg -loop 1 -re -i #{filename} -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0 > /dev/null 2>&1")
    @pid = `ps aux | grep #{filename} | awk '{ print $2 " " $11 }' | grep ffmpeg | awk '{ print $1 }'`.chomp
    @log.info('[FFmpeg] Started FFmpeg')
    @log.info("[FFmpeg] PID: #{@pid}, FileName: #{filename}")
  end

  # 現在のクライアント用に動いているFFmpegを停止します
  def stop_ffmpeg
    return if @driver.nil?
    return if @pid.nil?

    @log.info('[FFmpeg] Stopping FFmpeg...')

    begin
      Process.kill 9, @pid.to_i
      @log.info('[FFmpeg] Stopped FFmpeg')
    rescue StandardError
      @log.info('[FFmpeg] Already stopped!')
    end
    @pid = nil
  end

  # 映像の有効/無効ボタンをクリックします
  # @param [Integer] count クリックする回数
  def click_video_btn(count = 1)
    return if @driver.nil?

    count.times do
      @driver.find_element(:class, 'send-video-container__btn').click
      @log.info('[Firefox] Click video button')
    end
  end

  # 指定されたユーザーをミュートします
  # @param [String] user_id ミュートするユーザーID
  def mute(user_id)
    return if @driver.nil?

    @log.info("[Firefox] Mute microphone: #{user_id}")
    @driver.execute_script "mute(#{user_id}, true)"
  end

  # 指定されたユーザーにミュート解除を要請します
  # @param [String] user_id ミュート解除を要請するユーザーID
  def request_unmute(user_id)
    return if @driver.nil?

    @log.info("[Firefox] Request unmute microphone: #{user_id}")
    @driver.execute_script "mute(#{user_id}, false)"
  end

  # 全員をミュートします
  def mute_all
    return if @driver.nil?

    @log.info('[Firefox] Mute all')
    @driver.execute_script 'muteAll(true)'
  end

  # 全員にミュート解除を要請します
  def request_unmute_all
    return if @driver.nil?

    @log.info('[Firefox] Request unmute all')
    @driver.execute_script 'muteAll(false)'
  end

  # ミーティングを退出します
  def leave_meeting
    return if @driver.nil?

    @log.info('[Firefox] Leave meeting')
    @driver.execute_script 'leaveMeeting()'
  end

  # 終了処理をします
  def close
    return if @driver.nil?

    @log.info('[ZoomClient] Closing client...')

    # @watch_leave.kill
    stop_ffmpeg
    begin
      @driver.execute_script 'leaveMeeting()'
    rescue StandardError
      nil
    end
    begin
      @wait.until { @driver.current_url == 'http://example.com/' }
    rescue StandardError
      nil
    end
    begin
      @driver.close
    rescue StandardError
      nil
    end
    begin
      @driver.quit
    rescue StandardError
      nil
    end
    @driver = nil
    @log.info('[ZoomClient] Closed client')
  end

  private

  def initialize(meeting_number, meeting_password)
    @mn = meeting_number
    @mp = meeting_password
    @log = Logger.new(STDOUT)

    @log.debug("[Meeting Info] Number: #{@mn}")
    @log.debug("[Meeting Info] Password: #{@mp}")

    start_browser # 接続するための準備
    start_ffmpeg('public/assets/img/aika.jpg')

    # @watch_leave = Thread.new do # ミーティング終了フック
    #   @log.info('[ZoomClient] Detected leaving')
    #   sleep 5 while @driver.current_url != 'http://example.com/'
    #   close
    # end

    at_exit { close }
  end
end
