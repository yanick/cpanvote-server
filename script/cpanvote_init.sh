#! /bin/sh

# Simple script for starting Dancer applications.

LISTEN=127.0.0.1:6130
HOME=/home/cpanvote
DIR=/home/cpanvote/cpanvote
USER=cpanvote
FASTCGI=/home/cpanvote/cpanvote/script/cpanvote_fastcgi.pl

PERL5LIB=$HOME/perl5/lib/perl5/x86_64-linux-gnu-thread-multi/:$HOME/perl5/lib/perl5/
CPANVOTE_CONFIG=$HOME/config
CPANVOTE_LOG=$HOME/logs

PIDFILE=/home/cpanvote/pid/acp.pid

case "$1" in
  start)
    PERL5LIB=$PERL5LIB \
	CPANVOTE_CONFIG=$CPANVOTE_CONFIG \
	CPANVOTE_LOG=$CPANVOTE_LOG \
	 start-stop-daemon --start --chuid $USER --chdir $DIR \
      --pidfile=$PIDFILE \
      --exec $FASTCGI -- \
                --daemon \
                --listen $LISTEN \
                --pidfile $PIDFILE
    ;;
  stop)
    start-stop-daemon --stop --pidfile $PIDFILE
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop}" >&2
    exit 3
    ;;
esac
