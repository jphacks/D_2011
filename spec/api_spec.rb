# frozen_string_literal: true

RSpec.describe 'GET /api' do
  before do
    get '/api'
  end
  it 'レスポンスがOKである' do
    expect(last_response).to be_ok
  end
  it 'bodyのokがtrueである' do
    body = JSON.parse(last_response.body)
    expect(body['ok']).to eq true
  end
  it 'bodyのcodeが200である' do
    body = JSON.parse(last_response.body)
    expect(body['code']).to eq 200
  end
end

RSpec.describe 'GET /api/404' do
  before do
    get '/api/404'
  end
  it 'ステータスコードが404である' do
    expect(last_response.status).to eq 404
  end
  it 'bodyのokがfalseである' do
    body = JSON.parse(last_response.body)
    expect(body['ok']).to eq false
  end
  it 'bodyのcodeが404である' do
    body = JSON.parse(last_response.body)
    expect(body['code']).to eq 404
  end
end

RSpec.describe 'POST /api/meeting' do
  context '正しいリクエスト' do
    before :all do
      @count = Meeting.count
      header 'Content-Type', 'application/json'
      post '/api/meeting', attributes_for(:meeting).to_json.to_s
    end

    example 'レスポンスがOKである' do
      expect(last_response).to be_ok
    end

    example 'DBのレコードが1件増えた' do
      expect(Meeting.count - @count).to eq 1
    end

    example '正しく生成に成功した' do
      expect(Meeting.last.meeting_id).not_to eq ''
      expect(Meeting.last.title).to eq attributes_for(:meeting)[:title]
      expect(Meeting.last.zoom_id).to eq attributes_for(:meeting)[:zoom_id]
      expect(Meeting.last.zoom_pass).to eq attributes_for(:meeting)[:zoom_pass]
      expect(Meeting.last.start_time).to eq attributes_for(:meeting)[:start_time]
    end
  end
  context '不足したリクエスト' do
    before :all do
      @count = Meeting.count
      header 'Content-Type', 'application/json'
      post '/api/meeting', attributes_for(:missing_zoom_id_meeting).to_json.to_s
    end

    example 'レスポンスがOKでない' do
      expect(last_response).not_to be_ok
    end

    example 'ステータスコードが400である' do
      expect(last_response.status).to eq 400
    end

    example 'DBのレコードが増えていない' do
      expect(Meeting.count - @count).to eq 0
    end
  end
  context '無効なリクエスト' do
    before :all do
      @count = Meeting.count
      header 'Content-Type', 'application/json'
      post '/api/meeting', attributes_for(:invalid_meeting).to_json.to_s
    end

    example 'レスポンスがOKでない' do
      expect(last_response).not_to be_ok
    end

    example 'ステータスコードが400である' do
      expect(last_response.status).to eq 400
    end

    example 'DBのレコードが増えていない' do
      expect(Meeting.count - @count).to eq 0
    end
  end
end
