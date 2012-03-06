#!/bin/bash
LIBSPIRC=/usr/local/src/silverplatter-irc/lib
LIBSPLOG=/usr/local/src/silverplatter-log/lib
LIBM4DB=/usr/local/src/m4dbi/lib
#for heavy debugging
#ruby -vvvv -rdebug -rubygems -I$LIBSPIRC -I$LIBSPLOG -I$LIBM4DB -Ilib irc-bot.rb

ruby -rubygems -I$LIBSPIRC -I$LIBSPLOG -I$LIBM4DB -Ilib irc-bot.rb
