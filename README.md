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

    ---
      nick: your_bot
      password: 'thesecretpassword'
      channels:
          - name: '#some_channel'
            ops: true
          - name: '#some_other_channel'
      plugins:
        - channel-util
        # broken atm
        # - chanstats
        - convert
        - dictionary
        - down-for-me
        - etymology
        - github-hook
        - google-fight
        - google
        - kicker
        - last-spoke
        # requires a database & table
        # - memo
        - nick-info
        - pun
        - rss
        - russian-roulette
        - sample
        - spell
        - translate
        - twitter
        - url-summary
        - web-scrape

If you're going to use twitter you also need to configure it:

    cp mathetes-twitter.yaml.sample mathetes-twitter.yaml

Right now it's username and password, maybe you can fork it and make it use oauth instead?  It's only using it to *pull* though...

    ---
    username: TwitterUsername
    password: twitterpassword

## Running it

    ruby -rubygems -Iexternal/silverplatter-irc/lib -Iexternal/silverplatter-log/lib -Ilib irc-bot.rb
