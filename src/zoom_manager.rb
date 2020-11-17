# frozen_string_literal: true

require 'singleton'

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

    @clients[id] = ZoomClient.connect_with_url(url) if clients[id].nil?
    @clients[id]
  end

  def create_by_meeting_number(id, meeting_number, pwd)
    return nil if id.nil? || id.empty?

    @clients[id] = ZoomClient.connect_with_number(meeting_number, pwd) if @clients[id].nil?
    @clients[id]
  end

  def get(id)
    return nil if id.nil? || id.empty?

    @clients[id]
  end

  def destroy(id)
    return false if id.nil? || id.empty?
    return false if @clients[id].nil?

    @clients[id].close
    @clients[id] = nil
    true
  end
end
