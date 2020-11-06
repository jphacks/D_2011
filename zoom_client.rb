require 'selenium-webdriver'

# 提供するもの
# ログイン by mtgID
# カメラの接続
# ユーザー一覧取得
# mute切り替え
# 共同ホストチェック 
class ZoomClient
  def initialize

    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    options.add_preference("permissions.default.microphone", 1);
    options.add_preference("permissions.default.camera", 1);
    options.add_preference('media.navigator.permission.disabled', true)
    @driver = Selenium::WebDriver.for :firefox, options: options

    @driver.get 'http://localhost:' + ENV['PORT'] + '/zoom/index.html'
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)

    cmd = "ffmpeg -loop 1 -re -i test1.png -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0"
    pid = Process.spawn(cmd)
    puts "current process: #{pid}"

    puts 'waiting...'
    begin
      @driver.find_element(:class,'send-video-container__btn').click
    rescue
      retry
    end
    puts "done"
    sleep 10

    puts "Kill Process!"
    Process.kill 9, pid.to_i  
  end

  def changeImage(name)
    cmd = "ffmpeg -loop 1 -re -i " + name + " -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0"
    pid = Process.spawn(cmd)
    @driver.find_element(:class,'send-video-container__btn').click
    sleep 1
    
    @driver.find_element(:class,'send-video-container__btn').click
    sleep 10
    Process.kill 9, pid.to_i  
  end

  def close
    @driver.quit
  end
end
