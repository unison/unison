package MyModule::Exception;
use base CBT::Exception;
# This just illustrates that one can subclass Exception to define additional
# behavior.



package MyModule;
sub think
  {
  my $s = shift;
  print(STDERR "thinking with s=$s...\n");

  if ($s==0)
	{ print(STDERR "I can think, apparently\n"); return; }

  throw MyModule::Exception( { error => '% exception iv from hash',
								  detail => "you provided \$s=$s",
								  advice => 'soak your head' } ) if $s == 1;

  throw MyModule::Exception( '@ exception iv from array',
								"you provided \$s=$s",
								'soak your head' ) if $s == 2;

  throw MyModule::Exception( { error => 'wrapping test',
								  detail => "you provided \$s=$s, and I'm "
								            ."giving a lot lot lot lot of detail",
								  advice => 'this is a really long suggestion '
								            . 'for you to go soak your head perhaps '
								            . 'after first slamming your head against '
								            . 'the nearest metal door frame' } )  if $s == 3;

  throw MyModule::Exception( '@ problem thinking, without advice',
								'this is the detail' ) if $s==4;

  throw MyModule::Exception( { detail => 'exception wo/error string' } ) if $s == 5;

  if ($s==6)
	{
	my $fn = '/BOGUSFILENAME';
	open(F,"<$fn")
	  or throw MyModule::Exception ( "couldn't open $fn" );
	}


  throw MyModule::Exception( "a real problem... argument $s unrecognized" );

  return;
  }

1;
