#!/usr/bin/perl -w

use strict;
use diagnostics;

use CGI;
use CGI::Carp;

sub trim {
  my $s = shift;
  $s =~ s/^\s+//;
  $s =~ s/\s+$//;
  return $s;
}

my $cgi = CGI->new;

my $haggled_collection = trim($cgi->param('collection'));
my $haggled_piece      = trim($cgi->param('piece'));
my $haggler_email      = trim($cgi->param('email'));
my $haggler_offer      = trim($cgi->param('offer'));

my $email_valid = 0;
if ($haggler_email =~ /^.+@.+\..+$/) {
  $email_valid = 1;
}

my $offer_valid = 0;
if ($haggler_offer =~ /^(?:\d+(?:\.\d*)?|\.\d+)$/) {
  $offer_valid = 1;
}

if ($email_valid && $offer_valid) {
  my $dm = join("|", $haggled_collection, $haggled_piece, $haggler_email, $haggler_offer);
  my $dm_response = `curl --write-out \"response-code=%{http_code}\" -X POST http://twitter.com/direct_messages/new.xml -u glassprintdeals:fooobaar -duser=glassprint -dtext=\"$dm\"`;
  if ($dm_response =~ /response-code=(.+)/) {
    if (200 != $1) {
      carp "DM=$dm; response=$dm_response";
    }
  }
  else {
    carp "DM=$dm; response=$dm_response";
  }

  print $cgi->header("text/html", "202"),
        $cgi->start_html,
        $cgi->p({-class=>'haggle-dialog'}, "Your offer (US\$" . $haggler_offer . ") for the '" . $haggled_piece . "' piece from the '" . $haggled_collection . "' collection was submitted successfully. We will email you at " . $haggler_email . " within 24 hours. Thank you!"),
        $cgi->end_html;
}
else {
  print $cgi->header("text/html", "403"),
        $cgi->start_html,
        $cgi->p({-class=>'haggle-dialog-error'}, "Please correct the following errors before re-submitting your offer:"),
        $cgi->start_ul;
  if (!$email_valid) {
    print $cgi->li({-class=>'haggle-dialog-error'}, "Invalid email address (" . $haggler_email . "). Valid email addresses have a joe\@smith.com format.");
  }
  if (!$offer_valid) {
    print $cgi->li({-class=>'haggle-dialog-error'}, "Invalid offer ammount (" . $haggler_offer . "). Valid offers need to be whole or decimal numbers.");
  }
  print $cgi->end_ul,
        $cgi->end_html;
}
