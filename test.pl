# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use strict;
use warnings;
use Test::More tests => 20;

BEGIN { use_ok( 'Win32::mIRC', qw(:all) ); }

ok( connect('irc.zirc.org',6667,'#test',1), 'Can we connect?' );

print "sleeping 15 seconds before checking connection status...\n";
sleep(15);

my $connected = connected();
print "connection status: $connected (how to test with Test::More?)\n";
like( $connected, qr/connect/, 'connected() returned a connection state?' );

print "testing evaluate()...\n";
my $client = evaluate();
isa_ok( $client, 'Win32::DDE::Client' );

my $connections = connections($client);
print "$connections connections\n";
cmp_ok( $connections, '>=', 1, 'At least one connection?' );

cmp_ok( networks($client), '>=', 1, 'networks() returns at least one network?' );

cmp_ok( servers($client), '>=', 1, 'servers() returns at least one server?' );

my $command = command();
isa_ok( $command, 'Win32::DDE::Client' );

my $version = version();
print "version is $version\n";
like( $version, qr/mIRC v\d\.\d{2}/, 'mIRC Version info returned?' );

my $exename = exename();
print "exename is $exename\n";
like( $exename, qr/mirc.exe/i, q/exename() returned 'mirc.exe' as part of the filename?/ );

my $inifile = inifile();
print "inifile is $inifile\n";
like( $inifile, qr/mirc.ini/i, q/inifile() returned 'mirc.ini' as part of the filename?/ );

my $nickname = nickname();
print "nickname is $nickname\n";
cmp_ok( $nickname, 'ne', '', 'nickname() is not null?' );

my $server = server();
print "server is $server\n";
cmp_ok( $server, 'ne', '', 'server() is not null?' );

my $port = port();
print "port is $port\n";
cmp_ok( $port, '>', 0, 'port() is not 0?' );

my $channels = channels();
print "channels are $channels()\n";
cmp_ok( $channels, 'ne', '', 'channels() returns channels?' );

my $users = users('#test');
print "users on #test are $users\n";
cmp_ok( $users, 'ne', '', 'users() returned users?' );

my $cid = cid($client, 1);
print "cid is $cid\n";
cmp_ok( $cid, '>=', 0, 'cid() is >= 0' );

ok( scid($command, $cid, '/echo 1 hello from perl (scid)'), 'scid()' );

ok( scon($command, 1, '/echo 1 hello again from perl (scon)'), 'scon()' );

ok( multiserver($command, "othernet"), 'multiserver()' );


