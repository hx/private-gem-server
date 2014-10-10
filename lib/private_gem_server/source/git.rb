require 'fileutils'
require 'shellwords'

module PrivateGemServer
  class Source
    class Git < self

      DEBOUNCE = 10 # Minimum number of seconds between refreshes

      def refresh!
        return if @last_refresh && (Time.now - @last_refresh) < DEBOUNCE
        prepare_git_files!
        check_out_or_fetch!
        find_new_versions!
        @last_refresh = Time.now
      end

      private

      def check_out_or_fetch!
        if repo_path.join('.git').exist?
          git 'git fetch', cwd: repo_path
        else
          repo_path.mkpath
          git "git clone #{e url} #{e repo_path}"
        end
      end

      def key
        @key ||= @sources.keys[@properties['key']]
      end

      def url
        @url ||= @properties['url']
      end

      def temp_path
        @temp_path ||= @sources.temp_path + 'git' + name
      end

      def repo_path
        @repo_path = temp_path + 'repo'
      end

      def git(cmd, **opts)
        (opts[:env] = (opts[:env] || {}).dup)['GIT_SSH'] = git_ssh_path
        opts[:output] ||= logger
        opts[:error] ||= logger
        run!(cmd, **opts) == 0
      end

      def ssh_template
        "#!/bin/bash\n" <<
        'ssh -oStrictHostKeyChecking=no -i %s "$@"'
      end

      def prepare_git_files!
        unless git_key_path.exist?
          git_key_path.parent.mkpath
          git_key_path.binwrite key
          git_key_path.chmod 0400
        end
        unless git_ssh_path.exist?
          git_ssh_path.parent.mkpath
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

      def find_new_versions!
        available_versions.each do |version|
          build_version! version unless PrivateGemServer.has name, version[/\d.*/]
        end
      end

      def available_versions
        list = ''
        run! 'git tag -l', cwd: repo_path, output: list, error: logger
        list.split("\n").select { |tag| tag =~ /^v?\d+(\.\d+)*$/ }
      end

      def build_version!(version)
        target_path = Pathname "#{repo_path}/#{name}-#{version[/\d.*/]}.gem"
        run! "git checkout tags/#{e version} && gem build #{e name}.gemspec", cwd: repo_path, output: logger, error: logger unless target_path.exist?
        PrivateGemServer.add target_path if target_path.exist?
      end

      def e(arg)
        Shellwords.escape arg
      end

    end
  end
end
