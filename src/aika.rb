# frozen_string_literal: true

require './src/base'
require './src/routes/root'
require './src/image_edit'
require './src/zoom_client'
require './src/zoom_manager'
require './src/models'

# Aika
class Aika < Base
  use Rack::JSONBodyParser
  use RootRouter

  configure do
    set :server, :puma
    set :public_folder, 'public'
  end

  not_found do |e|
    return notfound e.to_s if request.path.start_with?('/api/')

    erb :notfound
  end

  error 500 do |e|
    internal_error e.to_s
  end
end
