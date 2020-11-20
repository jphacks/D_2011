# frozen_string_literal: true

# Router Base
#
# 汎用的なコードをまとめたものです
# 全てのRouterクラスで継承してください
class Base < Sinatra::Base
  helpers do
    def ok(data)
      status 200
      json({ ok: true, status: 'success', code: 200, data: data })
    end

    def notfound(error)
      status 404
      json({ ok: false, status: 'error', code: 404, error: error })
    end

    def internal_error(error)
      status 500
      json({ ok: false, status: 'error', code: 500, error: error })
    end
  end

  configure do
    set :views, File.join(root, '../views')
    set :show_exceptions, false
    register Sinatra::Namespace
  end

  configure :development do
    register Sinatra::Reloader
    use Rack::JSONBodyParser
  end

  error 500 do |e|
    puts e.to_s
    internal_error e.to_s
  end
end
