# frozen_string_literal: true

RSpec.describe '/api' do
  describe 'GET /api' do
    before :all do
      get '/api'
      @body = JSON.parse(last_response.body)
    end

    example('レスポンスがOKである') { expect(last_response).to be_ok }
    example('bodyのokがtrueである') { expect(@body['ok']).to eq true }
    example('bodyのcodeが200である') { expect(@body['code']).to eq 200 }
  end

  describe 'GET /api/404' do
    before :all do
      get '/api/404'
      @body = JSON.parse(last_response.body)
    end

    example('ステータスコードが404である') { expect(last_response.status).to eq 404 }
    example('bodyのokがfalseである') { expect(@body['ok']).to eq false }
    example('bodyのcodeが404である') { expect(@body['code']).to eq 404 }
  end

  describe 'POST /api/meeting' do
    context '正しいリクエスト' do
      before :all do
        @meeting_count = Meeting.count
        @agenda_count = Agenda.count
        header 'Content-Type', 'application/json'
        post '/api/meeting', attributes_for(:meeting).to_json.to_s
      end

      example('レスポンスがOKである') { expect(last_response).to be_ok }
      example('Meetingレコードが1件増えた') { expect(Meeting.count - @meeting_count).to eq 1 }
      example('Agendaレコードが2件増えた') { expect(Agenda.count - @agenda_count).to eq 2 }
      example 'Meetingレコードが正常に生成された' do
        expect(Meeting.last.meeting_id).not_to eq ''
        expect(Meeting.last.title).to eq attributes_for(:meeting)[:title]
        expect(Meeting.last.zoom_id).to eq attributes_for(:meeting)[:zoom_id]
        expect(Meeting.last.zoom_pass).to eq attributes_for(:meeting)[:zoom_pass]
        expect(Meeting.last.start_time).to eq attributes_for(:meeting)[:start_time]
      end
      example 'Meetingレコードが正常に生成された' do
        attributes_for(:meeting)[:agendas].each_with_index do |agenda, i|
          expect(Meeting.last.agendas[i].title).to eq agenda[:title]
          expect(Meeting.last.agendas[i].duration).to eq agenda[:duration]
        end
      end
    end

    # context '不足したリクエスト' do
    #   before :all do
    #     @meeting_count = Meeting.count
    #     @agenda_count = Agenda.count
    #     header 'Content-Type', 'application/json'
    #     post '/api/meeting', attributes_for(:missing_zoom_id_meeting).to_json.to_s
    #   end

    #   example('レスポンスがOKでない') { expect(last_response).not_to be_ok }
    #   example('ステータスコードが400である') { expect(last_response.status).to eq 400 }
    #   example('Meetingレコードが増えていない') { expect(Meeting.count - @meeting_count).to eq 0 }
    #   example('Agendaレコードが増えていない') { expect(Agenda.count - @agenda_count).to eq 0 }
    # end

    # context '無効なリクエスト' do
    #   before :all do
    #     @meeting_count = Meeting.count
    #     @agenda_count = Agenda.count
    #     header 'Content-Type', 'application/json'
    #     post '/api/meeting', attributes_for(:invalid_meeting).to_json.to_s
    #   end

    #   example('レスポンスがOKでない') { expect(last_response).not_to be_ok }
    #   example('ステータスコードが400である') { expect(last_response.status).to eq 400 }
    #   example('Meetingレコードが増えていない') { expect(Meeting.count - @meeting_count).to eq 0 }
    #   example('Agendaレコードが増えていない') { expect(Agenda.count - @agenda_count).to eq 0 }
    # end
  end

  # describe 'GET /api/meeting/:id/agenda/next' do
  #   before :all do
  #     meeting = Meeting.first
  #     get "/api/meeting/#{meeting.meeting_id}/agenda/next"
  #     @body = JSON.parse(last_response.body)
  #   end

  #   example('レスポンスがOKである') { expect(last_response).to be_ok }
  #   example('bodyのokがtrueである') { expect(@body['ok']).to eq true }
  #   example('bodyのcodeが200である') { expect(@body['code']).to eq 200 }
  #   example('bodyのdataが正しい内容である') do
  #     expect(@body['data']['title']).to eq attributes_for(:meeting)[:agendas][1][:title]
  #     expect(@body['data']['duration']).to eq attributes_for(:meeting)[:agendas][1][:duration]
  #   end
  # end
end
