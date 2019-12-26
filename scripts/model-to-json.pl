#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use JSON;

sub main {
  my $file = shift;

  open(my $fh, "<:encoding(utf8)", $file) or die $!;
  
  my %dict = ();

  while ( my $line = <$fh> ) {
    chomp($line);

    if ( $line =~ m{\t} ) {
      my ( $tag, $bias ) = split qr{\t}, $line;
      my ( $section, $chars ) = ( $tag =~ m{^([^:]+):(.+)$} );

      $dict{$section} //= {};
      $dict{$section}{$chars} //= sprintf('%.4f', $bias) * 10000;
    } 
  }

  close($fh);

  print encode_json(\%dict);
}

main(@ARGV);
