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
      title: params[:title],
      email: params[:email]
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
    return internal_error 'Failed to connect to Zoom' if zoom.nil?

    Thread.new do
      zoom.enable_video
      zoom.request_co_host
      zoom.show_image ImageEdit.topic_write('しばらくお待ちください')
    end
    meeting.update(join: true)
    ok
  end

  # ミーティング開始
  post '/api/meeting/:id/start' do
    zoom = ZoomManager.instance.get(params[:id])
    return not_found("No such meeting: #{params[:id]}") if zoom.nil?

    # タイマーの処理

    zoom.show_image(ImageEdit.topic_write("#{params[:title]}\n(#{params[:duration]}分)"))
    ok
  end

  # ミーティング終了
  post '/api/meeting/:id/finish' do
    zoom = ZoomManager.instance.get(params[:id])
    return not_found("No such meeting: #{params[:id]}") if zoom.nil?

    File.delete("public/assets/img/tmp/#{params[:id]}.png") rescue puts $ERROR_INFO
    zoom.leave_meeting rescue puts $ERROR_INFO
    meeting = Meeting.find_by(meeting_id: params[:id])
    meeting.update(join: false)
    ok
  end

  # カメラ再読み込み
  post '/api/meeting/:id/reload' do
    zoom = ZoomManager.instance.get(params[:id])
    return not_found("No such meeting: #{params[:id]}") if zoom.nil?

    zoom.click_video_btn 2 rescue puts $ERROR_INFO
    ok
  end

  # スクリーンショット撮影
  post '/api/meeting/:id/screenshot/:name' do
    zoom = ZoomManager.instance.get(params[:id])
    return not_found("No such meeting: #{params[:id]}") if zoom.nil?

    zoom.screen_shot params[:name] rescue puts $ERROR_INFO
    ok
  end

  # ミュート & アンミュート通知
  post '/api/meeting/:id/mute_all' do
    zoom = ZoomManager.instance.get(params[:id])
    return not_found("No such meeting: #{params[:id]}") if zoom.nil?

    zoom.mute_all
    zoom.request_unmute_all
    ok
  end

  # OGP画像を返す
  get '/api/meeting/:id/ogp.png' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    return not_found("No such meeting: #{params[:id]}") if meeting.nil?

    title = meeting.title
    title = title.length >= 14 ? "#{title.delete("\n").slice(0, 14)}…" : title
    time_text = Time.at(meeting.start_time).strftime('Start: %Y.%m.%d %H:%M')
    content_type 'image/png'
    ImageEdit.ogp_write(title, time_text)
  end

  # emailでの検索
  post '/api/meeting/find' do
    meeting = Meeting.where(email: params[:email])
    ok(meeting)
  end

  # Macアプリで擬似的に参加する（時間延長などのために）
  post '/api/meeting/:id/join_status_bar' do
    meeting = Meeting.find_by(email: params[:email], meeting_id: params[:id])
    if meeting.nil?
      ok({ "isJoining": false })
    else
      ok({ "isJoining": true , "meeting": meeting })
    end
  end

  # テンプレート機能（タイトルを受け取って反応するものをJSONで返却）
  get '/api/meeting/template/:title' do
    respond_word_list = RespondWord.pluck(:word)
    suggestion_bool = respond_word_list.map{ | word | params[:title].include?(word) }
    suggestion = suggestion_bool.map.with_index{| tf , index |
      if tf == true
        agendas = RespondContent.where(respond_words_id: index)
        {"title": respond_word_list[index], "agendas": agendas}
      end
    }.compact.reject(&:empty?)
    ok({ "suggestion": suggestion })
  end
end