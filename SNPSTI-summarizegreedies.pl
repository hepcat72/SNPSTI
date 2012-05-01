#!/usr/bin/perl -w

#Generated using perl_script_template.pl 1.44
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Center for Computational Research
#Copyright 2008
#These variables (in main) are used by getVersion() and usage()
my $software_version_number = '1.4';
my $created_on_date         = '3/27/2012';

##
## Start Main
##

use strict;
use Getopt::Long;
use File::Glob ':glob';

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix); #Not defined so input can be overwritten
my @input_files          = ();
my @stderr_files         = ();
my @sample_info_files    = ();
my @default_desc_columns = (2,3,4);
my @desc_columns         = ();
my $desc_delimiter       = '/';
my @default_desc_prepends= ('Main-','Major-','Minor-');
my @desc_prepends        = ();
my $node_name_pattern    = '^[^\(]+';
my @default_states       = ('unk','low','mid','hi','vhi','vvh');
my @states               = ();
my @outdirs              = ();
my $current_output_file  = '';
my $help                 = 0;
my $version              = 0;
my $overwrite            = 0;
my $noheader             = 0;
my $error_limit          = 50;
my $score1_min           = 0;
my $score2_min           = 0;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, getCommand, quit, and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;
my $ignore_errors = 0;

my $GetOptHash =
  {'i|input-file|greedy-file=s'
                        => sub {push(@input_files,     #REQUIRED unless <> is
			             [sglob($_[1])])}, #         supplied
   '<>'                 => sub {push(@input_files,     #REQUIRED unless -i is
				     [sglob($_[0])])}, #         supplied
   'e|stderr-file=s'    => sub {push(@stderr_files,    #OPTIONAL [none]
			             [sglob($_[1])])},
   's|sampleinfo-file=s'=> sub {push(@sample_info_files,
			             [sglob($_[1])])}, #OPTIONAL [none]
   'd|node-desc-col=s'  => sub {push(@desc_columns,    #OPTIONAL [2,3,4]
			             sglob($_[1]))},
   'desc-prepends=s'    => sub {push(@desc_columns,    #OPTIONAL ['Main-',
			             sglob($_[1]))},   #     'Major-','Minor-']
   'convert-states=s'   => sub {push(@states,          #OPTIONAL ['unk','low',
			             sglob($_[1]))},   #'mid','hi','vhi','vvh']
   'desc-delimiter=s'   => \$desc_delimiter,           #OPTIONAL [/]
   'p|node-patern=s'    => \$node_name_pattern,        #OPTIONAL ['^[^\(]+']
   'loc1-score-min=s'   => \$score1_min,               #OPTIONAL [0]
   'loc2-score-min=s'   => \$score2_min,               #OPTIONAL [0]
   'o|outfile-suffix=s' => \$outfile_suffix,           #OPTIONAL [undef]
   'outdir=s'           => sub {push(@outdirs,         #OPTIONAL
				     [sglob($_[1])])},
   'force|overwrite'    => \$overwrite,                #OPTIONAL [Off]
   'ignore'             => \$ignore_errors,            #OPTIONAL [Off]
   'verbose:+'          => \$verbose,                  #OPTIONAL [Off]
   'quiet'              => \$quiet,                    #OPTIONAL [Off]
   'debug:+'            => \$DEBUG,                    #OPTIONAL [Off]
   'help'               => \$help,                     #OPTIONAL [Off]
   'version'            => \$version,                  #OPTIONAL [Off]
   'noheader|no-header' => \$noheader,                 #OPTIONAL [Off]
   'error-type-limit=s' => \$error_limit,              #OPTIONAL [0]
  };

#If there are no arguments and no files directed or piped in
if(scalar(@ARGV) == 0 && isStandardInputFromTerminal())
  {
    usage();
    quit(0);
  }

#Get the input options & catch any errors in option parsing
unless(GetOptions(%$GetOptHash))
  {
    #Try to guess which arguments GetOptions is complaining about
    my @possibly_bad = grep {!(-e $_)} map {@$_} @input_files;

    error('Getopt::Long::GetOptions reported an error while parsing the ',
	  'command line arguments.  The error should be above.  Please ',
	  'correct the offending argument(s) and try again.');
    usage(1);
    quit(-1);
  }

#Print the debug mode (it checks the value of the DEBUG global variable)
debug('Debug mode on.') if($DEBUG > 1);

#If the user has asked for help, call the help subroutine
if($help)
  {
    help();
    quit(0);
  }

#If the user has asked for the software version, print it
if($version)
  {
    print(getVersion($verbose),"\n");
    quit(0);
  }

#Check validity of verbosity options
if($quiet && ($verbose || $DEBUG))
  {
    $quiet = 0;
    error('You cannot supply the quiet and (verbose or debug) flags ',
	  'together.');
    quit(-2);
  }

if(scalar(@outdirs) && !defined($outfile_suffix))
  {
    error("An outfile suffix (-o) is required if an output directory ",
	  "(--outdir) is supplied.  Note, you may supply an empty string to ",
	  "name the output files the same as the input files.");
    quit(-8);
  }

#If standard input has been redirected in
my $outfile_stub = 'STDIN';
if(!isStandardInputFromTerminal())
  {
    #If there's only one input file detected, use that input file as a stub for
    #the output file name construction
    if(scalar(grep {$_ ne '-'} map {@$_} @input_files) == 1)
      {
	$outfile_stub = (grep {$_ ne '-'} map {@$_} @input_files)[0];
	@input_files = ();

	#If $outfile_suffix has not been supplied, set it to an empty string
	#so that the name of the output file will be what they supplied with -i
	if(!defined($outfile_suffix))
	  {
	    #Only allow this is the supplied the overwite flag
	    if(-e $outfile_stub && !$overwrite)
	      {
		error("File exists: [$outfile_stub]  Use --outfile-suffix ",
		      '(-o) or --overwrite to continue.');
		quit(-3);
	      }
	    $outfile_suffix = '';
	  }
      }
    #If standard input has been redirected in and there's more than 1 input
    #file detected
    elsif(scalar(grep {$_ ne '-'} map {@$_} @input_files) > 1)
      {
	#Warn the user about the naming of the outfile when using STDIN
	if(defined($outfile_suffix))
	  {warning('Input on STDIN detected along with multiple other input ',
		   'files and an outfile suffix.  Your output file for the ',
		   'input on standard input will be named [',$outfile_stub,
		   $outfile_suffix,'].')}
      }

    #Unless the dash was supplied by the user on the command line, push it on
    unless(scalar(grep {$_ eq '-'} map {@$_} @input_files))
      {
	#If there are other input files present, push it
	if(scalar(@input_files))
	  {push(@{$input_files[-1]},'-')}
	#Else create a new input file set with it as the only file member
	else
	  {@input_files = (['-'])}
      }
  }
debug(1);

#Warn users when they turn on verbose and output is to the terminal
#(implied by no outfile suffix checked above) that verbose messages may be
#uncleanly overwritten
if($verbose && !defined($outfile_suffix) && isStandardOutputToTerminal())
  {warning('You have enabled --verbose, but appear to possibly be ',
	   'outputting to the terminal.  Note that verbose messages can ',
	   'interfere with formatting of terminal output making it ',
	   'difficult to read.  You may want to either turn verbose off, ',
	   'redirect output to a file, or supply an outfile suffix (-o).')}

#Make sure there is input
if(scalar(@input_files) == 0)
  {
    error('No input files detected.');
    usage(1);
    quit(-4);
  }

