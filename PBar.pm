#!perl

package Mac::Apps::PBar;

$version = 'v1.0.0 1997/05/15 05:37:28';

=head1 NAME

B<PBar.pm> --  An AppleEvent Module for C<Progress Bar 1.0.1>

=head1 DESCRIPTION

Progress Bar is a small AppleScriptable utility written by Gregory H. Dow. This module, C<PBar.pm>, generates Apple Event calls using AEBuild in place of AppleScript. Because the Apple Event Manager is not involved, Progress Bar updates more quickly.

In most applications the time taken to up date the Progress Bar must be kept to a minimum. On this machine (68030 CPU) An C<AppleScript> update to the progress bar takes about 0.72 seconds. Using C<PBar.pm> the time is reduced to 0.10 seconds; a seven-fold improvement.

Progress Bar 1.0.1 is found by a search for the creator type C<PBar> and launched automatically. To minimise the time taken for the search, C<Progress Bar 1.0.1> should be kept in the same volume as C<PBar.pm>.

=head1 SYNOPSIS

	use Mac::AppleEvents
	use Mac::Processes
	use Mac::MoreFiles
	
Install C<E<quot>PBar.pmE<quot>> in a folder named C<E<quot>AppsE<quot>> in the C<E<quot>MacE<quot>> folder in MacPerl's library path.


=head1 TEST PROGRAM

The following script (ideally saved as a MacPerl droplet) shows 10 increments of the bar at 1 second intervals. The window is closed when the bar is full after a final five second pause.

	#!perl
	# Droplet "Run_PBar"

	use Mac::Apps::PBar;

	$bar = Mac::Apps::PBar->new('FTP DOWNLOAD', '100, 50');
	$bar->data(Cap1, 'file: BigFile.tar.gz');
	$bar->data(Cap2, 'size: 1,230K');
	$bar->data(MinV, '0');
	$bar->data(MaxV, '1230');
	for(0..10) {
		$n = $_*123;
		$bar->data(Valu, $n);
		sleep(1);
	}
	sleep(5);
	$bar->close_window;


=head2 CREATING A NEW PROGRESS BAR

Progress Bar 1.0.1 is launced and a new Progress bar created by:

	 $bar = Mac::Apps::PBar->new('NAME', 'xpos, ypos');

where the arguments to the C<new> constructor have the following meanings:


=over 4

=item B<First argument:>

is a string for the title bar of the Progress Bar window.

=item B<Second argument:>

is a string C<'xpos, ypos'> defining the position of the top left-hand corner of the window in pixels. The pair of numbers and the comma should be enclosed in single quotes as shown.

=back

=head2 SENDING DATA

Values are sent to the C<Progress Bar> by the C<data> sub-routine using the variable names in the C<aete resource> for each of the C<Progress Bar> properties. There are five property values for the C<PBar> class. The syntax is:

	$bar->data('property', 'value')

Values, whether numeric or not, should be single quoted strings.

=over 4

=item B<Minimum value>  C<'MinV'>

This is the value of the displayed parameter corresponding to the origin of the bar. Often it is zero, but may take other values (for instance a temperature bar in degrees Fahrenheit might start at 32).

=item B<Maximum value>  C<'MaxV'>

This is the value corresponding to the full extent of the bar. It can take any value, such as the size of a file in KB, or 100 for a percentage variable. Bar increments are integers, hence discrimination is finer the larger the value of C<MaxV>.

=item B<Current value>  C<'Valu'>

This is the value which sets the progress bar to the position corresponding to the current value of the parameter displayed. The value must obviously lie somewhere between C<MinV> and C<MaxV>.

=item B<Upper caption>  C<'Cap1'>

This string, immediately under the title bar, can be set to anything appropriate
for the application.

=item B<Lower caption>  C<'Cap2'>

The lower caption string can either be set to a constant value (e.g. C<File size = 1234K>) or up-dated with the bar. For instance it might be appropriate to set C<'Cap2'> as follows:

	$n = $max_value - $current_value;
	$bar->data('Cap2', "remaining $n");

Note the double quotes so that the value of C<$n> is interpolated.

It should be remembered however that it will take twice as long to update both C<Cap2> and C<Valu> as just to update the bar C<Valu> by itself. In applications where speed is of the essence, just the bar value C<Valu> should be changed.

