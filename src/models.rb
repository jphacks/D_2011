# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")

# Meeting Table
class Meeting < ActiveRecord::Base
  has_many :agendas
end

# Agenda Table
class Agenda < ActiveRecord::Base
  belongs_to :meeting
end
