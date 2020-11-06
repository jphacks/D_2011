require 'selenium-webdriver'
require 'open3'
require 'json'

# 提供するもの
# ログイン by mtgID DONE
# カメラの接続 DONE
# カメラの切り替え DONE
# ユーザー一覧取得 DONE
# mute切り替え DONE
# 共同ホストチェック 
# initializeとか非同期的に
class ZoomClient
  def initialize(meetingId, meetingPwd)

    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    options.add_preference("permissions.default.microphone", 1);
    options.add_preference("permissions.default.camera", 1);
    options.add_preference('media.navigator.permission.disabled', true)

    @driver = Selenium::WebDriver.for :firefox, options: options
    @driver.get "http://localhost:#{ENV['PORT']}/zoom/index.html"
    @driver.execute_script "initialize('#{meetingId}', '#{meetingPwd}')"

    @pid = startFfmpeg('public/assets/img/aika_bg.jpg')
    begin
      clickVideoBtn()
    rescue
      retry
    end
  end

  def changeImage(name)
    if @pid != 0
      Process.kill 9, @pid.to_i
      @pid = 0
    end
    @pid = startFfmpeg(name)

    clickVideoBtn()
    sleep 1
    clickVideoBtn()
  end

  def requestCoHost
    changeImage('public/assets/img/request_co_host.jpg')
    puts getCurrentUser()
  end

  def getAttendeesList
    @driver.execute_script 'updateAttendeesList()'
    return (@driver.execute_script 'return getAttendeesList() || {}').to_json
  end

  def getCurrentUser
    @driver.execute_script 'updateCurrentUser()'
    return (@driver.execute_script 'return getCurrentUser()').to_json
  end

  def startFfmpeg(filename)
    cmd = "nohup ffmpeg -loop 1 -re -i #{filename} -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0 > /dev/null 2>&1"
    Process.spawn(cmd)
    return `ps aux | grep #{filename} | awk '{ print $2 " " $11 }' | grep ffmpeg | awk '{ print $1 }'`
  end

  def clickVideoBtn
    @driver.find_element(:class,'send-video-container__btn').click
  end

  def mute(userId)
    @driver.execute_script "mute(#{userId}, true)"
  end

  def unmuteRequest(userId)
    @driver.execute_script "mute(#{userId}, false)"
  end

  def close
    @driver.quit
  end
end
