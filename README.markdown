# capistrano-mountaintop

capistrano-mountaintop makes it easy to announce deployments to a [Campfire](http://campfirenow.com/) room.

 * [Homepage](http://github.com/technicalpickles/mountaintop)
 * [Report a bug](http://github.com/technicalpickles/mountaintop/issues)

## The story

> I just wanted to shout [about the deploy] from on top of a mountain. But I didn't have a mountain. I had [capistrano] and [a campfire room] - Ron Burgandy, but not really

Deploys are kind of a big deal. Days, weeks, worth of code go live at last. Communication is always important, but it is particularly important when you need to get code out there.

 * Only one person should be deploying at a given, because bad things could happen if multiple people try to deploy at the same time
 * Everyone needs to know a deploy happening. If there is any impact following the deploy, it's important to know that a deploy happened recently and that it may be a cause of the problem
 * If the deploy goes wrong, it's crucial to easily share the logs for debugging purposes

We use capistrano for deploying and Campfire for our day to day communication, so improving our deployment to announce itself was the logical step.

Behold, for this is what capistrano-mountaintop was born to do.

## Install

    gem install capistrano-mountaintop

## Configuration

Since we're dealing with Campfire, we'll need to setup Campfire and the info to go along with it:

 * A Campfire account
 * A Campfire user for announcing. I'd recommend robotic sounding names, like MrRoboto, Bender, Gir, Number Six, etc
 * The API authentication token for the Campfire
 * A Campfire room to shout into

There's also some lines to add to config/deploy.rb:

    require 'capistrano/mountaintop'
    set :campfire_options, {
      :account => 'zim',
      :room => 'World Conquest',
      :user => 'Gir',
      :token => '001000101110101001011112',
      :ssl => true
    }

capistrano-mountain tries to figure out who is deploying by running:

    git config user.name

If you don't want to use this behavior, you can set it explicitly, or use a configure a different way of determing it:

    # hardcoded
    set :deployer, 'Zim'
    # use a different command
    set :deployer, `whoami`.chomp

## The final product

With this in place, deploy in the normal fashion. As that's going on, you'll start seeing messages in the Campfire room: 

    Gir: Zim is deploying impending_doom's master to staging
    Gir: <INSERT FULL LOG HERE>

Boom. Instant team communication about deploys without having to, you know, communicate manually.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Joshua Nichols. See LICENSE for details.
