require 'capistrano'
require 'capistrano/log_with_awesome'
require 'json'
require 'net/http'
require 'active_support/all'
# TODO need to handle loading a bit beter. these would load into the instance if it's defined
module Capistrano
  module Slack
    def self.extended(configuration)
      configuration.load do


        before 'deploy:update', 'slack:starting'
        before 'deploy:migrations', 'slack:configure_for_migrations', 'slack:starting'
        after 'deploy',  'slack:finished'
        after 'deploy:migrations', 'slack:configure_for_migrations', 'slack:finished'

        set :deployer do
          uname = ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp
          uname = ENV['USER'] if uname.empty?
          uname
        end
        set :slack_with_migrations, false

        deploy_failed_msg = lambda do
          announcement = "#{@announced_deployer} cancelled deployment of #{@slack_application}"
          announcement << "'s #{fetch(:branch)}" if fetch(:branch, nil)
          announcement << " to #{@announced_stage}"
        end

        deploy_start_msg = lambda do
          announcement = "#{@announced_deployer} is deploying #{@slack_application}"
          announcement << "'s #{fetch(:branch)}" if fetch(:branch, nil)
          announcement << " with migrations" if slack_with_migrations
          announcement << " to #{@announced_stage}"
        end

        deploy_finished_msg = lambda do
          announcement = "#{@announced_deployer} deployed #{@slack_application}"
          announcement << "'s #{fetch(:branch)}" if fetch(:branch, nil)
          announcement << " with migrations" if slack_with_migrations
          announcement << " to #{@announced_stage}"
          announcement << " to #{@announced_stage} successfully in #{@elapsed} seconds"
        end

        def send_slack(msg)
          begin
            @slack_token = fetch(:slack_token)
            @slack_room = fetch(:slack_room)
            @slack_emoji = fetch(:slack_emoji) rescue nil || ":ghost:"
            @slack_username = fetch(:slack_username) rescue nil || "deploybot"
            @slack_application = fetch(:slack_application) rescue nil || application || "unknown"
            @slack_subdomain = fetch(:slack_subdomain)
            return if slack_token.nil?
            @announced_deployer = ActiveSupport::Multibyte::Chars.new(fetch(:deployer)).mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').to_s
            @announced_stage = fetch(:stage, 'production')
            @elapsed = fetch(:elapsed, "")

            announcement = msg.call

            # Parse the API url and create an SSL connection
            uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER

            # Create the post request and setup the form data
            request = Net::HTTP::Post.new(uri.request_uri)
            request.set_form_data(:payload => {'channel' => @slack_room, 'username' => @slack_username, 'text' => announcement, "icon_emoji" => @slack_emoji}.to_json)

            # Make the actual request to the API
            response = http.request(request)
          rescue Faraday::Error::ParsingError
            # FIXME deal with crazy color output instead of rescuing
            # it's stuff like: ^[[0;33m and ^[[0m
          end
        end

        namespace :slack do
            task :configure_for_migrations do
              set :slack_with_migrations, true
            end
            task :starting do
              on_rollback do
                set(:slack_emoji, ":no_entry:")
                send_slack(deploy_failed_msg)
              end

              send_slack(deploy_start_msg)
              set(:start_time, Time.now)
            end


            task :finished do
              end_time = Time.now
              start_time = fetch(:start_time)
              set(:elapsed, end_time.to_i - start_time.to_i)

              send_slack(deploy_finished_msg)
            end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Slack)
end
