#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Lingua::JA::Regular::Unicode ();

sub main {
  while (my $line = <STDIN>) {
    utf8::decode($line);
    $line = normalize($line);
    utf8::encode($line);

    print $line;
  }
}

sub normalize {
  my $src = shift;

  # Zenkaku alphanum to Hankaku
  $src =~ tr{０-９Ａ-Ｚａ-ｚ}{0-9A-Za-z};

  # Hankaku katakana to Zenkaku
  $src = Lingua::JA::Regular::Unicode::katakana_h2z($src);

  # Normalize Hyphen-like chars
  $src =~ s{[\˗\֊\‐\‑\‒\–\⁃\⁻\₋\−]}{-}g;
  $src =~ s{[\﹣\－\ｰ\—\―\─\━]}{ー}g;
  $src =~ s{[ー]+}{ー}g;

  # Remove Childa-like chars
  $src =~ s{[\~\∼\∾\〜\〰\～]}{}g;
  
  # Hankaku symbols to Zenkaku 
  $src =~ tr/!"#$%&'()*+,-.\/:;<=>?@[¥]^_`{|}~｡､･｢｣/！”＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿｀｛｜｝〜。、・「」/;

  # Normalize space
  $src =~ s{　}{ }g;
  $src =~ s{[ ]+}{ }g;
  $src =~ s{^[ ]+}{}g;
  $src =~ s{[ ]+$}{}g;
  
  my $re = qr{\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}};
  $src =~ s{([$re]+?)[ ]([$re]+?)}{$1$2}g while ( $src =~ m{[$re]+?[ ][$re]+?} );
  $src =~ s{([\p{InBasicLatin}]+?)[ ]([$re]+?)}{$1$2}g while ( $src =~ m{[\p{InBasicLatin}]+?[ ][$re]+?} );
  $src =~ s{([$re]+?)[ ]([\p{InBasicLatin}]+?)}{$1$2}g while ( $src =~ m{[$re]+?[ ][\p{InBasicLatin}]+?} );
  
  # Zenkaku symbols to hankaku
  $src =~ tr/！”＃＄％＆’（）＊＋，－．／：；＜＞？＠［￥］＾＿｀｛｜｝/!"#$%&'()*+,-.\/:;<>?@[¥]^_`{|}/;
  
  return $src;
}

main();
