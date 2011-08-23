package Cladichat;

use 5.006001;
use strict;
use warnings;
use IO::Socket;
require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(client server) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.05';

sub client

{
    #use reference for values

    my $cl = shift;

    my $macchina_di_arrivo = $cl->{server};
    my $porta_di_arrivo    = $cl->{porta};
    my $username           = $cl->{username};
    my $log                = $cl->{logfile};


    my $tunnel = IO::Socket::INET->new(
        Proto    => 'tcp',
        PeerAddr => $macchina_di_arrivo,
        PeerPort => $porta_di_arrivo
      );


    $tunnel->autoflush(1) or die "can't connect to port $porta_di_arrivo on          $macchina_di_arrivo: $!"; 

    print "Connected to $macchina_di_arrivo on port: $porta_di_arrivo, protocol: tcp...\n Talk!...\n";

    
   
    my $processo = fork();

    # 1st process
    if ($processo) {

        # server Talk.....
        while ( defined( my $paroleserver = <$tunnel> ) ) {
         
        chomp $log;

        open( LOGCLIENT, ">>$log" )or die "$!"; 
            # standard output...
            print STDOUT $paroleserver;
            print LOGCLIENT "$paroleserver\n";
            close LOGCLIENT;
        }

        kill( "TERM", $processo );

    }

# 2nd process
    else {

        # client talk......
        print $tunnel "Client Connected!\n Talk!...\n\r";    #  test  
        while ( defined( my $parolemie = <STDIN> ) ) {

            # send
            chomp $parolemie;

            open( LOGCLIENT, ">>$log" )or die "$!";

            $parolemie =    "$username".':'."$parolemie";
 
            print $tunnel   "$parolemie\n\r";

            chomp $parolemie;

            print LOGCLIENT "$parolemie\n";
            close LOGCLIENT;
            
        }
    }

}

sub server

{

    #use reference for values

    my $srv = shift; 
    my $porta = $srv->{porta}; 
    my $username = $srv ->{username};
    my $log = $srv->{logfile};


    my $tunnel = IO::Socket::INET->new(
        Proto     => 'tcp',
        LocalPort => $porta,
        Listen    => SOMAXCONN,
        Reuse     => 1
    );

print "\nServer online, port: $porta, protocol: tcp, wait for connections...\n\t";
    die "Non riesco a creare il tunnel" unless $tunnel;
    while ( my $pc_remoto = $tunnel->accept() ) {
        $pc_remoto->autoflush(1);
         
        
        
        my $processo = fork();

        #1st process
        if ($processo) {

            # client speak
            while ( defined( my $paroleclient = <$pc_remoto> ) ) {

                chomp $log;
         
                open( LOGSERVER, ">>$log" )or die "$!";
                
                print STDOUT $paroleclient;
                print LOGSERVER "$paroleclient\n";

                close LOGSERVER;
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
                chomp $log;
                open( LOGSERVER, ">>$log" )or die "$!";
                print $pc_remoto $parolemie;
                print LOGSERVER "$parolemie\n";
                
                close LOGSERVER;
            }
        }
    }
}



1;
__END__


=head1 NAME

Cladichat - Simple Perl Chat

=head1 SYNOPSIS


use Cladichat qw (server);

my %srvref = ( porta    => "9998", 
               username => "Max",
               logfile  => "logserver.txt" );

server( \%srvref );

###############################

use Cladichat qw (client);

my %clref = ( server => "localhost",
               porta => "9998", 
            username => "John",
             logfile => "logclient.txt" );

client( \%clref );


=head1 DESCRIPTION


Simple Server-Client Chat


=head2 EXPORT

None by default.

=head1 SEE ALSO


=head1 AUTHOR

Cladi, E<lt>cladi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Cladi Di Domenico

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
