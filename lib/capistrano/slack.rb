require 'capistrano'
require 'capistrano/log_with_awesome'
require 'json'
require 'net/http'
require 'active_support/all'
# TODO need to handle loading a bit beter. these would load into the instance if it's defined
module Capistrano
  module Slack
  
      def payload(announcement)
      {
        'channel' => fetch(:slack_room),
        'username' => fetch(:slack_username, ''), 
        'text' => announcement, 
        'icon_emoji' => fetch(:slack_emoji, '') 
        }.to_json
      end

      def slack_connect(message)
        begin
          uri = URI.parse("https://#{fetch(:slack_subdomain)}.slack.com/services/hooks/incoming-webhook?token=#{fetch(:slack_token)}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(:payload => payload(message))
          http.request(request) 
        rescue SocketError => e 
           puts "#{e.message} or slack may be down"
         end
      end
      def slack_defaults 
        if fetch(:slack_deploy_defaults, true) == true
          before 'deploy', 'slack:starting'
          before 'deploy:migrations', 'slack:starting'
          after 'deploy',  'slack:finished'
          after 'deploy:migrations',  'slack:finished'
        end
      end

      def self.extended(configuration)
        configuration.load do

          before('deploy') do 
            slack_defaults
          end

          set :deployer do
            ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp
          end

          namespace :slack do
            task :starting do
              return if slack_token.nil?
              announced_deployer = ActiveSupport::Multibyte::Chars.new(fetch(:deployer)).mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').to_s
              msg = if fetch(:branch, nil)
                "#{announced_deployer} is deploying #{slack_application}'s #{branch} to #{fetch(:stage, 'production')}"
              else
                "#{announced_deployer} is deploying #{slack_application} to #{fetch(:stage, 'production')}"
              end

              slack_connect(msg)  
              set(:start_time, Time.now)
            end
            task :finished do
              return if slack_token.nil?
              announced_deployer = fetch(:deployer)
              start_time = fetch(:start_time)
              elapsed = Time.now.to_i - start_time.to_i
              msg = "#{announced_deployer} deployed #{slack_application} successfully in #{elapsed} seconds." 
              slack_connect(msg)
            end
          end

        end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Slack)
end
  
