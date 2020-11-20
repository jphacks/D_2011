# frozen_string_literal: true

RSpec.describe '/api' do
  it 'レスポンスがOKである' do
    get '/api'
    expect(last_response).to be_ok
  end
end

RSpec.describe '存在しないAPI' do
  it 'レスポンスが404である' do
    get '/api/404'
    body = JSON.parse(last_response.body)
    expect(body['ok']).to eq false
    expect(body['code']).to eq 404
    expect(last_response.status).to eq 404
  end
end
