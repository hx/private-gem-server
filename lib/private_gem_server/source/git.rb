require 'fileutils'
require 'shellwords'

module PrivateGemServer
  class Source
    class Git < self

      def refresh!
        prepare_git_files!
        check_out_or_fetch!
      end

      private

      def check_out_or_fetch!
        if temp_path.exist?
          git "cd #{e temp_path} && git fetch"
        else
          temp_path.mkpath
          git "git clone #{e url} #{e temp_path}" or FileUtils.rmtree(temp_path.to_s)
        end
      end

      def key
        @key ||= @sources.keys[@properties['key']]
      end

      def url
        @url ||= @properties['url']
      end

      def temp_path
        @temp_path ||= @sources.temp_path + 'git'
      end

      def git(cmd, **opts)
        (opts[:env] = (opts[:env] || {}).dup)['GIT_SSH'] = git_ssh_path
        run! cmd, **opts
      end

      def ssh_template
        "#!/bin/bash\n" <<
        'ssh -oStrictHostKeyChecking=no -i %s "$@"'
      end

      def prepare_git_files!
        unless git_key_path.exist?
          git_key_path.binwrite key
          git_key_path.chmod 0400
        end
        unless git_ssh_path.exist?
          git_ssh_path.write ssh_template % e(git_key_path)
          git_ssh_path.chmod 0700
        end
      end

      def git_key_path
        @git_key_path ||= temp_path + 'git.key'
      end

      def git_ssh_path
        @git_ssh_path ||= temp_path + 'git_ssh'
      end

      # noinspection RubyInstanceMethodNamingConvention
      def e(arg)
        Shellwords.escape arg
      end

    end
  end
end
