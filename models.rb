require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")

class Meeting < ActiveRecord::Base
  has_many :agendas
end

class Agenda < ActiveRecord::Base
  belongs_to :meeting
end