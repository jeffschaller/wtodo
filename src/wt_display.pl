#!/usr/bin/perl -w

# displays the todos, with a link to wt_edit
# can also enter a new todo entry
# can also tweak filters for displaying the todos

use strict;
use CGI qw/:standard/;
require 'utilities.pl';

my %todos = ();

read_todos(\%todos);

# if they clicked "Add entry" ...
# assign an ID, write out the todos, then continue displaying
# sanity-check the data:
# priority and percent-complete must be 1 to 3 digits and <= 100
# description has to have /something/

if (param('Add entry') && 
	param('pri') =~ /^\d{1,3}$/ && param('pri') <= 100 &&
	param('perc') =~ /^\d{1,3}$/ && param('perc') <= 100 &&
	param('desc') =~ /\w/) {

	# take highest-numbered ID and add one
	my $new_id = (sort { $a+0 <=> $b+0 } keys %todos)[-1] + 1;

	$todos{$new_id} = [ 	clean_csv_string(param('perc')),
				clean_csv_string(param('pri')),
				scalar(localtime()) . ": " .
				$ENV{REMOTE_USER} . ": " .
				clean_csv_string(param('desc')),
				clean_csv_string(param('who')  || "&nbsp;"),
				clean_csv_string(param('when') || "&nbsp;") ];
	write_todos(\%todos);
}

print header(),
	start_html(-title => "Todo list",
		-author => 'schaller@users.sourceforge.net'),
	'<CENTER>' . h1("Jeff's Awesome Web-based Todo Program"). '</CENTER>',
	start_form();

# reset to defaults after a submission
# (otherwise, submitting a new todo leaves those values in the form)
param('perc', 0);
param('pri', 50);
param('desc', '');
param('who', '');
param('when', '');

# print the 'Add' table, "Add" button
print "Percent complete: ",
        textfield(-name => 'perc', -size => 3, -maxlength => 3),
        "Priority: ",
        textfield(-name =>  'pri', -size => 3, -maxlength => 3),
        "Who: ",
        textfield(-name => 'who', -size => 20, -maxlength => 30),
        "When: ",
        textfield(-name => 'when', -size => 12, -maxlength => 12),

        br(),
	"Description: ",
	br(),
	textarea(-name => 'desc', -rows => 2, -columns => 80),
	br(),
        submit(-name => "Add entry"),
        CGI::reset("Reset"),
	br(), hr(), br();

# print the options table
# Sort by (radio) weighted pri, pri, perc
# [] Reverse sort
# [] Show completed items
# "Who" must contain: (textfield)
# "Redisplay" button
# -- let them be sticky (don't reset), because it lets them
#    consistently filter on stuff

print table({-summary => "Display-filter table", -border => 1}, Tr( [ 
		td([ "Sort by: " . radio_group(-name => 'sortby',
			-values => ['Weighted priority', 'Percent complete',
					'Priority'],
                	-default => 'Weighted priority') . br() .
			checkbox(-name => 'reverse', -value => 'on',
				-label => "Reverse sort"),
		    '"Who" field must contain: ' .
			textfield(-name => 'whofilter', -size => 12,
				-maxlength => 12)]),
		td([ submit(-name => "Redisplay entries"),
			checkbox(-name => 'showall', -value => 'on',
                		-label => "Show completed items")
		     ]) ] )),
	br(), hr(), br();


# print the todos table
# if (param(whofilter)), loop through todos and remove non-matches
# (doesn't affect 'Add' because we did that before)
# if (!param(showall)), loop through todos and remove 100%'s
# if (param(sort) eq 'weighted'), @keys = sort by_weight keys %todos
# elsif eq 'pri'), @keys = sort ...

if (my $whof = param('whofilter')) {
	foreach (keys %todos) {
		delete $todos{$_} unless ($todos{$_}[3] =~ /$whof/oi);
	}
}

if (!param('showall')) {
	foreach (keys %todos) {
		delete $todos{$_} if $todos{$_}[0] eq '100';
	}
}

if (!param('sortby')) {
	param('sortby', 'Weighted priority');
}

my @keys = keys %todos;

if (param('sortby') eq 'Weighted priority') {
	@keys = sort by_weighted_p @keys;
	@keys = reverse @keys if param('reverse');

} elsif (param('sortby') eq 'Percent complete') {
	@keys = sort by_complete @keys;
	@keys = reverse @keys if param('reverse');

} elsif (param('sortby') eq 'Priority') {
	@keys = sort by_priority @keys;
	@keys = reverse @keys if param('reverse');
}

print scalar(@keys) . " entries displayed.<BR>\n";

print table({-summary => "Todo list", -border => 1},
		  Tr( [ th(['Id', '%', 'Pri', 'Description', 'Who', 'When']),
			map { td([ a({-href => "wt_edit.pl?id=$_"}, $_), @{$todos{$_}} ])
			    } @keys
			  ]));

print end_html();

sub by_weighted_p {
	my ($a_perc, $b_perc, $a_pri, $b_pri) =
		($todos{$a}[0], $todos{$b}[0], $todos{$a}[1], $todos{$b}[1]);

	(100 - $b_perc) * $b_pri
		<=>
	(100 - $a_perc) * $a_pri;
}

sub by_complete {
	$todos{$b}[0] <=> $todos{$a}[0];
}

sub by_priority {
	$todos{$b}[1] <=> $todos{$a}[1];
}
