#! /usr/bin/perl
use Modern::Perl;
use Perlude;
use Test::More;
my ( @input, $got, $expected );

my $doubles = sub {
    state $seed = 0;
    $seed+=2;
};

my @first  = fold takeWhileUnshift { $_ < 5 } $doubles;
is_deeply \@first, [2, 4];

my ($next) = fold take 1, $doubles;
is $next, 6;

done_testing();