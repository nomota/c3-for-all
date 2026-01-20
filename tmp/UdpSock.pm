package SockUDP;

use strict;
use Socket;
use Fcntl;

sub DEBUG() { return $main::debug if (defined($main::debug)); return 1; }
sub ASSERT($) {use Carp; Carp::confess("FATAL\n") if (DEBUG && ! $_[0]);}

sub new_fh() { local(*F); return *F; }

sub SockUDP::new($;$)
{
    my ($classname, $localport) = @_;

    my $socket = new_fh();
    socket($socket, PF_INET, SOCK_DGRAM, getprotobyname('udp'));

    if (defined($localport)) {
        setsockopt($socket, SOL_SOCKET, SO_REUSEADDR, 1);
        my $my_addr = sockaddr_in($localport, INADDR_ANY);

        if (! bind($socket, $my_addr)) {
            warn "udp socket bind($my_addr, $localport) failed" if DEBUG;
            return undef;
        }

      # set_nonblock($socket);
    }

    bless(\$socket, $classname);
}

sub SockUDP::send($$$$)
{
    my ($this_socket, $host, $port, $msg) = @_;

    my $ipaddr = inet_aton($host);

    my $portaddr = sockaddr_in($port, $ipaddr);

    my $r = send($this_socket, $msg, 0, $portaddr);

    if ($r == length($msg)) {
        return 1;
    } else {
        return 0;
    }
}

sub SockUDP::recv($)
{
    my ($this_socket) = @_;

    my $msg = '';
    my $maxlen = 1024;

    my $portaddr = recv($this_socket, $msg, $maxlen, 0);

    my ($portno, $ipaddr) = sockaddr_in($portaddr);
    my $ipstr = inet_ntoa($ipaddr);

    return ($ipstr, $portno, $msg);
}

1;

__END__

Usage:

(1) UDP Socket server

      # ----------------------------------------------
      # give accepting/listening port to make UDP socket server
      # ----------------------------------------------
      my $server = new SockUDP($local_waiting_port);

      while (1) {
          my ($client_ip, $client_port, $message) = $server->recv();

          # do something with $message
      }


(2) UDP Socket for client

      # ------------------------------------------
      # client socket if port is not given
      # ------------------------------------------      
      my $client = new SockUDP();

      $client->send($server_ip, $server_port, $message);

(3) Log server with timeout


    $main::flush_duration = 10;
    $main::max_buf = 10000;

    my $server = new SockUDP($local_waiting_port);

    my $msgs = [];
    my $last_flushtime = time();

    while (1) {
        my ($host, $port, $msg) = ('', '', '');

        eval {
            local $SIG{ALRM} = sub { die "$!"; };
            alarm($main::flush_duration);
            ($host, $port, $msg) = $sock->recv();
            alarm(0);
        };

        if ($@) {
            print "TIMEOUT\n";
            do_flush($msgs);
            $last_flushtime = time();
            $msgs = [];
            next;
        }

        push @$msgs, [$host, $port, $msg];

        if (@{$msgs} > $main::max_buf ||
            time() - $last_flushtime > $main::flush_duration)
        {
            do_flush($msgs);
            $last_flushtime = time();
            $msgs = [];
        }
    }
  
__END__




#!/bin/env perl

use strict;

use POSIX;
use SockUDP;

MAIN:
{
    if (scalar(@ARGV) < 1) {
        print "Usage: $0 127.0.0.1 udpPort 'msg data'\n";
        print "       $0 127.0.0.1 52526 'test smtp log port send'\n";
        exit(0);
    }

    my $client = new SockUDP();

    $client->send($ARGV[0], $ARGV[1], $ARGV[2]);
}
