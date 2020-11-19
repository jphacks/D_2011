# frozen_string_literal: true

# Agenda Router
class AgendaRouter < Base
  # 議題変更
  post '/api/meeting/:id/agenda/next' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    zoom = ZoomManager.instance.get(params[:id])
    ZoomManager.instance.terminate(meeting.id)
    not_found("No such meeting: #{params[:id]}") if zoom.nil?
    File.delete("public/assets/img/tmp/#{params[:id]}.png") rescue puts $!
    zoom.changeImage(topicWrite("#{params[:title]}\n(#{params[:duration]}分)", id))
  end

  post '/api/meeting/:id/agenda/delay' do 
    meeting = Meeting.find_by(meeting_id: params[:id])
    ZoomManager.instance.delay(meeting.id, params[:duration])
  end
end
