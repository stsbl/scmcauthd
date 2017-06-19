# scmcauth client

package scmcauth;

# avoid loading modules to improve startup time
#use strict;
#use warnings;
#use Socket

# Socket
sub PF_UNIX { 1 }; # /usr/include/bits/socket.h
sub SOCK_STREAM { 1 };
sub sockaddr_un($) { pack "sZ108", PF_UNIX, @_ }; # /usr/include/sys/un.h

my $socket = "/run/scmcauthd/socket";

sub get()
{
  my ($size, $data) = (0, 0);
  (sysread CLI, $size, 2) == 2 or return;
  $size = unpack "n", $size;
  (sysread CLI, $data, $size) == $size or return;
  $data;
}

sub put($)
{
  my ($data) = @_;
  die "too much data" if length $data > 0xffff;
  my $size = pack "n", length $data;
  syswrite CLI, $size.$data;
}

sub scmcauth(@)
{
  socket CLI, PF_UNIX, SOCK_STREAM, 0 or die "socket: $!";
  connect CLI, sockaddr_un $socket or die "connect: $!";
  put $_ for @_;
  put "";
  my $res = get;
  close CLI;
  $res;
}

sub login(@)
{
  (scmcauth @_) =~ /^OK\b/;
}

sub simple_login($$$$)
{
  my @args;
  push @args, shift;
  push @args, shift;
  push @args, shift;
  # the following arguments are only required on first login
  # to supply user/master password and client info
  push @args, '[ "unused", "unused"]'; # pseudo argument
  push @args, '{"_dummy":""}'; # 
  push @args, shift;

  login @args;
}

1;
