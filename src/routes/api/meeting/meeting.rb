# frozen_string_literal: true

# Meeting Router
class MeetingRouter < Base
  # ミーティング作成
  post '/api/meeting' do
    title = params[:title]
    start_time = params[:start_time]
    link = params[:link]
    agendas = params[:agendas]

    meeting = Meeting.create(meeting_id: SecureRandom.hex, start_time: Time.at(start_time.to_i), link: link, title: title)
    agendas.each do |agenda|
      Agenda.create(meeting_id: meeting.id, title: agenda[:title], duration: agenda[:duration].to_i)
    end
    ok({url: "https://aika.lit-kansai-mentors.com/agenda/#{meeting.meeting_id}",id: meeting.meeting_id })
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

  # アジェンダ画像を返す
  get '/api/meeting/img/:meeting_id' do
    meeting = Meeting.find_by(meeting_id: params[:meeting_id])
    title = meeting.title
    title = "#{title.delete("\n").slice(0, 14)}…" if title.length >= 14
    agendas = Agenda.where(meeting_id: meeting.id)
    time_text = ""
    content_text = ""
    p agendas
    agendas.each_with_index do |value,i|
      p value.duration
      time_text += ((value.duration / 60).ceil).to_s + "分\n"
      content_text += if value.title.length >= 12
                        "#{value.title.delete("\n").slice(0, 12)}…\n"
                      else
                        value.title.delete("\n")+"\n"
                      end
      break if i == 6
    end
    blob = agendaWrite(title,time_text,content_text)
    content_type "image/png"
    blob
  end
end
