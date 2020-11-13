# frozen_string_literal: true

require './src/routes/api/meeting/meeting'
require './src/routes/api/meeting/agenda'

# Api Router
class ApiRouter < Base
  use MeetingRouter
  use AgendaRouter

  get '/api' do
    ok({ version: 1 })
  end
end
