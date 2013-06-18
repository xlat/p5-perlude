#! /usr/bin/perl
use Modern::Perl;
use Perlude;
use Test::More;# skip_all => 'this is not fixable';

my ( @input, $got, $expected );

my $doubles = sub {
    state $seed = 0;
    $seed+=2;
};

my @first  = fold takeWhile { $_ < 5 } $doubles;
is_deeply \@first, [2, 4];

$TODO = 'dolmen says this test is broken';

#Hack / workarround :  en cas de "condition évaluée à false" takeWhile pourrait? modifier $doubles pour qu'il retourne la derniére valeur testé, puis remodifer $doubles pour reprendre son rôle initial.

my ($next) = fold take 1, $doubles;
is $next, 6;

done_testing();

__DATA__
#xlat's proof of concept
use Modern::Perl;

my $doubles = sub { 
	state $seed = 0;
	$seed +=2
};
my $v;
say 'a)', $v = $doubles->(), ', <5?=', $v<5;
say 'b)', $v = $doubles->(), ', <5?=', $v<5;
say 'c)', $v = $doubles->(), ', <5?=', $v<5;

todo_inside_takeWhile: do {
	my $cvref = \$doubles;
	#~ say $$cvref->();
	my $doubles_ref = $$cvref;
	$$cvref = sub{ $$cvref = $doubles_ref; $v };
};

say 'd)', $v = $doubles->(), ', <5?=', $v<5;	#Continue after takeWhile with previous "lost" value
say 'e)', $v = $doubles->(), ', <5?=', $v<5;	#then, continue normaly :-)
say 'f)', $v = $doubles->(), ', <5?=', $v<5;
