package Win32::mIRC;

use strict;
use warnings;

BEGIN {
	use Exporter();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $dde);
	$VERSION     = 0.06;
	@ISA         = qw(Exporter);
	@EXPORT      = qw();
	@EXPORT_OK   = qw(
	  command evaluate connect connected exename version inifile nickname multiserver
	  server port channels users connections networks servers cid scid scon $dde
	);
	%EXPORT_TAGS = (all => [ @EXPORT_OK ], );
}

use Win32::DDE::Client;

$dde = 'mIRC'; # default DDE name

sub new { # internal, may change to _new
  my $topic = shift;
  my $client = new Win32::DDE::Client($dde, $topic);
  die "Unable to initiate conversation" if $client->Error;
  return $client;
}

sub command {
  return new('COMMAND');
}

sub evaluate {
  return new('EVALUATE');
}

sub connect {
  my ($server, $port, $channel, $active) = @_;
  my $client = new('CONNECT');
  $client->Execute("$server,$port,$channel,$active") || die "Unable to connect";
}

sub connected {
  my $client = new('CONNECTED');
  return $client->Request('CONNECTED');
}

sub exename {
  my $client = new('EXENAME');
  return $client->Request('EXENAME');
}

sub version {
  my $client = new('VERSION');
  return $client->Request('VERSION');
}

sub inifile {
  my $client = new('INIFILE');
  return $client->Request('INIFILE');
}

sub nickname {
  my $client = new('NICKNAME');
  return $client->Request('NICKNAME');
}

sub server {
  my $client = new('SERVER');
  return $client->Request('SERVER');
}

sub port {
  my $client = new('PORT');
  return $client->Request('PORT');
}

sub channels {
  my $client = new('CHANNELS');
  return $client->Request('CHANNELS');
}

sub users {
  my $channel = shift;
  my $client = new('USERS');
  return $client->Request($channel);
}

sub connections {
  my $req = shift;
  return $req->Request('$scon(0)'); # request the number of open connections
}

sub networks {
  my $req = shift;
  my @networks = map { $req->Request("\$scon($_).network"); } (1 .. connections($req));
  return @networks;
}

sub servers {
  my $req = shift;
  my @servers = map { $req->Request("\$scon($_).server"); } (1 .. connections($req));
  return @servers;
}

sub cid {
  my $req = shift;
  my $conn = shift;
  return $req->Request("\$scon($conn).cid");
}

sub scid {
  my $com = shift;
  my $cid = shift;
  my $command = shift;
  $com->Execute("/scid $cid $command")
    || die("/scid $cid $command failed");
}

sub scon {
  my $com = shift;
  my $conn = shift;
  my $command = shift;
  $com->Execute("/scon $conn $command")
    || die("/scon $conn $command failed");
}

sub multiserver {
  my $com = shift;
  my $command = shift;
  $com->Execute("/server -m $command")
    || die("/server -m $command failed");
}

=head1 NAME

Win32::mIRC - Communicate with mIRC via DDE

=head1 SYNOPSIS

  #!/usr/bin/perl
  use strict;
  use warnings;
  use Win32::mIRC qw( :all );
  connect('irc.zirc.org',6667,'#test',1);

=head1 DESCRIPTION

This module provides functions for controlling mIRC via DDE.

=head1 Functions

=over 4

=item command

Returns a new mIRC COMMAND connection.  You can use this to Execute commands in mIRC.

  my $command = command();
  $command->Execute('/say Hello from Perl!');

=item evaluate 

Returns a new mIRC EVALUATE connection.

  my $evaluate = evaluate();
  my $anick = $evaluate->Request('$anick');
  print "You're alternate nickname is $anick\n";

=item connect(SERVER, PORT, CHANNEL, ACTIVE)

Connects to the specified server, port and channel.  ACTIVE is a boolean value that specifies whether or not mIRC should make that window active.

Note: This will disconnect you if you are currently connected to a server.  This command cannot be used to initiate multi-server mode.  See multiserver.

=item connected

Returns the connection status: "connected" if you're connected to a server, "connecting" if you're in the process of connecting to a server, and "not connected" if you're not currently connected to a server.

=item exename

Returns the full path and name of the mIRC EXE file. eg. "c:\mirc\mirc.exe".

=item version

Returns mIRC's version info.

=item inifile

Returns the full path and name of the main INI file that is being used. eg. "c:\mirc\mirc.ini".

=item nickname

Returns the nickname currently being used.

=item server

Returns the server to which you were last or are currently connected. eg. "irc.undernet.org"

=item port

Returns the port currently being used to connect to the irc server.

=item channels

Returns a single line of text listing the channels which you are currently on separated by spaces. eg. "#mirc #mircremote #irchelp"

=item users(CHANNEL)

Returns a single line of text listing the users on the specified channel separated by spaces.

=item connections(REQUEST)

Returns the number of open connections. (Multi-server)  REQUEST is an mIRC REQUEST connection.

=item networks(REQUEST)

Returns a list of the networks currently connected.  REQUEST is an mIRC REQUEST connection.

=item servers(REQUEST)

Returns a list of the servers currently connected.  REQUEST is an mIRC REQUEST connection.

=item cid(CONNECTION NUMBER)

Returns a connection id based on the connection number passed.

=item scid(CMDOBJ, CID, COMMAND)

Changes the active connection for a script to connection id N, where N is a $cid value.

CMDOBJ is an mIRC COMMAND connection object.

CID is either a connection id or a switch.

COMMAND is the mIRC command you wish to run.

All commands after the scid command will be performed on the new connection id.

If you specify the command parameter, the connection id is set only for that command.

The -r switch resets the connection id to the original id for that script.

The -a and -tM switches can only be used if you specify a command.

The -a switch performs the command on all connection ids.

The -tM switch limits the command to being performed only on servers with a certain connection status, where M is an or'd value of 1 = server connected, 2 = not connected, 4 = connecting, 8 = not connecting.The command is only performed if M matches the connect status of the connection id.

The -s makes any called commands or identifiers show their results.

=item scon(CMDOBJ, CONN, COMMAND)

The scon command works in exactly the same way, except that CONN represents the Nth connection, not a connection id value.

=item multiserver(CMDOBJ, NETWORK)

This allows you to connect to a new server in multi-server mode.

CMDOBJ is an mIRC COMMAND connection object.

NETWORK is a string containing the network (or optionally the server) to connect to.

=head1 BUGS

None that I know of.

=head1 AUTHOR

Matthew Musgrove
CPAN ID: MMUSGROVE
E<lt>muskrat@mindless.comE<gt>
L<http://mrmuskrat.perlmonk.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<Win32::DDE::Client>
L<http://www.mirc.com>

=cut

1;
