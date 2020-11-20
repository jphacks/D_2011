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
    if next_agenda.nil?
      not_found("Not found next agenda.")
    end

    zoom.changeImage(topic_write("#{next_agenda.title}\n(#{(next_agenda.duration / 60).to_s}分)", params[:id]))
    ok('')
  end
end
