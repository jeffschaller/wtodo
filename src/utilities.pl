# This is the path to the "todo" file; it should be writable by
# the web server userid. The program won't run until you change 
# the 'undef' in the line below!

my $TODO_FILE = undef;
# my $TODO_FILE = '/home/schaller/todos/todo.csv';
die "Edit utilites.pl and set a TODO_FILE location" unless $TODO_FILE;

use strict;
use Text::CSV;
use Fcntl qw(:DEFAULT :flock);

sub read_todos {
	my $hash_ref = shift;

	# make sure file exists
	unless (open F, "<$TODO_FILE") {
		open F, ">$TODO_FILE" or
			die "can't create todo file: $TODO_FILE: $!";
		close F;
	}

	open F, "<$TODO_FILE" or
		die "unable to open todo file: $TODO_FILE: $!";
	flock(F, LOCK_SH);
	while (<F>) {
		my $csv = Text::CSV->new();

		chomp;
		$csv->parse($_);
		my @columns = $csv->fields();
		my $id = shift @columns;
		$hash_ref->{$id} = [ @columns ];
	}
	close F;
	flock(F, LOCK_UN);
}


sub write_todos {
	my $hash_ref = shift;
	my $tmpfile = $TODO_FILE . ".$$";

	open F, ">$tmpfile" or
		die "couldn't open tmp file: $tmpfile: $!";
	flock(F, LOCK_EX);
	foreach (keys %{$hash_ref}) {
		my $csv = Text::CSV->new();
		$csv->combine($_, @{$hash_ref->{$_}});
		print F $csv->string() . "\n";
	}
	close F;
	flock(F, LOCK_UN);
	rename ($tmpfile, $TODO_FILE) or
		die "couldn't rename $tmpfile to $TODO_FILE: $!";
}


sub clean_csv_string {
	my $input = shift;
	my $bad_csv = '[^\t\x20-\x7E]+'; # straight from 'perldoc Text::CSV'

	$input =~ s/\n/<BR>/g;
	$input =~ s/$bad_csv//g;

	return $input;
}
