# frozen_string_literal: true

# Router Base
#
# 汎用的なコードをまとめたものです
# 全てのRouterクラスで継承してください
class Base < Sinatra::Base
  helpers do
    def ok(data = nil)
      status 200
      json({ ok: true, status: 'success', code: 200, data: data })
    end

    def notfound(error = nil)
      status 404
      json({ ok: false, status: 'error', code: 404, error: error, stacktrace: Thread.current.backtrace })
    end

    def internal_error(error = nil)
      status 500
      json({ ok: false, status: 'error', code: 500, error: error, stacktrace: Thread.current.backtrace })
    end
  end

  configure do
    set :views, File.join(root, '../views')
    set :show_exceptions, false
  end

  configure :development do
    register Sinatra::Reloader
  end
end
