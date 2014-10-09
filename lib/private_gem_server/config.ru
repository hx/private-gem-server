require 'private-gem-server'
require 'rack/traffic_logger'
require 'rubygems'
require 'geminabox'
require 'yaml'

ENV['GEM_STORE'] ||= `pwd`.chomp

begin
  YAML.load_file ENV['GEM_SOURCES']
rescue
  STDERR << "Please supply a path to your gem sources YAML file in the GEM_SOURCES environment variable.\n"
  exit 1
end

Geminabox.data = File.expand_path ENV['GEM_STORE']
Geminabox.settings.data = Geminabox.data
Geminabox.rubygems_proxy = true

puts "Serving gems from #{Geminabox.data}"

use Rack::TrafficLogger, STDOUT, colors: true
use PrivateGemServer::Scanner, ENV['GEM_SOURCES'], "#{ENV['GEM_STORE']}/_working"
run PrivateGemServer::Server
