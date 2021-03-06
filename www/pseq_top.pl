#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page qw(skip_db_connect);
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
