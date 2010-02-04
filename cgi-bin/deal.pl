#!/usr/bin/perl -w

use CGI;

my $cgi = CGI->new;

my $haggled_collection = $cgi->param('collection');
my $haggled_piece = $cgi->param('piece');
my $haggler_email = $cgi->param('email');
my $haggler_offer = $cgi->param('offer');

#== validate email (.+@.+\..+)
#== validate offer (number)

#== if invlid param(s) return (400 or 403) error response
#print $cgi->header("text/html", "403"),
#      $cgi->start_html,
#      $cgi->p({-class=>'haggle-dialog-error'}, "Please correct the following errors before submitting your offer:"),
#      $cgi->start_ul,
#      $cgi->li({-class=>'haggle-dialog-error'}, "Invalid email address (" . $haggler_email . "). Valid email addresses have a joe\@smith.com format."),
#      $cgi->li({-class=>'haggle-dialog-error'}, "Invalid offer ammount (" . $haggler_offer . "). Valid offers need to be whole or decimal numbers."),
#      $cgi->end_ul,
#      $cgi->end_html;

#== if params valid generate email to sales@glass-print.com and return OK response

print $cgi->header("text/html", "202"),
      $cgi->start_html,
      $cgi->p({-class=>'haggle-dialog'}, "Your offer (US\$" . $haggler_offer . ") for the '" . $haggled_piece . "' piece from the '" . $haggled_collection . "' collection was submitted successfully. We will email you at " . $haggler_email . " within 24 hours. Thank you!"),
      $cgi->end_html;
