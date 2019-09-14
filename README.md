# NAME

DBIx::Class::Schema::PgSetTimezone

# SYNOPSIS

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

# DESCRIPTION

Component for [DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema)

Set the connection time\_zone in a way that persists within connection
managers like DBIx::Connection and Catalyst::Model::DBIC::Schema

# About Schema->connection() parameters

Schema->connection() supports several formats of parameter list

This module only supports a hashref parameter list, as in the synopsis

# METHODS

## timezone TIME\_ZONE

Read or set the time zone string

# METHODS Overload

## connection %connect\_info

Overload ["connection" in DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema#connection)

Inserts a callback into ["on\_connect\_call" in DBIx::Class::Storage::DBI](https://metacpan.org/pod/DBIx::Class::Storage::DBI#on_connect_call)

Use of this module requires using only the hashref style of
connect\_info arguments. Other connect\_info formats are not
supported.  See ["connect\_info" in DBIx::Class::Storage::DBI](https://metacpan.org/pod/DBIx::Class::Storage::DBI#connect_info)

# INTERNAL SUBS

## \_\_dbh\_do\_set\_timezone $storage, $timezone

Execute sql statement to set session time zone

# SEE ALSO

[DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema), [DBIx::Connection](https://metacpan.org/pod/DBIx::Connection), [Catalyst::Model::DBIC::Schema](https://metacpan.org/pod/Catalyst::Model::DBIC::Schema)

# COPYRIGHT

(c) 2019 Mitch Jackson <mitch@mitchjacksontech.com> under the perl5 license
