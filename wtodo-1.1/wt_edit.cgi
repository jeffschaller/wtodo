#!/usr/bin/perl -w

# takes an 'id' parameter which says which entry to edit
# can update %, pri, who, when
# can add a log/desc entry (which gets timestamped & 
# your ID (REMOTE_USER) added)

# Submit -> update entry, go back to main page (wt_display.cgi)
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
		a({href => "wt_display.cgi"},
			"Try again."),
		end_html();
	exit 0;
}

read_todos(\%todos);

# decide if we're being asked to edit one XOR they hit 'submit'

if (param('Submit')) {
	# update the info in csv, run wt_display.cgi

	# sanity-check perc & pri
	my $perc = param('perc');
	my $pri = param('pri');
	my $oldperc = $todos{$id}[0];
	my $oldpri = $todos{$id}[1];

	if ($perc =~ /^\d{1,3}$/ && $perc <= 100) {
		$todos{$id}[0] = clean_csv_string($perc);
	}
	if ($pri =~ /^\d{1,3}$/ && $pri <= 100) {
		$todos{$id}[1] = clean_csv_string($pri);
	}

	if (param('perc') != $oldperc) {
		$todos{$id}[2] .= '<BR>' . scalar(localtime) . ": " .
		($ENV{'REMOTE_USER'} || 'someone') . 
		" updated percent-complete from $oldperc to $todos{$id}[0]";
	}

	if (param('pri') != $oldpri) {
		$todos{$id}[2] .= '<BR>' . scalar(localtime) . ": " .
		($ENV{'REMOTE_USER'} || 'someone') .
		" updated priority from $oldpri to $todos{$id}[1]";
	}

	# see if we need to update 'desc'
	if (param('moredesc') =~ /\w/) {
		$todos{$id}[2] .= '<BR>' .
			scalar(localtime) . ": " .
			($ENV{'REMOTE_USER'} || 'someone') . ": " .
			param('moredesc');
	}

	$todos{$id}[2] = clean_csv_string($todos{$id}[2]);
	$todos{$id}[3] = clean_csv_string(param('who'));
	$todos{$id}[4] = clean_csv_string(param('when'));

	write_todos(\%todos);

	# use full path for safety
	# print redirect(-uri => 'wt_display.cgi',);
	print "Location: http://nc.gcintranet.net/cgi-bin/" .
	      "wtodo/wt_display.cgi\n\n";
} else {

  print 
	header(),
	start_html(-title => 'Edit EIS todo entry',
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
	a({href => "wt_display.cgi"},
		"Forget this, take me back to the list!"),
	end_html();
}
