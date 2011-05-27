# encoding: utf-8

namespace :deploy do
  desc 'Upload the compiled site to the cloud'
  task :cloud do
    config_name = ENV['config'] || :default

    deployer = NanocDeploy::Extra::Deployers::Cloud.new
    deployer.run(:config_name => config_name)
  end
end