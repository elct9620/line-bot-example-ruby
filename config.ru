# Setup Ruby Gems
require 'rubygems'
require 'bundler/setup'

ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

# Load Application
require './app'
run Application.new
