# frozen_string_literal: true

# Meeting Router
class MeetingRouter < Base
  # ミーティング作成
  post '/api/meeting' do
    title = params[:title]
    start = params[:start]
    link = params[:link]
    agendas = params[:agenda]

    meeting = Meeting.create(meeting_id: SecureRandom.hex, start: Time.at(start), link: link, title: title)
    agendas.each do |agenda|
      Agenda.create(meeting_id: meeting.id, title: title, duration: agenda[:duration])
    end

    ok({ agenda: agendaphoto(title, start.to_i, JSON.parse(agenda.to_json)), url: "https://aika.lit-kansai-mentors.com/agenda/#{meeting.meeting_id}", id: meeting.meeting_id })
  end

  # ミーティング開始
  post '/api/meeting/start' do
    zoom = ZoomClient.connect_with_number(params[:meetingid], params[:meetingpass])
    return internal_error 'zoom connection error' unless zoom

    Thread.new do
      zoom.enable_video
      zoom.request_co_host
      zoom.change_image(topicWrite("#{params[:title]}\n(#{params[:duration]}分)", id))
    end
    ok
  end

  # ミーティング終了
  post '/api/meeting/finish' do
    File.delete("public/assets/img/tmp/#{id}.png") rescue puts $!
    zoom.leaveMeeting rescue puts $!
    ok
  end

  # ミュート && アンミュート通知
  post '/api/meeting/mute_all' do
    zoom.muteAll
    zoom.reqyest_unmute_all
    ok
  end

  # アジェンダ画像生成（タイトル(String),開始時間(UNIX時間),アジェンダのリスト(連想配列)）
  def agendaphoto(title, startTime, agendas)
    @startTime = startTime
    agendaList = agendas.each_slice(7).to_a
    # p agendaList
    returnText = []
    agendaList.each_with_index do |a, i|
      text = { photo: agendaSheetPhoto(title, a, i + 1, agendaList.length) }
      returnText = returnText.push(text)
    end
    returnText.to_json
  end

  # アジェンダ画像生成（タイトル(String),アジェンダのリスト(連想配列),何個目の画像か(Int),全体の数(int)）
  def agendaSheetPhoto(title, agendas, num, length)
    title = "#{title.delete("\n").slice(0, 14)}…" if title.length >= 14
    title += "(#{num}/#{length})"
    text = ''
    agendas.each do |a|
      start = Time.at(@startTime).strftime('%H:%M') # このアジェンダシートの開始時刻
      duration = (a['duration'] / 60).ceil
      titleA = if a['title'].length >= 12
                "#{a['title'].delete("\n").slice(0, 12)}…"
              else
                a['title'].delete("\n")
              end
      text += "#{start} #{duration}分 #{titleA}\n"
      @startTime += a['duration']
    end
    agendaWrite(title, text)
  end
end
