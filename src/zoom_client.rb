# frozen_string_literal: true

require 'selenium-webdriver'
require 'json'
require 'logger'
require 'open3'

# Zoomと接続して映像を表示するクラス
# TODO: 複数仮想カメラ対応
# TODO: 承認待機やカメラ有効化などのフローがイケてない
#       ↓→ 「現在の画像」を保持して状態に応じて上から承認待機とか出すのが良さそう
# TODO: 終了したZoomでokが出る
class ZoomClient
  @video_devices = {}

  # パスワード付きURLの内容に基づいてZoomミーティングに接続します
  #
  # @param [String] meeting_url パスワード付きミーティングURL
  # @return [ZoomClient] インスタンス
  # @return [nil] ミーティングに参加する事が出来なかった場合はnil
  def self.connect_with_url(meeting_url)
    meeting_number = meeting_url.match(%r{^https://us02web\.zoom\.us/j/(\d+)}) # ミーティング情報を整理
    mn = meeting_number[1] unless meeting_number.nil?
    return unless mn

    meeting_password = meeting_url.match(%r{^https://us02web\.zoom\.us/j/\d+\?pwd=(.+)$})
    mp = meeting_password[1] unless meeting_password.nil?

    zoom = create_client(mn, mp) # ミーティングに接続
    return zoom.close unless zoom.connect # 失敗したらnilを返す

    zoom
  end

  # ミーティング番号とパスワードに基づいてZoomミーティングに接続します
  # @param [String] meeting_number ミーティング番号
  # @param [String] meeting_password ミーティングパスワード
  # @return [ZoomClient] インスタンス
  # @return [nil] ミーティングに参加する事が出来なかった場合はnil
  def self.connect_with_number(meeting_number, meeting_password)
    return unless meeting_number.match(/^\d{9,12}$/) # ミーティング情報を整理

    zoom = create_client(meeting_number, meeting_password) # ミーティングに接続
    return zoom.close unless zoom.connect # 失敗したらnilを返す

    zoom
  end

  def self.create_client(meeting_number, meeting_password)
    video = Dir.glob('/dev/video*').find { |v| @video_devices[v].nil? }
    raise 'Failed to assign a video device' if video.nil?

    @video_devices[video] = true
    __send__(:new, meeting_number, meeting_password, video)
  end

  def connect
    return false if @driver.nil?

    @log.info('[Zoom] Connecting...')

    # devices = @driver.execute_script "return navigator.mediaDevices.enumerateDevices();"
    # device = devices.find { |d| d['label'] == @video.split('/')[2] }
    # return false if device.nil?

    @driver.execute_script "window.video = '#{@video.split('/')[2]}'"
    @driver.execute_script "initialize('#{@mn}', '#{@mp}')"
    # sleep 1 until @driver.execute_script 'return window.test != undefined' # タイムアウト設定

    @wait.until { @driver.execute_script 'return getStatus() >= 2' }
    @log.info('[Zoom] Connected')
    true
  rescue StandardError => e
    @log.error('[Zoom] Failed to connect')
    @log.error e
    false
  end

  # Zoomの映像を有効化します
  def enable_video
    return if @driver.nil?

    @log.info('[Zoom] Enable video(before)')
    sleep 1 until @driver.execute_script 'return canEnableVideo()'
    return if @driver.execute_script 'return isEnabledVideo()'

    @log.info('[Zoom] Enable video')
    click_video_btn

    loop do
      sleep 5
      pixels = @driver.execute_script 'return document.querySelector("#suspension-my-video").getContext("2d").getImageData(0, 0, 2, 2).data'

      @log.info("[Zoom] pixels sum: #{pixels.values.sum}")
      break unless pixels.values.sum.zero?

      @log.info('[Zoom] Video Refresh')
      click_video_btn 2
    end
    @log.info('[Zoom] Video is now enabled')
  end

  # ブラウザを起動してZoom用のページを開きます
  def start_browser
    @log.info('[Firefox] Starting Firefox...')
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    options.add_preference('permissions.default.microphone', 1)
    options.add_preference('permissions.default.camera', 100)
    options.add_preference('media.navigator.permission.disabled', true)

    @driver = Selenium::WebDriver.for :firefox, options: options
    @driver.get 'https://romantic-wing-4e2620.netlify.app/index.html'

    devices = @driver.execute_script 'return navigator.mediaDevices.enumerateDevices();'
    device = devices.find { |d| d['label'] == @video.split('/')[2] }

    @log.info('[Firefox] Reloading page...')
    @log.info('[Firefox] Device ID: ' + device['deviceId'])
    @driver.get "https://romantic-wing-4e2620.netlify.app/index.html?#{device['deviceId']}"
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
    @log.info('[Firefox] Started Firefox')
  end

  # 指定されたファイルをZoomに表示します
  # @param [String] image 流し込む画像のblob
  def show_image(image)
    return if @driver.nil?

    @log.info('[FFmpeg] Running FFmpeg...')
    Open3.capture2(
      "ffmpeg -i pipe:0 -f v4l2 -vcodec rawvideo -vf format=pix_fmts=yuv420p #{@video} > /dev/null 2>&1",
      stdin_data: image,
      binmode: true
    )
  end

  # 指定されたファイルをZoomに表示します
  # @param [String] filepath 流し込む画像のパス
  def show_image_by_path(filepath)
    return if @driver.nil?

    @log.info('[FFmpeg] Running FFmpeg...')
    Open3.capture2(
      "ffmpeg -i #{filepath} -f v4l2 -vcodec rawvideo -vf format=pix_fmts=yuv420p #{@video} > /dev/null 2>&1"
    )
  end

  # 共同ホスト権限を要求します
  def request_co_host
    return if @driver.nil?

    @log.info('[Zoom] Request Co-host...')
    show_image_by_path('public/assets/img/request_co_host.jpg')
    sleep 1 until @driver.execute_script 'return window.isCoHost'
    @log.info('[Zoom] Done')
    show_image_by_path('public/assets/img/aika.jpg')
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

  # スクリーンショットを撮影します
  def screen_shot(path)
    return if @driver.nil?

    @log.info('[Firefox] Screen shot')
    @driver.save_screenshot path
  end

  # 終了処理をします
  def close
    return if @driver.nil?

    @log.info('[ZoomClient] Closing client...')

    # @watch_leave.status

    @log.info('@watch_leave.kill rescue nil')
    # Thread.kill @watch_leave rescue nil

    @log.info("@driver.execute_script 'leaveMeeting()' rescue nil")
    @driver.execute_script 'leaveMeeting()' rescue nil

    @log.info("@wait.until { @driver.current_url == 'http://example.com/' } rescue nil")
    @wait.until { @driver.current_url == 'http://example.com/' } rescue nil

    @log.info('@driver.close rescue nil')
    @driver.close rescue nil
    @driver.quit rescue nil
    @driver = nil
    @log.info('[ZoomClient] Closed client')
  end

  private

  def initialize(meeting_number, meeting_password, video)
    @mn = meeting_number
    @mp = meeting_password
    @video = video
    @log = Logger.new(STDOUT)

    @log.debug("[Meeting Info] Number: #{@mn}")
    @log.debug("[Meeting Info] Password: #{@mp}")

    start_browser # 接続するための準備
    show_image_by_path('public/assets/img/aika.jpg')

    # @watch_leave = Thread.new do # ミーティング終了フック
    #   sleep 5 while @driver.current_url != 'http://example.com/'
    #   @log.info('[ZoomClient] Detected leaving')
    #   close
    # end

    at_exit { close }
  end

  private_class_method :new, :create_client
end
