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

my $collection = trim($cgi->param('collection'));
my $piece      = trim($cgi->param('piece'));
my $email      = trim($cgi->param('email'));

if ($email =~ /^.+@.+\..+$/) {
  my $dm = join("|", "find", $collection, $piece, $email);
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
        $cgi->p({-class=>'haggle-dialog'}, "Thank you for your interest in the '" . $piece . "' piece from the '" . $collection . "' collection. We will do our magic to obtain it for you and will email you with more details at " . $email . " within 24 hours."),
        $cgi->end_html;
}
else {
  print $cgi->header("text/html", "403"),
        $cgi->start_html,
        $cgi->p({-class=>'haggle-dialog-error'}, "Please correct the following error before sending your request:"),
        $cgi->start_ul,
        $cgi->li({-class=>'haggle-dialog-error'}, "Invalid email address (" . $email . "). Valid email addresses have a joe\@smith.com format."),
        $cgi->end_ul,
        $cgi->end_html;
}
