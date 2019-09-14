package DBIx::Class::Schema::PgSetTimezone;
use base qw/DBIx::Class::Schema/;
use strict;
use warnings;

=head1 NAME

DBIx::Class::Schema::PgSetTimezone

=head1 SYNOPSIS

  # Define your Schema class
  package MyApp::Schema;
  use base qw/DBIx::Class::Schema::PgSetTimezone/;
  
  __PACKAGE__->load_classes(qw/Arthur Ford Zaphod/);

  # Initialize the schema
  # (Only hashref connect_info style supported)
  $schema = MyApp::Schema->connection({
    dsn => 'dbi:Pg:database=myapp',
    user => undef,
    pass => undef,
    auto_commit => 1,
    raise_error => 1,
  )};
  
  # Set time zone for the connection. SQL will be executed immediately,
  # and on any further connect/reconnects
  $schema->timezone('America/Chicago');

=head1 DESCRIPTION

Component for L<DBIx::Class::Schema>

Set the connection time_zone in a way that persists within connection
managers like DBIx::Connection and Catalyst::Model::DBIC::Schema

=head1 About Schema->connection() parameters

Schema->connection() supports several formats of parameter list

This module only supports a hashref parameter list, as in the synopsis

=cut

our $VERSION = '0.1';
use Carp qw( croak );

__PACKAGE__->mk_group_accessors( inherited => (qw/ __timezone /));
#__PACKAGE__->mk_classdata('__timezone');
__PACKAGE__->__timezone('UTC');

=head1 METHODS

=head2 timezone TIME_ZONE

Read or set the time zone string

=cut

sub timezone {
  my ( $self, $timezone ) = @_;

  if ( $timezone ) {
    $self->__timezone( $timezone );
    __dbh_do_set_timezone( $self->storage, $timezone );
  }

  $timezone || $self->__timezone;
}

=head1 METHODS Overload

=head2 connection %connect_info

Overload L<DBIx::Class::Schema/connection>

Inserts a callback into L<DBIx::Class::Storage::DBI/on_connect_call>

Use of this module requires using only the hashref style of
connect_info arguments. Other connect_info formats are not
supported.  See L<DBIx::Class::Storage::DBI/connect_info>

=cut

sub connection {
  my ( $self, @args ) = @_;

  my %conn = %{$args[0]};

  die 'DBIx::Class::Schema::PgTimezone only supports hashref '
    . 'style connection() argument list'
      unless $conn{dsn};

  my $callback_sub = sub {
    # my ( $storage ) = @_;
    __dbh_do_set_timezone( $_[0], $self->timezone );
  };

  # Add an on_connect_call callback
  if ( exists $conn{on_connect_call} ) {
    my $occ = $conn{on_connect_call};

    if ( ref $occ eq 'ARRAY' ) {
      push @$occ, $callback_sub;
    } else {
      $conn{on_connect_call} = [ $occ, $callback_sub ];
    }
  } else {
    $conn{on_connect_call} = [ $callback_sub ];
  }

  return $self->next::method( \%conn );
}

=head1 INTERNAL SUBS

=head2 __dbh_do_set_timezone $storage, $timezone

Execute sql statement to set session time zone

=cut

sub __dbh_do_set_timezone {
  my ( $storage, $timezone ) = @_;

  # Other code interacting with $storage->timezone may decide to set
  # the timezone value before a connection has been established
  return unless $storage;

  $storage->dbh_do( sub {
    # my ( $storage, dbh ) = @_;
    $_[1]->do('SET session time zone ?', undef, $timezone || 'UTC');
  });
}

=head1 SEE ALSO

L<DBIx::Class::Schema>, L<DBIx::Connection>, L<Catalyst::Model::DBIC::Schema>

=head1 COPYRIGHT

(c) 2019 Mitch Jackson <mitch@mitchjacksontech.com> under the perl5 license

=cut

1;
