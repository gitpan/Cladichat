package Cladichat;

use 5.006001;
use strict;
use warnings;
use IO::Socket;
require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Cladichat ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our %EXPORT_TAGS = ( 'all' => [ qw(client server) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.03';

sub client

{

    my $macchina_di_arrivo = $_[0];
    my $porta_di_arrivo    = $_[1];
    my $username           = $_[2];


    my $tunnel = IO::Socket::INET->new(
        Proto    => 'tcp',
        PeerAddr => $macchina_di_arrivo,
        PeerPort => $porta_di_arrivo
      );

print "Connected to $macchina_di_arrivo on port: $porta_di_arrivo, protocol:tcp...\n Talk!...\n"

      or die
      "can't connect to port $porta_di_arrivo on $macchina_di_arrivo: $!";

    
    $tunnel->autoflush(1);
    my $processo = fork();

    # 1st process
    if ($processo) {

        # server Talk.....
        while ( defined( my $paroleserver = <$tunnel> ) ) {

            # standard output...
            print STDOUT $paroleserver;
        }


        kill( "TERM", $processo );

        die;
    }

# 2nd process
    else {

        # client talk......
        print $tunnel "Client Connected!\n Talk!...\n\r";    #  test  
        while ( defined( my $parolemie = <STDIN> ) ) {

            # send
            chomp $parolemie;
            $parolemie = "$username".':'."$parolemie"; 
            print $tunnel "$parolemie\n\r";

        }
    }

}

sub server

{

    my $mia_porta_in_ascolto = $_[0];
    my $username = $_[1];
    my $tunnel = IO::Socket::INET->new(
        Proto     => 'tcp',
        LocalPort => $mia_porta_in_ascolto,
        Listen    => SOMAXCONN,
        Reuse     => 1
    );

print "\nServer online, port: $mia_porta_in_ascolto, protocol: tcp, wait for connections...\n\t";
    die "Non riesco a creare il tunnel" unless $tunnel;
    while ( my $pc_remoto = $tunnel->accept() ) {
        $pc_remoto->autoflush(1);

        
        my $processo = fork();

        #1st process
        if ($processo) {

            # client speak
            while ( defined( my $paroleclient = <$pc_remoto> ) ) {

                
                print STDOUT $paroleclient;
            }
            kill( "TERM", $processo );
        }

        # 2nd process
        else {
        
            # server speak
            while ( defined( my $parolemie = <> ) ) {

                # send
                chomp $username;
                $parolemie = "$username".':'."$parolemie"; 
                print $pc_remoto $parolemie;
            }
        }
    }
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Cladichat - Simple Perl Chat

=head1 SYNOPSIS

  use Cladichat qw (server client);
  server (port username);
  client (server port username);

=head1 DESCRIPTION

Stub documentation for Cladichat, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.


=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

Cladi.it

=head1 AUTHOR

Cladi, E<lt>cladi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Cladi Di Domenico

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
