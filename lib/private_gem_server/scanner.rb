module PrivateGemServer
  class Scanner

    def initialize(app, sources_path, temp_path)
      @app = app
      @sources = Sources.new YAML.load_file(sources_path), temp_path
    end

    def call(env)
      scan! if env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'] !~ %r{^/gems/}
      @app.call env
    end

    def scan!
      @sources.values.map do |source|
        Thread.new { source.refresh! }.tap { |thread| thread.abort_on_exception = true }
      end.each(&:join)
    end

  end
end
