# This package merely provides syntactic sugar to distinguish exception
# throwers andproviders from exception catchers.  See Exception.pm.

# If you want to catch exceptions, do:
#   use CBT::Exceptions;

# If you want to subclass CBT::Exception, do:
#   use base 'CBT::Exception';

# If you want to throw Some::Exception, do:
#   use Some::Exception;
#   ...
#   throw Some::Exception;

use Error qw(:try);
1;
