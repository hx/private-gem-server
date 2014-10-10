require 'logger'

require_relative 'private_gem_server/version'
require_relative 'private_gem_server/server'
require_relative 'private_gem_server/scanner'
require_relative 'private_gem_server/sources'
require_relative 'private_gem_server/sanity'

module PrivateGemServer

  class << self

    attr_writer :logger

    def has(name, version)
      gem = gems[name]
      gem.include? version if gem
    end

    def add(file)
      @gems = nil
      Geminabox::GemStore.create Geminabox::IncomingGem.new File.open(file, 'rb')
    end

    def gems
      @gems ||= Dir["#{Geminabox.data}/gems/*.gem"].group_by { |x| x[%r{(\w+(-\D\w*)*)[^/]+$}, 1] }.map { |k, v| [k, v.map { |z| z[/(\d+[\.\d+]*)\.gem$/, 1] }] }.to_h
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
