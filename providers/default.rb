def whyrun_supported?
  true
end

def play_service(project_name, home_dir)
  # create pid directory
  directory new_resource.pid_dir do
    owner new_resource.user
    group new_resource.user
    mode 0755
    action :create
  end

  # make play script executable
  execute "chmod +x #{project_name}" do
    cwd "#{home_dir}/bin"
    action :run
  end

  service new_resource.service_name do
    init_command "/etc/init.d/#{new_resource.service_name}"
    supports status: true, start: true, stop: true, restart: true
    action :nothing
  end

  conf_path =
    new_resource.app_conf_file =~ /^\// ? new_resource.app_conf_file : "#{home_dir}/#{new_resource.app_conf_file}"

  # create play service
  play_service_template = template "/etc/init.d/#{new_resource.service_name}" do
    cookbook 'playframework'
    source 'play.init.erb'
    owner 'root'
    group 'root'
    mode 0755
    variables(
        service_name: new_resource.service_name,
        source: home_dir,
        executable: project_name,
        user: new_resource.user,
        pid_path: new_resource.pid_dir,
        config_file: conf_path,
        app_args: new_resource.app_args.join(' ')
    )
    notifies :enable, "service[#{new_resource.service_name}]", :immediately
    notifies :start, "service[#{new_resource.service_name}]", :immediately
  end

  new_resource.updated_by_last_action(true) if play_service_template.updated_by_last_action?
end

def play_logrotate(home_dir, new_resource)
  play_service = service new_resource.service_name do
    action :nothing
  end

  # make log path absolute, if relative
  log_path = new_resource.app_log =~ /^\// ? new_resource.app_log : "#{home_dir}/#{new_resource.app_log}"

  logrotate_app play_service.service_name do
    path log_path
  end
end

action :install do
  converge_by(new_resource) do
    fail "Install requires 'source' attribute" if new_resource.source.nil?

    package 'unzip' do
      action :install
    end

    package 'rsync' do
      action :install
      only_if { node['platform'] == 'centos' }
    end

    user new_resource.user do
      comment 'playframework'
      system true
      shell '/bin/false'
      action :create
    end

    version = new_resource.version
    version ||= (new_resource.source).match(/-([\d|.|(-SNAPSHOT)]*)[-|.]/)[1] # http://rubular.com/r/X9K1KPkEpx

    ark new_resource.service_name do
      url new_resource.source
      checksum new_resource.checksum
      version version
      owner new_resource.user
      not_if { ::File.directory?(new_resource.source) }
      action :install
    end

    project_name = new_resource.project_name
    project_name ||= (new_resource.source).match(/.*\/(.*)-[0-9].*/)[1] # http://rubular.com/r/X9PUgZl0UW

    home_dir = ::File.directory?(new_resource.source) ? new_resource.source : "/usr/local/#{new_resource.service_name}"

    play_service(project_name, home_dir)

    # make template path absolute, if relative
    if new_resource.app_conf_template =~ /^\//
      template_path =  new_resource.app_conf_template
    else
      template_path = "#{home_dir}/#{new_resource.app_conf_template}"
    end

    # create application.conf
    app_conf = template "#{home_dir}/#{new_resource.app_conf_file}" do
      local true
      owner new_resource.user
      source template_path
      variables(new_resource.app_conf)
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end

    new_resource.updated_by_last_action(true) if app_conf.updated_by_last_action?

    play_logrotate(home_dir, new_resource)
  end
end
