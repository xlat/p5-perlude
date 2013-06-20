#! /usr/bin/perl
use Modern::Perl;
use Perlude;
use Test::More;

sub seq{
	my $limit   = shift // 1 << 15;
	my $counter = shift // 0;
	sub { $counter < $limit ? ++$counter : () }
}

# test dropWhile
my $to_be_dropped = seq;
my $dropper  = dropWhile { $_ % 16 } $to_be_dropped;
my @hexablock = fold take 2, $dropper; 
is_deeply \@hexablock, [16, 32],"dropWhile";

@hexablock = fold take 2, $dropper; 
is_deeply \@hexablock, [48, 64],"dropWhile again";

@hexablock = fold take 2, $to_be_dropped; 
is_deeply \@hexablock, [65, 66],"dropped seq";

done_testing();