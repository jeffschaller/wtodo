#!/usr/bin/perl -w
use strict;

# converts wtodo-1.6 CSV file to wtodo-1.7 format
# since 1.6 only had a "priority" field where 1.7 has split
# that into "urgency" and "impact", we just square the old priority field
# to get the new urgency & impact values

# Usage: $0 < old16.todos > new17.todos

use Text::CSV;

my %todos = ();

while (<>) {
	my $csv = Text::CSV->new();
	chomp;
	$csv->parse($_);
	my @columns = $csv->fields();
	my $id = shift @columns;
	$todos{$id}{'percent'} = shift @columns;
	my $oldpri = shift @columns;
	$todos{$id}{'impact'} = $oldpri;
	$todos{$id}{'urgency'} = $oldpri;
	$todos{$id}{'notes'} = shift @columns;
}

foreach my $id (keys %todos) {
	my $csv = Text::CSV->new();
	$csv->combine($id, ($todos{$id}{'percent'},
			    $todos{$id}{'impact'},
			    $todos{$id}{'urgency'},
			    $todos{$id}{'notes'},
			  ));
	print $csv->string() . "\n";
}
