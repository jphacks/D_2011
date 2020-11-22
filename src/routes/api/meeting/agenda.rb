# frozen_string_literal: true

# Agenda Router
class AgendaRouter < Base
  # 議題変更
  post '/api/meeting/:id/agenda/next' do
    zoom = ZoomManager.instance.get(params[:id])
    not_found("No such meeting: #{params[:id]}") if zoom.nil?
    File.delete("public/assets/img/tmp/#{params[:id]}.png") rescue puts $!
    meeting = Meeting.find_by(meeting_id: params[:id])
    agendas = Agenda.where(meeting_id: meeting.id)

    next_agenda = agendas[meeting.agenda_now + 1]
    not_found('Not found next agenda.') if next_agenda.nil?

    zoom.changeImage(topic_write("#{next_agenda.title}\n(#{next_agenda.duration / 60}分)", params[:id]))
    ok
  end

  # アジェンダ一覧画像を返す
  get '/api/meeting/:id/agenda/list.png' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    agendas = Agenda.where(meeting_id: meeting.id)
    title = title.length >= 14 ? "#{title.delete("\n").slice(0, 14)}…" : meeting.title
    time_text = ''
    content_text = ''
    agendas.each_with_index do |value, i|
      time_text += (value.duration / 60).ceil.to_s + "分\n"
      content_text += adjust_content_text(value.title)
      break if i == 6
    end
    content_type 'image/png'
    agenda_write(title, time_text, content_text)
  end

  def adjust_content_text(text)
    if text.length >= 12
      "#{text.delete('\n').slice(0, 12)}…\n"
    else
      "#{text.delete('\n')}\n"
    end
  end
end
