#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Finance::Quote;

my @symbols = qw/foo/;

my $q = Finance::Quote->new('-defaults', 'MtGox')->mt_gox(@symbols);

my @fields = qw/success currency method name date time price errormsg/;
for my $sym (@symbols) {
  print join("\t", $sym, map { $q->{$sym, $_} // 'N/A' } @fields), "\n";
}
