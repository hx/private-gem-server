require 'private-gem-server'
require 'rack/traffic_logger'
require 'rubygems'
require 'geminabox'
require 'yaml'

ENV['GEM_STORE'] ||= `pwd`.chomp

PrivateGemServer::Sanity.check!

Geminabox.data = File.expand_path ENV['GEM_STORE']
Geminabox.settings.data = Geminabox.data
Geminabox.rubygems_proxy = true

puts "Working from #{Geminabox.data}"
puts "Reading sources from #{ENV['GEM_SOURCES']}"

log_path = ENV['GEM_SERVER_LOG']
PrivateGemServer.logger = Logger.new(log_path) if log_path

use Rack::TrafficLogger, STDOUT, colors: true
use PrivateGemServer::Scanner, ENV['GEM_SOURCES'], "#{ENV['GEM_STORE']}/_working"
run PrivateGemServer::Server
