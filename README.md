# Play Framework Cookbook

A LWRP cookbook to install Play Framework 
[2.2.x or higher](http://www.playframework.com/documentation/2.2.x/ProductionDist) standalone distributions.

Action `install` will do the following:

* Fetch and unpack stand alone distribution using [ark](https://supermarket.getchef.com/cookbooks/ark), if source is 
not a directory
* Create application configuration from template if one is provided
* Configure rotate of application log file, if `logrotate` recipe is included
* Install standalone distribution as a service, enabling it to start during server reboot

## Attributes

* `name` - Name of the resource as it is defined in the recipe. (required)
* `source` - URL to archive or directory path to exploded archive. 
* `checksum` - The SHA-256 checksum of the file. Use to prevent the resource from re-downloading a file. 
When the local file matches the checksum, the chef-client will not download it.
* `service_name` - Service name to run as.  Default value: the `name` of the resource block
* `project_name` - Used to identify start script executable.  Defaults to project name derived from standalone distribution filename, if blank.
* `version` - Version of application.  Defaults to version derived from standalone distribution filename, if blank.
* `user` - User to run service as.  Default value: `play`
* `app_args` - Array of additional configuration arguments.  Default value: empty array `[]` 
* `app_conf` - Hash of application configuration variables required by application.conf.erb template.  
Default value: empty hash `{}`
* `app_conf_template` - Path to configuration template.  Path can be relative, or if the template file is outside dist 
path, absolute.  Default value: `conf/application.conf.erb`
* `app_conf_file` - Path to application configuration file. Path can be relative, or if the config file is outside 
standalone distribution, absolute. This is also the path to the location in which a file will be created and the name 
of the file to be managed by template. Default value: `conf/application.conf`
* `app_log` - The log path. Path can be relative, or if the log file is outside standalone distribution, absolute.  
Default value: `logs/application.log`
* `pid_dir` - The pid directory. Default value: `/var/run/play`

## Usage

To `install` a standalone distribution as service from remote archive:

```ruby
playframework 'servicename' do
  source 'https://example.com/dist/myapp-1.0.0.zip'
  action :install
end
```

To `install` a standalone distribution as service from local file:

```ruby
playframework 'servicename' do
  source 'file:///var/chef/cache/myapp-1.0.0.zip'
  action :install
end
```

To `install` a standalone distribution as service from exploded archive:

```ruby
playframework 'sample_service' do
  source '/var/local/mysample'
  project_name 'sample'
  version '1.0.0'
  action :install
end
```

## Override Attributes

You can also use override attributes in the environment file for finer control (the attribute to be overridden must 
not be set in LWRP; otherwise, override attribute will be ignored):

```ruby
{
  "override_attributes": {
    "playframework": {
      "app_conf": {
        "foo": "bar"
      },
      "app_args": [
        "-Dhttp.port=8080",
        "-J-Xms128M",
        "-J-Xmx512m",
        "-J-server"
      ]
    },
    ...
  },
  ...
}
```
