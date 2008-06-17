#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
    "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::utilities qw(render_app_list);
use Unison::WWW::PageInfo;

my $p = new Unison::WWW::Page;

print $p->render(
				 'Analysis Tools',
				 render_app_list(
								 $p->is_prd_instance(),
								 $p->is_public_instance(),
								 @Unison::WWW::PageInfo::analyze_info
								)
				);

exit(0);
