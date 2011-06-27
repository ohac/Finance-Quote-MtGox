#!/usr/bin/perl -w

package Finance::Quote::MtGox;

use strict;
use warnings;
use utf8;
use HTTP::Request::Common;
use JSON qw/encode_json decode_json/;

our $VERSION = '0.1';

our $MT_GOX_URL = 'http://mtgox.com/code/data/ticker.php';

our $_ERROR_DATE = '0000-00-00';

sub methods {
    return (mt_gox => \&mt_gox);
}

sub labels {
    return (mt_gox => ['method', 'success', 'name', 'date', 'time', 'currency', 'price']);
}

sub mt_gox {
    my ($quoter, @symbols) = @_;
    return unless @symbols;

    my %info = ();
    my $ua = $quoter->user_agent;

    my $url = $MT_GOX_URL;
    my $reply = $ua->request(GET $url);

    if ($reply->is_success) {
        foreach my $sym (@symbols) {
            %info = (%info, _scrape($reply->content, $sym));
        }
    }
    return %info if wantarray;
    return \%info;
}

sub _scrape($;$) {
    my ($content, $sym) = @_;
    my %info = ();
    my @now = localtime;
    my $date = sprintf '%04d-%02d-%02d', $now[5] + 1900, $now[4] + 1, $now[3];
    my $time = sprintf '%02d:%02d:%02d', $now[2], $now[1], $now[0];
    my $data = decode_json($content);
    my $price = $data->{'ticker'}{'last'};
    my $success = 1;
    $info{$sym, 'success'} = $success;
    $info{$sym, 'currency'} = 'USD';
    $info{$sym, 'method'} = 'mt_gox';
    $info{$sym, 'name'} = 'Mt.Gox';
    $info{$sym, 'date'} = $date;
    $info{$sym, 'time'} = $time;
    $info{$sym, 'price'} = $price;
    $info{$sym, 'errormsg'} = $success ? '' : $content;
    return %info;
}

1;
