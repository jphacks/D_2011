# frozen_string_literal: true

# Meeting Router
class MeetingRouter < Base
  # ミーティング作成
  post '/api/meeting' do
    meeting = Meeting.create(
      meeting_id: SecureRandom.hex,
      start_time: Time.at(params[:start_time].to_i),
      zoom_id: params[:zoom_id],
      zoom_pass: params[:zoom_pass],
      title: params[:title]
    )
    params[:agendas].each do |agenda|
      Agenda.create(meeting_id: meeting.id, title: agenda[:title], duration: agenda[:duration].to_i)
    end
    ok({ url: "https://aika.lit-kansai-mentors.com/agenda/#{meeting.meeting_id}", id: meeting.meeting_id })
  end

  # aikaの追加
  post '/api/meeting/:id/join' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    zoom = ZoomManager.instance.create_by_meeting_number(params[:id], meeting.zoom_id, meeting.zoom_pass)
    return internal_error 'zoom connection error' if zoom.nil?

    Thread.new do
      zoom.enable_video
      zoom.request_co_host
      zoom.change_image(topicWrite("しばらくお待ちください", id))
    end
    ok
  end

  # ミーティング開始
  post '/api/meeting/:id/start' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    # ここにタイマーの処理書いて欲しい
    # 下のコードがzoomの画像変更するコード
    # zoom.change_image(topicWrite("#{params[:title]}\n(#{params[:duration]}分)", id))
    ok
  end

  # ミーティング終了
  post '/api/meeting/:id/finish' do
    zoom = ZoomManager.instance.get(params[:id])
    not_found("No such meeting: #{params[:id]}") if zoom.nil?
    File.delete("public/assets/img/tmp/#{params[:id]}.png") rescue puts $!
    zoom.leaveMeeting rescue puts $!
    ok
  end

  # ミュート && アンミュート通知
  post '/api/meeting/:id/mute_all' do
    zoom = ZoomManager.instance.get(params[:id])
    not_found("No such meeting: #{params[:id]}") if zoom.nil?
    zoom.muteAll
    zoom.request_unmute_all
    ok
  end

  # OGP画像を返す
  get '/api/meeting/:id/ogp.png' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    print(meeting.meeting_id+'\n')
    title = meeting.title
    title = "#{title.delete("\n").slice(0, 14)}…" if title.length >= 14
    time_text = meeting.start_time
    time_text = Time.at(time_text).strftime("Start: %Y.%m.%d %H:%M")
    blob = ogpWrite(title,time_text)
    content_type "image/png"
    blob
  end
end
