use Modern::Perl;
BEGIN{ push @INC, './lib' }
use Perlude;
use Data::Show;
$|++;

# stream consumers (lazy)
sub takeWhile2 (&\$) {
    my ($cond, $iref ) = @_;
		my $i = $$iref;
    sub {
        ( my @v = $i->() ) or return;
        return $cond->() ? @v : do{ 
					#patch $iref so it can provide again $_ !
					my $v = $_;
					$$iref = sub{ $$iref = $i; $v }; 
					()
				} for @v;
    }
}

#---------------------------------------------------------------
my $doubles = sub {
    state $seed = 0;
    $seed+=2;
};

my $v;
#~ say 'a)', $v = $doubles->(), ', <5?=', $v<5;
#~ say 'b)', $v = $doubles->(), ', <5?=', $v<5;
#~ say 'c)', $v = $doubles->(), ', <5?=', $v<5;
my @first  = fold takeWhile2 { $_ < 5 } $doubles;
show \@first;

#~ say 'a)', $v = $tmp->(), ', <5?=', $v<5;
#~ say 'b)', $v = $tmp->(), ', <5?=', $v<5;
#~ say 'c)', $v = $tmp->(), ', <5?=', $v<5;

#~ todo_inside_takeWhile: do {
	#~ my $cvref = \$doubles;
	#~ #say $$cvref->();
	#~ my $doubles_ref = $$cvref;
	#~ $$cvref = sub{ $$cvref = $doubles_ref; $v };
#~ };

say 'd)', $v = $doubles->(), ', <5?=', $v<5;	#Continue after takeWhile with previous "lost" value
say 'e)', $v = $doubles->(), ', <5?=', $v<5;	#then, continue normaly :-)
say 'f)', $v = $doubles->(), ', <5?=', $v<5;
