require 'selenium-webdriver'
require 'json'

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

    @pid = startFfmpeg('public/assets/img/aika.jpg')

    wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    wait.until{@driver.execute_script 'return getStatus()'}
    begin
      clickVideoBtn()
    rescue
      retry
    end
    
    Thread.new do
      while @driver.current_url != "http://example.com/"
        sleep 5
      end
      @driver.close
      if @pid != 0
        Process.kill 9, @pid.to_i
        @pid = 0
      end
      puts "finished"
    end
  end

  def changeImage(name)
    if @pid != 0
      puts "kill: " + @pid
      Process.kill 9, @pid.to_i
      @pid = 0
    end
    @pid = startFfmpeg(name)
    puts "start: " + @pid

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
