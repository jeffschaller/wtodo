#!/usr/bin/perl -w

# takes an 'id' parameter which says which entry to edit
# can update percent-complete, impact, urgency and/or add notes

use strict;
use CGI qw/:standard/;
require 'utilities.pl';

my %todos = ();
my $id = param('id');

if (! $id ) {
	print   header(), start_html('Error!'),
		a({href => "wt_display.pl"},
			"Try again."),
		end_html();
	exit 0;
}

read_todos(\%todos);

# decide if we're being asked to edit one XOR they hit 'submit'

if (param('Submit')) {
	# update the info in csv, run wt_display

	# sanity-check perc, impact, urgency
	my $perc = param('percent');
	my $impact = param('impact');
	my $urgency = param('urgency');
	my $oldperc = $todos{$id}{'percent'};
	my $oldimpact = $todos{$id}{'impact'};
	my $oldurgency = $todos{$id}{'urgency'};
	my $who = $ENV{'REMOTE_USER'} || "someone at " . $ENV{'REMOTE_ADDR'};

	if ($perc =~ /^\d{1,3}$/ && $perc <= 100) {
		$todos{$id}{'percent'} = clean_csv_string($perc);
	}
	if ($impact =~ /^\d{1,3}$/ && $impact <= 100) {
		$todos{$id}{'impact'} = clean_csv_string($impact);
	}

	if ($urgency =~ /^\d{1,3}$/ && $urgency <= 100) {
		$todos{$id}{'urgency'} = clean_csv_string($urgency);
	}

	if ($perc != $oldperc) {
		$todos{$id}{'notes'} .= '<BR>' . scalar(localtime) . ": " .
		"$who updated percent-complete from $oldperc to $todos{$id}{'percent'}";
	}

	if (param('impact') != $oldimpact) {
		$todos{$id}{'notes'} .= '<BR>' . scalar(localtime) . ": " .
		"$who updated impact from $oldimpact to $todos{$id}{'impact'}";
	}

	if (param('urgency') != $oldurgency) {
		$todos{$id}{'notes'} .= '<BR>' . scalar(localtime) . ": " .
		"$who updated urgency from $oldurgency to $todos{$id}{'urgency'}";
	}
	# see if we need to update the notes
	if (param('morenotes') =~ /\w/) {
		$todos{$id}{'notes'} .= '<BR>' .
			scalar(localtime) . ": $who: " . param('morenotes');
	}

	$todos{$id}{'notes'} = clean_csv_string($todos{$id}{'notes'});

	write_todos(\%todos);

	my $full_url = url(-full => 1);
	$full_url =~ s#/[^/]+$##;
	print redirect(-uri => "${full_url}/wt_display.pl");
} else {

  print 
	header(),
	start_html(-title => 'Edit todo entry',
		   -author => 'schaller@users.sourceforge.net'),
	'<CENTER>' . h1("Jeff's Awesome Web-based Todo Program"). '</CENTER>',
	start_form(),
	hidden(-name => 'id', -default => $id),
	"Percent complete: ",
	textfield(-name => 'percent', -size => 3, -maxlength => 3,
			-default => $todos{$id}{'percent'}),
	"Impact: ",
	textfield(-name => 'impact', -size => 3, -maxlength => 3,
			-default => $todos{$id}{'impact'}),
	"Urgency: ",
	textfield(-name => 'urgency', -size => 3, -maxlength => 3,
			-default => $todos{$id}{'urgency'}),
	"Priority: " . $todos{$id}{'impact'} * $todos{$id}{'urgency'},
	br(),
	"Previous notes:",
	br(),
	blockquote($todos{$id}{'notes'}),
	p(),
	"Additional notes: ",
	br(),
	textarea(-name => 'morenotes', -rows => 10, -columns => 80),
	br(),
	submit(-name => "Submit"),
	end_form(),
	a({href => "wt_display.pl"},
		"Forget this, take me back to the list!"),
	end_html();
}
