require 'selenium-webdriver'
require 'json'

class ZoomClient

  # Zoomセッションを張ります
  # @param [String] meetingInfo ミーティング番号かパスワード付きミーティングURL
  # @param [meetingPwd] meetingPwd ミーティングパスワード
  # @return [ZoomClient] インスタンス
  # @return [nil] ミーティングに参加する事が出来なかった場合はnil
  def initialize(meetingInfo, meetingPwd*)
    @mp = meetingPwd
    @mn = meetingInfo if meetingInfo.match(/^\d{9,}$/)
    @mn = d[1] if d = meetingInfo.match(/^https:\/\/us02web\.zoom\.us\/j\/(\d+)/)
    @mp = d[1] if d = meetingInfo.match(/^https:\/\/us02web\.zoom\.us\/j\/\d+\?pwd=(.+)$/)

    return unless @mn && @mp

    options = Selenium::WebDriver::Firefox::Options.new(args: ['--headless'], prefs: ["permissions.default.microphone": 1, "permissions.default.camera": 1, "media.navigator.permission.disabled": true])

    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    @driver = Selenium::WebDriver.for :firefox, options: options
    @driver.get "http://localhost:#{ENV['PORT']}/zoom/index.html"
    @driver.execute_script "initialize('#{@mn}', '#{@mp}')"

    startFFmpeg('public/assets/img/aika.jpg')

    begin 
      @wait.until { @driver.execute_script 'return getStatus()' > 2 }
    rescue
      return nil # ミーティングへの接続に失敗
    end

    @wait.until { @driver.execute_script 'return canEnableVideo()' }
    clickVideoBtn()

    Thread.new do

    end

    at_exit{
      killFFmpeg()
      # stopBrowser()
    }

    # wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    # wait.until{@driver.execute_script 'return getStatus()' > 2}
    # begin
    #   clickVideoBtn()
    # rescue
    #   retry
    # end
    
    watchLeave()
  end

  # 終了検知
  def watchLeave
    Thread.new do
      while @driver.current_url != "http://example.com/"
        sleep 5
      end
      @driver.close
      if @pid != nil
        Process.kill 9, @pid.to_i
        @pid = nil
      end
      puts "finished"
    end
  end

  def changeImage(name)
    startFFmpeg(name)

    clickVideoBtn()
    clickVideoBtn()
  end

  def requestCoHost
    changeImage('public/assets/img/request_co_host.jpg')
    until @driver.execute_script 'return isCoHost()' do
      sleep 1
    end
    changeImage('public/assets/img/aika.jpg')
  end

  def getAttendeesList
    @driver.execute_script 'updateAttendeesList()'
    return (@driver.execute_script 'return getAttendeesList() || {}').to_json
  end

  def getCurrentUser
    @driver.execute_script 'updateCurrentUser()'
    return (@driver.execute_script 'return getCurrentUser()').to_json
  end

  def startFFmpeg(filename)
    killFFmpeg()
    Process.spawn("nohup ffmpeg -loop 1 -re -i #{filename} -f v4l2 -vcodec rawvideo -pix_fmt yuv420p /dev/video0 > /dev/null 2>&1")
    @pid = `ps aux | grep #{filename} | awk '{ print $2 " " $11 }' | grep ffmpeg | awk '{ print $1 }'`
  end

  def killFFmpeg
    if @pid != nil
      begin 
        Process.kill 9, @pid.to_i
      rescue
      end
      @pid = nil
    end
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

  def muteAll()
    @driver.execute_script "muteAll(true)"
  end

  def unmuteRequestAll()
    @driver.execute_script "muteAll(false)"
  end

  def leaveMeeting()
    @driver.execute_script "leaveMeeting()"
  end

  def close
    @driver.quit
  end
end
