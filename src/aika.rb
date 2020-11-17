# frozen_string_literal: true

require './src/base'
require './src/routes/root'
require './src/image_edit'
require './src/zoom_client'
require './src/zoom_manager'
require './src/models'

# Aika
class Aika < Base
  use RootRouter

  configure do
    set :server, :puma
  end

  not_found do
    erb :notfound
  end
end
