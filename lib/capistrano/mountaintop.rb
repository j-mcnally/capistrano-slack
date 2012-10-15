require 'capistrano'
require 'capistrano/campfire'
require 'capistrano/log_with_awesome'
# TODO need to handle loading a bit beter. these would load into the instance if it's defined
module Capistrano
  module Mountaintop
    def self.extended(configuration)
      configuration.load do

        before 'deploy', 'mountaintop:campfire:starting'
        after 'deploy',  'mountaintop:campfire:finished'

        namespace :mountaintop do
          namespace :campfire do
            task :starting do
              announced_deployer = fetch(:deployer,  `git config user.name`.chomp)
              announced_stage = fetch(:stage, 'production')

              announcement = if fetch(:branch, nil)
                               "#{announced_deployer} is deploying #{application}'s #{branch} to #{announced_stage}"
                             else
                               "#{announced_deployer} is deploying #{application} to #{announced_stage}"
                             end
              
              campfire_room.speak announcement
            end


            task :finished do
              begin
                campfire_room.paste fetch(:full_log)
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
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Mountaintop)
end
  