#If output directories have been provided
if(scalar(@outdirs))
  {
    #If there are the same number of output directory sets as input file sets
    if(scalar(@outdirs) == scalar(@input_files))
      {
	#Unless all the output directory sets contain 1 specified directory
	unless(scalar(grep {scalar(@$_) == 1} @outdirs) ==
	       scalar(@input_files) ||
	       #Or each output directory set has the same number of directories
	       #as the corresponding input files
	       scalar(grep {scalar(@{$outdirs[$_]}) ==
			      scalar(@{$input_files[$_]})}
		      (0..$#{@input_files})) == scalar(@input_files))
	  {
	    error('The number of --outdir\'s is invalid.  You may either ',
		  'supply 1, 1 per input file set, 1 per input file, or ',
		  'where all sets are the same size, 1 per input file is a ',
		  'single input file set.  You supplied [',
		  join(',',map {scalar(@$_)} @outdirs),
		  '] output directories and [',
		  join(',',map {scalar(@$_)} @input_files),
		  '] input files.');
	    quit(-6);
	  }
      }
    elsif(scalar(@outdirs) == 1 && scalar(@{$outdirs[0]}) != 1)
      {
	#Unless all the input file sets are the same size as the single set of
	#output directories
	unless(scalar(grep {scalar(@$_) == scalar(@{$outdirs[0]})}
		      @input_files) == scalar(@input_files))
	  {
	    error('The number of --outdir\'s is invalid.  You may either ',
		  'supply 1, 1 per input file set, 1 per input file, or ',
		  'where all sets are the same size, 1 per input file is a ',
		  'single input file set.  You supplied [',
		  join(',',map {scalar(@$_)} @outdirs),
		  '] output directories and [',
		  join(',',map {scalar(@$_)} @input_files),
		  '] input files.');
	    quit(-7);
	  }
      }
  }
debug(2);

#Check to make sure previously generated output files won't be over-written
#Note, this does not account for output redirected on the command line
if(defined($outfile_suffix))
  {
    my $existing_outfiles = [];
    my $unique_out_check  = {};
    my $nonunique_found   = 0;
    my $set_num           = 0;
    foreach my $input_file_set (@input_files)
      {
	my $file_num = 0;
	#For each output file *name* (this will contain the input file name's
	#path if it was supplied)
	foreach my $infile (@$input_file_set)
	  {
	    my $output_file = ($infile eq '-' ? $outfile_stub : $infile) .
	      $outfile_suffix;
	    #If at least 1 output directory was supplied
	    if(scalar(@outdirs))
	      {
		#Eliminate any path strings from the output file name that came
		#from the input file supplied
		$output_file =~ s/.*\///;

		#If there is the same number of output directory sets as input
		#file sets
		if(scalar(@outdirs) > 1 &&
		   scalar(@outdirs) == scalar(@input_files))
		  {
		    #If there's 1 directory per input file set
		    if(scalar(@{$outdirs[$set_num]}) == 1)
		      {
			#Each set of input files has 1 output directory

			$output_file = $outdirs[$set_num]->[0]
			  . ($outdirs[$set_num]->[0] =~ /\/$/ ? '' : '/')
			    . $output_file;
		      }
		    #Else there must be the same number of directories
		    elsif(scalar(@{$outdirs[$set_num]}) ==
			  scalar(@{$input_files[$set_num]}))
		      {
			#Each input file has its own output directory

			$output_file = $outdirs[$set_num]->[$file_num] .
			  ($outdirs[$set_num]->[$file_num] =~ /\/$/ ? '' : '/')
			    . $output_file;
		      }
		    #Else Error
		    else
		      {
			error("Cannot determine corresponding directory for ",
			      "$output_file.  Will output to current ",
			      "directory.");
		      }
		  }
		#There must be only 1 output directory set, so if it's more
		#than 1 directory and has the same number of directories as
		#each set of input files
		elsif(scalar(@{$outdirs[0]}) > 1 &&
		      scalar(grep {scalar(@{$outdirs[0]}) == scalar(@$_)}
			     @input_files) == scalar(@input_files))
		  {
		    #Each set of input files has the same number of input
		    #files (guaranteed in code above), so each one in series
		    #will output to the corresponding directory specified in
		    #the single output directory set

		    $output_file = $outdirs[0]->[$file_num]
		      . ($outdirs[0]->[$file_num] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
		#There must be only 1 output directory set, so if it's more
		#than 1 directory and has the same number of directories as the
		#number of input file sets
		elsif(scalar(@{$outdirs[0]}) > 1 &&
		      scalar(@{$outdirs[0]}) == scalar(@input_files))
		  {
		    #Each file set will output to the corresponding directory
		    #in the first set of directories in series.  Note, if the
		    #number of input files in each set and the number of sets
		    #is the same, the default mechanism is for a single set's
		    #files to go in the various directories in the single set
		    #of directories.  For now, this cannot be overridden.

		    $output_file = $outdirs[0]->[$set_num]
		      . ($outdirs[0]->[$set_num] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
		#It must be a single output directory
		else
		  {
		    #All input files have the same output directory

		    $output_file = $outdirs[0]->[0]
		      . ($outdirs[0]->[0] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
	      }

	    $file_num++;
	    push(@$existing_outfiles,$output_file) if(-e $output_file);
	    if(exists($unique_out_check->{$output_file}))
	      {$nonunique_found = 1}
	    push(@{$unique_out_check->{$output_file}},$infile);
	  }
	$set_num++;
      }

    if(!$overwrite && scalar(@$existing_outfiles))
      {
	error("Files exist: [@$existing_outfiles].  Use --overwrite to ",
	      "continue.  E.g.:\n",getCommand(1),' --overwrite');
	quit(-5) unless($nonunique_found);
      }

    if($nonunique_found)
      {
	error('The following output file names overlap with the indicated ',
	      'input file names and will be overwritten.  Please make sure ',
	      'each similarly named input file outputs to a different output ',
	      'directory.  Offending file name conflicts: [',
	      join(',',map {"$_ is written to by [" .
			      join(',',@{$unique_out_check->{$_}}) . "]"}
		   (keys(%$unique_out_check))),"].");
	quit(-9);
      }
  }
debug(3);

#Error check the node description column numbers with the prepend strings for
#the sample info file
if(scalar(@desc_columns) && scalar(@desc_prepends) &&
   scalar(@desc_columns) != scalar(@desc_prepends))
  {
    error("--desc-prepends and --node-desc-col must each have the same ",
	  "number of space-delimited values.  [",scalar(@desc_prepends),
	  "] prepend values and [",scalar(@desc_columns),
	  "] columns were supplied.");
    quit(4);
  }

#Error-check the node description column numbers
if(scalar(grep {$_ < 1} @desc_columns))
  {
    my @errors = grep {$_ < 1} @desc_columns;
    error("Ivalid values supplied to --node-desc-col: [@errors].  Must be ",
	  "integers greater than 0.");
    quit(5);
  }

#Handle the node description column number defaults
my @desc_indexes = ();
if(scalar(@desc_columns))
  {@desc_indexes = map {$_ - 1} @desc_columns}
else
  {@desc_indexes = map {$_ - 1} @default_desc_columns}

#Set the prepend strings for the node descriptions of the sample info file
if(scalar(@desc_prepends) == 0 &&
   scalar(@desc_indexes) == scalar(@default_desc_prepends))
  {@desc_prepends = @default_desc_prepends}
else
  {@desc_prepends = map {''} @desc_indexes}

#Set default states if necessary
if(scalar(@states) == 0)
  {@states = @default_states}

#Create the output directories
if(scalar(@outdirs))
  {
    foreach my $dir_set (@outdirs)
      {
	foreach my $dir (@$dir_set)
	  {
	    if(-e $dir)
	      {
		warning('The --overwrite flag will not empty or delete ',
			'existing output directories.  If you wish to delete ',
			'existing output directories, you must do it ',
			'manually.') if($overwrite)
		}
	    else
	      {mkdir($dir)}
	  }
      }
  }
debug(4);

verbose('Run conditions: ',getCommand(1));

#If output is going to STDOUT instead of output files with different extensions
#or if STDOUT was redirected, output run info once
verbose('[STDOUT] Opened for all output.') if(!defined($outfile_suffix));

#Store info. about the run as a comment at the top of the output file if
#STDOUT has been redirected to a file
if(!isStandardOutputToTerminal() && !$noheader)
  {print(getVersion(),"\n",
	 '#',scalar(localtime($^T)),"\n",
	 '#',getCommand(1),"\n");}

#Print the column headers
if(!defined($outfile_suffix))
  {
    print("#Note: A score of 1 doesn't necessarily indicate a perfect ",
	  "solution when given ambiguous input or data for which there are ",
	  "missing values.\n",
	  "#\"States\" are given in the format in which they were input to ",
	  "SNPSTI.pl.  If SNPSTI-convert.pl was used, you must convert these ",
	  "states back using the original cutoffs to make sense of them.\n",
	  "#Equivalent loci (in the sense of resolving power, not state) ",
	  "will be shown comma-delimited.\n",
	  "#Node\t",(scalar(@sample_info_files) ? "Node Description\t" : ''),
	  "Greedy Num\tNum Target Samples with Real ",
	  "Values\tTotal Num Samples with Real Values\t",
	  "Num Locus 1 States Targets Exist in\t",
	  "Num Locus 2 States Targets Exist in\tLocus 1\t",
	  "Score Locus 1\tLocus 2\tScore Locus 2\t","States(Targets/Total)\t",
	  "Call Locus 1\t","Call Locus 2\t","Specificity Combined\t",
	  "Sensitivity Combined\t","Specificity Locus 1\t",
	  "Sensitivity Locus 1\t","Specificity Locus 2\t",
	  "Sensitivity Locus 2","\n");
  }

#For each input file set
my $set_num = 0;
foreach my $input_file_set (@input_files)
  {
    my $file_num = 0;
    #For each output file *name* (this will contain the input file name's
    #path if it was supplied)

    my $stderr_file_set = [];
    if(scalar(@stderr_files) == scalar(@input_files) &&
       scalar(@$input_file_set) == scalar(@{$stderr_files[$set_num]}))
      {$stderr_file_set = $stderr_files[$set_num]}
    elsif(scalar(@$input_file_set) == scalar(@stderr_files) &&
	  scalar(@stderr_files) == scalar(grep {scalar(@$_) == 1}
					  @stderr_files))
      {$stderr_file_set = [map {$_[0]} @stderr_files]}
    elsif(scalar(@stderr_files))
      {
	error("Cannot match up standard error file sets with the partial ",
	      "greedy solution file sets.  There are [",scalar(@input_files),
	      "] input file sets, [",scalar(@$input_file_set),
	      "] files in the first input file set, [",scalar(@stderr_files),
	      "] SNPSTI standard error file sets, and [",
	      scalar(@{$stderr_files[0]}),
	      "] files in the first SNPSTI standard error file set.");
	quit(2);
      }

    my $sampleinfo_file_set = [];
    if(scalar(@sample_info_files) == scalar(@input_files) &&
       scalar(@$input_file_set) == scalar(@{$sample_info_files[$set_num]}))
      {$sampleinfo_file_set = $sample_info_files[$set_num]}
    elsif(scalar(@$input_file_set) == scalar(@sample_info_files) &&
	  scalar(@sample_info_files) == scalar(grep {scalar(@$_) == 1}
					       @sample_info_files))
      {$sampleinfo_file_set = [map {$_[0]} @sample_info_files]}
    elsif(1 == scalar(@sample_info_files) &&
	  1 == scalar(grep {scalar(@$_) == 1} @sample_info_files))
      {$sampleinfo_file_set = $sample_info_files[0]}
    elsif(scalar(@sample_info_files) == 1 &&
	  scalar(@{$sample_info_files[0]}) == scalar(@input_files))
      {$sampleinfo_file_set = [$sample_info_files[0]->[$set_num]]}
    elsif(scalar(@sample_info_files))
      {
	error("Cannot match up sample info file sets with the partial greedy ",
	      "solution file sets.  There are [",scalar(@input_files),"] ",
	      "input file sets, [",scalar(@$input_file_set),"] files in the ",
	      "first input file set, [",scalar(@sample_info_files),"] SNPSTI ",
	      "standard error file sets, and [",
	      scalar(@{$sample_info_files[0]}),
	      "] files in the first SNPSTI standard error file set.");
	quit(7);
      }

    #For each input file
    foreach my $input_file (@$input_file_set)
      {
	my $stderr_file = '';
	if(scalar(@$stderr_file_set) == 1)
	  {$stderr_file = $stderr_file_set->[0]}
	elsif(scalar(@$stderr_file_set) == scalar(@$input_file_set))
	  {$stderr_file = $stderr_file_set->[$file_num]}
	elsif(scalar(@$stderr_file_set))
	  {
	    error("Cannot match up standard error files with the partial ",
		  "greedy solution files.");
	    quit(3);
	  }

	my $sampleinfo_file = '';
	if(scalar(@$sampleinfo_file_set) == 1)
	  {$sampleinfo_file = $sampleinfo_file_set->[0]}
	elsif(scalar(@$sampleinfo_file_set) == scalar(@$input_file_set))
	  {$sampleinfo_file = $sampleinfo_file_set->[$file_num]}
	elsif(scalar(@$sampleinfo_file_set))
	  {
	    error("Cannot match up sample info files with the partial ",
		  "greedy solution files.");
	    quit(8);
	  }

	#Get desc_hash->{$node_name}->{DESC|NUM} = string|number
	my $desc_hash = {};
	if(scalar(@sample_info_files))
	  {$desc_hash = getDescHash($sampleinfo_file,
				    \@desc_indexes,
				    \@desc_prepends,
				    $desc_delimiter,
				    $node_name_pattern)}

	#If an output file name suffix has been defined
	if(defined($outfile_suffix))
	  {
	    ##
	    ## Open and select the next output file
	    ##

	    #Set the current output file name
	    $current_output_file = ($input_file eq '-' ?
				    $outfile_stub : $input_file)
	      . $outfile_suffix;
	  }

	#If at least 1 output directory was supplied
	if(scalar(@outdirs))
	  {
	    #Eliminate any path strings from the output file name that came
	    #from the input file supplied
	    $current_output_file =~ s/.*\///;

	    #If there is the same number of output directory sets as input
	    #file sets
	    if(scalar(@outdirs) > 1 &&
	       scalar(@outdirs) == scalar(@input_files))
	      {
		#If there's 1 directory per input file set
		if(scalar(@{$outdirs[$set_num]}) == 1)
		  {
		    #Each set of input files has 1 output directory

		    $current_output_file = $outdirs[$set_num]->[0]
		      . ($outdirs[$set_num]->[0] =~ /\/$/ ? '' : '/')
			. $current_output_file;
		  }
		#Else there must be the same number of directories
		elsif(scalar(@{$outdirs[$set_num]}) ==
		      scalar(@{$input_files[$set_num]}))
		  {
		    #Each input file has its own output directory

		    $current_output_file = $outdirs[$set_num]->[$file_num]
		      . ($outdirs[$set_num]->[$file_num] =~ /\/$/ ? '' : '/')
			. $current_output_file;
		  }
		#Else Error
		else
		  {
		    error("Cannot determine corresponding directory for ",
			  "$current_output_file.  Will output to current ",
			  "directory.");
		  }
	      }
	    #There must be only 1 output directory set, so if it's more
	    #than 1 directory and has the same number of directories as
	    #each set of input files
	    elsif(scalar(@{$outdirs[0]}) > 1 &&
		  scalar(grep {scalar(@{$outdirs[0]}) == scalar(@$_)}
			 @input_files) == scalar(@input_files))
	      {
		#Each set of input files has the same number of input
		#files (guaranteed in code above), so each one in series
		#will output to the corresponding directory specified in
		#the single output directory set

		$current_output_file = $outdirs[0]->[$file_num]
		  . ($outdirs[0]->[$file_num] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	    #There must be only 1 output directory set, so if it's more
	    #than 1 directory and has the same number of directories as the
	    #number of input file sets
	    elsif(scalar(@{$outdirs[0]}) > 1 &&
		  scalar(@{$outdirs[0]}) == scalar(@input_files))
	      {
		#Each file set will output to the corresponding directory
		#in the first set of directories in series.  Note, if the
		#number of input files in each set and the number of sets
		#is the same, the default mechanism is for a single set's
		#files to go in the various directories in the single set
		#of directories.  For now, this cannot be overridden.

		$current_output_file = $outdirs[0]->[$set_num]
		  . ($outdirs[0]->[$set_num] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	    #It must be a single output directory
	    else
	      {
		#All input files have the same output directory

		$current_output_file = $outdirs[0]->[0]
		  . ($outdirs[0]->[0] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	  }

	if(defined($outfile_suffix))
	  {
	    #Open the output file
	    if(!open(OUTPUT,">$current_output_file"))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open output file: [$current_output_file].\n",
		      $!);
		$file_num++;
		next;
	      }
	    else
	      {verbose("[$current_output_file] Opened output file.")}

	    #Select the output file handle
	    select(OUTPUT);

	    #Store info about the run as a comment at the top of the output
	    print(getVersion(),"\n",
		  '#',scalar(localtime($^T)),"\n",
		  '#',getCommand(1),"\n") unless($noheader);
	  }

	my $line_num     = 0;
	my $verbose_freq = 100;
	my $equivsec     = 0;   #Section with equivalent solutions
	my $equiv_hash   = {};
	my $node         = $input_file;

	if($stderr_file ne '')
	  {
	    #Open the input file
	    if(!open(SNPSTIERR,$stderr_file))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open SNPSTI error file: [$stderr_file].\n$!");
		$file_num++;
		next;
	      }
	    else
	      {verbose('[',$stderr_file,'] ','Opened SNPSTI error file.')}

	    #For each line in the current SNPSTI error file
	    while(getLine(*SNPSTIERR))
	      {
		$line_num++;
		verboseOverMe('[',$stderr_file,
			      "] Reading line: [$line_num].")
		  unless($line_num % $verbose_freq);

		if(/These SNPs are equivalent/)
		  {$equivsec = 1}
		elsif(/Reading tree file/)
		  {
		    $equivsec = 0;
		  }
		elsif(/Checking analysis nodes: \[([^\]]+)\]\.$/)
		  {
		    $node = $1;
		    if($node =~ s/,.*//)
		      {error("Multiple nodes per SNPSTI run were detected.  ",
			     "This script only works on the first node in an ",
			     "analysis.")}
		    last;
		  }
		elsif($equivsec)
		  {
		    s/^\s+\[//;
		    chomp;
		    s/\]\s*$//;
		    foreach my $equiv (split(/,/,$_))
		      {$equiv_hash->{$equiv}=$_}
		  }
	      }

	    close(SNPSTIERR);

	    verbose('[',$stderr_file,'] ',
		    'SNPSTI error file done.  Time taken: [',
		    scalar(markTime()),' Seconds].');
	  }



	#Open the input file
	if(!open(INPUT,$input_file))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open input file: [$input_file].\n$!");
	    $file_num++;
	    next;
	  }
	else
	  {verbose('[',($input_file eq '-' ? $outfile_stub : $input_file),'] ',
		   'Opened input file.')}

	$line_num     = 0;
	$verbose_freq = 100;
	my $iteration = 0;
	my $size      = 0;
	my $hash      = {};
	my $state1    = '';
	my $state2    = '';
	my $done      = 0;
	my $got_score = 1;

	#For each line in the current input file
	while(getLine(*INPUT))
	  {
	    $line_num++;
	    verboseOverMe('[',($input_file eq '-' ?
			       $outfile_stub : $input_file),
			  "] Reading line: [$line_num].")
	      unless($line_num % $verbose_freq);

	    #Look for the GREEDY ITER # SIZE 1 and GREEDY ITER # SIZE 2
	    #sections
	    if(/^GREEDY ITER (\d+) SIZE (\d+)\s*$/)
	      {
		if(!$got_score && $2 == 1)
		  {
		    error("Could not find score for iteration [$iteration].");
		    delete($hash->{$iteration});
		  }
		$got_score = 0;
		$iteration  = $1;
		$size       = $2;
		$state1     = '';
		$state2     = '';

		debug("Starting iteration [$iteration] size [$size].");
	      }
	    #Keep track of the current state (locus names and values).  In each
	    #state, count the number of target samples and the total number of
	    #samples
	    elsif(($size == 1) &&
		  /^ ([^ :]+): (\S+) \(real: (\d+)\/(\d+), no data: (\d+)\/(\d+)/)
	      {
		$hash->{$iteration}->{$size}->{LOCUS} = $1;
		if($2 eq 'gap')
		  {$state1 = '-'}
		else
		  {$state1 = $2}
		$hash->{$iteration}->{REALTOTAL} += $3;
		$hash->{$iteration}->{ALLTOTAL}  += $4;
		#[[locus name,value,num real targets,real total,num no data
		#  targets,total no data],...]
		push(@{$hash->{$iteration}->{$size}->{STATES}},
		     [$1,$state1,$3,$4,$5,$6]);

		debug("State: [$1,$state1,$3,$4,$5,$6].");
	      }
	    elsif(($size == 2) &&
		  /^  ([^ :]+): (\S+) \(real: (\d+)\/(\d+), no data: (\d+)\/(\d+)/)
	      {
		$hash->{$iteration}->{$size}->{LOCUS} = $1;
		if($2 eq 'gap')
		  {$state2 = '-'}
		else
		  {$state2 = $2}
		#[[locus name,value,num real targets,real total,num no data
		#  targets,total no data],...]
		push(@{$hash->{$iteration}->{$size}->{STATES}},
		     [$1,"$state1$state2",$3,$4,$5,$6]);

		debug("State: [$1,$state1$state2,$3,$4,$5,$6].");
	      }
	    elsif(($size == 2) &&
		  /^ ([^ :]+): (\S+) \(real: (\d+)\/(\d+), no data: (\d+)\/(\d+)/)
	      {
		#[[locus name,value,num real targets,real total,num no data
		#  targets,total no data],...]
		$hash->{$iteration}->{$size}->{LOCUS} = $1;
		if($2 eq 'gap')
		  {$state1 = '-'}
		else
		  {$state1 = $2}

		debug("New state: [$state1].");
	      }
	    #At the end of the greedy iteration, record the score for each of
	    #the first 1 or 2 loci
	    elsif(/^Greedy set \d+: \[\[[^\]]+\]:\(([^\)]+)\),\[[^\]]+]:\(([^\)]+)/)
	      {
		$hash->{$iteration}->{1}->{SCORE} = $1;
		$hash->{$iteration}->{2}->{SCORE} = $2;
		$got_score = 1;

		debug("Scores: [$hash->{$iteration}->{1}->{SCORE},",
		      "$hash->{$iteration}->{2}->{SCORE}].");
	      }
	    #This is if the whole greedy solution is only 1 locus
	    elsif(/^Greedy set \d+: \[\[[^\]]+\]:\(([^\)]+)/)
	      {
		$hash->{$iteration}->{1}->{SCORE} = $1;
		$got_score = 1;

		debug("Scores: [$hash->{$iteration}->{1}->{SCORE}].");
	      }
	    elsif(/^Final/)
	      {
		debug("Stopping partial file parse.");
		$done = 1;
		last;
	      }
	  }

	close(INPUT);

	verbose('[',($input_file eq '-' ? $outfile_stub : $input_file),'] ',
		'Input file done.  Time taken: [',scalar(markTime()),
		' Seconds].');

	#Check to see if the last solution was completed
	unless($got_score)
	  {
	    error("Could not find score for iteration [$iteration].");
	    delete($hash->{$iteration});
	  }

	if(!$done)
	  {error("Input file [$input_file] appears to be incomplete.")}

	#Now I want to go through the greedy solutions and remove any which do
	#not meet these criteria: There must not be real data for target
	#samples in more than 2 states at size 1 and there must not be real
	#data for target samples in more than 4 states at size 2.  The score at
	#size 1 must be greater-than or equal-to 0.4.  The score at size 2 must
	#be greater than or equal to score2_min.  If the size 2 criteria are
	#not met, you only throw out size 2.  If the criteria for size 1 is not
	#met, you throw out both sizees 1 and 2.
	my $filtered_hash = {};
	foreach my $iteration (keys(%$hash))
	  {
	    my $num1states =
	      scalar(grep {$_->[2]} @{$hash->{$iteration}->{1}->{STATES}});
	    if($hash->{$iteration}->{1}->{SCORE} >= $score1_min)# && $num1states < 3)
	      {
		debug("Keeping locus 1 of iteration [$iteration] because (",
		      "$hash->{$iteration}->{1}->{SCORE} >= $score1_min && ",
		      "$num1states < 3).");

		$filtered_hash->{$iteration}->{1}->{SCORE} =
		  $hash->{$iteration}->{1}->{SCORE};
		$filtered_hash->{$iteration}->{1}->{STATES} =
		  $hash->{$iteration}->{1}->{STATES};
		$filtered_hash->{$iteration}->{1}->{NUMSTATES} = $num1states;
		$filtered_hash->{$iteration}->{1}->{LOCUS} =
		  $hash->{$iteration}->{1}->{LOCUS};
		$filtered_hash->{$iteration}->{REALTOTAL} =
		  $hash->{$iteration}->{REALTOTAL};
		$filtered_hash->{$iteration}->{ALLTOTAL} =
		  $hash->{$iteration}->{ALLTOTAL};

		if(exists($hash->{$iteration}->{2}) &&
		   $hash->{$iteration}->{2}->{SCORE} >= $score2_min)# &&
		   #$num2states < 5)
		  {
		    my $num2states =
		      scalar(grep {$_->[2]}
			     @{$hash->{$iteration}->{2}->{STATES}});
		    debug("Keeping locus 2 of iteration [$iteration].");

		    $filtered_hash->{$iteration}->{2}->{SCORE} =
		      $hash->{$iteration}->{2}->{SCORE};
		    $filtered_hash->{$iteration}->{2}->{STATES} =
		      $hash->{$iteration}->{2}->{STATES};
		    $filtered_hash->{$iteration}->{2}->{NUMSTATES} =
		      $num2states;
		    $filtered_hash->{$iteration}->{2}->{LOCUS} =
		      $hash->{$iteration}->{2}->{LOCUS};
		  }
		elsif(exists($hash->{$iteration}->{2}) &&
		      exists($hash->{$iteration}->{2}->{SCORE}) &&
		      !defined($hash->{$iteration}->{2}->{SCORE}))
		  {error("The score for iteration [$iteration] size 2 is ",
			 "undefined.  This should not have happened.")}
		elsif(exists($hash->{$iteration}->{2}) &&
		      !exists($hash->{$iteration}->{2}->{SCORE}))
		  {error("The score for iteration [$iteration] size 2 does ",
			 "not exist.  This should not have happened.  Here's",
			 "what's in the hash for size 2: [",
			 join(',',keys(%{$hash->{$iteration}->{2}})),"].")}
	      }
	    else
	      {debug("Skipping iteration [$iteration] because !(",
		     "$hash->{$iteration}->{1}->{SCORE} >= $score1_min && ",
		     "$num1states < 3).")}
	  }

	#Print the column headers
	if(defined($outfile_suffix))
	  {
	    print("#Note: A score of 1 doesn't necessarily indicate a ",
		  "perfect solution when given ambiguous input or data for ",
		  "which there are missing values.\n",
		  "#\"States\" are given in the format in which they were ",
		  "input to SNPSTI.pl.  If SNPSTI-convert.pl was used, you ",
		  "must convert these states back using the original cutoffs ",
		  "to make sense of them.\n",
		  "#Equivalent loci (in the sense of resolving power, not ",
		  "state) will be shown comma-delimited.\n",
		  "#Node\t",
		  (scalar(@sample_info_files) ? "Node Description\t" : ''),
		  "Greedy Num\tNum Target Samples with Real Values\t",
		  "Total Num Samples with Real Values\t",
		  "Num Locus 1 States Targets Exist in\t",
		  "Num Locus 2 States Targets Exist in\tLocus 1\t",
		  "Score Locus 1\tLocus 2\tScore Locus 2\t",
		  "States(Targets/Total)\t","Call Locus 1\t","Call Locus 2\t",
		  "Specificity Combined\t","Sensitivity Combined\t",
		  "Specificity Locus 1\t","Sensitivity Locus 1\t",
		  "Specificity Locus 2\t","Sensitivity Locus 2","\n");
	  }

	#Now I want to sort by ascending number of states and descending score
	#and print the results along with the equivalent loci:
	foreach my $iteration
	  (sort {$filtered_hash->{$a}->{1}->{NUMSTATES} <=>
		   $filtered_hash->{$b}->{1}->{NUMSTATES} ||
		     $filtered_hash->{$b}->{1}->{SCORE} <=>
		       $filtered_hash->{$a}->{1}->{SCORE} ||
			 (exists($filtered_hash->{$a}->{2}) &&
			  exists($filtered_hash->{$b}->{2}) ?
			  ($filtered_hash->{$a}->{2}->{NUMSTATES} <=>
			   $filtered_hash->{$b}->{2}->{NUMSTATES} ||
			   $filtered_hash->{$b}->{2}->{SCORE} <=>
			   $filtered_hash->{$a}->{2}->{SCORE}) :
			  0)} keys(%$filtered_hash))
	    {
	      debug("Outputting iteration [$iteration].");

	      if(scalar(@sample_info_files) &&
		 (!exists($desc_hash->{$node}) ||
		  !defined($desc_hash->{$node})))
		{
		  error("Node: [$node] from input file: [$input_file] ",
			"not found in sample info file: [$sampleinfo_file].  ",
			"If the node named here is a file name, then that ",
			"would mean that the node could not be found the ",
			"SNPSTI standard error file: [$stderr_file].")
		}

	      if(exists($filtered_hash->{$iteration}->{2}))
		{
		  my $sens_spec_ary =
		    (scalar(@sample_info_files) ?
		     getSensitivitySpecificity($filtered_hash->{$iteration}
					       ->{2}->{STATES},
					       \@states,
					       $desc_hash->{$node}->{NUM}) :
		     []);

		  my @mystates =
		    convertStates($filtered_hash->{$iteration}->{2}->{STATES},
				  \@states);

		  print($node,"\t",
			(scalar(@sample_info_files) ?
			 (exists($desc_hash->{$node}) ?
			  "$desc_hash->{$node}->{DESC}\t" : "$node\t") : ''),
			$iteration,"\t",
			$filtered_hash->{$iteration}->{REALTOTAL},"\t",
			$filtered_hash->{$iteration}->{ALLTOTAL},"\t",
			$filtered_hash->{$iteration}->{1}->{NUMSTATES},"\t",
			(exists($filtered_hash->{$iteration}->{2}) ?
			 $filtered_hash->{$iteration}->{2}->{NUMSTATES} :
			 ''),"\t",
			(exists($equiv_hash->{$filtered_hash->{$iteration}->{1}
					      ->{LOCUS}}) ?
			 $equiv_hash->{$filtered_hash->{$iteration}->{1}
				       ->{LOCUS}} :
			 $filtered_hash->{$iteration}->{1}->{LOCUS}),"\t",
			$filtered_hash->{$iteration}->{1}->{SCORE},"\t",
			(exists($equiv_hash->{$filtered_hash->{$iteration}->{2}
					      ->{LOCUS}}) ?
			 $equiv_hash->{$filtered_hash->{$iteration}->{2}
				       ->{LOCUS}} :
			 $filtered_hash->{$iteration}->{2}->{LOCUS}),"\t",
			$filtered_hash->{$iteration}->{2}->{SCORE},"\t",
			join(' ',@mystates),
			(scalar(@sample_info_files) ? "\t" .
			 join("\t",@$sens_spec_ary) . "\t" : ''),
			"\n");
		}
	      else
		{
		  my $sens_spec_ary =
		    (scalar(@sample_info_files) ?
		     getSensitivitySpecificity($filtered_hash->{$iteration}
					       ->{1}->{STATES},
					       \@states,
					       $desc_hash->{$node}->{NUM}) :
		     []);

		  my @mystates =
		    convertStates($filtered_hash->{$iteration}->{1}->{STATES},
				  \@states);

		  print($node,"\t",
			(scalar(@sample_info_files) ?
			 (exists($desc_hash->{$node}) ?
			  "$desc_hash->{$node}->{DESC}\t" : "$node\t") : ''),
			$iteration,"\t",
			$filtered_hash->{$iteration}->{REALTOTAL},"\t",
			$filtered_hash->{$iteration}->{ALLTOTAL},"\t",
			$filtered_hash->{$iteration}->{1}->{NUMSTATES},"\t\t",
			(exists($equiv_hash->{$filtered_hash->{$iteration}->{1}
					      ->{LOCUS}}) ?
			 $equiv_hash->{$filtered_hash->{$iteration}->{1}
				       ->{LOCUS}} :
			 $filtered_hash->{$iteration}->{1}->{LOCUS}),"\t",
			$filtered_hash->{$iteration}->{1}->{SCORE},"\t\t\t",
			join(' ',@mystates),
			(scalar(@sample_info_files) ? "\t" .
			 join("\t",@$sens_spec_ary) . "\t" : ''),
			"\n");
		}
	    }

	#If an output file name suffix is set
	if(defined($outfile_suffix))
	  {
	    #Select standard out
	    select(STDOUT);
	    #Close the output file handle
	    close(OUTPUT);

	    verbose("[$current_output_file] Output file done.");
	  }
	$file_num++;
      }
    $set_num++;
  }


verbose("[STDOUT] Output done.") if(!defined($outfile_suffix));

#Report the number of errors, warnings, and debugs on STDERR
printRunReport($verbose) if(!$quiet && ($verbose || $DEBUG ||
					defined($main::error_number) ||
					defined($main::warning_number)));

##
## End Main
##






























##
## Subroutines
##

##
## This subroutine prints a description of the script and it's input and output
## files.
##
sub help
  {
    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #$software_version_number  - global
    #$created_on_date          - global
    $created_on_date = 'UNKNOWN' if($created_on_date eq 'DATE HERE');

    #Print a description of this program
    print << "end_print";

$script version $software_version_number
Copyright 2008
Robert W. Leach
Created: $created_on_date
Last Modified: $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script will take a partial solutions file created from
                SNPSTI.pl *run on a single input tree node* and will report a
                summary of the first two loci in each partial solution in tab-
                delimited format.

* INPUT FORMAT: A partial solutions file created from SNPSTI.pl *run on a
                single input tree node*.

* SNPSTI STDERR FILE: The standard error output created from SNPSTI.pl *run on
                      a single input tree node*.

* SAMPLE INFO FILE: A tab-delimited file containing node names and node
                    descriptions.  The node names must match those found in the
                    input and SNPSTI standard error files.  The description may
                    span multiple columns which may be edited and joined
                    together using --desc-delimiter and --desc-prepends.  The
                    node names may be parsed out using -p.  There should be a
                    row for every sample which will be counted for each node to
                    determine sensitivity and specificity of each locus in each
                    solution.  Example:

#Sample	Main Branch	Major Branch	Minor Branch	Tissue Type	DFS Order
TCGA-E2-A14X-01A-11R-A115-07	2(5TUMOR)	3(2TUMOR)	none1()	TUMOR	1
TCGA-E2-A1IP-01A-11R-A14D-07	2(5TUMOR)	3(2TUMOR)	none2()	TUMOR	2
TCGA-E2-A14R-01A-11R-A115-07	2(5TUMOR)	4(3TUMOR)	none3()	TUMOR	3
TCGA-E2-A159-01A-11R-A115-07	2(5TUMOR)	4(3TUMOR)	5(2TUMOR)	TUMOR	4
TCGA-E2-A1LH-01A-11R-A14D-07	2(5TUMOR)	4(3TUMOR)	5(2TUMOR)	TUMOR	5
TCGA-E2-A1LA-01A-11R-A144-07	6(69TUMOR/10NORMAL)	7(10TUMOR)	8(3TUMOR)	TUMOR	6
TCGA-E2-A108-01A-13R-A10J-07	6(69TUMOR/10NORMAL)	7(10TUMOR)	8(3TUMOR)	TUMOR	7


* OUTPUT FORMAT: Tab-delimited file.  The columns are as follows:

                 Node
                 Node Description
                 Greedy Num
                 Num Target Samples with Real Values
                 Total Num Samples with Real Values
                 Num Locus 1 States Targets Exist in
                 Num Locus 2 States Targets Exist in
                 Locus 1
                 Score Locus 1
                 Locus 2
                 Score Locus 2
                 States(Targets/Total)

                 Example:

100	5	11	56	2		SAMD13	0.448420373952289			T(6/47) A(5/6) -(0/3)
100	6	11	56	2	3	SREBF1(0.444242424242424)	RRAGD	0.745059288537549	-T(5/5) TA(3/3) TT(3/46) T-(0/1) -A(0/1)

* ADVANCED FILE I/O FEATURES: Sets of input files, each with different output
                              directories can be supplied.  Supply each file
                              set with an additional -i (or --input-file) flag.
                              The files will have to have quotes around them so
                              that they are all associated with the preceding
                              -i option.  Likewise, output directories
                              (--outdir) can be supplied multiple times in the
                              same order so that each input file set can be
                              output into a different directory.  If the number
                              of files in each set is the same, you can supply
                              all output directories as a single set instead of
                              each having a separate --outdir flag.  Here are
                              some examples of what you can do:

                              -i 'a b c' --outdir '1' -i 'd e f' --outdir '2'

                                 Result: 1/a,b,c  2/d,e,f

                              -i 'a b c' -i 'd e f' --outdir '1 2 3'

                                 Result: 1/a,d  2/b,e  3/c,f

                                 This is the default behavior if the number of
                                 sets and the number of files per set are all
                                 the same.  For example, this is what will
                                 happen:

                                    -i 'a b' -i 'd e' --outdir '1 2'

                                       Result: 1/a,d  2/b,e

                                 NOT this: 1/a,b 2/d,e  To do this, you must
                                 supply the --outdir flag for each set, like
                                 this:

                                    -i 'a b' -i 'd e' --outdir '1' --outdir '2'

                              -i 'a b c' -i 'd e f' --outdir '1 2'

                                 Result: 1/a,b,c  2/d,e,f

                              -i 'a b c' --outdir '1 2 3' -i 'd e f' --outdir '4 5 6'

                                 Result: 1/a  2/b  3/c  4/d  5/e  6/f

end_print

    return(0);
  }

##
## This subroutine prints a usage statement in long or short form depending on
## whether "no descriptions" is true.
##
sub usage
  {
    my $no_descriptions = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Grab the first version of each option from the global GetOptHash
    my $options = '[' .
      join('] [',
	   grep {$_ ne '-i'}           #Remove REQUIRED params
	   map {my $key=$_;            #Save the key
		$key=~s/\|.*//;        #Remove other versions
		$key=~s/(\!|=.|:.)$//; #Remove trailing getopt stuff
		$key = (length($key) > 1 ? '--' : '-') . $key;} #Add dashes
	   grep {$_ ne '<>'}           #Remove the no-flag parameters
	   keys(%$GetOptHash)) .
	     ']';

    print << "end_print";
USAGE: $script -i "input file(s)" $options
       $script $options < input_file
end_print

    if($no_descriptions)
      {print("`$script` for expanded usage.\n")}
    else
      {
        print << 'end_print';

     -i|--input-file*     REQUIRED Space-separated input file(s) (or when used
                                   with standard input present: file name stub
                                   used for naming files).  Note, -o can be
                                   used to append to what is supplied here to
                                   form new output file names.  The script will
                                   expand BSD glob characters such as '*', '?',
                                   and '[...]' (e.g. -i "*.txt *.text").  See
                                   --help for a description of the input file
                                   format.  See --help for advanced usage.
                                   *No flag required.
     -e|--stderr-file     OPTIONAL SNPSTI.pl standard error file.  This file is
                                   used to retrieve equivalent solutions.
     --loc1-score-min     OPTIONAL [0] Minimum SNPSTI.pl solution score
                                   (between 0 and 1) to allow through the
                                   filter.  Minimum is applied to locus 1
                                   (e.g. the first SNP in a greedy solution),
                                   but if locus 1 doesn't pass this criteria,
                                   locus 2 is skipped as well.
     --loc2-score-min     OPTIONAL [0] Minimum SNPSTI.pl solution score
                                   (between 0 and 1) to allow through the
                                   filter.  Minimum is applied to locus 2
                                   (e.g. the second SNP in a greedy solution).
                                   If locus 2 doesn't pass this criteria,
                                   locus 1 is still kept.
     -s|--sampleinfo-file OPTIONAL [none] Sample Info file containing
                                   descriptions for the node names found in the
                                   solutions and standard error files.  See
                                   --help for file format.
     -d|--node-desc-col   OPTIONAL ["2 3 4"] The column numbers where node
                                   descriptions can be found (joined together
                                   using --desc-delimiter and --desc-prepends).
     --desc-prepends      OPTIONAL ["Main- Major- Minor-"] These strings are
                                   prepended to the respective node description
                                   column values found in the columns supplied
                                   with -d.  Space delimited.
     --desc-delimiter     OPTIONAL [/] If multiple columns are supplied to -d,
                                   the resulting description will be joined
                                   together with this string and the strings
                                   provided to --desc-prepends.
     -p|--node-patern     OPTIONAL [^[^\(]+] Perl regular expression used to
                                   parse the node name from the string found in
                                   the column(s) indicated via -d.  Values not
                                   matching this pattern will be ignored.
     -o|--outfile-suffix  OPTIONAL [nothing] This suffix is added to the input
                                   file names to use as output files.
                                   Redirecting a file into this script will
                                   result in the output file name to be "STDIN"
                                   with your suffix appended.  See --help for a
                                   description of the output file format.
     --outdir             OPTIONAL [input file location] Supply a directory to
                                   put output files.  Note, if there are input
                                   files from multiple directories going into
                                   one output directory, they must not have the
                                   same file name or they will be over-written.
                                   This option requires an outfile suffix be
                                   supplied (though an empty string is
                                   allowed).  See --help for advanced usage.
     --force|--overwrite  OPTIONAL Force overwrite of existing output files.
                                   Only used when the -o option is supplied.
     --ignore             OPTIONAL Ignore critical errors & continue
                                   processing.  (Errors will still be
                                   reported.)  See --force to not exit when
                                   existing output files are found.
     --verbose            OPTIONAL Verbose mode.  Cannot be used with the quiet
                                   flag.  Verbosity level can be increased by
                                   supplying a number (e.g. --verbose 2) or by
                                   supplying the --verbose flag multiple times.
     --quiet              OPTIONAL Quiet mode.  Suppresses warnings and errors.
                                   Cannot be used with the verbose or debug
                                   flags.
     --help               OPTIONAL Print an explanation of the script and its
                                   input/output files.
     --version            OPTIONAL Print software version number.  If verbose
                                   mode is on, it also prints the template
                                   version used to standard error.
     --debug              OPTIONAL Debug mode.  Adds debug output to STDERR and
                                   prepends trace information to warning and
                                   error messages.  Cannot be used with the
                                   --quiet flag.  Debug level can be increased
                                   by supplying a number (e.g. --debug 2) or by
                                   supplying the --debug flag multiple times.
     --noheader           OPTIONAL Suppress commented header output.  Without
                                   this option, the script version, date/time,
                                   and command-line information will be printed
                                   at the top of all output files commented
                                   with '#' characters.
     --error-type-limit   OPTIONAL [50] Limit errors and warnings to this
                                   number of each error/warning type.  A value
                                   of 0 means there is no limit.  Use --quiet
                                   to suppress all errors and warnings.

end_print
      }

    return(0);
  }


##
## Subroutine that prints formatted verbose messages.  Specifying a 1 as the
## first argument prints the message in overwrite mode (meaning subsequence
## verbose, error, warning, or debug messages will overwrite the message
## printed here.  However, specifying a hard return as the first character will
## override the status of the last line printed and keep it.  Global variables
## keep track of print length so that previous lines can be cleanly
## overwritten.
##
sub verbose
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 1 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

#    #Ignore the overwrite flag if STDOUT will be mixed in
#    $overwrite_flag = 0 if(isStandardOutputToTerminal());

    #Read in the message
    my $verbose_message = join('',grep {defined($_)} @_);

    $overwrite_flag = 1 if(!$overwrite_flag && $verbose_message =~ /\r/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\n|\t/)
	  {
	    warning('Hard returns and tabs cause overwrite mode to not work ',
		    'properly.');
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    #If this message is not going to be over-written (i.e. we will be printing
    #a \n after this verbose message), we can reset verbose_length to 0 which
    #will cause $main::last_verbose_size to be 0 the next time this is called
    if(!$overwrite_flag)
      {$verbose_length = 0}
    #If there were \r's in the verbose message submitted (after the last \n)
    #Calculate the verbose length as the largest \r-split string
    elsif($verbose_message =~ /\r[^\n]*$/)
      {
	my $tmp_message = $verbose_message;
	$tmp_message =~ s/.*\n//;
	($verbose_length) = sort {length($b) <=> length($a)}
	  split(/\r/,$tmp_message);
      }
    #Otherwise, the verbose_length is the size of the string after the last \n
    elsif($verbose_message =~ /([^\n]*)$/)
      {$verbose_length = length($1)}

    #If the buffer is not being flushed, the verbose output doesn't start with
    #a \n, and output is to the terminal, make sure we don't over-write any
    #STDOUT output
    #NOTE: This will not clean up verbose output over which STDOUT was written.
    #It will only ensure verbose output does not over-write STDOUT output
    #NOTE: This will also break up STDOUT output that would otherwise be on one
    #line, but it's better than over-writing STDOUT output.  If STDOUT is going
    #to the terminal, it's best to turn verbose off.
    if(!$| && $verbose_message !~ /^\n/ && isStandardOutputToTerminal())
      {
	#The number of characters since the last flush (i.e. since the last \n)
	#is the current cursor position minus the cursor position after the
	#last flush (thwarted if user prints \r's in STDOUT)
	#NOTE:
	#  tell(STDOUT) = current cursor position
	#  sysseek(STDOUT,0,1) = cursor position after last flush (or undef)
	my $num_chars = sysseek(STDOUT,0,1);
	if(defined($num_chars))
	  {$num_chars = tell(STDOUT) - $num_chars}
	else
	  {$num_chars = 0}

	#If there have been characters printed since the last \n, prepend a \n
	#to the verbose message so that we do not over-write the user's STDOUT
	#output
	if($num_chars > 0)
	  {$verbose_message = "\n$verbose_message"}
      }

    #Overwrite the previous verbose message by appending spaces just before the
    #first hard return in the verbose message IF THE VERBOSE MESSAGE DOESN'T
    #BEGIN WITH A HARD RETURN.  However note that the length stored as the
    #last_verbose_size is the length of the last line printed in this message.
    if($verbose_message =~ /^([^\n]*)/ && $main::last_verbose_state &&
       $verbose_message !~ /^\n/)
      {
	my $append = ' ' x ($main::last_verbose_size - length($1));
	unless($verbose_message =~ s/\n/$append\n/)
	  {$verbose_message .= $append}
      }

    #If you don't want to overwrite the last verbose message in a series of
    #overwritten verbose messages, you can begin your verbose message with a
    #hard return.  This tells verbose() to not overwrite the last line that was
    #printed in overwrite mode.

    #Print the message to standard error
    print STDERR ($verbose_message,
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }

sub verboseOverMe
  {verbose(1,@_)}

##
## Subroutine that prints errors with a leading program identifier containing a
## trace route back to main to see where all the subroutine calls were from,
## the line number of each call, an error number, and the name of the script
## which generated the error (in case scripts are called via a system call).
## Globals used defined in main: error_limit, quiet, verbose
## Globals used defined in here: error_hash, error_number
## Globals used defined in subs: last_verbose_state, last_verbose_size
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@error_message,'') unless(scalar(@error_message));
    pop(@error_message) if(scalar(@error_message) > 1 &&
			   $error_message[-1] !~ /\S/);

    $main::error_number++;
    my $leader_string = "ERROR$main::error_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);

    #Build a trace-back string.  This will be used for tracking the number of
    #each type of error as well as embedding into the error message in debug
    #mode.
    $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;
    @caller_info = caller(0);
    $line_num = $caller_info[2];
    $caller_string = '';
    $stack_level = 1;
    while(@caller_info = caller($stack_level))
      {
	my $calling_sub = $caller_info[3];
	$calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	$calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	$caller_string .= "$calling_sub(LINE$line_num):"
	  if(defined($line_num));
	$line_num = $caller_info[2];
	$stack_level++;
      }
    $caller_string .= "MAIN(LINE$line_num):";

    if($DEBUG)
      {$leader_string .= "$script:$caller_string"}

    $leader_string .= ' ';
    my $leader_length = length($leader_string);

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Clean up any previous verboseOverMe output that may be longer than the
    #first line of the error message, put leader string at the beginning of
    #each line of the message, and indent each subsequent line by the length
    #of the leader string
    my $error_string = $leader_string . shift(@error_message) .
      ($verbose && defined($main::last_verbose_state) &&
       $main::last_verbose_state ?
       ' ' x ($main::last_verbose_size - $error_length) : '') . "\n";
    foreach my $line (@error_message)
      {$error_string .= (' ' x $leader_length) . $line . "\n"}

    #If the global error hash does not yet exist, store the first example of
    #this error type
    if(!defined($main::error_hash) ||
       !exists($main::error_hash->{$caller_string}))
      {
	$main::error_hash->{$caller_string}->{EXAMPLE}    = $error_string;
	$main::error_hash->{$caller_string}->{EXAMPLENUM} =
	  $main::error_number;

	$main::error_hash->{$caller_string}->{EXAMPLE} =~ s/\n */ /g;
	$main::error_hash->{$caller_string}->{EXAMPLE} =~ s/ $//g;
	$main::error_hash->{$caller_string}->{EXAMPLE} =~ s/^(.{100}).+/$1.../;
      }

    #Increment the count for this error type
    $main::error_hash->{$caller_string}->{NUM}++;

    #Print the error unless it is over the limit for its type
    if($error_limit == 0 ||
       $main::error_hash->{$caller_string}->{NUM} <= $error_limit)
      {
	print STDERR ($error_string);

	#Let the user know if we're going to start suppressing errors of this
	#type
	if($error_limit &&
	   $main::error_hash->{$caller_string}->{NUM} == $error_limit)
	  {print STDERR ($leader_string,"NOTE: Further errors of this type ",
			 "will be suppressed.\n$leader_string",
			 "Set --error-type-limit to 0 to turn off error ",
			 "suppression\n")}
      }

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that prints warnings with a leader string containing a warning
## number
##
## Globals used defined in main: error_limit, quiet, verbose
## Globals used defined in here: warning_hash, warning_number
## Globals used defined in subs: last_verbose_state, last_verbose_size
##
sub warning
  {
    return(0) if($quiet);

    $main::warning_number++;

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@warning_message,'') unless(scalar(@warning_message));
    pop(@warning_message) if(scalar(@warning_message) > 1 &&
			     $warning_message[-1] !~ /\S/);

    my $leader_string = "WARNING$main::warning_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);

    #Build a trace-back string.  This will be used for tracking the number of
    #each type of warning as well as embedding into the warning message in
    #debug mode.
    $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;
    @caller_info = caller(0);
    $line_num = $caller_info[2];
    $caller_string = '';
    $stack_level = 1;
    while(@caller_info = caller($stack_level))
      {
	my $calling_sub = $caller_info[3];
	$calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	$calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	$caller_string .= "$calling_sub(LINE$line_num):"
	  if(defined($line_num));
	$line_num = $caller_info[2];
	$stack_level++;
      }
    $caller_string .= "MAIN(LINE$line_num):";

    if($DEBUG)
      {$leader_string .= "$script:$caller_string"}

    $leader_string   .= ' ';
    my $leader_length = length($leader_string);

    #Figure out the length of the first line of the error
    my $warning_length = length(($warning_message[0] =~ /\S/ ?
				 $leader_string : '') .
				$warning_message[0]);

    #Clean up any previous verboseOverMe output that may be longer than the
    #first line of the warning message, put leader string at the beginning of
    #each line of the message and indent each subsequent line by the length
    #of the leader string
    my $warning_string =
      $leader_string . shift(@warning_message) .
	($verbose && defined($main::last_verbose_state) &&
	 $main::last_verbose_state ?
	 ' ' x ($main::last_verbose_size - $warning_length) : '') .
	   "\n";
    foreach my $line (@warning_message)
      {$warning_string .= (' ' x $leader_length) . $line . "\n"}

    #If the global warning hash does not yet exist, store the first example of
    #this warning type
    if(!defined($main::warning_hash) ||
       !exists($main::warning_hash->{$caller_string}))
      {
	$main::warning_hash->{$caller_string}->{EXAMPLE}    = $warning_string;
	$main::warning_hash->{$caller_string}->{EXAMPLENUM} =
	  $main::warning_number;

	$main::warning_hash->{$caller_string}->{EXAMPLE} =~ s/\n */ /g;
	$main::warning_hash->{$caller_string}->{EXAMPLE} =~ s/ $//g;
	$main::warning_hash->{$caller_string}->{EXAMPLE} =~
	  s/^(.{100}).+/$1.../;
      }

    #Increment the count for this warning type
    $main::warning_hash->{$caller_string}->{NUM}++;

    #Print the warning unless it is over the limit for its type
    if($error_limit == 0 ||
       $main::warning_hash->{$caller_string}->{NUM} <= $error_limit)
      {
	print STDERR ($warning_string);

	#Let the user know if we're going to start suppressing warnings of this
	#type
	if($error_limit &&
	   $main::warning_hash->{$caller_string}->{NUM} == $error_limit)
	  {print STDERR ($leader_string,"NOTE: Further warnings of this ",
			 "type will be suppressed.\n$leader_string",
			 "Set --error-type-limit to 0 to turn off error ",
			 "suppression\n")}
      }

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that gets a line of input and accounts for carriage returns that
## many different platforms use instead of hard returns.  Note, it uses a
## global array reference variable ($infile_line_buffer) to keep track of
## buffered lines from multiple file handles.
##
sub getLine
  {
    my $file_handle = $_[0];

    #Set a global array variable if not already set
    $main::infile_line_buffer = {} if(!defined($main::infile_line_buffer));
    if(!exists($main::infile_line_buffer->{$file_handle}))
      {$main::infile_line_buffer->{$file_handle}->{FILE} = []}

    #If this sub was called in array context
    if(wantarray)
      {
	#Check to see if this file handle has anything remaining in its buffer
	#and if so return it with the rest
	if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) > 0)
	  {
	    return(@{$main::infile_line_buffer->{$file_handle}->{FILE}},
		   map
		   {
		     #If carriage returns were substituted and we haven't
		     #already issued a carriage return warning for this file
		     #handle
		     if(s/\r\n|\n\r|\r/\n/g &&
			!exists($main::infile_line_buffer->{$file_handle}
				->{WARNED}))
		       {
			 $main::infile_line_buffer->{$file_handle}->{WARNED}
			   = 1;
			 warning('Carriage returns were found in your file ',
				 'and replaced with hard returns.');
		       }
		     split(/(?<=\n)/,$_);
		   } <$file_handle>);
	  }
	
	#Otherwise return everything else
	return(map
	       {
		 #If carriage returns were substituted and we haven't already
		 #issued a carriage return warning for this file handle
		 if(s/\r\n|\n\r|\r/\n/g &&
		    !exists($main::infile_line_buffer->{$file_handle}
			    ->{WARNED}))
		   {
		     $main::infile_line_buffer->{$file_handle}->{WARNED}
		       = 1;
		     warning('Carriage returns were found in your file ',
			     'and replaced with hard returns.');
		   }
		 split(/(?<=\n)/,$_);
	       } <$file_handle>);
      }

    #If the file handle's buffer is empty, put more on
    if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) == 0)
      {
	my $line = <$file_handle>;
	#The following is to deal with files that have the eof character at the
	#end of the last line.  I may not have it completely right yet.
	if(defined($line))
	  {
	    if($line =~ s/\r\n|\n\r|\r/\n/g &&
	       !exists($main::infile_line_buffer->{$file_handle}->{WARNED}))
	      {
		$main::infile_line_buffer->{$file_handle}->{WARNED} = 1;
		warning('Carriage returns were found in your file and ',
			'replaced with hard returns.');
	      }
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} =
	      split(/(?<=\n)/,$line);
	  }
	else
	  {@{$main::infile_line_buffer->{$file_handle}->{FILE}} = ($line)}
      }

    #Shift off and return the first thing in the buffer for this file handle
    return($_ = shift(@{$main::infile_line_buffer->{$file_handle}->{FILE}}));
  }

##
## This subroutine allows the user to print debug messages containing the line
## of code where the debug print came from and a debug number.  Debug prints
## will only be printed (to STDERR) if the debug option is supplied on the
## command line.
##
sub debug
  {
    return(0) unless($DEBUG);

    $main::debug_number++;

    #Gather and concatenate the error message and split on hard returns
    my @debug_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@debug_message,'') unless(scalar(@debug_message));
    pop(@debug_message) if(scalar(@debug_message) > 1 &&
			   $debug_message[-1] !~ /\S/);

    #Assign the values from the calling subroutine
    #but if called from main, assign the values from main
    my($junk1,$junk2,$line_num,$calling_sub);
    (($junk1,$junk2,$line_num,$calling_sub) = caller(1)) ||
      (($junk1,$junk2,$line_num) = caller());

    #Edit the calling subroutine string
    $calling_sub =~ s/^.*?::(.+)$/$1:/ if(defined($calling_sub));

    my $leader_string = "DEBUG$main::debug_number:LINE$line_num:" .
      (defined($calling_sub) ? $calling_sub : '') .
	' ';

    #Figure out the length of the first line of the error
    my $debug_length = length(($debug_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $debug_message[0]);

    #Put location information at the beginning of each line of the message
    print STDERR ($leader_string,
		  shift(@debug_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $debug_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@debug_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## This sub marks the time (which it pushes onto an array) and in scalar
## context returns the time since the last mark by default or supplied mark
## (optional) In array context, the time between all marks is always returned
## regardless of a supplied mark index
## A mark is not made if a mark index is supplied
## Uses a global time_marks array reference
##
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set to contain (as the first
    #element) the time the program started (NOTE: "$^T" is a perl variable that
    #contains the start time of the script)
    $main::time_marks = [$^T] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error('Supplied time mark index is larger than the size of the ',
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = $time - $main::time_marks->[$mark_index];

    #Add the current time to the time marks array
    push(@$main::time_marks,$time)
      if(!defined($_[0]) || scalar(@$main::time_marks) == 0);

    #If called in array context, return time between all marks
    if(wantarray)
      {
	if(scalar(@$main::time_marks) > 1)
	  {return(map {$main::time_marks->[$_ - 1] - $main::time_marks->[$_]}
		  (1..(scalar(@$main::time_marks) - 1)))}
	else
	  {return(())}
      }

    #Return the time since the time recorded at the supplied time mark index
    return($time_since_mark);
  }

##
## This subroutine reconstructs the command entered on the command line
## (excluding standard input and output redirects).  The intended use for this
## subroutine is for when a user wants the output to contain the input command
## parameters in order to keep track of what parameters go with which output
## files.
##
sub getCommand
  {
    my $perl_path_flag = $_[0];
    my($command);

    #Determine the script name
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Put quotes around any parameters containing un-escaped spaces or astericks
    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\\)[\s\*]/ || $arg eq '')
	 {$arg = "'" . $arg . "'"}}

    #Determine the perl path used (dependent on the `which` unix built-in)
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }

    #Build the original command
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }

##
## This subroutine checks for files with spaces in the name before doing a glob
## (which breaks up the single file name improperly even if the spaces are
## escaped).  The purpose is to allow the user to enter input files using
## double quotes and un-escaped spaces as is expected to work with many
## programs which accept individual files as opposed to sets of files.  If the
## user wants to enter multiple files, it is assumed that space delimiting will
## prompt the user to realize they need to escape the spaces in the file names.
##
sub sglob
  {
    my $command_line_string = $_[0];
    unless(defined($command_line_string))
      {
	warning("Undefined command line string encountered.");
	return($command_line_string);
      }
    return(sort {$a cmp $b} map {my @x = bsd_glob($_);scalar(@x) ? @x : $_}
	   split(/(?<!\\)\s+/,$command_line_string));
  }


sub getVersion
  {
    my $full_version_flag = $_[0];
    my $template_version_number = '1.44';
    my $version_message = '';

    #$software_version_number  - global
    #$created_on_date          - global
    #$verbose                  - global

    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    if($created_on_date eq 'DATE HERE')
      {$created_on_date = 'UNKNOWN'}

    $version_message  = '#' . join("\n#",
				   ("$script Version $software_version_number",
				    " Created: $created_on_date",
				    " Last modified: $lmd"));

    if($full_version_flag)
      {
	$version_message .= "\n#" .
	  join("\n#",
	       ('Generated using perl_script_template.pl ' .
		"Version $template_version_number",
		' Created: 5/8/2006',
		' Author:  Robert W. Leach',
		' Contact: rwleach@ccr.buffalo.edu',
		' Company: Center for Computational Research',
		' Copyright 2008'));
      }

    return($version_message);
  }

#This subroutine is a check to see if input is user-entered via a TTY (result
#is non-zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note,
#explicit prints to STDOUT when another output handle is selected are not
#considered and may defeat this subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}

#This subroutine exits the current process.  Note, you must clean up after
#yourself before calling this.  Does not exit if $ignore_errors is true.  Takes
#the error number to supply to exit().
sub quit
  {
    my $errno = $_[0];

    if(!defined($errno))
      {$errno = -1}
    elsif($errno !~ /^[+\-]?\d+$/)
      {
	error("Invalid argument: [$errno].  Only integers are accepted.  Use ",
	      "error() or warn() to supply a message, then call quit() with ",
	      "an error number.");
	$errno = -1;
      }

    debug("Exit status: [$errno].");

    #Exit if we are not ignoring errors or if there were no errors at all
    exit($errno) if(!$ignore_errors || $errno == 0);
  }

sub printRunReport
  {
    my $extended = $_[0];

    return(0) if($quiet);

    #Report the number of errors, warnings, and debugs on STDERR
    print STDERR ("\n",'Done.  EXIT STATUS: [',
		  'ERRORS: ',
		  ($main::error_number ? $main::error_number : 0),' ',
		  'WARNINGS: ',
		  ($main::warning_number ? $main::warning_number : 0),
		  ($DEBUG ?
		   ' DEBUGS: ' .
		   ($main::debug_number ? $main::debug_number : 0) : ''),' ',
		  'TIME: ',scalar(markTime(0)),"s]");

    #If the user wants the extended report
    if($extended)
      {
	if($main::error_number || $main::warning_number)
	  {print STDERR " SUMMARY:\n"}
	else
	  {print STDERR "\n"}

	#If there were errors
	if($main::error_number)
	  {
	    foreach my $err_type
	      (sort {$main::error_hash->{$a}->{EXAMPLENUM} <=>
		       $main::error_hash->{$b}->{EXAMPLENUM}}
	       keys(%$main::error_hash))
	      {print STDERR ("\t",$main::error_hash->{$err_type}->{NUM},
			     " ERROR",
			     ($main::error_hash->{$err_type}->{NUM} > 1 ?
			      'S' : '')," LIKE: [",
			     $main::error_hash->{$err_type}->{EXAMPLE},"]\n")}
	  }

	#If there were warnings
	if($main::warning_number)
	  {
	    foreach my $warn_type
	      (sort {$main::warning_hash->{$a}->{EXAMPLENUM} <=>
		       $main::warning_hash->{$b}->{EXAMPLENUM}}
	       keys(%$main::warning_hash))
	      {print STDERR ("\t",$main::warning_hash->{$warn_type}->{NUM},
			     " WARNING",
			     ($main::warning_hash->{$warn_type}->{NUM} > 1 ?
			      'S' : '')," LIKE: [",
			     $main::warning_hash->{$warn_type}->{EXAMPLE},
			     "]\n")}
	  }
      }
    else
      {print STDERR "\n"}

    if($main::error_number || $main::warning_number)
      {print STDERR ("\tScroll up to inspect full errors/warnings ",
		     "in-place.\n")}
  }

#This parses the sample info file
sub getDescHash
  {
    my $file        = $_[0];
    my $indexes     = $_[1];
    my $prepends    = $_[2];
    my $delimiter   = $_[3];
    my $node_pat    = $_[4];
    my $hash        = {};
    my $backup_hash = {};

    my $largest_col = (sort {$b <=> $a} @$indexes)[0] + 1;

    #Open the input file
    if(!open(FILE,$file))
      {
	#Report an error and iterate if there was an error
	error("Unable to open sample info file: [$file].\n$!");
	return($hash);
      }
    else
      {verbose("[$file] Opened sample info file.")}

    while(getLine(*FILE))
      {
	next if(/^#/ || /^\s*$/);
	chomp;
	my @x = split(/\t/,$_);
	if(scalar(@x) < $largest_col)
	  {
	    warning("Too few columns in file: [$file] line: [$_].");
	    next;
	  }
	my $path = '';
	my $backup_path = '';
	my $cnt = 0;
	foreach my $i (@$indexes)
	  {
	    if($x[$i] =~ /(.*?($node_pat).*)/)
	      {
		my $name = $1;
		my $node = $2;
		unless(exists($hash->{$node}))
		  {
		    $hash->{$node}->{DESC} .= $path .
		      ($path eq '' ? '' : $delimiter) . $prepends->[$cnt] .
			$name;
		    $path = $hash->{$node}->{DESC};
		    $backup_path = $path;
		  }
		$hash->{$node}->{NUM}++;
	      }
	    else
	      {
		warning("Unmatched node description: [$x[$i]] using pattern ",
			"(-p): [$node_pat].");
		unless(exists($hash->{$x[$i]}))
		  {
		    $backup_hash->{$x[$i]}->{DESC} = $backup_path .
		      ($backup_path eq '' ? '' : $delimiter) .
			$prepends->[$i] . $x[$i];
		    $backup_path = $backup_hash->{$x[$i]}->{DESC};
		  }
		$backup_hash->{$x[$i]}->{NUM}++;
	      }
	    $cnt++;
	  }
      }

    close(FILE);

    return(scalar(keys(%$hash)) ? $hash : $backup_hash);
  }

sub getSensitivitySpecificity
  {
    my $instates     = $_[0]; #[[?,state_str,numer,denom],
                              # [?,state_str,numer,denom],...]
    my $states       = $_[1]; #From @states in main
    my $node_size    = $_[2]; #From $desc_hash->{$node}->{NUM}
    my $extras_array = [];

    my $first_time         = 1;
    my $num_targets_state1 = 0;
    my $total_state1       = 0;
    my $num_targets_state2 = 0;
    my $total_state2       = 1; #Def to 1 so no div. by 0 if no state2 exists
    my $state1             = '';
    my $state2             = '';

    #Sort by descending numerator
    foreach my $instate (sort {$b->[2] <=> $a->[2] || $a->[3] <=> $b->[3]}
			 @$instates)
      {
	my $state_str = $instate->[1];
	my $numer     = $instate->[2];
	my $denom     = $instate->[3];

	debug("Doing state [$state_str] numer [$numer] denom [$denom].");

	#If this is the first time through the loop, this is the first and most
	#abundant state, so record what locus 1 and 2 are.
	if($first_time)
	  {
	    debug("Setting locus states.");

	    if($state_str =~ /^(\S)(\S)$/)
	      {
		$state1 = $1;
		$state2 = $2 || '';
		#Push on the call for locus 1
		push(@$extras_array,convertState($state1,$states));
		#Push on the call for locus 2
		push(@$extras_array,convertState($state2,$states));
		#Push on the combined specificity and sensitivity
		push(@$extras_array,($numer/$denom,$numer/$node_size));
		$total_state2 = 0;
	      }
	    elsif($state_str =~ /^(\S)$/)
	      {
		$state1 = $1;
		$state2 = '';
		#Push on the call for locus 1
		push(@$extras_array,convertState($state1,$states));
		#Push on the call for locus 2
		push(@$extras_array,convertState($state2,$states));
		#Push on the combined specificity and sensitivity
		push(@$extras_array,($numer/$denom,$numer/$node_size));
	      }
	  }

	#If the current state has locus 1 as the same state as its most
	#abundant (i.e. first state), sum its numerator and denominator, (i.e.
	#the number of targets in this state and the total number of samples in
	#this state
	if($state_str =~ /^$state1/)
	  {
	    debug("Adding state1's numer $numer and denom $denom.");
	    $num_targets_state1 += $numer;
	    $total_state1       += $denom;
	  }

	#If there is a second locus
	if($state2 ne '')
	  {
	    #If the current state has locus 2 as the same state as its most
	    #abundant (i.e. first state), sum its numerator and denominator,
	    #(i.e. the number of targets in this state and the total number of
	    #samples in this state
	    if($state_str =~ /^[\.ATGC\-]$state2/)
	      {
		debug("Adding state2's numer $numer and denom $denom.");
		$num_targets_state2 += $numer;
		$total_state2       += $denom;
	      }
	  }

	$first_time = 0;
      }

    debug("Result of locus 2 spec & sens: [$num_targets_state2/$total_state2 ",
	  "& $num_targets_state2/$node_size].");

    push(@$extras_array,($num_targets_state1/$total_state1,
			 $num_targets_state1/$node_size,
			 ($num_targets_state2/$total_state2 || ""),
			 ($num_targets_state2/$node_size) || ""));

    return(wantarray ? @$extras_array : $extras_array);
  }

sub convertStates
  {
    my $instates = $_[0]; #[[?,state_str,numer,denom],
                          # [?,state_str,numer,denom],...]
    my $states   = $_[1];

    my $outstates = [];

    #Sort by descending numerator
    foreach my $instate (sort {$b->[2] <=> $a->[2] || $a->[3] <=> $b->[3]}
			 @$instates)
      {
	my $state_str = $instate->[1];
	my $numer     = $instate->[2];
	my $denom     = $instate->[3];

	#Convert the states
	$state_str =~ s/\./$states->[0],/g;
	$state_str =~ s/[A1]/$states->[1],/g if(scalar(@$states) > 1);
	$state_str =~ s/[T2]/$states->[2],/g if(scalar(@$states) > 2);
	$state_str =~ s/[G3]/$states->[3],/g if(scalar(@$states) > 3);
	$state_str =~ s/[C4]/$states->[4],/g if(scalar(@$states) > 4);
	$state_str =~ s/[\-5]/$states->[5],/g if(scalar(@$states) > 5);
	$state_str =~ s/,$//g;

	push(@$outstates,"$state_str($numer/$denom)");
      }

    return(wantarray ? @$outstates : $outstates);
  }

sub convertState
  {
    my $state = $_[0];
    my $states = $_[1];
    my $outstate = 'err';

    if($state eq '' || !defined($state))
      {$outstate = ''}
    elsif($state =~ /^\.$/)
      {$outstate = $states->[0]}
    elsif($state =~ /^[A1]$/)
      {$outstate = $states->[1] if(scalar(@$states) > 1)}
    elsif($state =~ /^[T2]$/)
      {$outstate = $states->[2] if(scalar(@$states) > 2)}
    elsif($state =~ /^[G3]$/)
      {$outstate = $states->[3] if(scalar(@$states) > 3)}
    elsif($state =~ /^[C4]$/)
      {$outstate = $states->[4] if(scalar(@$states) > 4)}
    elsif($state =~ /^[\-5]$/)
      {$outstate = $states->[5] if(scalar(@$states) > 5)}

    return($outstate);
  }
