actions :install
default_action :install

attribute :name, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :checksum, kind_of: String, required: false
attribute :project_name, kind_of: String, required: false
attribute :version, kind_of: String, required: false, default: nil
attribute :user, kind_of: String, default: node['playframework']['user']
attribute :app_args, kind_of: [Array, NilClass], default: node['playframework']['app_args']
attribute :app_conf, kind_of: [Hash, NilClass], default: node['playframework']['app_conf']
attribute :app_conf_file, kind_of: String, default: node['playframework']['app_conf_file']
attribute :app_conf_template, kind_of: String, default: node['playframework']['app_conf_template']
attribute :app_log, kind_of: String, default: node['playframework']['app_log']
attribute :pid_dir, kind_of: String, default: node['playframework']['pid_dir']

def service_name(arg = nil)
  if arg.nil? && @service_name.nil?
    @name
  else
    set_or_return(:service_name, arg, kind_of: String)
  end
end