=back

=head2 REFERENCES

The following documents, which are relevant to AEBuild, may be of interest:

=over 4

=item B<AEGizmos_1.4.1>

Written by Jens Peter Alfke this gives a description of AEBuild on which the MacPerl AEBuildAppleEvent is based. Available from:

	ftp://dev.apple.com/
	devworld/Tool_Chest/Interapplication_Communication/
	AE_Tools_/AEGizmos_1.4.1

=item B<aete.convert>

A fascinating MacPerl script by David C. Schooley which extracts the aete resources from scriptable applications. It is an invaluable aid for the construction ofAEBuild events. Available from:

	ftp://ftp.ee.gatech.edu/
	pub/mac/Widgets/
	aete.converter_1.1.sea.hqx

=item B<AE_Tracker>

This a small control panel which allows some or all AE Events to be tracked at various selectable levels of information. It is relatively difficult to decipher the output but AE_Tracker can be helpful. Available from:

	ftp://ftp.amug.org/
	pub/amug/bbs-in-a-box/files/system7/a/
	aetracker2.0.sit.hqx

=item B<Inside Macintosh>

Chapter 6 "Resolving and Creating Object Specifier Records" . The summary can be obtained from:

	http://gemma.apple.com/
	dev/techsupport/insidemac/IAC/
	IAC-287.html

=item B<Progress Bar 1.0.1>

Obtainable from Info-Mac archives as:

	info-mac/dev/osa/progress-bar-1.0.1.hqx

=back

References are valid as at May 1997.

=head1 COPYRIGHT

Copyright (c) 1997 by Chris Nandor and Alan Fry. All rights reserved. 

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHORS

B<Chris Nandor> C<E<lt>pudge@pobox.comE<gt>> is responsible for the AEBuild techniques, and particularly for evolving the AE object specifications. He wrote the first working script on which this module is largely based.

B<Alan Fry> C<E<lt>ajf@afco.demon.co.ukE<gt>> wrote the module and this documentation.

=head1 HISTORY

B<Version 1.0.0> 15 May 1997

=cut

use Mac::AppleEvents;
use Mac::Processes;
use Mac::MoreFiles;

sub new {
    my $pkg = shift;
    my $title = shift;
    my $ppos = shift;
    $pkg = \*$pkg;
    bless $pkg;

    ${*$pkg}{'windobj'} = "obj{want:type(cwin),
    from:null(), form:indx, seld:long(1)}";

    ${*$pkg}{'progobj'} = "obj{want:type(PBar),
    from:${*$pkg}{'windobj'}, form:indx, seld:long(1)}";
    
    $pkg->launch_pbar;

    $evt = AEBuildAppleEvent('core', 'crel', typeApplSignature, 'PBar', 0, 0,
    "kocl: type(cwin), prdt:{ pnam: Ò$titleÓ , ppos:[$ppos] }") or die $^E;
    $pkg->runEvent($evt);

    $pkg;
}

sub launch_pbar {
    my %Launch;
    tie %Launch, LaunchParam;
    $Launch{launchControlFlags} = launchContinue + launchNoFileFlags;
    $Launch{launchAppSpec} = $Application{PBar};
    LaunchApplication(\%Launch) or die $^E;
}

sub data {
   my $pkg = shift;
   my $str = shift;
   my $dat = shift;
   my $obj = "obj{want:type(prop), from:${*$pkg}{'progobj'},
   form:prop, seld:type($str)}";
   my $evt = AEBuildAppleEvent('core', 'setd', typeApplSignature,
   'PBar', 0, 0, "'----':$obj, data:Ò$datÓ ") or die $^E;
   $pkg->runEvent($evt)
}

sub close_window {
   my $pkg = shift;
   my $evt = AEBuildAppleEvent('aevt', 'quit', typeApplSignature,
  'PBar', 0, 0, "'----':''") or die $^E;
   $pkg->runEvent($evt)
}

sub runEvent {
    my $pkg = shift;
    my $evt = shift;
   #print AEPrint($evt), "\n";
    my $rep = AESend($evt, kAEWaitReply) or die $^E;
   #print AEPrint($rep), "\n\n";
    AEDisposeDesc $evt;
    AEDisposeDesc $rep;

}


1;
