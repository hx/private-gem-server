require 'open3'
require 'shellwords'

require_relative 'source/git'

module PrivateGemServer
  class Source

    SUBCLASSES = {
        git: Git
    }

    attr_reader :name

    def self.create(name, properties, sources)
      SUBCLASSES[properties['type'].to_sym].new name, properties, sources
    end

    def initialize(name, properties, sources)
      @name = name
      @properties = properties
      @sources = sources
    end

    def refresh!
      raise 'Not implemented'
    end

    protected

    def logger
      PrivateGemServer.logger
    end

    def run!(path, args: [], env: {}, cwd: nil, input: nil, output: nil, error: nil)
      cmd = ([path] + args.map { |arg| e arg }).join ' '
      opts = {}
      opts[:chdir] = cwd.to_s if cwd
      env = env.map { |k, v| [k.to_s, v.to_s] }.to_h
      msg = env.map { |k, v| "#{e k}=#{e v}" }
      msg << "cd #{e cwd};" if cwd
      msg << cmd
      logger.debug msg.join(' ')
      Open3.popen3 env, cmd, opts do |i, o, e, t|
        i << input if input; i.close
        {o => output, e => error}.each do |source, target|
          result = source.read
          target << result if target
          source.close
        end
        t.value.exitstatus
      end
    end

    def e(text)
      Shellwords.escape text
    end

  end
end
