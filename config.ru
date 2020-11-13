# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default, (ENV['ENV'] || 'development').to_sym

require './src/aika'
run Aika
