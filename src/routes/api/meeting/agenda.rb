# frozen_string_literal: true

# Agenda Router
class AgendaRouter < Base
  # 議題変更
  post '/api/meeting/:id/agenda/next' do
    zoom = ZoomManager.instance.get(params[:id])
    not_found("No such meeting: #{params[:id]}") if zoom.nil?

    meeting = Meeting.find_by(meeting_id: params[:id])
    next_agenda_id = meeting.agenda_now + 1
    next_agenda = meeting.agendas[next_agenda_id]
    not_found('Not found next agenda.') if next_agenda.nil?
    meeting.update(agenda_now: next_agenda_id)

    zoom.changeImage(ImageEdit.topic_write("#{next_agenda.title}\n(#{next_agenda.duration / 60}分)", params[:id]))
    ok
  end

  # 次の議題を返す
  get '/api/meeting/:id/agenda/next' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    next_agenda = meeting.agendas[meeting.agenda_now + 1]
    not_found('Not found next agenda.') if next_agenda.nil?

    ok({ title: next_agenda.title, duration: next_agenda.duration })
  end

  # 今の議題を返す（ポーリング用）
  get '/api/meeting/:id/agenda/now' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    agenda = meeting.agendas[meeting.agenda_now]
    not_found('Not found agenda.') if agenda.nil?
    # タイマーの経過時間を追加する
    ok({ title: next_agenda.title, duration: next_agenda.duration })
  end

  # アジェンダ一覧画像を返す
  get '/api/meeting/:id/agenda/list.png' do
    meeting = Meeting.find_by(meeting_id: params[:id])
    title = meeting.title
    meeting_title = title.length >= 14 ? "#{title.delete("\n").slice(0, 14)}…" : title

    time_text = ''
    content_text = ''
    meeting.agendas.each_with_index do |value, i|
      time_text += (value.duration / 60).ceil.to_s + "分\n"
      content_text += adjust_content_text(value.title) + "\n"
      break if i == 6
    end
    content_type 'image/png'
    agenda_write(meeting_title, time_text, content_text)
  end

  def adjust_content_text(text)
    text.length >= 12 ? "#{text.delete("\n").slice(0, 12)}…" : text.delete("\n")
  end
end
