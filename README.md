Nanoc Deploy
=============================

**Note: As of Nanoc 3.3, nanoc-deploy will be [integrated](https://github.com/nanoc/nanoc/commit/e4c7f16ea0fbb8a59eac8d33591b83b1915540ec) into nanoc.**

Nanoc Deploy is a nanoc gem that adds a deployer that will upload your site into the cloud.

It uses the [fog](https://github.com/geemus/fog) gem and currently supports Amazon S3, Rackspace Cloud Files, and Google Storage.

Installation
------------

- You need Nanoc 3.1.6 or above
- This gem requires fog 0.7.2 or above

If you're using bundler, just add this to your Gemfile:

    gem 'nanoc-deploy'

Otherwise, you can just install the gem manually:

    gem install nanoc-deploy

and then in your nanoc project, put this in Rakefile:

    require 'nanoc-deploy/tasks'

Usage
------------

In config.yaml:

    deploy:
      default:
        provider:              aws
        bucket:                some-bucket-name
        aws_access_key_id:     your_id
        aws_secret_access_key: your_key

In this example, the provider is aws (s3). Valid values are "aws", "rackspace", or "google".
The bucket is the s3 bucket name, or root directory for your data storage provider.
The key/secret pair differ depending on your provider. In this case, we use
aws_access_key_id/aws_secret_access_key because we're using s3.

If your provider is "rackspace":

        provider:           rackspace
        rackspace_username: your_username
        rackspace_api_key:  your_key

If your provider is "google":

        provider:                         google
        google_storage_secret_access_key: your_key
        google_storage_access_key_id:     your_id

If your provider is "aws", there's also an optional `aws_region` config:

aws_region:     us-west-1

You can set an optional path if you want a path prefix to your site. For example, the code
below:

        path:                  myproject

will produce a url similar to:

    https://s3.amazonaws.com/some-bucket-name/myproject

If you check your rake tasks you should now see a deploy:cloud task:

    rake -T

To deploy:

    rake deploy:cloud

Contact
------------
You can reach me at <jack@jackchu.com>.