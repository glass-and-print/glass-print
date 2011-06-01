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
  my $content = join("|", $haggled_collection, $haggled_piece, $haggler_email, $haggler_offer) . ".";

  open(DEALS, ">>/tmp/deals.txt");
  print DEALS "$content\n";
  close(DEALS);

  my $smos = open(SENDMAIL, "|/usr/bin/env sendmail -t");
  if ($smos) {
    print SENDMAIL "From: $haggler_email\n";
    print SENDMAIL "Reply-to: $haggler_email\n";
    print SENDMAIL "Subject: make-a-deal\n";
    print SENDMAIL "To: glassprintdeals\@gmail.com\n";
    print SENDMAIL "Content-type: text/plain\n\n";
    print SENDMAIL "$content";
    close(SENDMAIL);

    print $cgi->header("text/html", "202"),
          $cgi->start_html,
          $cgi->p({-class=>'haggle-dialog'}, "Your offer (US\$" . $haggler_offer . ") for the '" . $haggled_piece . "' piece from the '" . $haggled_collection . "' collection was submitted successfully. We will email you at " . $haggler_email . " within 24 hours. Thank you!"),
          $cgi->end_html;
  }
  else {
    carp "couldn't open sendmail to notify about offer: $content";

    print $cgi->header("text/html", "503"),
          $cgi->start_html,
          $cgi->p({-class=>'haggle-dialog-error'}, "Your offer (US\$" . $haggler_offer . ") for the '" . $haggled_piece . "' piece from the '" . $haggled_collection . "' collection could not be submitted. We are very sorry for the inconvienece. Please email us directly at sales\@glass-print.com."),
          $cgi->end_html;
  }
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
