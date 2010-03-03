# Mathetes - IRC Bot

## Installing

Clone the repository:

    git clone git://github.com/Pistos/Mathetes.git

Pull in some requirements:

[silverplatter-irc](http://github.com/apeiros/silverplatter-irc)

    git clone git://github.com/apeiros/silverplatter-irc.git

[silverplatter-log](git://github.com/apeiros/silverplatter-irc.git)

    git clone git://github.com/apeiros/silverplatter-log.git

We also need to install some gems:

    sudo gem install eventmachine
    sudo gem install mash -v 0.0.3
    sudo gem install httparty -v 0.4.3
    sudo gem install m4dbi
    sudo gem install dbd-pg

## Configuring

    cp mathetes-config.yaml.sample mathetes-config.yaml

You'll want to change things like nick, password and channels for starters.

If you're going to use the Twitter plugin you also need to configure it:

    cp mathetes-twitter.yaml.sample mathetes-twitter.yaml

## Running

    ruby -rubygems -Ipath/to/silverplatter-irc/lib -Ipath/to/silverplatter-log/lib -Ilib irc-bot.rb
