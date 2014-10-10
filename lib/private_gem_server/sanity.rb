require 'pathname'

module PrivateGemServer
  module Sanity
    def self.check!

      # Make sure we have a valid config file
      begin
        config = YAML.load_file ENV['GEM_SOURCES']
      rescue
        fail! 'Please supply a path to your gem sources YAML file in the GEM_SOURCES environment variable.'
      end

      # Make sure config has a hash of gems
      fail! 'Config file includes no gems' unless Hash === config && Hash === config['gems'] && !config['gems'].empty?

      # Make sure we can write to our working dir
      store = ENV['GEM_STORE']
      fail! 'Please set GEM_STORE to a readable/writable directory' unless store &&
          File.directory?(store) &&
          File.readable?(store) &&
          File.writable?(store) &&
          File.executable?(store)

      # Make sure the log is writable
      log_path = ENV['GEM_SERVER_LOG']
      if log_path
        log_path = Pathname(log_path)
        if log_path.exist?
          fail! "Server log (#{log_path}) is not writable" unless log_path.writable?
        else
          log_path.parent.mkpath rescue fail! "Cannot create server log directory (#{log_path.parent})"
          log_path.write '' rescue fail! "Cannot create server log (#{log_path})"
        end
      end

    end

    private

    def self.fail!(reason)
      STDERR << reason << "\n"
      exit 1
    end
  end
end
