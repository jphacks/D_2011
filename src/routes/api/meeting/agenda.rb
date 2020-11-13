# frozen_string_literal: true

# Agenda Router
class AgendaRouter < Base
  # 議題変更
  post '/api/meeting/agenda/next' do
    id = params[:id]
    duration = params[:duration]
    title = params[:title]
    File.delete("public/assets/img/tmp/#{id}.png") rescue puts $!
    zoom.changeImage(topicWrite("#{title}\n(#{duration}分)", id))
  end
end
