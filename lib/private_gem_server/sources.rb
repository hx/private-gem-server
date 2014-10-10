require_relative 'source'
require 'pathname'

module PrivateGemServer
  class Sources < Hash

    attr_reader :keys
    attr_reader :temp_path

    def initialize(config, temp_path)
      @keys = config['keys'] || {}
      @temp_path = Pathname(temp_path).tap(&:mkpath).realpath
      merge! (config['gems'] || {}).map { |k, v| [k, Source.create(k, v, self)] }.to_h
    end

  end
end
