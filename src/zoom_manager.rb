# frozen_string_literal: true

require 'singleton'

# @clients = {
#   "id": {
#     zoom: '',
#     thread: nil,
#     methods: [],
#     time: 0
#   },
#   "id": {
#     zoom: '',
#     thread: nil,
#     methods: [],
#     time: 0
#   }
# }

# ZoomClientを管理するクラス
# TODO: 再接続を考慮
class ZoomManager
  include Singleton

  def initialize
    @clients = {}
  end

  def create_by_url(id, url)
    # idに合致するクライアントを返す
    # なかったら空いている映像デバイスを割り当てたZoomClientを返す
    return nil if id.nil? || id.empty?

    @clients[id] = {}
    @clients[id][:zoom] = ZoomClient.connect_with_url(url) if @clients[id].nil?
    @clients[id][:zoom]
  end

  def create_by_meeting_number(id, meeting_number, pwd)
    return nil if id.nil? || id.empty?

    @clients[id] = {}
    @clients[id][:zoom] = ZoomClient.connect_with_number(meeting_number, pwd) if @clients[id].nil?
    @clients[id][:zoom]
  end

  def get(id)
    return nil if id.nil? || id.empty?

    @clients[id][:zoom]
  end

  def destroy(id)
    return false if id.nil? || id.empty?
    return false if @clients[id][:zoom].nil?

    @clients[id][:zoom].close
    @clients[id][:zoom] = nil
    true
  end

  def reserve_meeting(id, time)
    @clients[id][:time] = time
    @clients[id][:thread] = Thread.new do
      while Time.now.to_i <= @clients[id][:time]
        sleep(1)
        p 'tick'
      end
      puts "ミーティング開始！"
      start_agenda(id)
    end
  end

  def start_agenda(id)
    @clients[id][:methods][:method].first.call
    @clients[id][:time] += @clients[id][:methods][:duration]
    @clients[id][:thread] = Thread.new do
      while Time.now.to_i <= @clients[id][:time]
        p 'agenda'
        sleep(1)
      end
      next_agenda(id)
    end
  end

  def enqueue_agenda(id, duration, &method)
    @clients[id][:methods] = [] if @clients[id][methods] == nil
    @clients[id][:methods] << {
      duration: duration,
      method: method
    }
  end

  def next_agenda(id)
    p @clients[id][:methods]
    @clients[id][:methods].pop(1)
    if @clients[id][:methods].empty?
      p 'meeting finished!'
      return
    end
    start_agenda(id)
  end

  def delay(id, duration)
    @clients[id][:time] += duration
    @clients[id][:thread].kill
    begin
      while Time.now.to_i <= @clients[id][:time]
        p '延長'
        sleep(1)
      end
      next_agenda(id)
    end
  end

  def terminate(id)
    p 'terminate'
    @clients[id][:thread].kill
    next_agenda(id)
  end
end