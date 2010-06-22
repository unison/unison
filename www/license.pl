#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('License', <<EOBODY);

<h1>License</h1>

Source code, documentation, configuration, and other primary source files
are released under the Apache License 2.0.

<pre style="background: #ddd; margin: 10px 50px 10px 50px; padding: 5px;">
Unison Protein Database &mdash; http://unison-db.org/

Copyright 2009 Reece Hart
Copyright 2002-2008 Reece Hart, Genentech, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>


Any content not covered by the Apache License above is released under the 
Creative Commons License 3.0.

<div style="background: #ddd; margin: 10px 50px 10px 50px; padding: 5px;">
   <a rel="license" href="http://creativecommons.org/licenses/by/3.0/"><img
   alt="Creative Commons License" style="border-width:0"
   src="http://i.creativecommons.org/l/by/3.0/88x31.png" /></a><br />This
   work is licensed under a <a rel="license"
   href="http://creativecommons.org/licenses/by/3.0/">Creative Commons
   Attribution 3.0 Unported License</a>.
</div>


<p>Source data are distributed pursuant to their respective
licenses.
EOBODY


