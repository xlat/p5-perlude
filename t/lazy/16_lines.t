#! /usr/bin/perl
use Modern::Perl;
use Test::More 'no_plan';
use Perlude::Lazy;
use autodie;

my @seed = qw/ toto tata tutu /;
my $file = $ENV{TMP}.'/perlude-test-lines-data';

open F,'>',$file;
say F $_ for @seed;
close F;

is_deeply
( [fold lines $file]
, [map { "$_\n" } @seed]
, "raw lines" );

is_deeply
( [fold lines chomp => $file]
, \@seed
, "chomped lines" );
#~ END{	#~ Perlude::Lazy::gc;
unlink $file;
#~ }

__DATA__
xlat@cpan.org : 
	- si $^O eq 'MSWin32', alors ce test échoue d'abord à cause du $file = '/tmp/...' que je remplace par $ENV{TMP}
	- ensuite, il échoue sur le unlink avec: Can't unlink('C:\...\Temp/perlude-test-lines-data'): Permission denied at t/lazy/16_lines.t line 24
	-> c'est par ce que les "file handles" ne sont pas fermés tout seul, un hack rapide pour tester en modifiant Perlude::Lazy::lines comme suit permet de le verifier:
our @__garbage;
sub gc{
	foreach(@__garbage){
		close($_)
	}
}
sub lines {
    # private sub that coerce path to handles
    state $fh_coerce = sub {
        my $v = shift;
        return $v if ref $v;
        open my ($fh),$v;
				push @__garbage, $fh;											#+++ <<<
        $fh;
    };
    my $fh = $fh_coerce->( pop );

    # only 2 forms accepted for the moment
    # form 1: lines 'file'
    @_ or return enlist { <$fh> // () };

    # confess if not 2nd form
    $_[0] ~~ 'chomp' or confess 'cannot handle parameters ' , join ',', @_ ;

    # lines chomp => 'file'
    enlist {
        defined (my $v = <$fh>) or return;
        chomp $v;
        $v;
    }
		
}	

	=> Une solution serait peut-être de faire Tie::FILEHANDLE qui s'auto close à la lecture de la derniére ligne du fichier ?
	 -> ne gére pas le cas d'un now &say { take 1, lines $file }