#!/usr/bin/perl

use strict;
use warnings;

use lib '../..';
use Unison::Utilities::misc qw(get_context_coords context_highlight);

# example code:
my $seq = 'abcdefghi';
my %c = get_context_coords(length($seq),4,6,2,1);
my $ctx = substr($seq,$c{cl}-1,$c{cw});    # susbtr is 0-based!
my $ctx_hl = $ctx;
substr($ctx_hl,$c{hr}+1 ,0) = '<';
substr($ctx_hl,$c{hl}   ,0) = '>';

print( $seq, "\n",
	   join(', ', map {"$_=$c{$_}"} sort keys %c), "\n",
	   $ctx, "\n",
	   $ctx_hl, "\n" );



# additional tests:
my @args = ( 
			'0 context, left, middle, right',
			[  1, 1, 0, 0 ],
			[  2, 2, 0, 0 ],
			[  5, 5, 0, 0 ],
			[  8, 8, 0, 0 ],
			[  9, 9, 0, 0 ],

			'1 context, left, middle, right',
			[  1, 1, 1, 1 ],
			[  2, 2, 1, 1 ],
			[  5, 5, 1, 1 ],
			[  8, 8, 1, 1 ],
			[  9, 9, 1, 1 ],

			'3 context, left, middle, right',
			[  1, 1, 3, 3 ],
			[  2, 2, 3, 3 ],
			[  5, 5, 3, 3 ],
			[  8, 8, 3, 3 ],
			[  9, 9, 3, 3 ],

			'0 context, w=3, left, middle, right',
			[  1, 3, 0, 0 ],
			[  2, 4, 0, 0 ],
			[  5, 7, 0, 0 ],
			[  6, 8, 0, 0 ],
			[  7, 9, 0, 0 ],

			'1 context, w=3, left, middle, right',
			[  1, 3, 1, 1 ],
			[  2, 4, 1, 1 ],
			[  5, 7, 1, 1 ],
			[  6, 8, 1, 1 ],
			[  7, 9, 1, 1 ],

			'assymetric context, w=3, left, middle, right',
			[  1, 3, 2, 1 ],
			[  2, 4, 2, 1 ],
			[  5, 7, 2, 1 ],
			[  6, 8, 2, 1 ],
			[  7, 9, 2, 1 ],

		   );


foreach my $args ( @args ) {
  if (not ref($args)) {
	print("### $args\n");
	next;
  }

  my %c = get_context_coords(length($seq),@$args);
  my $ctx = substr($seq,$c{cl}-1,$c{cw});    # susbtr is 0-based!
  my $indent = ' ' x ($c{cl}-1);

  my $ctx_hl = $ctx;
  $ctx_hl = $ctx;
  substr($ctx_hl,$c{hr}+1 ,0) = '<';
  substr($ctx_hl,$c{hl}   ,0) = '>';

  my $ctx_hl2 = context_highlight($seq,'>>','<<',@$args);

  printf( "%s | %-15s | %-20s | %-20s\n",
		  join(', ', map {sprintf("$_=%2d",$c{$_})} sort keys %c),
		  $indent . $ctx,
		  $indent . $ctx_hl,
		  $indent . $ctx_hl2,
		);
}

exit;


