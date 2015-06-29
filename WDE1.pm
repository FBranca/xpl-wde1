package xPL::Dock::WDE1;

=head1 NAME

xPL::Dock::WDE1 - xPL::Dock plugin for an ELV WDE1 Receiver

=head1 SYNOPSIS

  use xPL::Dock qw/WDE1/;
  my $xpl = xPL::Dock->new();
  $xpl->main_loop();

=head1 DESCRIPTION

This module creates an xPL client for a serial port-based device.  There
are several usage examples provided by the xPL Perl distribution.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;

use English qw/-no_match_vars/;
use xPL::IOHandler;
use xPL::Dock::Plug;

our @ISA = qw(xPL::Dock::Plug);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

__PACKAGE__->make_readonly_accessor($_) foreach (qw/baud device/);

=head2 C<getopts( )>

This method returns the L<Getopt::Long> option definition for the
plugin.

=cut

sub getopts {
  my $self = shift;
  $self->{_baud} = 9600;
  return
    (
     'wde1-verbose+' => \$self->{_verbose},
     'wde1-baud=i' => \$self->{_baud},
     'wde1-tty=s' => \$self->{_device},
    );
}

=head2 C<init(%params)>

=cut

sub init {
  my $self = shift;
  my $xpl = shift;

  $self->required_field($xpl,
                        'device',
                        'The --wde1-tty parameter is required', 1);

  $self->SUPER::init($xpl, @_);

  $self->{_io} =
    xPL::IOHandler->new(xpl => $self->{_xpl}, verbose => $self->verbose,
                        device => $self->{_device},
                        baud => $self->{_baud},
                        reader_callback => sub { $self->read_wde1(@_) },
                        input_record_type => 'xPL::IORecord::LFLine',
                        output_record_type => 'xPL::IORecord::LFLine',
                        @_);

  return $self;
}


=head2 C<send_sensor(%params)>

=cut

sub send_sensor {
  my ($self, $device, $type, $value, $unit) = @_;
  my %body;

  $body{'device'}  = $device;
  $body{'type'}    = $type;
  $body{'current'} = $value;
  $body{'units'}   = $unit if (defined $unit);

  $self->xpl->send(message_type => 'xpl-trig',
                   class        => 'sensor.basic',
                   schema       => 'sensor.basic',
                   body         => \%body);
}


=head2 C<send_wde1_s300th_sensor(%params)>

=cut

sub send_wde1_s300th_sensor {
  my ($self, $sw1, $sw2, $temp, $hygro) = @_;

  my $device = "WDE1.S300TH_".$sw1.$sw2;

  if ($temp ne '') {
    $temp =~ s/,/./;
    $self->send_sensor($device, 'temp', $temp, 'c');
  }

  if ($hygro ne '') {
    $self->send_sensor($device, 'humidity', $hygro);
  }
}


sub send_wde1_k300_sensor {
  my ($self, $temperature, $humidity, $windspeed, $rain, $is_raining) = @_;

  if ($temperature ne '') {
    my $device = "WDE1.K300";

    $self->send_sensor($device, 'temp',     $temperature, 'c');
    $self->send_sensor($device, 'humidity', $humidity);
    $self->send_sensor($device, 'speed',    $windspeed);
    $self->send_sensor($device, 'count',    $rain);
  }
}


sub read_wde1 {
  my ($self, $handler, $msg, $waiting) = @_;
  my $line = $msg->raw;
print "hooooooo ".$line."\n";

  # S300TH Sensors data :
  # Each sensor address is configured by 2 switchs
  #
  #     S300TH Rear View
  #  +---------------------------------------------------------+
  #  |   *             |  switch1  |                           |
  #  |                 |   3 2 1   |   +   B a t t e r y   -   |
  #  |                 |           |                           |
  #  |                 |   3 2 1   |   -   B a t t e r y   +   |
  #  |   *             |  switch2  |                           |
  #  +---------------------------------------------------------+
  #
  # - t<switch1><switch2> = Temperature for sensor @<switch1><switch2>
  # - h<switch1><switch2> = Hygrometry for sensor @<switch1><switch2>
  #
  # KS300 Sensor data :
  # - kt = KS300 temperature
  # - kh = KS300 humidity
  # - kw = KS300 windspeed (km/h)
  # - kr = KS300 rain (unit ?)
  # - ki = KS300 is raining ? (1=yes, 0=no)
  #
  # Message structure :
  # $1;1;;t11;t12;t13;t21;t22;t23;t31;t32;h11;h12;h13;h21;h22;h23;h31;h32;kt;kh;kw;kr;ki;0
  #
  if ($line =~ /^\$1;([0-9]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*);([0-9,]*)/) {
    $self->send_wde1_s300th_sensor (1,1,$3, $11);
    $self->send_wde1_s300th_sensor (1,2,$4, $12);
    $self->send_wde1_s300th_sensor (1,3,$5, $13);
    $self->send_wde1_s300th_sensor (2,1,$6, $14);
    $self->send_wde1_s300th_sensor (2,2,$7, $15);
    $self->send_wde1_s300th_sensor (2,3,$8, $16);
    $self->send_wde1_s300th_sensor (3,1,$9, $17);
    $self->send_wde1_s300th_sensor (3,2,$10,$18);
    $self->send_wde1_ks300_sensor ($19,$20,$21,$22,$23);
  }
}

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

Based on xpl-perl framework.
Project website: http://www.xpl-perl.org.uk/

=head1 AUTHOR

Frederic Branca, E<lt>fredoxygene@gmail.comE<gt>

=head1 COPYRIGHT

This piece of software is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
