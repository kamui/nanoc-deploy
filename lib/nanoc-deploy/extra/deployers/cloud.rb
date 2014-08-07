# encoding: utf-8

require 'fog'

module NanocDeploy::Extra::Deployers

  # A deployer that deploys a site to the cloud.
  class Cloud

    # Creates a new deployer that uses fog. The deployment configurations
    # will be read from the configuration file of the site (which is assumed
    # to be the current working directory).
    #
    # The deployment configurations are stored like this in the site's
    # configuration file:
    #
    #   deploy:
    #     NAME:
    #       provider: [ aws, rackspace, google ]
    #       path:     ""
    #       bucket:     "some-bucket-name"
    #
    # if your provider is "aws"
    #       aws_access_key_id: your_id
    #       aws_secret_access_key: your_key
    # if your provider is "rackspace"
    #       rackspace_username: your_username
    #       rackspace_api_key: your_key
    # if your provider is "google"
    #       google_storage_secret_access_key: your_key
    #       google_storage_access_key_id: your_id
    #
    # `NAME` is a unique name for the deployment configuration. By default,
    # the deployer will use the deployment configuration named `"default"`.
    #
    # `BUCKET` is the name of the bucket or root directory
    #
    # `PATH` is a string containing the path prefix that will be used
    # in the cloud. For example, a path of "stuff" will serve your files from
    # `"s3.amazon.com/stuff"`. If you want to serve your static files from the root
    # then leave this blank. It should not end with a trailing slash.
    #
    # Example: This deployment configuration defines a "default" and a
    # "staging" deployment configuration. The default options are used.
    #
    #   deploy:
    #     default:
    #       provider:   aws
    #       bucket:     mywebsite
    #       aws_access_key_id: 123456789
    #       aws_secret_access_key: ABCDEFGHIJK
    #     rackspace:
    #       provider:   rackspace
    #       bucket:     backupsite
    #       rackspace_username: hello
    #       rackspace_api_key: 123456789
    def initialize
      # Get site
      error 'No site configuration found' unless File.file?('config.yaml')
      @site = Nanoc3::Site.new('.')
    end

    # Runs the task. Possible params:
    #
    # @option params [String] :config_name (:default) The name of the
    #   deployment configuration to use.
    #
    # @return [void]
    def run(params={})
      # Extract params
      config_name = params.has_key?(:config_name) ? params[:config_name].to_sym : :default

      # Validate config
      error 'No deploy configuration found'                    if @site.config[:deploy].nil?
      error "No deploy configuration found for #{config_name}" if @site.config[:deploy][config_name].nil?

      # Set arguments
      provider = @site.config[:deploy][config_name][:provider]
      src = File.expand_path(@site.config[:output_dir]) + '/'
      bucket = @site.config[:deploy][config_name][:bucket]
      aws_region = @site.config[:deploy][config_name][:aws_region]
      path = @site.config[:deploy][config_name][:path]
      

      # Validate arguments
      error 'No provider found in deployment configuration' if provider.nil?
      error 'No bucket found in deployment configuration' if bucket.nil?
      error 'The path requires no trailing slash' if path && path[-1,1] == '/'

      case provider
        when 'aws'
          if aws_region
            connection = Fog::Storage.new(
              :provider => 'AWS',
              :aws_access_key_id => @site.config[:deploy][config_name][:aws_access_key_id],
              :aws_secret_access_key => @site.config[:deploy][config_name][:aws_secret_access_key],
              :region => aws_region
            )
          else
            connection = Fog::Storage.new(
              :provider => 'AWS',
              :aws_access_key_id => @site.config[:deploy][config_name][:aws_access_key_id],
              :aws_secret_access_key => @site.config[:deploy][config_name][:aws_secret_access_key]
              )
          end
        when 'rackspace'
          connection = Fog::Storage.new(
            :provider => 'Rackspace',
            :rackspace_username => @site.config[:deploy][config_name][:rackspace_username],
            :rackspace_api_key => @site.config[:deploy][config_name][:rackspace_api_key]
            )
        when 'google'
          connection = Fog::Storage.new(
            :provider => 'Google',
            :google_storage_secret_access_key => @site.config[:deploy][config_name][:google_storage_secret_access_key],
            :google_storage_access_key_id     => @site.config[:deploy][config_name][:google_storage_access_key_id]
            )
      end

      # if bucket doesn't exist, create it
      begin
        directory = connection.directories.get(bucket)
      rescue Excon::Errors::NotFound
        directory = connection.directories.create(:key => bucket)
      end

      # deal with buckets with more than the 1,000 key limit
      files = directory.files
      truncated = files.is_truncated

      while truncated
        set = directory.files.all(:marker => files.last.key)
        truncated = set.is_truncated
        files = files + set
      end

      # delete all the files in the bucket
      files.all.each do |file|
        file.destroy
      end

      # upload all the files in the output folder to the clouds
      Dir.chdir(src)
      Dir.glob('**/*').each do |file_path|
        if (!File.directory?(file_path))
          directory.files.create(:key => "#{path}#{file_path}", :body => File.open(file_path), :public => true)
        end
      end
    end

  private

    # Prints the given message on stderr and exits.
    def error(msg)
      raise RuntimeError.new(msg)
    end
  end
end
