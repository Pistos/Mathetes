# Mathetes - IRC Bot

## Installing

### Ubuntu Prerequisites

Tested on Ubuntu 10.04.

    sudo apt-get install ruby ruby-dev libpq-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev

Install the latest rubygems (not from the repository).  Visit rubygems.org and download the latest and then run...

    ruby setup.rb


### Plugin Prerequisites

Clone the repository:

    git clone git://github.com/Pistos/Mathetes.git

Pull in some requirements:

[silverplatter-irc](http://github.com/apeiros/silverplatter-irc)

    git clone git://github.com/apeiros/silverplatter-irc.git

[silverplatter-log](git://github.com/apeiros/silverplatter-irc.git)

    git clone git://github.com/apeiros/silverplatter-log.git

The plugins have dependencies:

    gem install eventmachine
    gem install mash -v 0.0.3
    gem install httparty -v 0.4.3
    gem install m4dbi
    gem install dbd-pg
    gem install nokogiri

## Configuring

    cp mathetes-config.yaml.sample mathetes-config.yaml

You'll want to change things like nick, password and channels for starters.

If you're going to use the Twitter plugin you also need to configure it:

    cp mathetes-twitter.yaml.sample mathetes-twitter.yaml

## Running

    ruby -rubygems -Ipath/to/silverplatter-irc/lib -Ipath/to/silverplatter-log/lib -Ilib irc-bot.rb

## Support

Come visit me (Pistos) on FreeNode in the #mathetes channel, or report issues at
http://github.com/Pistos/Mathetes/issues .
