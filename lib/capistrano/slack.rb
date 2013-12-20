require 'capistrano'
require 'capistrano/log_with_awesome'
require 'json'
# TODO need to handle loading a bit beter. these would load into the instance if it's defined
module Capistrano
  module Slack
    def self.extended(configuration)
      configuration.load do

        before 'deploy', 'slack:starting'
        before 'deploy:migrations', 'slack:starting'
        after 'deploy',  'slack:finished'

        set :deployer do
          ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp
        end


        namespace :slack do
            task :starting do
              slack_token = fetch(:slack_token)
              slack_room = fetch(:slack_room)
              slack_subdomain = fetch(:slack_subdomain)
              return if slack_token.nil?
              announced_deployer = fetch(:deployer)
              announced_stage = fetch(:stage, 'production')

              announcement = if fetch(:branch, nil)
                               "#{announced_deployer} is deploying #{application}'s #{branch} to #{announced_stage}"
                             else
                               "#{announced_deployer} is deploying #{application} to #{announced_stage}"
                             end
              uri = URI("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
              res = Net::HTTP.post_form(uri, :payload => {'channel' => slack_room, 'username' => 'deploybot', 'text' => announcement, "icon_emoji" => ":ghost:"}.to_json)
              
            end


            task :finished do
              begin
                slack_token = fetch(:slack_token)
                slack_room = fetch(:slack_room)
                slack_subdomain = fetch(:slack_subdomain)
                log = fetch(:full_log)
                return if slack_token.nil?
                uri = URI("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
                res = Net::HTTP.post_form(uri, :payload => {'channel' => slack_room, 'username' => 'deploybot', 'text' => log, "icon_emoji" => ":ghost:"}.to_json)
              rescue Faraday::Error::ParsingError
                # FIXME deal with crazy color output instead of rescuing
                # it's stuff like: ^[[0;33m and ^[[0m
              end
            end
          end
        end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Slack)
end
  
