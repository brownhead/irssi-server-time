use strict;
use Irssi;
use DateTime;
use DateTime::TimeZone;

our $VERSION = '1.0';
our %IRSSI = (
    authors     => 'Adrian Keet & John Sullivan',
    contact     => 'johnsullivan.pem@gmail.com',
    name        => 'server_time',
    description => 'Implements the IRCv3 "server-time" capability',
    license     => 'MIT',
    url         => 'https://github.com/itsjohncs/irssi-server-time',
);

sub parse_servertime {
    my ($servertime, ) = @_;

    # Matches exactly YYYY-MM-DDThh:mm:ss.sssZ as specified in the server time spec
    my ($year, $month, $day, $hour, $minute, $second, $milliseconds) =
        ($servertime =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z$/);
    if ($year) {
        return DateTime->new(
            year => $year,
            month => $month,
            day => $day,
            hour => $hour,
            minute => $minute,
            second => $second,
            nanosecond => $milliseconds * 1000000,
            time_zone => "UTC",
        );
    } else {
        return undef;
    }
}

# Parse the @time tag on a server message
sub server_incoming {
    my ($server, $line) = @_;

    if ($line =~ /^\@time=([\S]*)\s+(.*)$/) {
        my $servertime = $1;
        $line = $2;

        my $tz = DateTime::TimeZone->new(name => 'local');

        my $ts = parse_servertime($servertime);
        unless ($ts) {
            Irssi::print("Badly formatted servertime: $servertime");
            return;
        }
        $ts->set_time_zone($tz);

        my $orig_format = Irssi::settings_get_str('timestamp_format');
        my $format = $orig_format;

        # Prepend the date if it differs from the current date.
        my $now = DateTime->now();
        $now->set_time_zone($tz);
        if ($ts->ymd() ne $now->ymd()) {
            $format = '[%F] ' . $format;
        }

        my $timestamp = $ts->strftime($format);

        Irssi::settings_set_str('timestamp_format', $timestamp);
        Irssi::signal_emit('setup changed');

        Irssi::signal_continue($server, $line);

        Irssi::settings_set_str('timestamp_format', $orig_format);
        Irssi::signal_emit('setup changed');
    }
}

# Request the server-time capability during capability negotiation
sub event_cap {
    my ($server, $args, $nick, $address) = @_;

    if ($args =~ /^\S+ (\S+) :(.*)$/) {
        my $subcmd = uc $1;
        if ($subcmd eq 'LS') {
            my @servercaps = split(/\s+/, $2);
            my @caps = grep {$_ eq 'server-time' or $_ eq 'znc.in/server-time-iso'} @servercaps;
            my $capstr = join(' ', @caps);
            if (!$server->{connected}) {
                $server->send_raw_now("CAP REQ :$capstr");
            }
        }
    }
}

Irssi::signal_add_first('server incoming', \&server_incoming);
Irssi::signal_add('event cap', \&event_cap);
