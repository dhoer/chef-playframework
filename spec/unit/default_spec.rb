require 'spec_helper'

describe 'playframework_test::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos', version: '6.5', step_into: ['playframework']
    ).converge(described_recipe)
  end
  let(:play_service_template) { chef_run.template('/etc/init.d/sample_service') }
  let(:service) { chef_run.service('sample_service') }

  it 'includes java recipe' do
    expect(chef_run).to include_recipe('java::default')
  end

  it 'includes logrotate recipe' do
    expect(chef_run).to include_recipe('logrotate::default')
  end

  it 'install unzip package' do
    expect(chef_run).to install_package('unzip')
  end

  it 'install rsync package' do
    expect(chef_run).to install_package('rsync')
  end

  it 'creates play system user' do
    expect(chef_run).to create_user('play')
  end

  # it 'unzips local file standalone distribution archive' do
  #   expect(chef_run).to install_ark('sample_service')
  # end

  it 'runs playframework install action' do
    expect(chef_run).to install_playframework('sample_service').with(
      source: 'file:///tmp/kitchen/cookbooks/playframework_test/files/default/sample-1.0.0.zip',
      app_conf: { application_secret: 'testingonetwothree' }
    )
  end

  describe 'service' do
    it 'creates pid directory' do
      expect(chef_run).to create_directory('/var/run/play').with(
        user: 'play',
        group: 'play'
      )
    end

    it 'does not install sample_service as a service' do
      expect(chef_run).to_not enable_service('sample_service')
      expect(chef_run).to_not restart_service('sample_service')
      expect(chef_run).to_not stop_service('sample_service')
      expect(chef_run).to_not start_service('sample_service')
    end

    it 'does not register sample_service to start on reboot' do
      expect(chef_run).to_not run_execute('chkconfig sample_service')
    end

    it 'make bin/sample_service file executable' do
      expect(chef_run).to run_execute('chmod +x sample')
    end

    it 'creates init.d script' do
      expect(chef_run).to create_template('/etc/init.d/sample_service').with(
                              user: 'root',
                              group: 'root',
                              backup: 5
                          )
    end

    it 'sends notifications if init.d script created' do
      expect(play_service_template).to notify('service[sample_service]').to(:enable)
      expect(play_service_template).to notify('service[sample_service]').to(:start)
    end

    it 'creates application.conf' do
      expect(chef_run).to create_template('/usr/local/sample_service/conf/application.conf').with(
                              user: 'play'
                          )
    end
  end

  describe 'logrotate' do
    it 'include logrotate package' do
      expect(chef_run).to install_package('logrotate')
    end

    it 'creates init.d script' do
      expect(chef_run).to create_template('/etc/logrotate.d/sample_service').with(
                              user: 'root',
                              group: 'root',
                              backup: false
                          )
    end
  end

end
