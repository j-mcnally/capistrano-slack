require 'capistrano'
require 'capistrano/log_with_awesome'
require 'json'
require 'net/http'
# TODO need to handle loading a bit beter. these would load into the instance if it's defined
module Capistrano
  module Slack
    def self.extended(configuration)
      configuration.load do

        before 'deploy',            'slack:starting'
        before 'deploy:migrations', 'slack:starting'
        before 'deploy:long',       'slack:starting'
        after  'deploy',            'slack:finished'
        after  'deploy:long',       'slack:finished'

        set :deployer do
          ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp
        end


        namespace :slack do

          task :starting do
            return if slack_token.nil?

            announcement = "#{announced_deployer} is deploying #{announced_application_name} to #{announced_stage}"

            post_slack_message(announcement)

            set(:start_time, Time.now)
          end

          task :finished do
            begin
              return if slack_token.nil?
              end_time = Time.now
              start_time = fetch(:start_time)
              elapsed = end_time.to_i - start_time.to_i

              announcement = "#{announced_deployer} deployed #{announced_application_name} successfully in #{elapsed} seconds."

              post_slack_message(announcement)

            rescue Faraday::Error::ParsingError
              # FIXME deal with crazy color output instead of rescuing
              # it's stuff like: ^[[0;33m and ^[[0m
            end
          end

        end

      end
    end

    def announced_application_name
      @announced_application_name ||= "".tap do |output|
        output << slack_application
        output << " #{branch}" if branch
        output << " (#{short_revision})" if short_revision
      end
    end

    def announced_deployer
      @announced_deployer ||= fetch(:deployer)
    end

    def announced_stage
      @announced_stage ||= fetch(:stage, fetch(:rack_env, fetch(:rails_env, 'production')))
    end

    def branch
      @branch ||= fetch(:branch, "")
    end

    def post_slack_message(message)
      # Parse the API url and create an SSL connection
      uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Create the post request and setup the form data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(:payload => {'channel' => slack_room, 'username' => slack_username, 'text' => message, "icon_emoji" => slack_emoji}.to_json)

      # Make the actual request to the API
      response = http.request(request)
    end

    def real_revision
      @real_revision ||= fetch(:real_revision)
    end

    def short_revision
      return unless real_revision
      real_revision[0..7]
    end

    def slack_application
      @slack_application ||= fetch(:slack_application) || application
    end

    def slack_emoji
      @slack_emoji ||= fetch(:slack_emoji) || ":ghost:"
    end

    def slack_room
      @slack_room ||= fetch(:slack_room)
    end

    def slack_subdomain
      @slack_subdomain ||= fetch(:slack_subdomain)
    end

    def slack_token
      @slack_token ||= fetch(:slack_token)
    end

    def slack_username
      @slack_username ||= fetch(:slack_username) || "deploybot"
    end

  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Slack)
end
