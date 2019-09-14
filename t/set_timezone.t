use Test::More;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use DateTime;
use DateTime::Format::DateParse;
use TestSchema;

#
# To run these tests, you'll need a live PostgreSQL server and a database
#
# sudo -u postgres createuser -s myusername
# createdb multi_schema_test
# export PGTIMEZONE_TEST_DSN=dbi:Pg:database=multi_schema_test
#

SKIP: {
  skip 'Set PGTIMEZONE_TEST_DSN for live database testing'
    unless $ENV{PGTIMEZONE_TEST_DSN};

  my $schema = TestSchema->connection({
    dsn => $ENV{PGTIMEZONE_TEST_DSN},
    user => undef,
    pass => undef,
    auto_commit => 1,
    raise_error => 1,
  });

  my ( $dt_utc, $dt_chicago, $dt_ny );

  ok( $schema->timezone eq 'UTC', 'Default timezone == UTC' );
  ok( $dt_utc = get_current_timestamp_as_dt($schema), "Read SQL timestamp $dt_utc" );
  ok( $schema->timezone('America/Chicago') eq 'America/Chicago', 'Set tz America/Chicago' );
  ok( $dt_chicago = get_current_timestamp_as_dt($schema), "Read SQL timestamp $dt_chicago" );
  ok( $schema->timezone('America/New_York') eq 'America/New_York', 'Set tz America/New_York' );
  ok( $dt_ny = get_current_timestamp_as_dt($schema), "Read SQL timestamp $dt_ny" );

  ok( fuzzy_compare( $dt_utc, $dt_chicago, (60*5*60)), "Check offset UTC->Chicago" );
  ok( fuzzy_compare( $dt_utc, $dt_ny, (60*4*60)), "Check offset UTC->NY" );

}; # SKIP

done_testing;

# Compare two datetime objects, check they are approx $diff_secs apart
# allowing a few seconds of slack
sub fuzzy_compare {
  my ( $dt1, $dt2, $diff_secs ) = @_;

  my $diff_min = $diff_secs - 10;
  my $diff_max = $diff_secs + 10;

  my $diff = abs( $dt1->epoch - $dt2->epoch );

  # warn "Diff: $diff\n";

  ( $diff >= $diff_min && $diff <= $diff_max ) ? 1 : 0;
}

sub get_current_timestamp_as_dt {
  my $schema = shift;

  my $ts;
  $schema->storage->dbh_do( sub {
    my ( $storage, $dbh ) = @_;
    ( $ts ) = $dbh->selectrow_array('SELECT CURRENT_TIMESTAMP;');
  });

  # warn "\$ts: $ts\n";

  # Strip timezone offset before creating datetime, to create
  # dt objects with no timezone knowledge
  $ts =~ s/[\+\-]\d\d$//;

  DateTime::Format::DateParse->parse_datetime($ts);
}

1;

