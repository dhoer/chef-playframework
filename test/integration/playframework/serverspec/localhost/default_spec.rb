require 'spec_helper'

describe 'dist zip' do
  describe file('/tmp/kitchen/cookbooks/playframework_test/files/default/sample-1.0.0.zip') do
    it { should be_file }
  end

  describe user('play') do
    it { should exist }
    it { should belong_to_group 'play' }
  end

  describe file('/usr/local/sample_service-1.0.0') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service') do
    it { should be_linked_to '/usr/local/sample_service-1.0.0' }
    it { should be_mode 777 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service/bin/sample') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
  end

  describe file('/usr/local/sample_service/conf/application.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/application\.secret="testingonetwothree"/) }
  end

  describe file('/var/run/play/sample_service.pid') do
    it { should be_file }
    it { should be_owned_by 'play' }
    it { should be_grouped_into 'play' }
  end

  describe file('/etc/init.d/sample_service') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{PLAY_DIST_HOME="/usr/local/sample_service"}) }
    its(:content) { should match(%r{PLAY="\$\{PLAY_DIST_HOME\}/bin/sample"}) }
    its(:content) { should match(/USER="play"/) }
    its(:content) { should match(%r{PID_PATH="/var/run/play"}) }
    its(:content) { should match(/PID_FILE="\$\{PID_PATH\}\/sample_service.pid"/) }
    its(:content) { should match(%r{CONFIG_FILE="/usr/local/sample_service/conf/application.conf"}) }
    its(:content) { should match(/APP_ARGS="-Dhttp\.port=8080 -J-Xms128M -J-Xmx512m -J-server"/) }
    its(:content) { should match(%r{su -s /bin/sh \$\{USER\} -c "\( \$\{PLAY\} -Dpidfile\.path=\$\{PID_FILE\}}) }
    its(:content) { should match(/-Dconfig\.file=\$\{CONFIG_FILE\} \$\{APP_ARGS\} &\ \)/) }
  end

  describe file('/etc/logrotate.d/sample_service') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{/usr/local/sample_service/logs/application.log"}) }
    its(:content) { should match(/weekly/) }
    its(:content) { should match(/missingok/) }
    its(:content) { should match(/compress/) }
    its(:content) { should match(/delaycompress/) }
    its(:content) { should match(/copytruncate/) }
    its(:content) { should match(/notifempty/) }
  end

  describe service('sample_service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe command('wget -O - localhost:8080') do
    its(:stdout) { should match(/<h1>Sample application is ready.<\/h1>/) }
  end

end
