require 'open3'
require 'shellwords'

require_relative 'source/git'

module PrivateGemServer
  class Source

    SUBCLASSES = {
        git: Git
    }

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

    def submit!(path)

    end

    def run!(path, args: [], env: {}, cwd: nil, input: nil, output: nil, error: nil)
      cmd = ([path] + args.map { |arg| Shellwords.escape arg }).join ' '
      opts = {}
      opts[:chdir] = cwd.to_s if cwd
      Open3.popen3 env, cmd, opts do |i, o, e, t|
        i << input if input; i.close
        {o => output, e => error}.each do |source, target|
          result = source.read
          target << result if target
          source.close
        end
        result = t.value.exitstatus
      end
      result
    end

  end
end
