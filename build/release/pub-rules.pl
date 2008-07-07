# $Id$

# the publicize script infers most "copy queries" automatically, but it
# needs a little help in certain circumstances. This file contains
# those exceptions.



%schemas = map { $_ => 1 }
  qw( pgutils  go gong marray ncbi pdb scop sst tax unison unison_aux );

%ignore_tables = map { $_ => 1 }
  qw(
	  unison.p2gblataln
	  unison.p2gblatalnhsp
	  unison.p2gblathsp
	  unison.paprospect
	  unison.gg_famid_pseq_id_mv
	  unison.pmprospect_scop_mv
	  unison.known_bcl2_overlaps_mv
   );

%custom_table_predicates = (
    'unison.origin' => ['is_public = TRUE'],
    'unison.params' => ['is_public = TRUE'],
    #'unison.pseq' 	=> ['pseq_id < 1000'  ], ## testing
);


%custom_copy_queries = (
    # The ER diagram looks like:
    #   origin <-- pannotation <-- pseq_pannotation --> pseq <-- predictions

	# We need to restrict pseq rows to only those that occur in at least
    # one public origin.  The is public is implied by the pseq_annotation
    # copy query, which eventually depends on the origin predicate above.
    'unison.pseq' => sub {
        my $qq  = $tables{'unison.pseq'}->pred_query();
        my $qacq = $tables{'unison.pseq_pannotation'}->copy_query();
        $qq  =~ s/\n/ /g;
        $qacq =~ s/\n/ /g;
        return (  "SELECT Q.* FROM ($qq) Q \n"
                . "JOIN (SELECT DISTINCT pseq_id FROM ($qacq) X) QACQ ON Q.pseq_id = QACQ.pseq_id"
        );
    },

    # pftype(preferred_params_id) is a nullable FK to params(params_id). We
    # DO NOT want to restrict pftype by this FK, and override it here:
    'unison.pftype' => 'SELECT * FROM unison.pftype',

    # don't restrict unison.params by anything other than its own predicates
    # This allows rows in params for non-public params, but results won't appear
    # in public releases.
    'unison.params' => sub { $tables{'unison.params'}->pred_query() },
);
