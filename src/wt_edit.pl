#!/usr/bin/perl -w

# takes an 'id' parameter which says which entry to edit
# can update %, pri, who, when
# can add a log/desc entry (which gets timestamped & 
# your ID (REMOTE_USER) added)

# Submit -> update entry, go back to main page (wt_display)
# Reset -> reset()

use strict;
use CGI qw/:standard/;
require 'utilities.pl';

my %todos = ();
my $id = param('id');

if (! $id ) {
	print 
		header(),
		start_html('Error!'),
		a({href => "wt_display.pl"},
			"Try again."),
		end_html();
	exit 0;
}

read_todos(\%todos);

# decide if we're being asked to edit one XOR they hit 'submit'

if (param('Submit')) {
	# update the info in csv, run wt_display

	# sanity-check perc & pri
	my $perc = param('perc');
	my $pri = param('pri');
	my $oldperc = $todos{$id}[0];
	my $oldpri = $todos{$id}[1];
	my $who = $ENV{'REMOTE_USER'} || "someone at " . $ENV{'REMOTE_IP'};

	if ($perc =~ /^\d{1,3}$/ && $perc <= 100) {
		$todos{$id}[0] = clean_csv_string($perc);
	}
	if ($pri =~ /^\d{1,3}$/ && $pri <= 100) {
		$todos{$id}[1] = clean_csv_string($pri);
	}

	if (param('perc') != $oldperc) {
		$todos{$id}[2] .= '<BR>' . scalar(localtime) . ": " .
		"$who updated percent-complete from $oldperc to $todos{$id}[0]";
	}

	if (param('pri') != $oldpri) {
		$todos{$id}[2] .= '<BR>' . scalar(localtime) . ": " .
		"$who updated priority from $oldpri to $todos{$id}[1]";
	}

	# see if we need to update 'desc'
	if (param('moredesc') =~ /\w/) {
		$todos{$id}[2] .= '<BR>' .
			scalar(localtime) . ": $who: " . param('moredesc');
	}

	$todos{$id}[2] = clean_csv_string($todos{$id}[2]);
	$todos{$id}[3] = clean_csv_string(param('who'));
	$todos{$id}[4] = clean_csv_string(param('when'));

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
	textfield(-name => 'perc', -size => 3, -maxlength => 3,
			-default => $todos{$id}[0]),
	"Priority: ",
	textfield(-name => 'pri', -size => 3, -maxlength => 3,
			-default => $todos{$id}[1]),
	br(),
	"Previous description:",
	br(),
	blockquote($todos{$id}[2]),
	p(),
	"Additional description: ",
	br(),
	textarea(-name => 'moredesc', -rows => 10, -columns => 80),
	br(),
	"Who: ",
	textfield(-name => 'who', -default => $todos{$id}[3],
		-size => 20, -maxlength => 30),
	"When: ",
	textfield(-name => 'when', -default => $todos{$id}[4],
		-size => 12, -maxlength => 12),
	br(),
	submit(-name => "Submit"),
	CGI::reset("Reset values"),
	end_form(),
	a({href => "wt_display.pl"},
		"Forget this, take me back to the list!"),
	end_html();
}
