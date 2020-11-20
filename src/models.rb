# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection((ENV['ENV'] || 'development').intern)

# Meeting Table
class Meeting < ActiveRecord::Base
  has_many :agendas
end

# Agenda Table
class Agenda < ActiveRecord::Base
  belongs_to :meeting
end
