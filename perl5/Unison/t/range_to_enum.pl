#!/usr/bin/env perl

use Unison::Utilities::misc;

print("This should print 1,2,3,4,5,6,7,8,9,10: \n");
print("result: ",
	  join(",",Unison::range_to_enum("1..3","4,5,6..10")), "\n" );

