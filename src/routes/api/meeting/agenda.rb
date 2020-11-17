# frozen_string_literal: true

# Agenda Router
class AgendaRouter < Base
  # 議題変更
  post '/api/meeting/:id/agenda/next' do
    zoom = ZoomManager.instance.get(params[:id])
    not_found("No such meeting: #{params[:id]}") if zoom.nil?
    File.delete("public/assets/img/tmp/#{params[:id]}.png") rescue puts $!
    zoom.changeImage(topicWrite("#{params[:title]}\n(#{params[:duration]}分)", id))
  end
end
