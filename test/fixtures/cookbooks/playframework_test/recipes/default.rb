include_recipe 'java'
include_recipe 'logrotate'

playframework 'sample_service' do
  source 'file:///tmp/kitchen/cookbooks/playframework_test/files/default/sample-1.0.0.zip'
  app_conf(
    application_secret: 'testingonetwothree'
  )
  action :install
end
