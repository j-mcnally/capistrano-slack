# Capistrano Slack

## Install

Best way to install Capistrano Slack intergration is via Bundler.  

Add the following to your Gemfile, then run the `bundle` command to install the gem direct from the git repository

```
gem 'capistrano-slack', :git => 'https://github.com/j-mcnally/capistrano-slack.git'
```

Once installed you can use the settings below in your Capistrano deploy.rb to configure Slack.

## Push deployment messages to Slack

```ruby

require 'capistrano/slack'

# required
set :slack_token, "webhook_token" # comes from inbound webhook integration
set :slack_room, "#general"
set :slack_subdomain, "kohactive" # if your subdomain is kohactive.slack.com

# optional
set :slack_application, "Rocketman"
set :slack_username, "Elton John"
set :slack_emoji, ":rocket:"
```

You can obtain your `webhook_token` from the integrations section of the team page in Slack.  

https://kohactive.slack.com/services/new/incoming-webhook (if your subdomain is kohactive.slack.com)

## Add custom messages to callbacks 
```ruby
namespace :slack do
    namespace :migration do 
        task :start do 
            @migration_start_time = Time.now
            msg = "#{random_emoji} Running Migrations"
            connect(msg)
        end
        task :end do 
            elapsed_time = Time.now.to_i - @migration_start_time.to_i   if @migration_start_time
            msg = "#{random_emoji} Migrations finished in #{elapsed_time} seconds"
            connect(msg)
        end
    end
    before "deploy:migrate", "slack:migration:start"
    after  "deploy:migrate", "slack:migration:end"
```

