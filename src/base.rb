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
      json({ ok: false, status: 'error', code: 404, error: error, stacktrace: Thread.current.backtrace })
    end

    def internal_error(error)
      status 500
      json({ ok: false, status: 'error', code: 500, error: error, stacktrace: Thread.current.backtrace })
    end
  end

  configure do
    set :views, File.join(root, '../views')
    set :show_exceptions, false
    register Sinatra::Namespace
  end

  configure :development do
    register Sinatra::Reloader
  end

  not_found do |e|
    return notfound e.to_s if request.path.start_with?('/api/')

    erb :notfound
  end

  error 500 do |e|
    internal_error e.to_s
  end
end
