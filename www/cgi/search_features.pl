#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::Exceptions;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;

sub _search_category_urls();

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

try {

    my $js = <<EOJS;
<script type="text/javascript" language="javascript">
var all_features = '';
var global_q = '';
function update_emb_search_form(feature,crit) {
var emb_form = document.getElementById('emb_search_form');
var emb_query = document.getElementById('emb_search_query');
if (emb_form) {
  if (typeof crit != "undefined")
     global_q = global_q + ':' + crit ;
  if(crit == "reset")
     global_q = '';
  var emb_url = 'emb_search_form.pl?';
  emb_url += 'feature='+feature;
  emb_url += ';global_q='+global_q;
  emb_form.setAttribute('src', emb_url);
}
if (emb_query) {
  var re = new RegExp("=no\$");
  if (typeof crit != "undefined") {
      if (!re.test(crit))
        all_features = all_features + ':'+ feature;
  }
  if(crit == "reset") {
     all_features = '';
     global_q = '';
  }
  var emb_url = 'emb_search_query.pl?';
  emb_url += 'features='+all_features;
  emb_url += ';global_q='+global_q;
  emb_query.setAttribute('src', emb_url);
}
}
</script>
EOJS

    print $p->render(
        "Search by Sequence Features",
        $js,
        '<p>',
        '<div align="left">',
'<iframe frameborder="0" src="emb_search_category.pl" width="25%" height="550"></iframe>',
'<iframe frameborder="0" src="emb_search_form.pl" width="75%" height="550" id="emb_search_form"></iframe>',
'<iframe frameborder="0" src="emb_search_query.pl" width="100%" height="300" id="emb_search_query"></iframe>',
        '</div>',
    );
}
catch Unison::Exception with {
    $p->die(shift);
};
exit(0);

