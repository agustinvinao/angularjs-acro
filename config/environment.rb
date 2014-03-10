require 'rubygems'
require 'bundler/setup'

$LOAD_PATH << File.expand_path('..', File.dirname(__FILE__))

Bundler.require :default, ENV['RACK_ENV']

ENV['RACK_ENV'] ||= 'development'

