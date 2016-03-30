#!/usr/bin/perl -w

# displays the todos, with a link to wt_edit
# can also enter a new todo entry
# can also tweak filters for displaying the todos

use strict;
use CGI qw/:standard/;
require 'utilities.pl';

my %todos = ();

read_todos(\%todos);

# if they clicked "Add entry", then assign an ID, 
# write out the todos, then continue displaying.

if (param('Add entry') && 
	param('impact') =~ /^\d{1,3}$/ && param('impact') <= 100 &&
	param('urgency') =~ /^\d{1,3}$/ && param('urgency') <= 100 &&
	param('percent') =~ /^\d{1,3}$/ && param('percent') <= 100 &&
	param('notes') =~ /\w/) {

	# new ID = highest-numbered ID plus one
	my $new_id = (sort { $a <=> $b } keys %todos)[-1] + 1;

	$todos{$new_id}{'percent'} = clean_csv_string(param('percent'));
	$todos{$new_id}{'impact'} = clean_csv_string(param('impact'));
	$todos{$new_id}{'urgency'} = clean_csv_string(param('urgency'));
	$todos{$new_id}{'notes'} = scalar(localtime()) . ": ". 
		($ENV{REMOTE_USER} || "someone") . ": " .
		clean_csv_string(param('notes'));
	write_todos(\%todos);
}

print header(),
	start_html(-title => "Todo list",
		-author => 'schaller@users.sourceforge.net'),
	'<CENTER>' . h1("Jeff's Awesome Web-based Todo Program"). '</CENTER>',
	start_form();

# reset to defaults after a submission
# (otherwise, submitting a new todo leaves those values in the form)
param('percent', 0);
param('impact', 50);
param('urgency', 50);
param('notes', '');

# print the 'Add' table, "Add" button
print "Percent complete: ",
        textfield(-name => 'percent', -size => 3, -maxlength => 3),
        "Impact: ",
        textfield(-name =>  'impact', -size => 3, -maxlength => 3),
        "Urgency: ",
        textfield(-name =>  'urgency', -size => 3, -maxlength => 3),
        br(),
	"Notes: ",
	br(),
	textarea(-name => 'notes', -rows => 2, -columns => 80),
	br(),
        submit(-name => "Add entry"),
        CGI::reset("Reset"),
	br(), hr(), br();

# print the options table
# Sort by (radio) weighted pri, impact, urgency, percent
# [] Reverse sort
# [] Show completed items
# "Redisplay" button
# -- let them be sticky (don't reset), because it lets them
#    consistently filter on stuff

print table({-summary => "Display-filter table", -border => 1}, 
	Tr( [ 
		td([ "Sort by: " . radio_group(-name => 'sortby',
			-values => ['Weighted priority', 'Percent complete',
					'Impact', 'Urgency', 'Priority', 'Id' ],
                	-default => 'Weighted priority') . br() .
			checkbox(-name => 'reverse', -value => 'on',
				-label => "Reverse sort") . br() . 
			checkbox(-name => 'showall', -value => 'on',
                		-label => "Show completed items") ]),
		td([ submit(-name => "Redisplay entries") ]) 
	     ] )),
	br(), hr(), br();

# print the todos table
# (doesn't affect 'Add' because we did that before)
# if (!param(showall)), loop through todos and remove 100%'s
# if (param(sort) eq 'weighted'), @keys = sort by_weight keys %todos
# elsif eq 'pri'), @keys = sort ...

if (!param('showall')) {
	foreach (keys %todos) {
		delete $todos{$_} if $todos{$_}{'percent'} eq '100';
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

} elsif (param('sortby') eq 'Impact') {
	@keys = sort by_impact @keys;
	@keys = reverse @keys if param('reverse');

} elsif (param('sortby') eq 'Urgency') {
	@keys = sort by_urgency @keys;
	@keys = reverse @keys if param('reverse');

} elsif (param('sortby') eq 'Priority') {
	@keys = sort by_priority @keys;
	@keys = reverse @keys if param('reverse');

} elsif (param('sortby') eq 'Id') {
        @keys = sort { $a <=> $b } keys %todos;
	@keys = reverse @keys if param('reverse');
}

print scalar(@keys) . " entries displayed.<BR>\n";

print table({-summary => "Todo list", -border => 1},
		  Tr( [ th(['Id', '%', 'Impact', 'Urgency', 'Priority', 'Notes', ]),
			map { td([ a({-href => "wt_edit.pl?id=$_"}, $_), 
					$todos{$_}{'percent'},
					$todos{$_}{'impact'},
					$todos{$_}{'urgency'},
					$todos{$_}{'impact'} * $todos{$_}{'urgency'},
					$todos{$_}{'notes'},
				])
			    } @keys
			  ]));

print end_html();

# compares: percent-left times impact times urgency
sub by_weighted_p {
	my $a_pri = $todos{$a}{'impact'} * $todos{$a}{'urgency'};
	my $b_pri = $todos{$b}{'impact'} * $todos{$b}{'urgency'};
	my $a_perc = $todos{$a}{'percent'};
	my $b_perc = $todos{$b}{'percent'};

	(100 - $b_perc) * $b_pri
		<=>
	(100 - $a_perc) * $a_pri;
}

sub by_complete {
	$todos{$b}{'percent'} <=> $todos{$a}{'percent'};
}

sub by_impact {
	$todos{$b}{'impact'} <=> $todos{$a}{'impact'};
}

sub by_urgency {
	$todos{$b}{'urgency'} <=> $todos{$a}{'urgency'};
}

# compares: impact * urgency
sub by_priority {
	($todos{$b}{'impact'} * $todos{$b}{'urgency'}) 
		<=> 
	($todos{$a}{'impact'} * $todos{$a}{'urgency'}) ;
}
