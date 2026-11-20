require 'json'
require 'open3'
require 'rbconfig'

root = File.expand_path('..', __dir__)
script = <<~'RUBY'
  require ARGV.shift
  def find_steamapp_with_library_path(_name)
    ['/proton path', '/steam library']
  end
  def system(*)
    false
  end
  def exec(*args)
    puts JSON.generate(args)
  end
  load ARGV.shift
RUBY

%w[8 11].each do |version|
  invoke = lambda do |*args|
    Open3.capture3(RbConfig.ruby, '-e', script,
                   File.join(root, 'bin/.utils.rb'),
                   File.join(root, "tools/LSU_Proton_#{version}_chroot/run.rb"), *args)
  end

  %w[run waitforexitandrun].each do |verb|
    args = [verb, '/path with spaces/evaluator.exe', 'argument with spaces', '--flag']
    stdout, stderr, status = invoke.call(*args)
    raise "Proton #{version} #{verb} failed: #{stderr}" unless status.success?
    expected = [File.join(root, 'bin/lsu-run-in-chroot'),
                version == '8' ? 'SteamLinuxRuntime_sniper' : 'SteamLinuxRuntime_4',
                '/proton path/proton', *args]
    raise "Proton #{version} #{verb}: unexpected command #{stdout}" unless JSON.parse(stdout) == expected
  end

  stdout, stderr, status = invoke.call('invalid', 'argument')
  unless !status.success? && stdout.empty? && stderr.include?('Unknown command invalid')
    raise "Proton #{version}: unknown verb was not rejected"
  end
end

puts 'Proton chroot verb tests passed'
