# $Id$

# the publicize script infers most "copy queries" automatically, but it
# needs a little help in certain circumstances. This file contains
# those exceptions.

%custom_table_predicates = (
    'unison.origin' => ['is_public = TRUE'],
    'unison.params' => ['is_public = TRUE'],

    #   'unison.pseq' 	=> [ 'pseq_id < 1000'   ], ## testing
);

%custom_copy_queries = (

    # The ER diagram looks like:
    #   origin <-- paliasorigin <-- pseqalias --> pseq

    # restrict pseq rows to only those that occur in at least one public
    # origin:
    'unison.pseq' => sub {
        my $qq  = $tables{'unison.pseq'}->pred_query();
        my $saq = $tables{'unison.pseqalias'}->copy_query();
        $qq  =~ s/\n/ /g;
        $saq =~ s/\n/ /g;
        return (  "SELECT Q.* FROM ($qq) Q \n"
                . "JOIN (SELECT DISTINCT pseq_id FROM ($saq) X) SACQ ON Q.pseq_id = SACQ.pseq_id"
        );
    },

    # pftype(preferred_params_id) is a nullable FK to params(params_id). We
    # DO NOT want to restrict pftype by this FK, and override it here:
    'unison.pftype' => 'SELECT * FROM unison.pftype',

    # don't restrict unison.params by anything other than its own predicates
    'unison.params' => sub { $tables{'unison.params'}->pred_query() },
);

