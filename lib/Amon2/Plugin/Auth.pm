package Amon2::Plugin::Auth;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use Class::Method::Modifiers qw(install_modifier);
use Amon2::Plugin::Auth::Site::Github;
use Amon2::Plugin::Auth::Site::Twitter;
use Amon2::Plugin::Auth::Site::Facebook;

sub init {
    my ($class, $c, $code_conf) = @_;

    my $mount_point = $code_conf->{mount} || '/auth';
    my $path = qr{^\Q$mount_point\E/?(github|facebook|twitter)/(authenticate|callback)$};

    $code_conf->{on_finished} or die "Missing mandatory parameter: on_finished";
    $code_conf->{on_error} or die "Missing mandatory parameter: on_error";

    install_modifier($c, 'around', "dispatch", sub {
        my ($orig, $c) = @_;
        my $path_info = $c->req->path_info;
        warn $path_info;
        if ($path_info =~ $path) {
            my ($site, $method) = ($1, $2);
            my $conf = $c->config->{'auth'}->{$site} || die "Missing configuration for auth.${site}";
            if ($site eq 'github') {
                return Amon2::Plugin::Auth::Site::Github->$2($c, $conf, $code_conf);
            } elsif ($site eq 'twitter') {
                return Amon2::Plugin::Auth::Site::Twitter->$2($c, $conf, $code_conf);
            } elsif ($site eq 'facebook') {
                return Amon2::Plugin::Auth::Site::Facebook->$2($c, $conf, $code_conf);
            } else {
                die "Unknown site: $site";
            }
        } else {
            return $orig->($c);
        }
    });
}

1;
__END__

=encoding utf8

=head1 NAME

Amon2::Plugin::Auth -

=head1 SYNOPSIS

  use Amon2::Plugin::Auth;

=head1 DESCRIPTION

Amon2::Plugin::Auth is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
