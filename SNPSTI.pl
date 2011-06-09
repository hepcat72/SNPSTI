#!/usr/bin/perl

#This script was copied from version 1.11 of SNPSTI.pl and is enhanced to run
#in low_memory mode with the -l option (slower, but uses less memory)

#Robert W. Leach
#4/12/04
#Los Alamos National Laboratory
#Copyright 2004

#USAGE: SNPSTI.pl -s SNP_infile -t Tree_infile [-v] [-h] [-m num] [-n num]
#Execute SNPSTI.pl -h to see a description of this program

#Keep track of the programs running time (reported in verbose mode)
my $time = time();

#Set the buffer to autoflush
$| = 1;

#Set up a path to the tree module on the cluster using the environment variable
#"SNPSTI_CLUSTER_TREE_PATH"
BEGIN
  {if(exists($ENV{SNPSTI_CLUSTER_TREE_PATH}) && $ENV{SNPSTI_CLUSTER_TREE_PATH} ne '')
     {use lib $ENV{SNPSTI_CLUSTER_TREE_PATH}}}

#If this is a run on the cluster, read in arguments from the environment
#variable "SNPSTI_CLUSTER_PARAMS"
my $cluster_run = 0;
my $host = (exists($ENV{HOSTNAME}) ?
	    $ENV{HOSTNAME} :
	    (exists($ENV{HOST}) ?
	     $ENV{HOST} : `hostname`));
chomp($host);
if(scalar(@ARGV) == 0 &&
   exists($ENV{SNPSTI_CLUSTER_PARAMS}) &&
   $ENV{SNPSTI_CLUSTER_PARAMS} ne '')
  {
    @ARGV = glob($ENV{SNPSTI_CLUSTER_PARAMS});
    $cluster_run = 1;
  }
if(exists($ENV{SNPSTI_CLUSTER_TREE_PATH}))
  {$cluster_run = 1}

#Declare/initialize variables
my $framesort_warning = 0;  #Global variable for isSolution
#my $snp_data          = [];
my $snp_names         = [];
my $genome_names      = [];
my $non_binary_nodes  = [];
my $all_snps_used     = {};
my $solutions         = {};
my $snp_data_buffer   = [];
my $partial_suffix    = '.prtl';
my($treefile,$snpfile,$verbose,$max_set_size_per_node,$help,$tree,$label_array,
   $num_SNPs,$num_genomes,$node_list,$solution_array,$framesort,$start_node,
   $min_num_solns_per_node,$breadth_first_order,$reverse_order,
   $skip_input_check,$internal_nodes_only,$leaves_only,@analyze_nodes,
   $min_set_size_per_node,$low_memory_mode,$greedy_flag,$max_greedies,
   $quality_ratio,$equal_chance,$min_indep_solns_per_node,$start_cutoff_size
  );
my $quiet = 0;
my $preserve_args = [@ARGV];

#Library for tree data structure
use tree;
my $tree = tree->new();

#Get the input options
use Getopt::Long;
GetOptions('t|treefile=s'            => \$treefile,
	   's|snpfile=s'             => \$snpfile,
	   'v|verbose!'              => \$verbose,
	   'q|quiet!'                => \$quiet,
	   'm|maxsize=s'             => \$max_set_size_per_node,
	   'z|minsize=s'             => \$min_set_size_per_node,
	   'h|help!'                 => \$help,
	   'p|start-cutoff-size=s'   => \$start_cutoff_size,
	   'n|minsolns=s'            => \$min_num_solns_per_node,
	   'j|minindeps=s'           => \$min_indep_solns_per_node,
	   'f|framesort!'            => \$framesort,
	   'l|low-memory-mode!'      => \$low_memory_mode,
	   'k|skip-input-check!'     => \$skip_input_check,
	   'b|breadth-first!'        => \$breadth_first_order,
	   'r|reverse-order!'        => \$reverse_order,
	   'i|internal-nodes-only!'  => \$internal_nodes_only,
	   'e|leaves-only!'          => \$leaves_only,
           'g|greedy!'               => \$greedy_flag,
           'partial-suffix=s'        => \$partial_suffix,
           'x|max-greedies=s'        => \$max_greedies,
           'u|quality-ratio=s'       => \$quality_ratio,
	   'c|chance=s'              => \$equal_chance,
	   'a|start-node=s'          => \$start_node,
	   '<>'                      => sub {push(@analyze_nodes,$_[0])});

#Set a max solution set size (i.e. number of SNPs) per phylogenetic tree branch
#because the running time other wise is:
#O(number_of_snps * (number_of_snps choose number_of_snps))
$max_set_size_per_node    = 3 unless($max_set_size_per_node =~ /^\d+$/);
$min_set_size_per_node    = 1 unless($min_set_size_per_node =~ /^\d+$/);
$min_num_solns_per_node   = 0 unless($min_num_solns_per_node =~ /^\d+$/);
$min_indep_solns_per_node = 0 unless($min_indep_solns_per_node =~ /^\d+$/);
$start_cutoff_size = ($start_cutoff_size =~ /^\d+$/ ?
		      $start_cutoff_size :
		      ($min_set_size_per_node > 3 ?
		       $min_set_size_per_node : 3));

#If the minimum number of independent solutions per node is 1, set it to 0 and
#change the minimum number of solutions per node to 1.  This saves work because
#independent solutions do not need to be calculated and is effectively the same
#outcome.  Plus, it utilizes the small solutions inside large solutions logic.
if($min_indep_solns_per_node == 1)
  {
    $min_indep_solns_per_node = 0;
    $min_num_solns_per_node   = 1;
  }

if($max_set_size_per_node < $min_set_size_per_node)
  {
    error("Your maximum solution size: [$max_set_size_per_node] is less than ",
	  "your minimum: [$min_set_size_per_node].");
    exit(1);
  }

if($min_set_size_per_node > 1)
  {
    warning("By not using the default minimum solution size (1), you may see ",
	    "smaller solutions repeated in all possible combinations.");
    exit(2);
  }

#$snp_data_buffer_size = $max_set_size_per_node * $low_memory_mode;

#If they have asked for help
if($help)
  {
    help();
    exit(0);
  }

#If the required parameters are not supplied
if(!$snpfile || !$treefile)
  {
    #Print the usage statement and exit
    usage();
    exit(3);
  }

if($internal_nodes_only && $leaves_only)
  {
    error("You cannot use the [-i] and [-e] flags together!");
    usage();
    exit(4);
  }

if(($internal_nodes_only || $leaves_only) && $breadth_first_order)
  {
    warning("The breadth first ordering (flag [-b]) is being ignored because ",
	    "it doesn't work with the [-i] or [-e] flags.");
    $breadth_first_order = 0;
  }

print STDERR ("Running on cluster node: [$host].\n") if($cluster_run);

#Load and validate the SNP data (and set $snp_names and $genome_names arrays)
#No memory sensitivity method
#if(LoadSNPs($snp_data,$snp_names,$genome_names,$snpfile,$verbose,
#Column hash buffer method
#if(LoadSNPs($snp_names,$genome_names,$snpfile,$verbose,$snp_data_buffer,
#	    $snp_data_buffer_size))
#Column string buffer method
if(LoadSNPs($snp_names,$genome_names,$snpfile,$verbose,$snp_data_buffer,
	    $low_memory_mode))
  {
    help();
    exit(0);
  }
my $optimized_snps = optimizeSNPs($snp_names,$genome_names,$snp_data_buffer);

#Prepare output for partial solutions generated from greedy set building
if($greedy_flag && $partial_suffix ne '')
  {
    if(-e "$snpfile$partial_suffix")
      {error("File exists: [$snpfile$partial_suffix].  Greedy output going to STDERR")}
    else
      {
        if(scalar(@analyze_nodes))
          {$partial_suffix = '.' . $analyze_nodes[0] . $partial_suffix}
        unless(open(PRTL,">$snpfile$partial_suffix"))
          {
            error("Unable to open partial greedy set file for output [$snpfile$partial_suffix].  $!");
            exit(10);
          }
        select(PRTL);
        $|=1;
        select(STDOUT);
      }
  }

#Print out a list of equivalent SNPs to STDERR
verbose("These SNPs are equivalent:\n\t[",
	join("]\n\t[",
	     map {join(',',
		       map {$snp_names->[$_]}
		       @$_)}
	     grep {scalar(@$_) > 1}
	     @$optimized_snps),
	"]\n");

verbose("Reading tree file: [$treefile].");

#Load and validate the phylogenetic tree data
$tree->treeThis($treefile);

verbose(($skip_input_check ? "Skipping tree check" : "Error checking tree"));

if(!$skip_input_check && CheckTreeNames($tree,$genome_names,$verbose))
  {
    error("Your SNP infile and phylogenetic tree infile's genomes don't ",
	  "match.  Please correct the files and try again.");
    exit(1);
  }

#Report the command line conditions for the run
print("#",getCommand(1),"\n");
print("#Run on cluster node: [$host].\n") if($cluster_run);

#Report the name of the SNP file used
print("#INPUT SNP FILE: [$snpfile]\n");

#Report the name of the tree file used
print("#INPUT TREE FILE: [$treefile]\n\n\n");

verbose("Initializing Solution Search.");

##
## Get all the nodes to analyze in the requested order
##

my($not_found);
if(scalar(@analyze_nodes))
  {
    verbose("Checking analysis nodes: [",join(',',@analyze_nodes),"].");

    $node_list = [map {
      my $nd = $tree->dfsKeySearch($_);
      if($nd->isNullNode())
	{
	  error("Node: [$_] was not found in the tree.");
	  $not_found = 1;
	}
      $nd;
    } @analyze_nodes];
    if($not_found)
      {exit(5)}
  }
#Get all the tree's nodes in BFS order
elsif($internal_nodes_only)
  {
    $node_list = $tree->getInternalNodesInDFSOrder();
    #Take off the root node
    shift(@$node_list);
  }
elsif($leaves_only)
  {$node_list = $tree->getLeafNodes()}
elsif($breadth_first_order)
  {
    $node_list = $tree->getAllNodesInBFSOrder();
    #Take off the root node
    shift(@$node_list);
  }
else
  {
    $node_list = $tree->getAllNodesInDFSOrder();
    #Take off the root node
    shift(@$node_list);
  }

verbose("Processing Tree.");

#Make the genomes numeric
if(ConvertGenomesInTreeToIndexes($genome_names,$tree,$verbose))
  {die("ERROR:SNPSTI.pl:Your SNP infile seems to be missing genomes present ",
       "in the tree.  Please correct the files and try again.\n")}

#Set the total number of SNPs and genomes
$num_SNPs    = scalar(@$snp_names);
my $num_optimal_snps = scalar(@$optimized_snps);
$num_genomes = scalar(@$genome_names);

if($min_set_size_per_node > $num_SNPs)
  {
    error("Your minimum solution size: [$min_set_size_per_node] is greater ",
	  "than the number of available SNPs in your data file: [$num_SNPs].");
    exit(6);
  }

if($max_set_size_per_node > $num_optimal_snps)
  {$max_set_size_per_node = $num_optimal_snps}
#if($max_set_size_per_node > $num_SNPs)
#  {$max_set_size_per_node = $num_SNPs}

#Error check and handle greedy options
if(!$greedy_flag && ($max_greedies || $quality_ratio))
  {$greedy_flag = 1}
if(!defined($max_greedies))
  {$max_greedies = 20}
if(!defined($quality_ratio))
  {$quality_ratio = .1}
if($greedy_flag && $max_greedies == 0 && $quality_ratio == 0)
  {
    error("You cannot have both max-greedies (-x) and quality-ratio (-u) set ",
	  "to zero.  One must be non-zero.");
    exit(1);
  }
if($max_greedies !~ /^\d+$/ || $max_greedies > $num_SNPs)
  {
    error("max-greedies (-x) must be an integer between 1 and the number of ",
	  "SNPs: [$num_SNPs].");
    if($max_greedies > $num_SNPs)
      {
	error("Resetting max-greedies.");
	$max_greedies = $num_SNPs;
      }
    else
      {
	error("Unable to proceed due to above error.");
	exit(2);
      }
  }
if($quality_ratio !~ /^(0*\.\d+|1|0)$/ || $max_greedies > $num_SNPs)
  {
    error("max-greedies (-x) cannot be greater than the number of SNPs.  ",
	  "Resetting to maximum.");
    $max_greedies = $num_SNPs;

    #Note, I'm not turning off the greedy flag because the ultimate number of
    #greedies could be less due to the quality ratio
  }
if($greedy_flag)
  {
    verbose("Greedy_mode.\n");
    print("#Greedy_mode.\n");
  }

#Reverse the node order if requested
$node_list = [reverse(@$node_list)] if($reverse_order);

if(defined($start_node))
  {
    shift(@$node_list) while(scalar(@$node_list) &&
			     $node_list->[0]->getKey() ne $start_node);
    if(scalar(@$node_list) == 0)
      {
	error("The start node: [$start_node] was not found in the tree.");
	exit(1);
      }
  }

print("#Solutions for a node are ordered by SNP variability (i.e. amount of\n",
      "#evolutionary saturation) and frame position respectively so that\n",
      "#SNP sets that are good identifiers appear at the top.  A SNP set is\n",
      "#a good identifier if its value can tell you if it occurs under the\n",
      "#indicated phylogenetic tree node (1st column in the output).  The\n",
      "#ordering imposed here reduces the chance that the reported SNP set\n",
      "#will match an unknown by chance.\n\n\n");

verbose("Starting Search.");

my $greedy_snp_candidates       = [];
my $final_greedy_snp_candidates = [];
my($num_solns,$combos_so_far);
#For each internal node
foreach my $node (@$node_list)
  {
    verbose("\nDOING NODE: ",
	    ($node->isLeaf() ? $genome_names->[$node->getKey()] :
	     $node->getKey()));

    #Label the genomes below the current DFS node (and zero out all others)
    $label_array = LabelGenomes($num_genomes,$node);
    if(grep {$_ ne '1' && $_ ne '0'} @$label_array)
      {
	error("The label array has invalid values.  This is a bug in the ",
	      "program and is unresolvable.  Contact the developer.");
	exit(7);
      }

    #Report phylogenetic tree node location and the leaves present
    $solutions->{output}  = [];
    $solutions->{message} =
		    "#Solutions for the branch leading to node: [" .
		    ($node->isLeaf() ?
		     $genome_names->[$node->getKey()] :
		     $node->getKey()) .
		    "] containing these genomes (represented by 1s):\n";

    foreach my $genome (grep {$label_array->[$_]} (0..$#{$label_array}))
      {$solutions->{message} .= "#\t$genome_names->[$genome]\n"}

    $solutions->{message} .=
      "#NODE\tSNPs\tSIGNIFICANT LEAVES OF NUCLEOTIDE TREE (.ATGC-) " .
	"[PHYLOGENETIC TREE RELATIONSHIP: 1 = UNDER NODE, 0 = NOT UNDER " .
	  "NODE, _ = NOT IN TREE]\n";

    verbose("Optimizing search SNPs and genomes.");

    ##
    ## Collect the optimal SNPs that actually have any real SNP values for the
    ## labelled genomes (i.e. not dots)
    ##

    my $relevant_optimal_snps  = [];

    #Collect the genome indexes that are labelled
    my $labelled_genome_indexes =
      [grep {$label_array->[$_]} (0..$#{$label_array})];

    #Grab the SNPs that have any value for the labelled genomes
    @$relevant_optimal_snps =
      #Filter out SNPs that have no values for the labelled genomes
      grep {
	my $lab_gen_ind_ind = 0;
	while($lab_gen_ind_ind <= $#{$labelled_genome_indexes} &&
	      getSNP($snp_data_buffer,
		     $labelled_genome_indexes->[$lab_gen_ind_ind],
		     $optimized_snps->[$_]->[0]) eq '.')
	  {$lab_gen_ind_ind++}
	#Return whether or not all the values were dots
	#(all = false, not_all = true)
	$lab_gen_ind_ind <= $#{$labelled_genome_indexes};
      }
	(0..($num_optimal_snps - 1));

    verbose(0,
	    scalar(@$relevant_optimal_snps),
	    " out of ",
	    scalar(@$optimized_snps),
	    " SNPs considered.  Other SNPs were filtered out because ",
	    "they had all 'ignore' values for genomes under this node.");

    ##
    ## Collect the genomes that actually have real SNP values for any of the
    ## SNPs collected above
    ##

    #Eliminate any genomes that don't have any SNP values for the remaining
    #SNPs filtered above.  This should improve greedy score calculations
    #because uninvolved genomes won't dilute the scores.  Keep labelled
    #genomes whether or not they have have any SNP values
    my $remaining_snp_index = 0;
    my $relevant_genomes =
      [grep {
	my $grep_genome = $_;
	$remaining_snp_index = 0;
	while($remaining_snp_index <= $#{$relevant_optimal_snps} &&
	      getSNP($snp_data_buffer,
		     $grep_genome,
		     $optimized_snps
		     ->[$relevant_optimal_snps
			->[$remaining_snp_index]]->[0]) eq '.')
	  {$remaining_snp_index++}
	#Return whether or not all the values were dots
	#(all = false, not_all = true)
	$remaining_snp_index <= $#{$relevant_optimal_snps};
      }
       (0..$#{$genome_names})];

    verbose(0,
	    scalar(@$relevant_genomes),
	    " out of ",
	    scalar(@$genome_names),
	    " genomes considered.  Other genomes were filtered out ",
	    "because they had all 'ignore' values for the SNPs remaining ",
	    "from the previous filtering step.");

    #Now filter the label_array based on the retained genomes
    my $relevant_label_array = [map {$label_array->[$_]} @$relevant_genomes];

    if($greedy_flag)
      {
	verbose("Collecting greedy SNPs.");

	$final_greedy_snp_candidates = [];
	my $num_greedies     = 0;
	my $greedy_set_count = 0;
	my $greedy_sol_num   = 0;
        my $num_added        = 0;
	do
	  {
	    $num_added = 0;
	    my $ratio = 0;
            my $prev_ratio = 0;
	    my $scores = {};
	    $greedy_sol_num++;

	    while(1)
	      {
		$ratio = getNextGreedySNP($greedy_snp_candidates,
					  $relevant_optimal_snps,
					  $snp_data_buffer,
					  $relevant_label_array,
					  $equal_chance,
					  $snp_names,
					  $verbose,
					  $greedy_sol_num,
					  $relevant_genomes);

		$scores->{$greedy_snp_candidates->[-1]} = $ratio;

		$num_added++ unless($ratio == 1);
		$num_greedies++ unless($ratio == 1);  #Do this so we get all
                                                      #perfect SNPs plus enough
                                                      #to find alternatives
		last if($max_greedies <= $num_greedies ||
			($ratio - $prev_ratio) < $quality_ratio ||
			$ratio == 1 ||
			#I added the below check to stop greedy sets from
			#getting out of hand.  If I ever get around to fixing
			#the bug that causes greedy sets to think they're
			#improving when they're not when no SNPs that can
			#improve the previous solution exist, I should remove
			#this check
		        $num_added >= (2 * $max_set_size_per_node));
                $prev_ratio = $ratio;
	      }

	    $greedy_set_count++;
            my $greedymsg = "Greedy set $greedy_set_count: \[" .
                              join(',',
                                   map {"[$snp_names->[$optimized_snps->[$_]->[0]]]:" .
                                        "($scores->{$_})"}
                                     @$greedy_snp_candidates) .
                              "].\n";
	    verbose(1,$greedymsg);
            print PRTL $greedymsg if($partial_suffix ne '');

	    push(@$final_greedy_snp_candidates,@$greedy_snp_candidates);
	    $greedy_snp_candidates = [];
	  }
	    while(scalar(@$relevant_optimal_snps) &&
		  (($num_greedies < $max_greedies || $max_greedies == 0) &&
		   ($num_added > 1 || $quality_ratio == 0)));
print STDERR ("TEST: ",scalar(@$relevant_optimal_snps)," && (($num_greedies < $max_greedies || $max_greedies == 0) && ($num_added > 1 || $quality_ratio == 0))\n");
	#I know there are places where SNP order is important.  I can't
	#remember where that is though, so I'm going to sort the greedies here
	#just to be safe.
	@$final_greedy_snp_candidates =
	  sort {$a <=> $b} @$final_greedy_snp_candidates;

        my $greedymsg = "Final Greedy set of " . scalar(@$final_greedy_snp_candidates) . " SNPs: [" .
                join(',',
                     map {$snp_names->[$optimized_snps->[$_]->[0]]}
                     @$final_greedy_snp_candidates) .
                "].\n";
	verbose($greedymsg,"Beginning exhaustive search of the greedy SNPs.");
        print PRTL $greedymsg if($partial_suffix ne '');
      }

    verbose("SELECTED ANALYSIS SNPS:\n\t",
	    join("\n\t",
		 map {$snp_names->[$optimized_snps->[$_]->[0]]}
		 ($greedy_flag ?
		  (@$final_greedy_snp_candidates) :
		  (@$relevant_optimal_snps))),
	    "\n");
    verbose("SELECTED ANALYSIS GENOMES:\n\t",
	    join("\n\t",map {$genome_names->[$_]} @$relevant_genomes),
	    "\n");

    #Clear out the current and solution sets for each new dfs node to start
    #searching from the beginning
    #If current_set turns out to be a solution, it will be pushed onto the
    #solution set array
    my $candidate_set = [];
    my $num_indep_solns = 0;
    my(@current_set,@solution_sets);
    #Keep track of small solution sets so I can skip them when they're in
    #larger solutions
    my $small_sets = [];
    foreach my $set_size ($min_set_size_per_node..$max_set_size_per_node)
      {
	#Keep track of the new small solution sets generated so I can add them
	#to the small_sets at the end of this loop
	my $new_small_sets = [];

	verbose("\nDOING SET SIZE: $set_size",#"  Estimated Time ",
#		      "Remaining to completion: ",
#		      timeRemainingEstimate($combos_so_far,
#					    $num_SNPs,
#					    $min_set_size_per_node,
#					    $max_set_size_per_node,
#					    scalar(@$node_list)),
#		      " Seconds",
	       );

	$num_solns_per_size = 0;
	#While an unseen combination of SNPs based on n choose r still exists
	#at the current set size (n = $num_SNPs, r = $set_size)
	while(GetNextCombo(\@current_set,
			   $set_size,
			   ($greedy_flag ?
			    scalar(@$final_greedy_snp_candidates) :
#			    $num_SNPs)))
			    scalar(@$relevant_optimal_snps))))
	  {
	    $candidate_set = [];

	    if($greedy_flag)
	      {
		#create a candidate solution using the values in the
		#@current_set and at the indexes indicated in the final greedy
		#snp candidates
		foreach my $greedy_index (@current_set)
		  {push(@$candidate_set,
			$final_greedy_snp_candidates->[$greedy_index])}
	      }
	    else
	      {
		foreach my $optimal_index (@current_set)
		  {push(@$candidate_set,
			$relevant_optimal_snps->[$optimal_index])}
	      }

	    #Convert the optimal SNP indexes to real SNP indexes
	    @$candidate_set = map {$optimized_snps->[$_]->[0]} @$candidate_set;

	    if($verbose)
	      {
		$combos_so_far++;
		verbose(1,
			"Doing combination: [",
			join(',',map {$snp_names->[$_]} @$candidate_set),
			"] Solutions found: $num_solns_per_size");
	      }

	    next if($min_num_solns_per_node != 1 && scalar(@$small_sets) &&
		    smallSolutionInside($candidate_set,$small_sets));

	    #Clear out the solution array.  The solution array is an array of
	    #all the genome labels at the leaves of the solution tree.  The
	    #solution tree is a 6 degree tree with branches (.ATGC-) that lead
	    #to a genome label at each leaf (0 = not in subtree, 1 = in
	    #subtree, _ = This SNP combination doesn't occur in any of the
	    #genomes).  Each level of the six degree tree is a SNP from the
	    #current_set
	    $solution_array = [];

	    #If current_set is a solution set
	    if(isSolution($candidate_set,
			  $snp_data_buffer,
			  $relevant_genomes,
			  $label_array,
			  $solution_array))
	      {
		$num_solns_per_size++;

		#Report the node the solution is for
		push(@{$solutions->{output}},
		     ($node->isLeaf() ?
		      $genome_names->[$node->getKey()] :
		      $node->getKey()) . "\t");
		#Report the SNPs in the solution (i.e. 6 degree tree levels)
		foreach my $snp (@$candidate_set)
		  {
		    $all_snps_used->{$snp_names->[$snp]} = 1;
		    $solutions->{output}->[-1] .= "$snp_names->[$snp] ";
		  }
		#Report the leaves of the six degree tree so that the SNP
		#values can be determined
		$solutions->{output}->[-1] .= "\t" .
		    join(' ',@$solution_array) . "\n";
		push(@solution_sets,[@$candidate_set]);

		##
		## Add equivalent solutions
		##

		#Inititialize the equivalent solutions
		my $equivalent_candidate_set = [];
		#Let the first one pass because we already have it (above)
		GetNextIndepCombo($equivalent_candidate_set,
				  [map
				   {scalar(@{$optimized_snps
					       ->[($greedy_flag ?
						   $final_greedy_snp_candidates
						   ->[$_] :
						   $relevant_optimal_snps
						   ->[$_])]})}
				   @current_set]);

#verbose("ALL ZEROES: EQUIVALENT SOLUTION TO: [",
#	join(' ',map {$snp_names->[$_]} @$candidate_set),
#	"]: [",
#	join(' ',map {$snp_names->[$_]}
#	     map {$optimized_snps->[$final_greedy_snp_candidates
#				    ->[$current_set[$_]]]
#		    ->[$equivalent_candidate_set->[$_]]}
#	     (0..(scalar(@$equivalent_candidate_set) - 1))),
#	"].");

		while(GetNextIndepCombo($equivalent_candidate_set,
					[map
					 {scalar(@{
					   $optimized_snps
					     ->[($greedy_flag ?
						 $final_greedy_snp_candidates
						 ->[$_] :
						 $relevant_optimal_snps
						 ->[$_])]})}
					 @current_set]))
		  {
		    #Convert to real SNP indexes
		    #  @current_set contains the indexes into $optimized_snps
		    #    for the "equivalent arrays"
		    #  $equivalent_candidate_set contains indexes into the
		    #    "equivalent arrays"
		    #  The indexes into @current_set and
		    #    $equivalent_candidate_set correspond such that the two
		    #    indexes into both levels of $optimized_snps can be
		    #    accessed with the same index into @current_set and
		    #    $equivalent_candidate_set
		    my $equivalent_solution =
		      [map {$optimized_snps->[($greedy_flag ?
					       $final_greedy_snp_candidates
					       ->[$current_set[$_]] :
					       $relevant_optimal_snps
					       ->[$current_set[$_]])]
			      ->[$equivalent_candidate_set->[$_]]}
		       (0..(scalar(@$equivalent_candidate_set) - 1))];

#verbose("EQUIVALENT SOLUTION TO: [",join(' ',map {$snp_names->[$_]} @$candidate_set),"]: [",join(' ',map {$snp_names->[$_]} @$equivalent_solution),"].");

		    $solution_array = [];

		    if(!isSolution($equivalent_solution,
				   $snp_data_buffer,
				   $relevant_genomes,
				   $label_array,
				   $solution_array))
		      {error("Equivalent solution failed!")}

		    $num_solns_per_size++;

		    #Report the node the solution is for
		    push(@{$solutions->{output}},
			 ($node->isLeaf() ?
			  $genome_names->[$node->getKey()] :
			  $node->getKey()) . "\t");
		    #Report the SNPs in the soln. (i.e. 6 degree tree levels)
		    foreach my $snp (@$equivalent_solution)
		      {
			$all_snps_used->{$snp_names->[$snp]} = 1;
			$solutions->{output}->[-1] .= "$snp_names->[$snp] ";
		      }
		    #Report the leaves of the six degree tree so that the SNP
		    #values can be determined
		    $solutions->{output}->[-1] .= "\t" .
		      join(' ',@$solution_array) . "\n";
		    push(@solution_sets,[@$equivalent_solution]);
		  }

		#Push this set onto the new_small_sets array if we're going to
		#be moving up to the next set size to look for more solutions
		push(@$new_small_sets,[@$candidate_set])
		  if($min_num_solns_per_node != 1 &&
		     $set_size != $max_set_size_per_node &&
		     (scalar(@solution_sets) <= $min_num_solns_per_node ||
		      $min_num_solns_per_node == 0));

		$num_indep_solns = numIndepSolns(@solution_sets);

		if($start_cutoff_size == 0 || $set_size >= $start_cutoff_size)
		  {
		    if(scalar(@solution_sets) >= $min_num_solns_per_node &&
		       $min_num_solns_per_node != 0)
		      {last}

		    if($min_indep_solns_per_node != 0 &&
		       $num_indep_solns >= $min_indep_solns_per_node)
		      {last}
		  }
	      }
	  }

	#This last update will be useful if the last combination is a solution
	verbose(1,
		"Doing combination: [",
		join(',',map {$snp_names->[$_]} @$candidate_set),
		"] Solutions found: $num_solns_per_size");

	if($start_cutoff_size == 0 || ($set_size + 1) >= $start_cutoff_size)
	  {
	    #If solutions were found at the current set size, don't bother
	    #looking for solutions at larger sizes and jump out of the loop
	    last if(scalar(@solution_sets) >= $min_num_solns_per_node &&
		    $min_num_solns_per_node != 0);
	    last if($min_indep_solns_per_node != 0 &&
		    $num_indep_solns >= $min_indep_solns_per_node);
	  }

	#If solutions were found at this set size, add them to the small_sets
	#so they can be skipped at subsequent set sizes
	push(@$small_sets,@$new_small_sets) if(scalar(@$new_small_sets));
      }

    #Print the sorted solutions
    printSortedResults($solutions,$framesort);

    #Report the number of solutions found and the time taken
    verbose("\nIt took ",
	    (time() - $time),
	    " seconds to get to & finish this node: [",
	    ($node->isLeaf() ?
	     $genome_names->[$node->getKey()] :
	     $node->getKey()),
	    "].  ",
	    (scalar(@solution_sets) ?
	     join('',("Smallest solution size: [",
		      scalar(@{$solution_sets[0]}),
		      " SNPs] using a maximum set size of ",
		      "[$max_set_size_per_node] SNPs per solution and a ",
		      "minimum solution size of: [$min_set_size_per_node].")) :
	     ''));

    #Put a hard return between sets of node solutions
    print("\n");
  }

close(PRTL) if($greedy_flag && $partial_suffix ne '');

print("#TOTAL SNPS USED IN ALL SOLUTIONS (",
      scalar(keys(%$all_snps_used)),
      "):\n#\t",
      join("\n#\t",sort {$a <=> $b} keys(%$all_snps_used)),
      "\n");

#Report the total running time if in verbose mode
verbose("Total Running Time: ",(time() - $time)," seconds.");


#isSolution Subroutine
#This subroutine is recursive.  It determines whether a proposed set of SNPS
#sent in (based on their values in the snp_data sent in) can uniquely identify
#the labelled genomes in the label_array sent in.  It stores the labels in a
#solution_array representing the leaves of a 6-degree tree where each node
#has branches in this order: . (none), A, T, G, C, and - (alignment gap).
#Another generic order can be superimposed on this representing 5 evolutionary
#states: 1, 2, 3, 4, and 5.  An example of an evolutionary state would be the
#loss or acquisition of a piece of DNA such as a gene.  These two
#representations are not allowed to be mixed.  in other words, one column of
#SNP data cannot have bases (or gaps) mixed with generic states (numbers).
#This mix is not error checked for here in this subroutine.  See LoadSNPs.  The
#dot character is present to support multi-locus alignments where a number of
#genomes may simply not contain the gene with a particular SNP used in the
#analysis.  but since the lack of a result is not dependable, solutions from
#genomes that are separated on the basis that they have no SNP value are
#compared for consistency to those that did have the SNP.  In other words the
#lack of a SNP result on an array can still yield an identification, but
#solutions which differ in what they identify because of the lack of a SNP (as
#opposed to the failure of probes made for a real SNP) are eliminated.
sub isSolution
  {
    #Break off the first snp in the array and store the rest in the
    #proposed_solution which will be sent in a recursive call
    my($snp,$proposed_solution);
    ($snp,@$proposed_solution) = @{$_[0]};

    my $snp_data_buffer        = $_[1];  #Array of SNP strings
#                                         #Array
#                                         #containing SNP data columns as hashes
#                                         #NOTE that this assumes the buffer to
#                                         #contain all the SNPs in the proposed
#                                         #solution, so the buffer must be
#                                         #checked and initialized to ensure
#                                         #this every time.  It should not be
#                                         #done here because this sub is
#                                         #recursive.
    my $genome_indexes         = $_[2];  #Array of genome indexes into the SNP
                                         #data buffer
    my $label_array            = $_[3];  #Array of genome labels indexed by
                                         #genome
    my $solution_array         = $_[4];  #Leaves of a [.ATGC-] 6-degree tree
                                         #which stores labels.  Levels of the
                                         #tree represent SNPs in the entire
                                         #proposed solution
    my $skip_empty             = $_[5];  #Internal use only.  DO NOT SUPPLY.
                                         #When all the wells are empty, we can
                                         #skip this recursive call after adding
                                         #the necessary solution spacers

    #my($framesort_warning): required global variable
    my $answer = 1;  #This indicates we've found an answer

    if($skip_empty)
      {
	push(@$solution_array,
	     split('',('_' x (6 ** (scalar(@$proposed_solution) + 1)))));
	return($answer);
      }

    #The solution array is an empty array sent in.  It is populated with the
    #leaves of a 5-degree tree.  The branches are nucleotides (.ATGC- or
    #.12345) from left to right.  The number of levels corresponds to the
    #number of SNPs in the solution (left to right in the SNP solution array
    #corresponds to top down in the tree).  The tree can be reconstructed from
    #the SNPs, the .ATGC- (.12345) order, and the solution array.  The values
    #at the leaves are the labels (i.e. whether or not a genome is in the
    #phylogenetic sub-tree).  The important information is the values of the
    #SNPs when they lead to the subtree leaves.

    #Initialize variables local to this recursive call
    my $genome_types    = []; #Indicates what label a genome well contains
    my $genome_wells    = [[],[],[],[],[],[]];  #Contains genome indexes based
                                                #on the current SNP value
#  #Contains genome SNP data split
#                                                #by the current SNP values
#    my $new_label_array = [[],[],[],[],[],[]];  #labels are split the same way
#                                                #as genomes in the genome wells
#                                                #for the next recursive call

    my($matched);
    #For each genome
    foreach my $genome (sort {$label_array->[$b] <=> $label_array->[$a]}
			@$genome_indexes)
#			(0..(scalar(@$snp_data_buffer) - 1)))
      {
	my $snp_val = getSNP($snp_data_buffer,$genome,$snp);

	$matched = 0;

	#If this is the first call and this is a labelled genome
	if(!defined($skip_empty) && $label_array->[$genome])
	  {
	    my $give_up = 1;

	    #If the SNP is totally ambiguous, look ahead to see if this search
	    #will be futile (i.e. all SNPs for this labelled genome are
	    #ambiguous)
	    my $snp_val = getSNP($snp_data_buffer,$genome,$snp);
	    if($snp_val !~ /^\.$/i)
	      {$give_up = 0}
	    elsif(scalar(@$proposed_solution))
	      {
		#Foreach future SNP value for the current genome
		foreach my $snp_val (map {getSNP($snp_data_buffer,$genome,$_)}
				     @$proposed_solution)
		  {
		    #If the SNP value is not entirely ambiguous
		    if($snp_val !~ /^\.$/i)
		      {
			#Decide not to give up and move on
			$give_up = 0;
			last;
		      }
		  }
	      }

	    return(0) if($give_up);
	  }

	#If the first snp value from the proposed solution contains a dot
	#(i.e. totally ambiguous or ignored SNP)
	if($snp_val eq '.')
	  {
	    $matched = 1;

	    #If the well type is not defined, give it this genome's label
	    if($genome_types->[0] eq '')
	      {$genome_types->[0] = $label_array->[$genome]}
	    #Else if it has a label and it doesn't match the label of the
	    #current genome, set the answer to false
	    elsif($genome_types->[0] != $label_array->[$genome])
	      {$answer = 0}

	    if(!defined($skip_empty) &&
	       scalar(@$proposed_solution) == 0 &&
	       $label_array->[$genome])
	      {
		error("The first call to isSolution allowed a totally ",
		      "ambiguous proposed solution to get through.  This ",
		      "should not have happened because these situations are ",
		      "supposed to be filtered out.  The SNP that got here ",
		      "is at index: [$snp] and genome index: [$genome] with ",
		      "value: [.].");
		exit(9);
	      }

	    #Push the current genome's SNP data and labels into the pseudo-well
	    push(@{$genome_wells->[0]},$genome);
#	    push(@{$genome_wells->[0]},$snp_data_buffer->[$genome]);
#	    push(@{$new_label_array->[0]},$label_array->[$genome]);
	  }
	else
	  {
	    #If the first snp value from the proposed solution contains an A or
	    #1 for this genome
	    if($snp_val =~ /^[a1dhvrmwnx]$/i)
	      {
		$matched = 1;

		#If the genome well for As does not yet contain a label, label
		#it
		if($genome_types->[1] eq '')
		  {$genome_types->[1] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[1] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the A well
		push(@{$genome_wells->[1]},$genome);
#		push(@{$genome_wells->[1]},$snp_data_buffer->[$genome]);
#		push(@{$new_label_array->[1]},$label_array->[$genome]);
	      }
	    #If the first snp value from the proposed solution contains a T or
	    #2 for this genome
	    if($snp_val =~ /^[t2bdhykwnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Ts does not yet contain a label, label
		#it
		if($genome_types->[2] eq '')
		  {$genome_types->[2] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[2] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the T well
		push(@{$genome_wells->[2]},$genome);
#		push(@{$genome_wells->[2]},$snp_data_buffer->[$genome]);
#		push(@{$new_label_array->[2]},$label_array->[$genome]);
	      }
	    #If the first snp value from the proposed solution contains a G or
	    #3 for this genome
	    if($snp_val =~ /^[g3bdvrksnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Gs does not yet contain a label, label
		#it
		if($genome_types->[3] eq '')
		  {$genome_types->[3] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[3] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the G well
		push(@{$genome_wells->[3]},$genome);
#		push(@{$genome_wells->[3]},$snp_data_buffer->[$genome]);
#		push(@{$new_label_array->[3]},$label_array->[$genome]);
	      }
	    #If the first snp value from the proposed solution contains a C or
	    #4 for this genome
	    if($snp_val =~ /^[c4bhvymsnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Cs does not yet contain a label, label
		#it
		if($genome_types->[4] eq '')
		  {$genome_types->[4] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[4] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the C well
		push(@{$genome_wells->[4]},$genome);
#		push(@{$genome_wells->[4]},$snp_data_buffer->[$genome]);
#		push(@{$new_label_array->[4]},$label_array->[$genome]);
	      }
	    #If the first snp value from the proposed solution contains a gap
	    #(-) or 5 for this genome
	    if($snp_val =~ /^[\-5]$/i)
	      {
		$matched = 1;

		if(!$framesort_warning && $framesort &&
		   $snp_val eq '-')
		  {
		    warning("WARNING:SNPSTL.pl:isSolution:Your SNPs have a ",
			    "gap character (-).  Framesort will not work ",
			    "properly.");
		    $framesort_warning = 1;
		  }

		#If the genome well for gaps does not yet contain a label,
		#label it
		if($genome_types->[5] eq '')
		  {$genome_types->[5] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[5] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the dot (.)
		#well
		push(@{$genome_wells->[5]},$genome);
#		push(@{$genome_wells->[5]},$snp_data_buffer->[$genome]);
#		push(@{$new_label_array->[5]},$label_array->[$genome]);
	      }
	  }

	#If the SNP character is erroneous
	if(!$matched)
	  {
	    error("Bad SNP character in input file for genome: ",
		  "[$genome_names->[$genome]] and SNP: [$snp_names->[$snp]]: ",
		  "[$snp_val].\n");
	  }
      }

    #If this is the first call and all the "real" wells are all empty (i.e. not
    #including the pseudo-well at index 5 becuase we shouldn't run into a SNP
    #that has NO real values)
    if(!defined($skip_empty) &&
       ((scalar(@{$genome_wells->[0]}) == 0 &&
	 scalar(@{$genome_wells->[1]}) == 0 &&
	 scalar(@{$genome_wells->[2]}) == 0 &&
	 scalar(@{$genome_wells->[3]}) == 0 &&
	 scalar(@{$genome_wells->[4]}) == 0 &&
	 scalar(@{$genome_wells->[5]}) == 0) ||
	(scalar(@$genome_types) == 0)))
      {
	#ERROR
	error("The first call to isSolution did not find any data for ",
	      "SNP[$snp] in the buffer of size: [",
	      scalar(@$genome_indexes),
	      "]!  Either there is a bug in the program or your SNP data ",
	      "file is not correctly formatted.");
	exit(8);
      }

    #If we're not at the end of the solution
    if(scalar(@$proposed_solution))
      {
	#Make a recursive call for each well and return their AND'ed result
	#For the fifth argument, supply a boolean value indicating whether
	#there are any genomes in the wells being sent
	return(#Call the 6th well first so that if it doesn't resolve, I don't
	       #waste memory

#########Note that putting this call first changes the order of leaves in the solution array.  I need to update everything to reflect this.


	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  $genome_wells->[0],
			  $label_array,
#			  $new_label_array->[0],
			  $solution_array,
			  scalar(@{$genome_wells->[0]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[1]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[1]},@{$genome_wells->[0]}] :
			   $genome_wells->[1]),
			  $label_array,
#			  #If there are genomes in the real well and in the
#			  #pseudo-well, then add the labels from the pseudo
#			  #well
#			  (scalar(@{$genome_wells->[1]}) &&
#			   scalar(@{$genome_wells->[0]}) ?
#			   [@{$new_label_array->[1]},@{$new_label_array->[0]}]
#			   : $new_label_array->[1]),
			  $solution_array,
			  scalar(@{$genome_wells->[1]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[2]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[2]},@{$genome_wells->[0]}] :
			   $genome_wells->[2]),
			  $label_array,
#			  #If there are genomes in the real well and in the
#			  #pseudo-well, then add the labels from the pseudo
#			  #well
#			  (scalar(@{$genome_wells->[2]}) &&
#			   scalar(@{$genome_wells->[0]}) ?
#			   [@{$new_label_array->[2]},@{$new_label_array->[0]}]
#			   : $new_label_array->[2]),
			  $solution_array,
			  scalar(@{$genome_wells->[2]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[3]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[3]},@{$genome_wells->[0]}] :
			   $genome_wells->[3]),
			  $label_array,
#			  #If there are genomes in the real well and in the
#			  #pseudo-well, then add the labels from the pseudo
#			  #well
#			  (scalar(@{$genome_wells->[3]}) &&
#			   scalar(@{$genome_wells->[0]}) ?
#			   [@{$new_label_array->[3]},@{$new_label_array->[0]}]
#			   : $new_label_array->[3]),
			  $solution_array,
			  scalar(@{$genome_wells->[3]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[4]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[4]},@{$genome_wells->[0]}] :
			   $genome_wells->[4]),
			  $label_array,
#			  #If there are genomes in the real well and in the
#			  #pseudo-well, then add the labels from the pseudo
#			  #well
#			  (scalar(@{$genome_wells->[4]}) &&
#			   scalar(@{$genome_wells->[0]}) ?
#			   [@{$new_label_array->[4]},@{$new_label_array->[0]}]
#			   : $new_label_array->[4]),
			  $solution_array,
			  scalar(@{$genome_wells->[4]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[5]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[5]},@{$genome_wells->[0]}] :
			   $genome_wells->[5]),
			  $label_array,
#			  #If there are genomes in the real well and in the
#			  #pseudo-well, then add the labels from the pseudo
#			  #well
#			  (scalar(@{$genome_wells->[5]}) &&
#			   scalar(@{$genome_wells->[0]}) ?
#			   [@{$new_label_array->[5]},@{$new_label_array->[0]}]
#			   : $new_label_array->[5]),
			  $solution_array,
			  scalar(@{$genome_wells->[5]}) == 0));
      }

    #The following code only executes at leaves of the 6-degree [.ATGC-] (or
    #.12345) tree
    #Mark unlabelled leaves of the 5-degree tree
    $genome_types->[0] = '_' unless($genome_types->[0] =~ /\S/);
    $genome_types->[1] = '_' unless($genome_types->[1] =~ /\S/);
    $genome_types->[2] = '_' unless($genome_types->[2] =~ /\S/);
    $genome_types->[3] = '_' unless($genome_types->[3] =~ /\S/);
    $genome_types->[4] = '_' unless($genome_types->[4] =~ /\S/);
    $genome_types->[5] = '_' unless($genome_types->[5] =~ /\S/);

    #Push the leaves onto the solution_array (this happens in DFS order)
    push(@$solution_array,@$genome_types);

    #Return the answer
    return($answer);
  }


#This subroutine takes a current Combination, the size of the combination set,
#and the pool size.  It returns a new combination that hasn't been returned
#before.  This is an n_choose_r iterator.  It returns true if it was able to
#create an unseen combination, false if there are no more/
sub GetNextCombo
  {
    #Read in parameters
    my $combo     = $_[0];  #An Array of numbers
    my $set_size  = $_[1];  #'r' from (n choose r)
    my $pool_size = $_[2];  #'n' from (n choose r)

    #return false and report error if the combo is invalid
    if(@$combo > $pool_size)
      {
	error("Combination cannot be bigger than the pool size!");
	return(0);
      }

    #Initialize the combination if it's empty (first one) or if the set size
    #has increased since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	#Empty the combo
	@$combo = ();
	#Fill it with a sequence of numbers starting with 0
        foreach(0..($set_size-1))
          {push(@$combo,$_)}
	#Return true
        return(1);
      }

    #Define an upper limit for the last number in the combination
    my $upper_lim = $pool_size - 1;
    my $cur_index = $#{@$combo};

    #Increment the last number of the combination if it is below the limit and
    #return true
    if($combo->[$cur_index] < $upper_lim)
      {
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == $upper_lim && $cur_index >= 0)
      {
	#Decrement the limit and the current number index
        $upper_lim--;
        $cur_index--;
      }

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{@$combo})
      {
	#Set its value equal to the one before it plus one
	$combo->[$_] = $combo->[$_-1]+1;
      }

    #If we've exceded the ppol size on the last number of the combination
    if($combo->[-1] > $pool_size)
      {
	#Return false
	return(0);
      }

    #Return true
    return(1);
  }


#This sub has a "bag" for each position being incremented.  In other words, the
#$pool_size is an array of values equal in size to the $set_size.  So it yields
#all combinations where characters may be repeated in each slot.
sub GetNextIndepCombo
  {
    #Read in parameters
    my $combo      = $_[0];  #An Array of numbers
    my $pool_sizes = $_[1];  #An Array of numbers indicating the range for each
                             #position in $combo

    if(ref($combo) ne 'ARRAY' ||
       scalar(grep {/\D/} @$combo))
      {
	error("The first argument must be an array reference to an array of ",
	      "integers.");
	return(0);
      }
    elsif(ref($pool_sizes) ne 'ARRAY' ||
	  scalar(grep {/\D/} @$pool_sizes))
      {
	error("The second argument must be an array reference to an array of ",
	      "integers.");
	return(0);
      }

    my $set_size   = scalar(@$pool_sizes);

    #Initialize the combination if it's empty (first one) or if the set size
    #has changed since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	#Empty the combo
	@$combo = ();
	#Fill it with zeroes
        @$combo = (split('','0' x $set_size));
	#Return true
        return(1);
      }

    my $cur_index = $#{@$combo};

    #Increment the last number of the combination if it is below the pool size
    #(minus 1 because we start from zero) and return true
    if($combo->[$cur_index] < ($pool_sizes->[$cur_index] - 1))
      {
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == ($pool_sizes->[$cur_index] - 1) &&
	  $cur_index >= 0)
      {
	#Decrement the current number index
        $cur_index--;
      }

    #If we've gone past the beginning of the combo array
    if($cur_index < 0)
      {
	@$combo = ();
	#Return false
	return(0);
      }

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{@$combo})
      {
	#Set its value equal to 0
	$combo->[$_] = 0;
      }

    #Return true
    return(1);
  }



#This sub takes a file of SNP data, sets names arrays for SNPs and genomes, and
#returns a 2D array of SNP data indexed on genome and SNP respectively.  See
#`SNPSTI.pl -h` for a description and example of the input file format.
sub LoadSNPs
  {





####################I need to identify columns with evolutionary states 12345 so that I don't use frame sort on them.  I also need to make sure the states 12345 aren't mixed with other states (except ambiguous ones are OK)








    #Use a strict environment
    use strict;

    #Read in parameters
    my $snp_names       = $_[0];  #A declared empty array from main
    my $genome_names    = $_[1];  #A declared empty array from main
    my $file            = $_[2];  #SNP data file name
    my $verbose         = $_[3];
    my $snp_data_buffer = $_[4];
    my $low_memory_mode = $_[5];

    #Make sure we can open the SNP data file
    unless(open(FILE,$file))
      {
	error("LoadSNPs:Unable to open file: [$file].\n$!");
	return(1);
      }

    #Initialize and declare variables
    my $line = 0;
    my $snp_names_done = 0;
    my($last_size,$tmp,$curline,$score_hash,
#       @tmp_data
      );

    #For each line of the SNP data file
    while($curline = <FILE>)
      {
	#Eliminate the hard return
        chomp($curline);

	#Skip empty and commented lines
        next if($curline =~ /^\#/ || $curline !~ /\S/);

	#If we haven't processed the first line of SNP names yet
	unless($snp_names_done)
	  {
	    #Error check the first line
	    my @errors =
	      (grep {$_ !~ /^(\D*\d+\D*|\d*|\d+\D.*)$/} split(/\s+/,$curline));
	    if($framesort && scalar(@errors))
	      {
               error("Invalid SNP names: [@errors] on the first line: ",
		     "[$curline].\n",
		     "In order to sort results by frame position, the SNP ",
		     "names in your data file must have only one number ",
		     "representing the SNP sequence position relative to the ",
		     "start codon (starting from 1).  There may not be any ",
		     "other numbers.");
		return(2);
	      }

	    #Get rid of the leading white space on the line
	    $curline =~ s/^\s+//;

	    #Split the names on white space
	    @$snp_names = split(/\s+/,$curline);

	    #Mark the SNP names as done
	    $snp_names_done = 1;

	    #Skip the rest for this iteration
	    next;
	  }

	verbose(1,'Reading SNP Data row ',($line + 1),'.')
	  if(($line + 1) % 10 == 0);

	#Separate the genome name from the SNP data by the first tab
        #We do this because a comment with spaces is allowed before
        #the SNP names, as in the node names below
	($genome_names->[$line],$tmp) =
	  ($curline =~ /^([^\t]*?)\s*\t+([^\t]*.*)$/g);

	#Eliminate leading and trailing white space from the data
	$tmp =~ s/^\s+//;
	$tmp =~ s/\s+$//;

        my @checklens = grep {length($_) != 1} split(/\s+/,$tmp);
        if(scalar(@checklens))
          {
            error("Invalid SNP value(s): [@checklens] for genome $genome_names->[$line].");
          }

	$tmp =~ s/\s+//g;

	#Split up the data on the line
#	undef(@tmp_data);
#	@tmp_data = split(/\s+/,$tmp);

	#Score the genomes based on number of ambiguous characters
	my $tmp_score = 0;
	$tmp_score++ while($tmp =~ /[nx\?\.]/g);
	push(@{$score_hash->{$tmp_score}},$line);
#	push(@{$score_hash->{scalar(grep {/^[nx\?\.]$/i} @tmp_data)}},$line);

	#If we're going to buffer the data, store the first few SNP columns
	if($low_memory_mode)
	  {
	    $tmp =~ s/\s//g;
	    ${$snp_data_buffer->[$line]} = $tmp;
#	    foreach my $index (0..(scalar(@tmp_data) - 1))
#	      {${$snp_data_buffer->[$line]} .= $tmp_data[$index]}
	  }
	else
#	  {$snp_data_buffer->[$line] = [@tmp_data]}
	  {$snp_data_buffer->[$line] = [split('',$tmp)]}

	#Error check the number of columns
#        if($last_size != scalar(@tmp_data) && defined($last_size))
        if($last_size != length($tmp) && defined($last_size))
	  {
            error("Genome: [$genome_names->[$line]] on line $line has a different number of SNPs: [",
#			  scalar(@tmp_data),
		  length($tmp),
		  "] than previous lines: [$last_size]!");
	    return(3);
	  }
	elsif($snp_names_done != 2 &&
#	      scalar(@$snp_names) != scalar(@tmp_data))
	      scalar(@$snp_names) != length($tmp))
	  {
	    error("Genome [$genome_names->[$line]] on line [$line] doesn't have the same number of ",
		  "columns: [",
#			  scalar(@tmp_data),
		  length($tmp),
		  "] as the column names (SNP (names and) positions): [",
		  scalar(@$snp_names),
		  "]!");
	    return(4);
	  }
	else
	  {
	    #SNP names had the correct number of columns, so mark the name
	    #error check as done
	    $snp_names_done = 2;
	  }

	#Store the last number of columns
#        $last_size = scalar(@tmp_data);
        $last_size = length($tmp);

	#Increment the line number
        $line++;
      }
    close(FILE);

    #Sort the genomes based on score so that isSolution will give up on
    #pointless searches as early as possible
    my(@sorted_data,@sorted_genome_names);
    #Foreach score in the keys of this score hash
    foreach my $score (sort {$b <=> $a} keys(%$score_hash))
      {
	#Foreach genome index in the array at this score
        foreach my $genome_index (@{$score_hash->{$score}})
	  {
	    #Push the genome index onto a temp array
	    push(@sorted_data,$snp_data_buffer->[$genome_index]);
	    push(@sorted_genome_names,$genome_names->[$genome_index]);
	  }
      }
    @$genome_names = @sorted_genome_names;
    @$snp_data_buffer = @sorted_data;

    verbose("\n");

    return(0);
  }


#This subroutine checks the names of genomes in the tree against those in the
#genome_names array created by LoadSNPs.  Note that this sub must be called
#before ConvertGenomesInTreeToIndexes
sub CheckTreeNames
  {
    #Read in the parameters
    my $tree         = $_[0];
    my $genome_names = $_[1];
    my $verbose      = $_[2];

    #Get the genome names stored in the leaves of the tree
    my $tree_names = $tree->getLeafKeys();

    #Create a hash to use to check the tree leaves
    my $tree_name_check = {};
    foreach my $name (@$tree_names)
      {$tree_name_check->{$name}++}

    #Initialize check status to successful
    my $status = 0;

    #Go through the genome names from the SNP file
    foreach my $name (@$genome_names)
      {
	verbose(1,"Checking genome: [$name].");

	#If there's not 1 occurrence of the name in the tree leaves
	if(!exists($tree_name_check->{$name}) ||
	   1 != $tree_name_check->{$name})
	  {
	    #Update status to failed
	    $status = 1;

	    #Print an error message
	    error("Genome name [$name] from the SNP data was found in tree [",
		  (exists($tree_name_check->{$name}) ?
		   $tree_name_check->{$name} : 0),
		  "] times.");
	  }
      }

    print STDERR ("\n") if($verbose);

    #Release the memory used by the finished tree name check hash
    undef($tree_name_check);

    #Create a hash to use to check the genome names
    my $genome_name_check = {};
    foreach my $name (@$genome_names)
      {$genome_name_check->{$name}++}

    #Go through the genome names from the tree file (in case
    #the tree has extra names that the SNP file didn't have)
    foreach my $name (@$tree_names)
      {
	verbose(1,"Checking leaf: [$name].");

	if(!exists($genome_name_check->{$name}) ||
	   1 != $genome_name_check->{$name})
	  {
	    #Update status to failed
	    $status = 1;

	    #Print an error message
	    error("Genome name [$name] from the tree data was found in the ",
		  "SNP data [",
		  (exists($genome_name_check->{$name}) ?
		   $genome_name_check->{$name} : 0),
		  "] times.");
	  }
      }

    #Return the success status
    return($status);
  }


#This subroutine simply assigns a numeric value to each genome and replaces the
#name in the tree with that value
sub ConvertGenomesInTreeToIndexes
  {
    #Read in parameters
    my $genome_names = $_[0];  #Array of genome names
    my $tree         = $_[1];  #Root node
    my $verbose      = $_[2];
    my $status = 0;  #Return value is success

    verbose("\tGathering tree leaves.");

    #Get all the leaves of the tree
    my $leaves = $tree->getLeafNodes();

    my $genome_indexes = {};
    foreach my $index (0..(scalar(@$genome_names) - 1))
      {$genome_indexes->{$genome_names->[$index]} = $index}

    #For each genome/leaf node
    foreach my $leaf_node (@$leaves)
      {
	 verbose(1,
		 "\tConverting leaf: [",
		 $leaf_node->getKey(),
		 ']');

	if(!exists($genome_indexes->{$leaf_node->getKey()}))
	  {
	    error("Missing genome in SNP data!: [",$leaf_node->getKey(),"].");
	    $status = 1;  #Return value is failure
	    last;
	  }

	$leaf_node->setKey($genome_indexes->{$leaf_node->getKey()});
      }

    return($status);
  }


#This subroutine takes a tree's root node and any other node and labels the
#numeric leaves with a 1 if they are below the node and 0 if not.  Note that
#this sub must be called after ConvertGenomesInTreeToIndexes
sub LabelGenomes
  {
    #Read in parameters
    my $num_genomes = $_[0];
    my $node        = $_[1];

    #Make a list of the leaves to be labelled
    my $label_genomes = $node->getLeafKeys();
    #Create the label array
    my $label_array   = [];

    my $last_genome = -1;
    #label the genomes with ones
    foreach my $genome (sort {$a <=> $b} @$label_genomes)
      {
	foreach my $unlabelled_genome (($last_genome + 1)..($genome - 1))
	  {$label_array->[$unlabelled_genome] = 0}
	$label_array->[$genome] = 1;
	$last_genome = $genome;
      }

    #Take care of the genomes between the last labelled one and the end
    foreach my $unlabelled_genome (($last_genome + 1)..($num_genomes - 1))
      {$label_array->[$unlabelled_genome] = 0}

    #Return the labelled array of genomes
    return($label_array);
  }



sub usage
  {
    print STDERR << "end";
USAGE: SNPSTI.pl -s snp_file -t tree_file [-v] [-h] [-m number] [-z number] [-n number] [-f] [-l] [-k] [-b] [-r] [-g] [-x number] [-u decimal from 0 to 1] [list of nodes to solve]
CLUSTER USAGE: See the "HOW TO PARALLELIZE SNPSTI" section of the --help output.

     -s   REQUIRED  Supply the name of the SNP input file
     -t   REQUIRED  Supply the name of the phylogenetic tree input file
     -v   OPTIONAL  [Off] Verbose mode
     -h   OPTIONAL  [Off] Help.  Use this option to see sample input files and
                    an explanation of how to interpret the output.
     -m   OPTIONAL  [3] Maximum number of SNPs per solution per phylogenetic
                    tree branch.  This must be greater than or equal to the -z
                    option.  If you supply a number here that is greater than
                    the number of SNPs in your SNP data file, it will be
                    silently changed to the number of available SNPs.
     -z   OPTIONAL  [1] Minimum number of SNPs per solution per phylogenetic
                    tree branch.  This must be less than or equal to the -m
                    option.  Note that if you use this option and solutions of
                    lesser size exist, those solutions will be repeated with
                    all combinations of every other SNP at the size you supply
                    for this parameter.
     -p   OPTIONAL  [3] This is the set size at which the -n and -j options
                    will begin to be used.  in other words, all solutions below
                    this set size will be computed regardless of the -n and -j
                    options.
     -n   OPTIONAL  [0] Minimum number of solutions to find per phylogenetic
                    tree node.  0 means \'Find all solutions within the maximum
                    number of SNPs restriction\'.  Iterations on a node will
                    cease once this number of solutions is found UNLESS this is
                    pre-empted by the minimum number of independent solutions
                    (see -j).  The -p option only activates this option after a
                    certain number of SNPs per solution is reached.
                    Note, use this if you want more solutions at a larger SNP
                    set size.  Otherwise, only all solutions at the smallest
                    set size are reported.  For example, if there\'s only one
                    solution at a set size of one and you want more solutions,
                    increasing this number to 2 will cause the program to look
                    for larger solutions sets.  Set this to 0 if you want all
                    solution sets up to the maximum number of SNPs.
     -j   OPTIONAL  [0] Minimum number of INDEPENDENT solutions to find per
                    phylogenetic tree node.  0 means 'Find all solutions within
                    the maximum number of SNPs restriction'.  Iterations on a
                    node will cease once this number of solutions is found
                    UNLESS this is pre-empted by the minimum number of
                    solutions (see -n).  The -p option only activates this
                    option after a certain number of SNPs per solution is
                    reached.
     -f   OPTIONAL  [Off] Turn on frame sort.  Use this when your SNPs are from
                    a gene and the SNP coordinates are relative to the reading
                    frame.  Solutions with a low cumulative frame total will
                    appear nearer to the top however note that solutions are
                    first sorted on number of evolutionary states.  Solutions
                    with the fewest states will appear at the top.
     -l   OPTIONAL  [Off] Low memory mode.  Slower.
     -k   OPTIONAL  [Off] Skip input check.  It is suggested you leave this off
                    unless you absolutely know the file is good by having run
                    it before and are running it again with different
                    parameters.  This option saves time.
     -b   OPTIONAL  [Off] Breadth first order.  Process the nodes in the
                    phylogenetic tree in breadth first order.  Default behavior
                    is depth-first order.
     -r   OPTIONAL  [Off] Reverse order.  Process the nodes in the phylogenetic
                    tree in reverse order.  Reversing is performed on a depth
                    first order unless the -b option is supplied.
     -i   OPTIONAL  [Off] Internal Nodes only.  This option tells the script to
                    only look for solutions to the internal nodes of the
                    phylogenetic tree (i.e. it ignores the leaves of the tree).
                    Cannot be used with the -e option.  This option overrides
                    the -b option.
     -e   OPTIONAL  [Off] Leaves only.  This option tells the script to only
                    look for solutions to the leaves of the phylogenetic tree
                    (i.e. it ignores the internal nodes of the tree).  Cannot
                    be used with the -i option.  This option overrides the -b
                    option.
     -a   OPTIONAL  [none] Starting node.  This option is useful if you stopped
                    SNPSTI.pl and want to resume where you left off.  Note, you
                    must use the same node ordering options to ensure all
                    undone nodes are done and none are redone.
          OPTIONAL  [none] List of node names to solve.  Note, there is no flag
                    for this option.  Simply supply the bare node names among
                    the other options.  If any node names have spaces in them,
                    use quotes to define them.
     -g   OPTIONAL  [Off] Use greedy heuristic to search for SNP solutions for
                    each branch of the phylogenetic tree.  This is faster than
                    the default exhaustive method, but is not guaranteed to
                    find all or any solutions.  However, grredy could be run
                    first and then do a second run using the command line to
                    list the nodes desired to be analyzed to solve the
                    remaining nodes exhaustively.
     -x   OPTIONAL  [20] Maximum number of greedily selected SNPs to
                    exhaustively search.  Note, the default value is only used
                    if -g is supplied.  If this value is explicitly set on the
                    command line, then -g is "turned on".  If this value is set
                    to 0, then -u must not be 0.  If -u is set, the final set
                    of SNPs may be lesser in size than max_greedies if there
                    are not enough SNPs above the quality cutoff for any one
                    solution.  Note that if a SNP added to the greedy set is a
                    perfect solution, it is added to the greedy set, but not
                    counted, so your number of greedy SNPs in the final set
                    could be more than the number specified through this
                    option.
     -u   OPTIONAL  [0.1] Quality ratio cut-off.  If a SNP being added to the
                    greedy set further resolves fewer than this fraction of
                    genomes and max_greedies has not yet
                    been reached (or is zero), the current greedy solution will
                    be saved and a new greedy solution will be started.
     -c   OPTIONAL  [0] When two SNPs both improve a solution by the same
                    amount, the fraction between 0 and 1 set here will
                    determine the chance that the next same-quality SNP will be
                    chosen over the first one encountered.  A value of zero
                    means that the first best SNP encountered will be added to
                    the greedy solution.  A value of one means that the last
                    best SNP encountered will always be added to the solution.
end
  }



sub help
  {
    #Print a description of this program
    print STDERR ("SNP Sub-Tree Isolator (SNPSTI.pl)\n",
		  "Robert W. Leach\n",
		  "Bioscience Division\n",
		  "MS M888\n",
		  "Los Alamos National Laboratory\n",
		  "Los Alamos, NM 87545\n",
		  "robleach\@lanl.gov\n\n");
    print STDERR ("* WHAT IS THIS: This program takes a phylogenetic tree ",
		  "and SNP data and assigns SNP values to the branches of ",
		  "the phylogenetic tree.  These values uniquely identify ",
		  "the genomes in the sub-trees.  Multiple solutions are ",
		  "output per branch, but only the smallest possible set of ",
		  "SNPs is used in the solutions reported.\n\n");
    print STDERR ("* RESULTS INTERPRETATION: Results are ordered by nodes in ",
		  "the phylogenetic tree in a depth-first-search manner.  ",
		  "Each branch (represented by the node it leads to) has a ",
		  "set of results.  For any particular result, you get a set ",
		  "of SNP IDs and an array of 0s, 1s, and _s.  Each array ",
		  "element is the leaf of a 6 degree tree where each node ",
		  "has six branches (from left to right: .ATGC-).  Each level ",
		  "of the quarternary tree (from top down) represents a SNP ",
		  "from the set of SNP IDs from left to right.  The tree can ",
		  "be constructed from these two sets of data.  By following ",
		  "the SNP values down the tree, the resulting chacter (_, ",
		  "0, or 1) tells you whether the SNP values identify a ",
		  "genome in the current sub-tree of the phylogenetic ",
		  "tree.  A 1 means it belongs to the sub-tree and a 0 means ",
		  "it doesn\'t belong to the sub-tree.  An _ ",
		  "means that the combination of SNP values does not occur ",
		  "in any genome in the phylogenetic tree.\n\n");
    print STDERR ("* SNP FILE FORMAT: Basically, this is a white-space ",
		  "delimited file where the first row is the column names ",
		  "which is made up of SNP positions in the sequences, ",
		  "the first column is genome names, and each 'cell' ",
		  "is a sequence character.  Here is a table of sequence ",
		  "characters and what they mean.  Case is not important.\n\n",
		  "     A     Adenosine\n",
		  "     T     Thymidine\n",
		  "     G     Guanosine\n",
		  "     C     Cytidine\n",
		  "     -     Gap in an alignment (due to either deletion or ",
		  "insertion)\n",
		  "     N,X,? A, T, G, or C\n",
		  "     X     A, T, G, or C\n",
		  "     B     C, G, or T\n",
		  "     D     A, G, or T\n",
		  "     H     A, C, or T\n",
		  "     V     A, C, or G\n",
		  "     S     G or C\n",
		  "     W     A or T\n",
		  "     R     A or G\n",
		  "     Y     C or T\n",
		  "     K     G or T\n",
		  "     M     A or C\n",
		  "     .     A, T, G, C, or -.  Non-existant SNP (i.e. when ",
		  "the gene in which the\n",
		  "           SNP resides is absent.  Only useful for ",
		  "multilocus analyses involving\n",
		  "           multiple genes.)  It tells SNPSTI to ignore ",
		  "this SNP because it adds\n",
		  "           no information to the analysis.\n\n",
		  "Alternatively, generic evolutionary states can be ",
		  "represented with numbers (0-4).  These numbers are ",
		  "effectively the same as these states:\n\n",
		  "     1     A\n",
		  "     2     T\n",
		  "     3     G\n",
		  "     4     C\n",
		  "     5     -\n\n",
		  "0-4 cannot be mixed with ATGC- in one column of SNP ",
		  "data.  An example of how to use a generic evolutionary ",
		  "state/event is the loss of a gene.  If a particular gene ",
		  "has been lost in one genome, you would put dots (.) in ",
		  "the SNP columns for that gene (so that they will be ",
		  "ignored) and add a a column that represents the loss of ",
		  "the gene.  If the genome on a row is missing the gene, ",
		  "you\'d arbitrarily put a 0.  Otherwise, you'd put a 1.\n\n",
		  "The number of white spaces between columns doesn't ",
		  "matter, except that the row names and the first column of ",
		  "SNP data must be separated by a tab.  You may put ",
		  "comments on lines in the file not containing data as long ",
		  "as the line's first character is a # character.\n\nHere ",
		  "is an example file (Note the first indent seen here is ",
		  "not a part of the file and the first and second columns ",
		  "are separated by a tab.  The rest are a variable number ",
		  "of spaces.):\n\n",
		  "     #My SNP data example\n",
		  "     \n",
		  "                5 12 23 25 69 72 75 88 91\n",
		  "     \n",
		  "     genome1    C  T  G  A  T  G  C  G  C\n",
		  "     genome2    C  T  A  G  C  G  G  C  T\n",
		  "     genome3    A  C  G  C  T  G  T  C  G\n",
		  "     genome4    T  G  C  G  C  G  A  C  C\n",
		  "\nFor multi-locus analyses, the SNP positions may have ",
		  "non-numeric gene names preceding the position like this:\n",
		  "\n",
		  "     #My multilocus SNP data example\n",
		  "     \n",
		  "                gyr5 gyr22 gyr29 rpo10 rpo11 rpo36 rpo64\n",
		  "     \n",
		  "     genome1       C     T     G     A     T     G     C\n",
		  "     genome2       C     T     A     G     C     G     G\n",
		  "     genome3       A     C     G     C     T     G     T\n",
		  "     genome4       T     G     C     G     C     G     A\n",
		  "\n",
		  "Column headings for extra generic evolutionary ",
		  "information may not have numbers in them.  Let's use the ",
		  "same example as above, but let's say that genomes 1 and 2 ",
		  "are missing the gyrase gene (represented by SNPs in the ",
		  "first three columns).  The table would then look like ",
		  "this:\n\n",
		  "     #My multilocus missing gene SNP data example\n",
		  "     \n",
		  "                gyr5 gyr22 gyr29  delA rpo10 rpo11 rpo36\n",
		  "     \n",
		  "     genome1       .     .     .     0     A     T     G\n",
		  "     genome2       .     .     .     0     G     C     G\n",
		  "     genome3       A     C     G     1     C     T     G\n",
		  "     genome4       T     G     C     1     G     C     G\n",
		  "\nHere you see that there is no SNP data for the missing ",
		  "genes in those genomes and the deletion of the gene is ",
		  "represented in the fourth column as a single evolutionary ",
		  "event.  I arbitrarily named the deletion event 'delA'.\n\n"
		 );
    print STDERR ("* PHYLOGENETIC TREE FILE FORMAT: The tree file takes the ",
		  "form of an outline.  Note that spaces are significant.  ",
		  "They indicate the 'indent', i.e. where a node occurs in ",
		  "the tree.  Genomes are at the leaves and MUST have the ",
		  "same names used in the SNP input file.  Internal nodes ",
		  "may have any name you want.  You could use numbers or ",
		  "letters, but make sure they are unique, because they will ",
		  "appear in the output to assign SNP values to the ",
		  "branches.  The tree must also be binary, meaning that ",
		  "each node has only two child nodes.  There may also be ",
		  "comments in this file on lines starting with # characters.",
		  "\n\nHere is an example file (note the indent seen here is ",
		  "not a part of the file):\n\n",
		  "     #My Tree Test Data\n",
		  "     \n",
		  "     node0\n",
		  "      node1\n",
		  "       node2\n",
		  "        genome1\n",
		  "        genome2\n",
		  "       node3\n",
		  "        genome3\n",
		  "        genome4\n\n");
    print STDERR << "end";
* USING THE GREEDY OPTIONS: The three greedy options are -g|--greedy,
                            -x|--max-greedies, -u|--quality-ratio, and
                            -c|--chance.  By explicitly setting -x or -u, -g is
                            "turned on" automatically.  max-greedies is the
                            maximum number of SNPs to be greedily collected and
                            exhaustively searched for perfect solutions.  A
                            greedy solution is built up based on the best
                            improvement you get from adding an extra SNP to the
                            greedy solution.  In other words, you keep adding
                            SNPs based on how well the SNP being added resolves
                            the origanisms remaining to be resolved.  So if I
                            had a greedy solution that resolved all but 5
                            organisms, I will add the next of the remaining
                            SNPs which resolves the most of those 5.  If you
                            supply a quality-ratio of say .5, and the best SNP
                            that resolves the most of the remaining 5 resolves
                            only 2 more organisms, the last best SNP will be
                            added, but after which a new greedy solution will
                            be started.  When the total SNPs greedily collected
                            either reaches the max-greedies limit or no more
                            SNPs are above the quality ratio, the greedy search
                            will end and the exhaustive search of the greedily
                            collected SNPs will begin.  A greedy search will be
                            performed for each node of the phylogenetic tree
                            being analyzed (based on other parameters).  Note
                            that if a SNP added to the greedy set causes the
                            greedy set to be a perfect solution, the SNP is
                            added, but not counted, so the final number of
                            greedy SNPs can be larger than what is specified by
                            max-greedies.  The smaller the value for max-
                            greedies is, the faster the program will run, but
                            the more chance there is of missing a perfect
                            solution.  However, if you want more solutions for
                            any particular nodes, you can rerun the program on
                            just those nodes by supplying node names on the
                            command line (the option without a flag in the
                            USAGE output).  The quality-ratio is used not for
                            speed, but to manage the number of greedy
                            iterations for any one node.  If the quality ratio
                            was set to zero and no perfect solutions are
                            encountered in the greedy built solution, you would
                            likely end up adding junk SNPs that contain no real
                            information and are improving the solution by pure
                            chance.  You would completely miss other possibly
                            very good or even perfect solutions that happen to
                            not have any one SNP that well resolves the node.
                            For example, a ratio of a half will ensure that
                            each SNP added to the greedy solution will resolve
                            half of the genomes that have not yet been
                            resolved.  However, due to small SNP anomolies, it
                            is recommended to keep this ratio fairly low.  See
                            the usage output to get an explanation of the
                            chance option.

* HOW TO PARALLELIZE SNPSTI: SNPSTI.pl is very parallelizable.  You can run
                             each tree node separately in a different process.
                             All you have to do is execute the same command
                             many times, but provide a different tree node on
                             the command line each time.  There are two
                             environment variables that can be utilized to pass
                             arguments and include paths to cluster nodes:

                               SNPSTI_CLUSTER_PARAMS
                               SNPSTI_CLUSTER_TREE_PATH

                             Simply set SNPSTI_CLUSTER_PARAMS to be one long
                             string containing all the arguments to SNPSTI.pl.
                             The presence of this environment variable (and the
                             absence of any command line arguments) tells
                             SNPSTI to grab the arguments from the environment
                             variable.  Similarly, the presence of the
                             SNPSTI_CLUSTER_TREE_PATH environment variable (and
                             the absence of any command line arguments) tells
                             SNPSTI to add the tree.pm module in the location
                             given in the environment variable.  note that if
                             tree.pm exists anywhere else in the @INC array, it
                             will occlude the instance your environment
                             variable adds.  A special script specific to the
                             rlx cluster at Los Alamos called
                             "qsub_command_wrapper.pl" will take a file of
                             commands, duplicate your environment, and execute
                             each command on a different node.  All you have to
                             do is generate the command file.  However, here is
                             an example of how to run one command for
                             phylogenetic tree node "test_node" on an
                             individual cluster node of the rlx cluster at Los
                             Alamos:

                               >qsub -v SNPSTI_CLUSTER_PARAMS="test_node -s input.snps -t input.tree -v",SNPSTI_CLUSTER_TREE_PATH="/cluster/path/to/tree/module/" /path/to/SNPSTI.pl -e redirected_output_file.txt.err -o redirected_output_file.txt

                             You simply need to repeat this command for every
                             node in the tree to run multiple parallel
                             processes.  This is what qsub_command_wrapper.pl
                             does given a file of commands like this:

                               /path/to/SNPSTI.pl test_node1 -s input.snps -t input.tree -v > test_node1_output.txt
                               /path/to/SNPSTI.pl test_node2 -s input.snps -t input.tree -v > test_node2_output.txt
                               /path/to/SNPSTI.pl test_node3 -s input.snps -t input.tree -v > test_node3_output.txt
                               /path/to/SNPSTI.pl test_node4 -s input.snps -t input.tree -v > test_node4_output.txt
                               ...

                             It parses the commands to run qsub and also
                             duplicates your environment using qsub\'s -v
                             option, so be sure to set up your environment
                             (hint: put it in your shell\'s login script).

                             NOTE: If you have very large input files, you
                             should run multiple tree nodes per process because
                             the initialization step has a large constant time
                             overhead that each instance must perform.  The
                             same input files for each process is a requirement
                             because the search space for each process is the
                             same.  It\'s only the search context (i.e.
                             phylogenetic tree node) which changes.

end
  }



#This sub takes a solution hash which contains various output strings and
#scores and prints them sorted on that score.
sub printSortedResults
  {
    #Read in the parameters
    my $solutions = $_[0];
    my $framesort = $_[1];
    my $scores = {};

    #Print the message
    print($solutions->{message});

    #For each solution in the output array
    foreach my $sol (@{$solutions->{output}})
      {
	##Sum the frame positions.  The lower the sum, the better the SNP is as
	##an identifier because there's higher genetic pressure to not change.
	##If it does change, it's less likely to change again and saturate the
	##data.

	#Grab the portion of the string that
	#contains the space-delimited SNP positions
	my $snp_area;
	($snp_area) = ($sol =~ /\t([^\t]+)\t/g);

	my $framesum = 0;







###########If I disallow numbers as headers of columns containing generic evolutionary events, I won't need to do anything here.  Otherwise, I must make sure I don't use their numbers in the frame calculation here.







	if($framesort)
	  {map {$framesum += 3 - ($1 % 3)} ($snp_area =~ /(\d+)/g)}

	##Determine the number of total character states a SNP has in the data.
	##The lower the number of states a SNP has, the better an identifier it
	##is because it's less evolutionarily saturated.

	#Reset the match position
	pos($sol) = 0;
	my $label_area;
	#Grab the portion of the string that
	#contains the space-delimited labels
	($label_area) = ($sol =~ /\t([^\t]+)$/g);
	#Count the the number of existing states in the
	#tree leaves (i.e. anything with a numeric label)
	(@states) = ($label_area =~ /(\d+)/g);

	#Record the scores for this solution
	$scores->{$sol}->{states} = scalar(@states);
	$scores->{$sol}->{frames} = $framesum;
      }

    #Print sorted by number of states.  If the number of states is the same,
    #sort based on framesum
    print(sort {($scores->{$a}->{states} == $scores->{$b}->{states} ?
		 ($scores->{$a}->{frames} <=> $scores->{$b}->{frames}) :
		 ($scores->{$a}->{states} <=> $scores->{$b}->{states}))}
	  @{$solutions->{output}});
  }


sub getSNP
  {
    my $buffer       = $_[0];
    my $genome_index = $_[1];
    my $snp_index    = $_[2];
    my $snp_val = '';
    #Get the global value
    my $low_mode = $low_memory_mode;

    error("Invalid genome index: [$genome_index].")
      if($genome_index !~ /^-?\d+$/);
    if(abs($genome_index) > $#{$buffer})
      {
	error("Genome index: [$genome_index] overextends the array bounds: [",
	      scalar(@$buffer),
	      "]!");
	return('');
      }

    error("Invalid SNP index: [$snp_index].")
      if($snp_index !~ /^-?\d+$/);
    if(abs($snp_index) > ($low_mode ?
			  (length(${$buffer->[$genome_index]}) - 1) :
                          scalar(@{$buffer->[$genome_index]})))
      {
	error("SNP index: [$snp_index](SNP $snp_names->[$snp_index]) ",
	      "overextends the array bounds: [",
	      ($low_mode ?
	       "LOW MEMORY SIZE:" . (length(${$buffer->[$genome_index]}) - 1) :
	       scalar(@{$buffer->[$genome_index]})),
	      "] for genome index: [$genome_index]",
	      "(genome $genome_names->[$genome_index])!");#  Number of SNPs should be: [",scalar(@$snp_names),"].\n${$buffer->[$genome_index]}\n");
exit;
        return('');
      }

    if($low_mode)
      {$snp_val = substr(${$buffer->[$genome_index]},$snp_index,1)}
    else
      {$snp_val = $buffer->[$genome_index]->[$snp_index]}

    if($snp_val !~ /\S/)
      {
	my($junk,$junk,$junk,$calling_sub) = caller(1);
	die("ERROR:$calling_sub:getSNP:No SNP value at specified location ",
	    "(genome index: [$genome_index], SNP index: [$snp_index])!\n");
      }

    return($snp_val);
  }



#This is not estimating even close to the amount of time.  Fix it before reincorporating the calls I took out
sub timeRemainingEstimate
  {
    use Math::BigInt;
    my $combos_so_far      = $_[0];
    my $num_snps           = $_[1];
    my $min_combo_size     = $_[2];
    my $max_combo_size     = $_[3];
    my $num_tree_nodes     = $_[4];
    my($time_so_far);

    if(!defined($main::total_combos))
      {
	$time_so_far = markTime();
	$main::total_combos = 0;
	foreach my $r ($min_combo_size..$max_combo_size)
	  {$main::total_combos += numCombos($num_snps,$r)}
	$main::total_combos *= $num_tree_nodes;
	return('?');
      }

    $time_so_far = markTime(0);

    #Return the estimated time remaining
    return(($time_so_far / $combos_so_far) *
	   ($main::total_combos - $combos_so_far));
  }



#This sub calculates "n choose r"
sub numCombos
  {
    my $n = $_[0];
    my $r = $_[1];
    my $a = $n;
    foreach(1..$r)
      {$a *= --$n}
    $a /= factorial($r);
    return($a);
  }



sub factorial
  {
    my $n = $_[0];
    return(1) if($n == 1);
    return(0) if($n == 0);
    return($n * factorial($n - 1));
  }



#This sub marks the time (which it pushes onto an array) and in scalar context
#returns the time since the last mark by default or supplied mark (optional)
#In array context, the time between all marks is always returned regardless of
#a supplied mark index
#A mark is not made if a mark index is supplied
#Uses a global time_marks array reference
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set
    $main::time_marks = [] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error("Supplied time mark index is larger than the size of the ",
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = (scalar(@$main::time_marks) ?
			   ($time - $main::time_marks->[$mark_index]) : 0);

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
## Subroutine that prints errors with a leading program identifier
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split("\n",join('',@_));
    pop(@error_message) if($error_message[-1] !~ /\S/);

    $main::error_number++;

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Assign the values from the calling subroutines/main
    my @caller_info = caller(0);
    my $line_num = $caller_info[2];
    my $caller_string = '';
    my $stack_level = 1;
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

    my $leader_string = "ERROR$main::error_number:$script:$caller_string ";

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@error_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $error_length) : ''),
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
## Subroutine that checks to see if solutions found so far occur inside another
##
sub smallSolutionInside
  {
    my $current_set = $_[0];
    my $small_sets  = $_[1];
    my $presense = 0;

    #For each small solution
    foreach my $small_solution_set (@$small_sets)
      {
	my $matches = 0;
	my $no_match = 0;
	my $current_position = 0;

	#For each SNP in the small solution
	for(my $snp_position = 0;
	    $snp_position < scalar(@$small_solution_set);
	    $snp_position++)
	  {
	    #For each position in the current set
	    for(my $position = $current_position;
		$position < scalar(@$current_set);
		$position++)
	      {
		#If the SNPs in the small and current solutions match
		if($current_set->[$position] ==
		   $small_solution_set->[$snp_position])
		  {
		    #Increment the number of matches to the small solution
		    $matches++;
		    #Set the position to start at in the current set for
		    #checking the next SNP from the small solution (we can do
		    #this because the SNPs are in order)
		    $current_position = $position + 1;

		    last;
		  }
		#Else if the small solutions SNP wasn't found (in order) in the
		#current set OR the remainder of the current set is larger than
		#the remainder of the small set
		elsif($current_set->[$position] >
		      $small_solution_set->[$snp_position] ||
		      (scalar(@$current_set) - 1 - $position) <
		      (scalar(@$small_solution_set) - 1 - $snp_position))
		  {
		    #These solutions cannot match
		    $no_match = 1;
		    last;
		  }
	      }

	    #If this small set cannot match, go to the next one
	    last if($no_match);
	  }

	#If there's a match for all the SNPs in the small solution
	if($matches == scalar(@$small_solution_set))
	  {
	    $presense = 1;
	    last;
	  }
      }

    #return the true/false presence of a small solution in the current set
    return($presense);
  }


##
## Subroutine that prints warnings with a leader string
##
sub warning
  {
    return(0) if($quiet);

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split("\n",join('',@_));
    pop(@warning_message) if($warning_message[-1] !~ /\S/);

    #Put leader string at the beginning of each line of the message
    foreach my $line (@warning_message)
      {print STDERR (($line =~ /\S/ ? 'WARNING: ' : ''),$line,"\n")}

    #Return success
    return(0);
  }



sub getNextGreedySNP
  {
    my $greedy_snp_candidates = $_[0];
    my $greedy_snp_pool       = $_[1];
    my $snp_data_buffer       = $_[2];
    my $label_array           = $_[3];
    my $equal_chance          = (defined($_[4]) ? $_[4] : 0);
    my $snp_names             = $_[5];
    my $verbose               = $_[6];
    my $greedy_sol_num        = $_[7];
    my $relevant_genomes      = $_[8];

#print STDERR "TEST GREEDY SNP POOL: [@$greedy_snp_pool]\n";
    my($score,$maxscore,$maxsnp,$line,
#       @tmp_pool
      );
    my $linesize = 0;
    my $greedy_pool_index = 0;
    my $max_index = 0;
    my $greedymsg = '';
    foreach my $snp (@$greedy_snp_pool)
      {
#print STDERR "TEST GREEDILY EVALUATING SNP: $snp WITH CANDIDATES: @$greedy_snp_candidates\n";
	$score = getRatioResolved((scalar(@$greedy_snp_candidates) ?
				   [map {$optimized_snps->[$_]->[0]}
				    (@$greedy_snp_candidates,$snp)] :
				   [$optimized_snps->[$snp]->[0]]),
				  $snp_data_buffer,
				  $label_array,
				  $relevant_genomes,1);
#print STDERR "TEST: SCORE FOR SNP $snp_names->[$snp]: $score\n";
	if(!defined($maxscore) || $score > $maxscore ||
	   ($equal_chance && $score == $maxscore && rand() < $equal_chance))
	  {
#	    #bin the formerly maximum SNPs in a temporary pool
#	    if(defined($maxsnp))
#	      {push(@tmp_pool,$maxsnp)}

	    $max_index = $greedy_pool_index;

	    $maxscore = $score;
	    $maxsnp   = $snp;

            $greedymsg = "GREEDY ITERATION: [$greedy_sol_num]  SIZE: [" .
              (scalar(@$greedy_snp_candidates) + 1) .
                "] SNP [$snp_names->[$optimized_snps->[$snp]->[0]]] SCORE = $score.  " .
                  "MAX [$snp_names->[$optimized_snps->[$maxsnp]->[0]]] = $maxscore.\n"
	  }
#	else
#	  #Keep the evaluated SNPs in a temporary pool so that we don't have to
#	  #do a grep to remove the chosen SNP
#	  {push(@tmp_pool,$snp)}

	verbose(1,
		"GREEDY ITERATION: [$greedy_sol_num]  SIZE: [",
		scalar(@$greedy_snp_candidates) + 1,
		"] ",
		"SNP [$snp_names->[$optimized_snps->[$snp]->[0]]] ",
		"SCORE = $score.  ",
		"MAX [$snp_names->[$optimized_snps->[$maxsnp]->[0]]] = ",
		"$maxscore.");

	$greedy_pool_index++;

	#I'm doing a pattern match here just in case the real number wouldn't
	#work using == against an integer
	if($score == 1)
	  {
#	    #Take care of the max snp extraction from the pool because the
#	    #temporary pool doesn't have all the SNPs in it.
#	    @$greedy_snp_pool = grep {$_ ne $maxsnp} @$greedy_snp_pool;
	    last;
	  }
      }

    if($partial_suffix ne '')
      {
        print PRTL $greedymsg;
      }

#    #Only use the temporary pool if it has all the SNPs in it (i.e. didn't sto
#    # short in the loop above with the call to last)
#    @$greedy_snp_pool = @tmp_pool unless($score == 1);

    splice(@$greedy_snp_pool,$max_index,1);

    push(@$greedy_snp_candidates,$maxsnp);
    return($maxscore);
  }



#This sub scores proposed solutions based on the ratio of labelled versus
#unlabelled genomes in each well.
sub getRatioResolved
  {
    use strict;
    #Break off the first snp in the array and store the rest in the
    #proposed_solution which will be sent in a recursive call
    my($snp,$proposed_solution);
    ($snp,@$proposed_solution) = @{$_[0]};
    my $snp_data_buffer        = $_[1];  #Array of SNP strings
    my $label_array            = $_[2];  #Array of genome labels indexed by
                                         #genome
    my $relevant_genomes       = $_[3];  #Array of genome indexes to consider
    my $overall_score_flag     = $_[4];  #Return the score of the partial solution instead of the improvement score.  I added this to solve issues with negative scores being returned
    my $counted_scores         = $_[5];  #genomes whose score "counts" will be
                                         #labelled in this array.  A genome
                                         #"counts", if it's been placed in a
                                         #real well because a SNP value put it
                                         #there (other than a dot).  This allows us to skip genomes which provide no information for the particular set of SNPs supplied UNTIL a real value is encountered.  It is assumed/guaranteed elsewhere that all genomes will have a value for at least one of the SNPs provided (if not, 0 is returned).  INTERNAL
                                         #USE ONLY.  DO NOT SUPPLY.
    my $not_first_call         = $_[6];  #INTERNAL USE ONLY.  DO NOT SUPPLY.

    my $going_to_recurse = scalar(@$proposed_solution);

#print STDERR "TEST: PARAMS SENT IN: SNPS: [$snp,",join(',',@$proposed_solution),"] SIZE OF SNP DATA BUFFER: ",scalar(@$snp_data_buffer)," LABELS: [@$label_array]\n";

    #If this is a recursive call and the well was empty, return 1
    if($not_first_call &&
       scalar(@$label_array) == 0)
      {return(wantarray ? (0,0) : 0)}

    if(!defined($counted_scores))
      {$counted_scores = [map {0} @$label_array]}

    #Initialize variables local to this recursive call
    my $real_label_counts = [0,0,0,0,0,0];      #Number of genomes in each well that didn't originate from a pseudo-well
    my $label_counts     = [0,0,0,0,0,0];       #Number of labelled organisms
                                                #in each well
    my $total_counts     = [0,0,0,0,0,0];       #Number of total organisms in
                                                #each well

#I'm taking out the genome wells because I've abstracted it away.  I now use
#real genome indexes to access the buffer and pass those indexes along in the
#relevant genomes arrays.  The reason for this was to filter the genomes based
#on whether or not they had any real SNP values for the SNPs that remained
#(because SNPs were filtered too based on whether there were any real values
#for any of the labelled genomes)
#    my $genome_wells     = [[],[],[],[],[],[]]; #Contains genome SNP data split
#                                                #by the current SNP values

    my $new_label_array  = [[],[],[],[],[],[]]; #labels are split the same way
                                                #as genomes in the genome wells
                                                #for the next recursive call
    my $new_relevant_genomes = [[],[],[],[],[],[]]; #same as above
    my $new_counted_scores = [[],[],[],[],[],[]];

    my($matched);
    #For each genome
#    foreach my $genome (0..(scalar(@$snp_data_buffer) - 1))
    my $relevant_genome_index = -1;
    foreach my $real_genome_index (@$relevant_genomes)
      {
	$relevant_genome_index++;
	my $snp_val = getSNP($snp_data_buffer,$real_genome_index,$snp);

	$matched = 0;

	##I want to get a partial score on SNPs when some of the genomes have a set of totally ambiguous SNPs, so I need to comment out the code below.  Every node is going to have some totally ambiguous genomes for the set of SNPs, but I want to get a score regardless so I can pick those SNPs that still cover a bunch of genomes so that other SNPs later can be added that those genomes have SNP values for

########But what about when all genomes have no info in any of these SNPs?  how do I skip those?

#	#If this is the first call and this is a labelled genome
#	if(!$not_first_call && $label_array->[$genome])
#	  {
#	    my $give_up = 1;
#
#	    #Look ahead for this genome to see if its SNPs are all totally
#	    #ambiguous
#	    my $snp_val = getSNP($snp_data_buffer,$genome,$snp);
#	    if($snp_val !~ /^\.$/i)
#	      {$give_up = 0}
#	    elsif(scalar(@$proposed_solution))
#	      {
#		#Foreach future SNP value for the current genome
#		foreach my $snp_val (map {getSNP($snp_data_buffer,$genome,$_)}
#				     @$proposed_solution)
#		  {
#		    #If the SNP value is not entirely ambiguous
#		    if($snp_val !~ /^\.$/i)
#		      {
#			#Decide not to give up and move on
#			$give_up = 0;
#			last;
#		      }
#		  }
#	      }
#
#	    #Return 0 resolved
#	    return(0) if($give_up);
#	  }

	if($snp_val eq '.')
	  {
	    $matched = 1;

	    if($label_array->[$relevant_genome_index])
	      {
		$label_counts->[0]++;
		if($counted_scores->[$relevant_genome_index])
		  {$real_label_counts->[0]++}

###Whoops.  Took out the code below because I just realized that the resultant calculations for internal nodes becomes skewed when nothing real went into any of these wells.  It may have been taken care of by the calculation of 0 that these numbers would have been multiplied by since the recursive call is based on the population of the arrays sent in the recursive calls, but I think it would be better to add $label_counts->[0] when needed instead of relying on that.
#		#Don't let non-existant SNPs affect the results in other branches when we're doing the leaves.  We can either assume that any labelled genomes in this well have been previously separated by SNPs WITH values OR consider unlabelled genomes separated down other real branches as the contribution of this SNP.  The relative improvement of the score in this well actually indicates the potential it has to improve solutions with other SNPs by the amount it can rule out down those other branches.  So if there's only one SNP in the solution and all the labelled genomes end up in this well, it will get a high score because while it can't positively identify the labelled genomes, it can positively identify all the unlabelled genomes
#		if(scalar(@$proposed_solution))
#		  {
#		    $label_counts->[1]++;
#		    $label_counts->[2]++;
#		    $label_counts->[3]++;
#		    $label_counts->[4]++;
#		    $label_counts->[5]++;
#		  }
	      }

	    $total_counts->[0]++;

###Whoops.  Took out the code below because I just realized that the resultant calculations for internal nodes becomes skewed when nothing real went into any of these wells.  It may have been taken care of by the calculation of 0 that these numbers would have been multiplied by since the recursive call is based on the population of the arrays sent in the recursive calls, but I think it would be better to add $label_counts->[0] when needed instead of relying on that.
#		#Don't let non-existant SNPs affect the results in other branches when we're doing the leaves.  We can either assume that any labelled genomes in this well have been previously separated by SNPs WITH values OR consider unlabelled genomes separated down other real branches as the contribution of this SNP.  The relative improvement of the score in this well actually indicates the potential it has to improve solutions with other SNPs by the amount it can rule out down those other branches.  So if there's only one SNP in the solution and all the labelled genomes end up in this well, it will get a high score because while it can't positively identify the labelled genomes, it can positively identify all the unlabelled genomes
#		if(scalar(@$proposed_solution))
#		  {
#		    $unlabel_counts->[1]++;
#		    $unlabel_counts->[2]++;
#		    $unlabel_counts->[3]++;
#		    $unlabel_counts->[4]++;
#		    $unlabel_counts->[5]++;
#		  }

	    if($going_to_recurse)
	      {
		#Push the current genome's SNP data and labels into the dot
		#well
#		push(@{$genome_wells->[0]},
#		     $snp_data_buffer->[$real_genome_index]);
		push(@{$new_label_array->[0]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[0]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[0]},
		     $counted_scores->[$relevant_genome_index]);
	      }
	  }
	else
	  {
	    $counted_scores->[$relevant_genome_index] = 1 if(!$not_first_call);

	    #If the first snp value from the proposed solution contains an A or
	    #1 for this genome
	    if($snp_val =~ /^[a1dhvrmwnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[1]++;
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[1]++}
		  }
		$total_counts->[1]++;

		if($going_to_recurse)
		  {
		    #Push the current genome's SNP data and labels into the A
		    #well
#		    push(@{$genome_wells->[1]},
#			 $snp_data_buffer->[$real_genome_index]);
		    push(@{$new_label_array->[1]},
			 $label_array->[$relevant_genome_index]);
		    push(@{$new_relevant_genomes->[1]},
			 $relevant_genomes->[$relevant_genome_index]);
		    push(@{$new_counted_scores->[1]},1);
		  }
	      }

	    #If the first snp value from the proposed solution contains a T or
	    #2 for this genome
	    if($snp_val =~ /^[t2bdhykwnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[2]++;
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[2]++}
		  }
		$total_counts->[2]++;

		if($going_to_recurse)
		  {
		    #Push the current genome's SNP data and labels into the T
		    #well
#		    push(@{$genome_wells->[2]},
#			 $snp_data_buffer->[$real_genome_index]);
		    push(@{$new_label_array->[2]},
			 $label_array->[$relevant_genome_index]);
		    push(@{$new_relevant_genomes->[2]},
			 $relevant_genomes->[$relevant_genome_index]);
		    push(@{$new_counted_scores->[2]},1);
		  }
	      }

	    #If the first snp value from the proposed solution contains a G or
	    #3 for this genome
	    if($snp_val =~ /^[g3bdvrksnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[3]++;
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[3]++}
		  }
		$total_counts->[3]++;

		if($going_to_recurse)
		  {
		    #Push the current genome's SNP data and labels into the G
		    #well
#		    push(@{$genome_wells->[3]},
#			 $snp_data_buffer->[$real_genome_index]);
		    push(@{$new_label_array->[3]},
			 $label_array->[$relevant_genome_index]);
		    push(@{$new_relevant_genomes->[3]},
			 $relevant_genomes->[$relevant_genome_index]);
		    push(@{$new_counted_scores->[3]},1);
		  }
	      }

	    #If the first snp value from the proposed solution contains a C or
	    #4 for this genome
	    if($snp_val =~ /^[c4bhvymsnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[4]++;
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[4]++}
		  }
		$total_counts->[4]++;

		if($going_to_recurse)
		  {
		    #Push the current genome's SNP data and labels into the C
		    #well
#		    push(@{$genome_wells->[4]},
#			 $snp_data_buffer->[$real_genome_index]);
		    push(@{$new_label_array->[4]},
			 $label_array->[$relevant_genome_index]);
		    push(@{$new_relevant_genomes->[4]},
			 $relevant_genomes->[$relevant_genome_index]);
		    push(@{$new_counted_scores->[4]},1);
		  }
	      }

	    #If the first snp value from the proposed solution contains a gap
	    #(-) or 5 for this genome
	    if($snp_val =~ /^[\-5]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[5]++;
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[5]++}
		  }
		$total_counts->[5]++;

		if($going_to_recurse)
		  {
		    #Push the current genome's SNP data and labels into the gap
		    #(-) well
#		    push(@{$genome_wells->[5]},
#			 $snp_data_buffer->[$real_genome_index]);
		    push(@{$new_label_array->[5]},
			 $label_array->[$relevant_genome_index]);
		    push(@{$new_relevant_genomes->[5]},
			 $relevant_genomes->[$relevant_genome_index]);
		    push(@{$new_counted_scores->[5]},1);
		  }
	      }
	  }

	#If the SNP character is erroneous
	if(!$matched)
	  {
	    error("Bad SNP character in input file for genome: ",
		  "[$genome_names->[$real_genome_index]] and SNP: ",
		  "[$snp_names->[$snp]]: [$snp_val].\n");
	  }
      }

    #If this is the first call and the wells are all empty
    if(!$not_first_call && $going_to_recurse &&
       (scalar(@{$new_label_array->[0]}) == 0 &&
	scalar(@{$new_label_array->[1]}) == 0 &&
	scalar(@{$new_label_array->[2]}) == 0 &&
	scalar(@{$new_label_array->[3]}) == 0 &&
	scalar(@{$new_label_array->[4]}) == 0 &&
        scalar(@{$new_label_array->[5]}) == 0))
      {
	#ERROR
	error("The first call did not find any data for SNP[$snp] in the ",
	      "buffer of size: [",
	      scalar(@$label_array),
	      "]!  Either there is a bug in the program or your SNP data ",
	      "file is not correctly formatted.\n");
	exit(8);
      }

    #If we're not at the end of the solution
    if(scalar(@$proposed_solution))
      {
	##
	## Get the relative scores from the children
	##

	#Get the scores from the recursive call
	my($dot_score,$dot_labels,$a_score,$a_labels,$t_score,$t_labels,$g_score,$g_labels,$c_score,$c_labels,$gap_score,$gap_labels);

        #If there were no labeled genomes in any of the other branches/wells (i.e. no other recursive calls will be made), go down this branch to separate the genomes further by the next SNP.  Otherwise, there's no need to traverse this branch in the computation, because the genomes here will travel with the other branches that have had genomes put in them.
        if(scalar(grep {$_} @{$label_counts}[1..5]) == 0)
          {
            #$dot_labels = ($label_counts->[0] ? $label_counts->[0] : 1);
	    if($label_counts->[0] &&
	       $real_label_counts->[0] != $total_counts->[0])
	      {#($dot_score,$dot_labels) = getRatioResolved($proposed_solution,
               $dot_score = getRatioResolved($proposed_solution,
					     $snp_data_buffer,
					     $new_label_array->[0],
					     $new_relevant_genomes->[0],
                                             1,
					     $new_counted_scores->[0],
					     1)}
	    elsif($label_counts->[0] &&
	          $total_counts->[0] == $real_label_counts->[0])
	      {
                #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
                if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
                  {$dot_score = 0}
                else
                  #{$dot_score = $label_counts->[0]}
                  {$dot_score = 1}
              }
	    else
	      {$dot_score = 0}
          }
        else
          {$dot_score = 0}

	#If there are any label or unlabel counts AND
	#(there exists both real or unreal label counts AND
	#real or unreal unlabel counts)
	#In other words, only determine if both label and unlabel counts
	#(including those added from the pseudo-well) are above zero if there
	#are real-well genomes that have been added
	#(Then the score must be further discerned recursively)

        #$a_labels = ($label_counts->[1] ? $label_counts->[1] : 1);
	#If (there are labelled genomes (real or unreal) OR
	if(1)#($label_counts->[1] ||
	#    #There are any real genomes (labelled OR unlabelled) AND
	#    #labelled unreal genomes) AND
	#    ($total_counts->[1] && $label_counts->[0])) &&
	#   #The number of real + unreal labelled genomes is not equal to...
	#   ($real_label_counts->[1] + $real_label_counts->[0]) !=
	#   #the total real + unreal genomes
	#   ($total_counts->[1] + $total_counts->[0]))
	  {#($a_score,$a_labels) = getRatioResolved($proposed_solution,
           $a_score = getRatioResolved($proposed_solution,
				       $snp_data_buffer,
				       (scalar(@{$new_label_array->[1]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_label_array->[1]},
					 @{$new_label_array->[0]}] :
					$new_label_array->[1]),
				       (scalar(@{$new_label_array->[1]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_relevant_genomes->[1]},
					 @{$new_relevant_genomes->[0]}] :
					$new_relevant_genomes->[1]),
                                       1,
				       (scalar(@{$new_label_array->[1]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_counted_scores->[1]},
					 @{$new_counted_scores->[0]}] :
					$new_counted_scores->[1]),
				       1)}
	#Esle if (there are labelled genomes (real or unreal) OR
	elsif(($label_counts->[1] ||
	       #There are any real genomes (labelled OR unlabelled) AND
	       #labelled unreal genomes) AND
	       ($total_counts->[1] && $label_counts->[0])) &&
	      #The number of real + unreal labelled genomes is equal to...
	      ($real_label_counts->[1] + $real_label_counts->[0]) ==
	      #the total real + unreal genomes
	      ($total_counts->[1] + $total_counts->[0]))
	  {
            #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
            if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
              {$a_score = 0}
            else
              {$a_score = 1}
              #{$a_score = $label_counts->[1]}
          }
	#Otherwise the score is zero
	else
	  {$a_score = 0}

        #$t_labels = ($label_counts->[2] ? $label_counts->[2] : 1);
	#Same as above
	if(1)#($label_counts->[2] ||
	#    ($total_counts->[2] && $label_counts->[0])) &&
	#   ($real_label_counts->[2] + $real_label_counts->[0]) !=
	#   ($total_counts->[2] + $total_counts->[0]))
	  {#($t_score,$t_labels) = getRatioResolved($proposed_solution,
           $t_score = getRatioResolved($proposed_solution,
				       $snp_data_buffer,
				       (scalar(@{$new_label_array->[2]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_label_array->[2]},
					 @{$new_label_array->[0]}] :
					$new_label_array->[2]),
				       (scalar(@{$new_label_array->[2]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_relevant_genomes->[2]},
					 @{$new_relevant_genomes->[0]}] :
					$new_relevant_genomes->[2]),
                                       1,
				       (scalar(@{$new_label_array->[2]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_counted_scores->[2]},
					 @{$new_counted_scores->[0]}] :
					$new_counted_scores->[2]),
				       1)}
	elsif(($label_counts->[2] ||
	       ($total_counts->[2] && $label_counts->[0])) &&
	      ($real_label_counts->[2] + $real_label_counts->[0]) ==
	      ($total_counts->[2] + $total_counts->[0]))
	  {
            #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
            if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
              {$t_score = 0}
            else
              {$t_score = 1}
              #{$t_score = $label_counts->[2]}
          }
	else
	  {$t_score = 0}

        #$g_labels = ($label_counts->[3] ? $label_counts->[3] : 1);
	#Same as above
	if(1)#($label_counts->[3] ||
	#    ($total_counts->[3] && $label_counts->[0])) &&
	#   ($real_label_counts->[3] + $real_label_counts->[0]) !=
	#   ($total_counts->[3] + $total_counts->[0]))
	  {#($g_score,$g_labels) = getRatioResolved($proposed_solution,
           $g_score = getRatioResolved($proposed_solution,
				       $snp_data_buffer,
				       (scalar(@{$new_label_array->[3]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_label_array->[3]},
					 @{$new_label_array->[0]}] :
					$new_label_array->[3]),
				       (scalar(@{$new_label_array->[3]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_relevant_genomes->[3]},
					 @{$new_relevant_genomes->[0]}] :
					$new_relevant_genomes->[3]),
                                       1,
				       (scalar(@{$new_label_array->[3]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_counted_scores->[3]},
					 @{$new_counted_scores->[0]}] :
					$new_counted_scores->[3]),
				       1)}
	elsif(($label_counts->[3] ||
	       ($total_counts->[3] && $label_counts->[0])) &&
	      ($real_label_counts->[3] + $real_label_counts->[0]) ==
	      ($total_counts->[3] + $total_counts->[0]))
	  {
            #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
            if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
              {$g_score = 0}
            else
              {$g_score = 1}
              #{$g_score = $label_counts->[3]}
          }
	else
	  {$g_score = 0}

        #$c_labels = ($label_counts->[4] ? $label_counts->[4] : 1);
	#Same as above
	if(1)#($label_counts->[4] ||
	#    ($total_counts->[4] && $label_counts->[0])) &&
	#   ($real_label_counts->[4] + $real_label_counts->[0]) !=
	#   ($total_counts->[4] + $total_counts->[0]))
	  {#($c_score,$c_labels) = getRatioResolved($proposed_solution,
           $c_score = getRatioResolved($proposed_solution,
				       $snp_data_buffer,
				       (scalar(@{$new_label_array->[4]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_label_array->[4]},
					 @{$new_label_array->[0]}] :
					$new_label_array->[4]),
				       (scalar(@{$new_label_array->[4]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_relevant_genomes->[4]},
					 @{$new_relevant_genomes->[0]}] :
					$new_relevant_genomes->[4]),
                                       1,
				       (scalar(@{$new_label_array->[4]}) &&
					scalar(@{$new_label_array->[0]}) ?
					[@{$new_counted_scores->[4]},
					 @{$new_counted_scores->[0]}] :
					$new_counted_scores->[4]),
				       1)}
	elsif(($label_counts->[4] ||
	       ($total_counts->[4] && $label_counts->[0])) &&
	      ($real_label_counts->[4] + $real_label_counts->[0]) ==
	      ($total_counts->[4] + $total_counts->[0]))
	  {
            #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
            if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
              {$c_score = 0}
            else
              {$c_score = 1}
              #{$c_score = $label_counts->[4]}
          }
	else
	  {$c_score = 0}

        #$gap_labels = ($label_counts->[5] ? $label_counts->[5] : 1);
	#Same as above
	if(1)#($label_counts->[5] ||
	#    ($total_counts->[5] && $label_counts->[0])) &&
	#   ($real_label_counts->[5] + $real_label_counts->[0]) !=
	#   ($total_counts->[5] + $total_counts->[0]))
	  {#($gap_score,$gap_labels) = getRatioResolved($proposed_solution,
           $gap_score = getRatioResolved($proposed_solution,
					 $snp_data_buffer,
					 (scalar(@{$new_label_array->[5]}) &&
					  scalar(@{$new_label_array->[0]}) ?
					  [@{$new_label_array->[5]},
					   @{$new_label_array->[0]}] :
					  $new_label_array->[5]),
					 (scalar(@{$new_label_array->[5]}) &&
					  scalar(@{$new_label_array->[0]}) ?
					  [@{$new_relevant_genomes->[5]},
					   @{$new_relevant_genomes->[0]}] :
					  $new_relevant_genomes->[5]),
                                         1,
					 (scalar(@{$new_label_array->[5]}) &&
					  scalar(@{$new_label_array->[0]}) ?
					  [@{$new_counted_scores->[5]},
					   @{$new_counted_scores->[0]}] :
					  $new_counted_scores->[5]),
					 1)}
	elsif(($label_counts->[5] ||
	       ($total_counts->[5] && $label_counts->[0])) &&
	      ($real_label_counts->[5] + $real_label_counts->[0]) ==
	      ($total_counts->[5] + $total_counts->[0]))
	  {
            #Set the improvement to 0 instead of the ratio resolved if we're higher than 2 from the leaves
            if(!$overall_score_flag && scalar(@$proposed_solution) > 1)
              {$gap_score = 0}
            else
              {$gap_score = 1}
              #{$gap_score = $label_counts->[5]}
          }
	else
	  {$gap_score = 0}

	##
	## Average the weighted scores obtained from the relative children's
	## scores
	##

#        my $failsafe = (($a_labels + $t_labels + $g_labels + $c_labels + $gap_labels) == 0 && ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 && $dot_labels == 0) || (scalar(grep {$_} @{$label_counts}[1..5]) > 0))  ? 1 : 0);
	my $children_score = 0;
#	$children_score = ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ?
#			    $dot_score : 0) * $label_counts->[0] +
#			   #Multiply the ratio of real isolated labelled counts
#			   $a_score *
#			   #by the total number of label counts that were put
#			   #down that well to get a relative value of how many
#			   #labelled genomes at this level of the tree were
#			   #isolated by the lower level of the tree.  Include
#			   #the number from the pseudowell only if there are
#			   #labelled genomes in the real well
#			   ($label_counts->[1] ?
#			    ($label_counts->[1] + $label_counts->[0]) : 0) +
#			   $t_score *
#			   ($label_counts->[2] ?
#			    ($label_counts->[2] + $label_counts->[0]) : 0) +
#			   $g_score *
#			   ($label_counts->[3] ?
#			    ($label_counts->[3] + $label_counts->[0]) : 0) +
#			   $c_score *
#			   ($label_counts->[4] ?
#			    ($label_counts->[4] + $label_counts->[0]) : 0) +
#			   $gap_score *
#			   ($label_counts->[5] ?
#			    ($label_counts->[5] + $label_counts->[0]) : 0)) /
#	   #Divide the number of isolated real labelled genomes above by the
#	   #total number of labelled genomes below to see how good the answer
#	   #at the lower level of the tree was
#	   ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ? $label_counts->[0] : 0) +
#	    $label_counts->[1] +
#	    ($label_counts->[1] ? $label_counts->[0] : 0) +
#	    $label_counts->[2] +
#	    ($label_counts->[2] ? $label_counts->[0] : 0) +
#	    $label_counts->[3] +
#	    ($label_counts->[3] ? $label_counts->[0] : 0) +
#	    $label_counts->[4] +
#	    ($label_counts->[4] ? $label_counts->[0] : 0) +
#	    $label_counts->[5] +
#	    ($label_counts->[5] ? $label_counts->[0] : 0))
#	   if($label_counts->[0] ||
#	      $label_counts->[1] ||
#	      $label_counts->[2] ||
#	      $label_counts->[3] ||
#	      $label_counts->[4] ||
#	      $label_counts->[5]);

	$children_score = ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ?
			    $dot_score : 0) * $label_counts->[0] +

			   #Multiply the ratio of real isolated labelled counts
			   $a_score *
			   #by the total number of label counts that were put
			   #down that well to get a relative value of how many
			   #labelled genomes at this level of the tree were
			   #isolated by the lower level of the tree.  Include
			   #the number from the pseudowell only if there are
			   #labelled genomes in the real well
			   $label_counts->[1] +
			   $t_score   * $label_counts->[2] +
			   $g_score   * $label_counts->[3] +
			   $c_score   * $label_counts->[4] +
			   $gap_score * $label_counts->[5]) /

	   #Divide the number of isolated real labelled genomes above by the
	   #total number of labelled genomes below to see how good the answer
	   #at the lower level of the tree was
	   ($label_counts->[0] +
	    $label_counts->[1] +
	    $label_counts->[2] +
	    $label_counts->[3] +
	    $label_counts->[4] +
	    $label_counts->[5])
	   if($label_counts->[0] ||
	      $label_counts->[1] ||
	      $label_counts->[2] ||
	      $label_counts->[3] ||
	      $label_counts->[4] ||
	      $label_counts->[5]);

#	$children_score = ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ? $dot_score : 0) +
#			   $a_score + $t_score + $g_score + $c_score + $gap_score) /
#	   #Divide the number of isolated real labelled genomes above by the
#	   #total number of labelled genomes below to see how good the answer
#	   #at the lower level of the tree was
#	   ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ? $dot_labels : 0) +
#	    $a_labels + $t_labels + $g_labels + $c_labels + $gap_labels + $failsafe)
#	   if($label_counts->[0] ||
#	      $label_counts->[1] ||
#	      $label_counts->[2] ||
#	      $label_counts->[3] ||
#	      $label_counts->[4] ||
#	      $label_counts->[5]);

	#If we're one step up from the leaves, calculate the improvement of the
	#score that the last SNP added to the previous solution (Note that the
	#score of the first SNP is the improvement from a score of 0 without
	#this calculation)
	if(!$overall_score_flag && scalar(@$proposed_solution) == 1)
	  {
	    ##
	    ## Calculate the score at one step up from the leaves, calling it
	    ## the "parents_score"
	    ##

            my $parents_score = 0;
#            my $parents_total = 0;
            my $parents_total = $label_counts->[0];
            if(scalar(grep {$_} @{$label_counts}[1..5]) == 0)
              {
                $parents_score = $label_counts->[0] *
                  ($label_counts->[0] / $total_counts->[0]);
#                $parents_total = $label_counts->[0];
              }
            else
              {
#	    my $parents_score = $label_counts->[0] *
#	      ($real_label_counts->[0] ?
#	       ($label_counts->[0] / $total_counts->[0]) : 0);
#	    my $parents_total = $label_counts->[0];
#print STDERR "\nTHERE ARE ",scalar(@$label_array)," GENOMES BEING ANALYZED\n";
#print STDERR "TEST: PARENT'S WELL 0 CONTAINS $real_label_counts->[0] REAL LABELLED GENOMES AND $label_counts->[0] TOTAL LABELLED AND $total_counts->[0] TOTAL GENOMES\n";
	        foreach my $well (1..5)
	          {
		    #Add the total label counts for this well and the pseudowell
		    #multiplied by their ratio of the total number of counts that
		    #were "real" over the total overall counts.  By real, I mean
		    #that a genome in a well was added because of a real SNP value
		    #and not by a pseudowell
                    #5/26/2011 - I took out the "real" thing because I think it is inflating the returned scores.  By only including the reals, the unreal ones, yet unresolved start to appear resolved in the parent nodes of the solution, but they were included in the children nodes and could essentially make the solution worse than the parent inadvertently, potentially leading to negative improvement scores.

#		    $parents_score +=
#		      ($label_counts->[$well] + $label_counts->[0]) *
#		        (($label_counts->[$well] + $label_counts->[0]) /
#		         ($total_counts->[$well] + $total_counts->[0]))
##		          #Only count these calculations if there are labelled
##		          #genomes present in the well
##		          if($label_counts->[$well]);
#                          if($total_counts->[$well] || $total_counts->[0]);

		    $parents_score +=
		      $label_counts->[$well] *
		        ($label_counts->[$well] /
		         ($total_counts->[$well] +
			  ($total_counts->[0] - $label_counts->[0])))
#		          #Only count these calculations if there are labelled
#		          #genomes present in the real well
                          if($total_counts->[$well]);


#		#Subtract .5 from the larger of the count ratios for this well
#		#(labelled vs. unlabelled counts, because the lowest score is
#		#.5 and the largest is 1) and multiply by two to get a score
#		#between 0 and 1 and then multiply by the number of genomes in
#		#this well (to ultimately be divided by the total number of
#		#genomes in all wells)
#		  ((($label_counts->[$well] > $unlabel_counts->[$well] ?
#		     $label_counts->[$well] : $unlabel_counts->[$well]) /
#		    ($label_counts->[$well] || $unlabel_counts->[$well] ?
#		     ($label_counts->[$well] + $unlabel_counts->[$well]) : 1))
#		   - .5) * 2 *
#		     ($label_counts->[$well] + $unlabel_counts->[$well]);

#		    #Add to the total if genomes in the real well exist
#		    $parents_total += $label_counts->[$well] + $label_counts->[0]
##		      if($label_counts->[$well]);
#                      ;

		    $parents_total += $label_counts->[$well];

#		  $label_counts->[$well] + $unlabel_counts->[$well];
#print STDERR "TEST: PARENT'S WELL $well CONTAINS $real_label_counts->[$well] REAL LABELLED GENOMES AND $label_counts->[$well] TOTAL LABELLED AND $total_counts->[$well] TOTAL GENOMES\n";
	          }
              }

	    #Normalize the score using the total number of genomes in all wells
	    $parents_score /= $parents_total
	      if($parents_total);

	    ##
	    ## Now calculate the improvement over the children
	    ##

	    #Return the ratio of additionally resolved organisms that were
	    #unresolved in this parent node.  Theoretically, this should not be
	    #greater than 1 or less than 0
#print STDERR ("\nTEST: CHILDREN SCORE: $children_score PARENT SCORE: $parents_score FOR CHILD SNP [$snp_names->[$snp]] AND PARENT SNP: [$snp_names->[$proposed_solution->[-1]]] TOTAL SOLUTION SIZE: [",scalar(@$proposed_solution)+1,"]\n");
	    my $improvement = ($children_score == $parents_score ||
			       $parents_score == 1 ? 0 :
			       (($children_score - $parents_score) /
				(1 - $parents_score)));
#print STDERR ("\nTEST: CHILDREN SCORE: $children_score PARENT SCORE: $parents_score IMPROVEMENT: $improvement FOR LAST 2 SNPs [$snp_names->[$snp],$snp_names->[$proposed_solution->[0]]]\ndot score $dot_score dot labels $label_counts->[0] dot total $total_counts->[0]\na score $a_score a labels $label_counts->[1] a total $total_counts->[1]\nt score $t_score t labels $label_counts->[2] t total $total_counts->[2]\ng score $g_score g labels $label_counts->[3] g total $total_counts->[3]\nc score $c_score c labels $label_counts->[4] c total $total_counts->[4]\ngap score $gap_score gap labels $label_counts->[5] gap total $total_counts->[5]\n") if($improvement < 0);
if($improvement < 0)
{
            my $parents_score = 0;
#            my $parents_total = 0;
            my $parents_total = $label_counts->[0];
            if($total_counts->[0] && scalar(grep {$_} @{$label_counts}[1..5]) == 0)
              {
                $parents_score = $label_counts->[0] *
                  ($label_counts->[0] / $total_counts->[0]);
#                $parents_total = $label_counts->[0];
#print STDERR "SET parents score to $parents_score and total to $parents_total because there were no labeled genomes in the non-dot wells.  (Should not happen)\n";
              }
            foreach my $well (1..5)
              {
#print STDERR ("WELL: $well ",'$parents_score'," += ($label_counts->[$well] + $label_counts->[0]) * (($label_counts->[$well] + $label_counts->[0]) / ($total_counts->[$well] + $total_counts->[0])) if($label_counts->[$well]);\n");

#                $parents_score +=
#                  ($label_counts->[$well] + $label_counts->[0]) *
#                    (($label_counts->[$well] + $label_counts->[0]) /
#                     ($total_counts->[$well] + $total_counts->[0]))
#                      #Only count these calculations if there are labelled
#                      #genomes present in the well
##                      if($label_counts->[$well]);
#                      if($total_counts->[$well] || $total_counts->[0]);

                $parents_score +=
                  $label_counts->[$well] *
                    ($label_counts->[$well] /
                     ($total_counts->[$well] +
		      ($total_counts->[0] - $label_counts->[0])))
                      #Only count these calculations if there are labelled
                      #genomes present in the well
#                      if($label_counts->[$well]);
                      if($total_counts->[$well]);

#print STDERR ('$parents_total'," += $label_counts->[$well] + $label_counts->[0] if($label_counts->[$well]);\n");

#                $parents_total += $label_counts->[$well] + $label_counts->[0]
#                  if($label_counts->[$well]);

                $parents_total += $label_counts->[$well]
                  if($label_counts->[$well]);
              }

}
	    return(wantarray ? ($improvement,1) : $improvement);
	  }
	else
	  #Return the children score
	  {
#print STDERR "\nTEST: RETURNING AVERAGED CHILDREN SCORES: [$children_score] FROM THESE CHILD SCORES: [$dot_score] [$a_score] [$t_score] [$g_score] [$c_score] [$gap_score]\n" if($children_score < 0 || $children_score > 1);
	    return(wantarray ? ($children_score,1) : $children_score);
          }
      }
    else
      {
	##
	## Calculate the score of the whole solution at this SNP leaf.  Scores
	## at this level will be collected and averaged upon return of this
	## last level of recursion
	##

        my $score = 0;
#        my $total = 0;
        my $total = $label_counts->[0];
        if($total_counts->[0] && scalar(grep {$_} @{$label_counts}[1..5]) == 0)
          {
            $score = $label_counts->[0] *
              ($label_counts->[0] / $total_counts->[0]);
#            $total = $label_counts->[0];
          }
        else
          {
#	my $score = $label_counts->[0] *
#	  ($real_label_counts->[0] ?
#	   ($label_counts->[0] / ($total_counts->[0])) : 0);
#	my $total = $label_counts->[0];
            foreach my $well (1..5)
	      {
	        #Add the total label counts for this well and the pseudowell
	        #multiplied by their ratio of the total number of counts
	        $score +=
	          #Don't need to test the real well because that's done at the
	          #if at the end of this equation
	          $label_counts->[$well] *
		    ($label_counts->[$well] /
		     ($total_counts->[$well] +
		      #Penalize the score by adding the number of
		      #unlabeled genomes in the dot well to the total
                      ($total_counts->[0] - $label_counts->[0])))
		      if($total_counts->[$well]);
#	          ($label_counts->[$well] + $label_counts->[0]) *
#		    (($label_counts->[$well] + $label_counts->[0]) /
#		     ($total_counts->[$well] + $total_counts->[0]))
##		      if($label_counts->[$well]);
#                      if($total_counts->[$well] || $total_counts->[0]);

#	    #Subtract .5 from the larger of the count ratios for this well
#	    #(labelled vs. unlabelled counts, because the lowest score is
#	    #.5 and the largest is 1) and multiply by two to get a score
#	    #between 0 and 1 and then multiply by the number of genomes in
#	    #this well (to ultimately be divided by the total number of
#	    #genomes in all wells)
#	      ((($label_counts->[$well] > $unlabel_counts->[$well] ?
#		 $label_counts->[$well] : $unlabel_counts->[$well]) /
#		($label_counts->[$well] || $unlabel_counts->[$well] ?
#		 ($label_counts->[$well] + $unlabel_counts->[$well]) : 1)) -
#	       .5) * 2 * ($label_counts->[$well] + $unlabel_counts->[$well]);

#print STDERR ("WELL $well HAS $label_counts->[$well]  REAL AND $label_counts->[0] FAKE LABELED GENOMES AND $total_counts->[$well] + $total_counts->[0] TOTAL GENOMES\n") if($snp_names->[$snp] eq "16.69397102.69409491");
#	        $total += $label_counts->[$well] + $label_counts->[0]
##	          if($label_counts->[$well]);
#                  ;
	        $total += $label_counts->[$well];

#	      $label_counts->[$well] + $unlabel_counts->[$well];
	      }
          }
#print STDERR "\nNUMBER RESOLVED for SNP $snp_names->[$snp]: [$score] OUT OF: [$total]\n" if($snp_names->[$snp] eq "16.69397102.69409491");
	#Normalize the score using the total number of genomes in all wells
        my $normal_score = 0;
	$normal_score = $score / $total
	  if($total);

	#Return the leaves' score
	return(wantarray ? ($score,$total) : $normal_score);
      }
  }






#This subroutine optimizes the SNPs and returns an array of SNP sets that are
#informationally equivalent (in the context of genome resolving power).  An
#example of such an array is: [[2,4,8],[1,3],[5,6,7]].  SNPs 2, 4, and 8 are
#equivalent.  Only one of them needs to be tested to see if it's a solution.
#If 2 is a solution, then 4 and 8 are as well, however note that their values
#may be different (although the pattern of their values is the same).
sub optimizeSNPs
  {
    my $snp_names       = $_[0];
    my $genome_names    = $_[1];
    my $snp_data_buffer = $_[2];

    verbose("Optimizing SNPs.");

    my $matched = 0;
    my $sorted_genome_sets = [];
    my $equivalent_snps = {};
    foreach my $snp_index (0..(scalar(@$snp_names) - 1))
      {
	#Since masking due to haplotype awareness can eliminate SNP value
	#variation, make sure a SNP is still a SNP by seeing if the organisms
	#have multiple values other than the ignore character.
	my $snp_check = {};

	#Separate all the genomes based on the current SNP's values
	my $current_genome_sets = [[],[],[],[],[],[]];
	foreach my $genome_index (0..(scalar(@$genome_names) - 1))
	  {
	    my $snp_val = getSNP($snp_data_buffer,$genome_index,$snp_index);
	    $matched = 0;

	    if($snp_val eq '.')
	      {
		$matched = 1;
		push(@{$current_genome_sets->[0]},$genome_index);
	      }
	    else
	      {
		#Make sure there are multiple REAL SNP values
		$snp_check->{$snp_val}++;

		if($snp_val =~ /^[a1dhvrmwnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[1]},$genome_index);
		  }
		if($snp_val =~ /^[t2bdhykwnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[2]},$genome_index);
		  }
		if($snp_val =~ /^[g3bdvrksnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[3]},$genome_index);
		  }
		if($snp_val =~ /^[c4bhvymsnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[4]},$genome_index);
		  }
		if($snp_val =~ /^[\-5]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[5]},$genome_index);
		  }
	      }

	    #If the SNP character is erroneous
	    if(!$matched)
	      {
		delete($snp_check->{$snp_val});
		error("Bad SNP character in input file for genome: ",
		      "[$genome_names->[$genome_index]] and SNP: ",
		      "[$snp_names->[$snp_index]]: [$snp_val].");
	      }
	  }

	if(scalar(keys(%$snp_check)) <= 1)
	  {
	    verbose("This SNP has lost its variability (probably due to ",
		    "haplotype awareness masking or poor data input) and ",
		    "will not be considered: [$snp_names->[$snp_index]].");
	    next;
	  }

	#Sort the groups of genomes by the value of the first genome index
	#(i.e. the smallest genome index) in each group.  This makes it faster
	#to compare the current grouping produced by the current SNP with
	#groupings produced by other SNPs.
	@$current_genome_sets = sort {$a->[0] <=> $b->[0]}
	  grep {defined($_) && scalar(@$_)} @$current_genome_sets;

	if(scalar(@$sorted_genome_sets) == 0)
	  {
	    #Push the current genome sets array ref onto the empty sorted
	    #genome sets array
	    push(@$sorted_genome_sets,$current_genome_sets);
	    #Make the current genome set array reference, the key to a hash
	    #containing arrays of SNP indexes that created the sets
	    $equivalent_snps->{$current_genome_sets} = [$snp_index];
	  }
	else
	  {
	    ##
	    ## Put the next genome set (made with the current SNP) onto the
	    ## sorted genome sets array (in order) and store the SNP with the
	    ## appropriate array reference key (if the current genome set was
	    ## equal to one already on the sorted genome sets array, the
	    ## current genome set will not be added to the sorted array)
	    ##

	    my $not_equal = 0;  #0 means 'left value is equal to right value'
	                        #-1 means 'left value is less than right value'
	                        #1 means 'left value is greater than rt. value'
	    my $bottom    = 0;
	    my $top       = scalar(@$sorted_genome_sets) - 1; #guranteed >= 1
	    my $position  = int($top / 2);

	    while(1)
	      {
		$position = $bottom + int(($top - $bottom) / 2);
		my $seen_genome_pattern = $sorted_genome_sets->[$position];

		#Start out assuming they are equal
		$not_equal = 0;
		#For each well/set
		foreach my $set (0..((scalar(@$seen_genome_pattern) <
				      scalar(@$current_genome_sets) ?
				      scalar(@$seen_genome_pattern) :
				      scalar(@$current_genome_sets)) - 1))
		  {
		    #Make sure the genome indexes are equal
		    foreach my $genome_index_index
		      (0..((scalar(@{$seen_genome_pattern->[$set]}) <
			    scalar(@{$current_genome_sets->[$set]}) ?
			    scalar(@{$seen_genome_pattern->[$set]}) :
			    scalar(@{$current_genome_sets->[$set]})) - 1))
			{
			  if($current_genome_sets->[$set]
			     ->[$genome_index_index] <
			     $seen_genome_pattern->[$set]
			     ->[$genome_index_index])
			    {$not_equal = -1}
			  elsif($current_genome_sets->[$set]
			     ->[$genome_index_index] >
			     $seen_genome_pattern->[$set]
			     ->[$genome_index_index])
			    {$not_equal = 1}

			  #Last if they're not equal (i.e. continue to prove
			  #they're equal if they're equal so far)
			  last if($not_equal);
			}

		    #If they are equal so far, base equality on size where
		    #(larger is "less than" smaller)
		    if($not_equal == 0)
		      {
			$not_equal = scalar(@{$seen_genome_pattern->[$set]})
			  <=> scalar(@{$current_genome_sets->[$set]});
		      }

                    #Last if they're not equal (i.e. continue to prove they're
                    #equal if they're equal so far)
		    last if($not_equal);
		  }

                #Make sure they're equal in size if equal otherwise
                if($not_equal == 0)
		  {$not_equal = scalar(@$seen_genome_pattern) <=>
		     scalar(@$current_genome_sets)}

		#If they are equal or the search is done (and none were equal)
		if($not_equal == 0 || $bottom == $top)
		  {
		    if($not_equal == 1 && $position &&
		       $top != scalar(@$sorted_genome_sets) - 1)
		      {
			#Increment the position and set equal to "less than"
			#because equal == 1 means that the position is larger
			#than everything
			$position++;
			$not_equal = -1;
		      }
		    last;
		  }
                elsif($bottom > $top)
                  {
		    error("Log(n) search of genome sets has encountered an ",
			  "unexplained error.  The search has extended past ",
			  "the known search space.  Please report this error ",
			  "to the author: [BOTTOM: $bottom TOP: $top TOTAL: ",
			  scalar(@$sorted_genome_sets) - 1,
			  "].");
		    exit(3);
		  }

                if($not_equal == -1)
                  {
		    $top = $position - ($position == $bottom ? 0 : 1);
		  }
                elsif($not_equal == 1)
                  {
		    $bottom = $position + ($position == $top ? 0 : 1);
		  }
	      }

	    #If the current_genome_sets is less than anything seen so far,
	    #Push is onto the end of the sorted_genome_sets
	    if($not_equal == 1)
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being appended ",
		        "at position: [",scalar(@$sorted_genome_sets),"].");

		push(@$sorted_genome_sets,$current_genome_sets);
		$equivalent_snps->{$current_genome_sets} = [$snp_index];
	      }
	    elsif($not_equal == -1)
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being inserted ",
		        "at position: [$position].");

		splice(@$sorted_genome_sets,$position,0,$current_genome_sets);
		$equivalent_snps->{$current_genome_sets} = [$snp_index];
	      }
	    else
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being added to ",
		        "position: [$position] with SNP: [",
			$snp_names
			->[$equivalent_snps
			   ->{$sorted_genome_sets->[$position]}->[0]],
			"].");

		error("Invalid sorted genome sets position: [$position].\n",
		      "Please report this error to the author.")
		  if($position == scalar(@$sorted_genome_sets));

		push(@{$equivalent_snps
			 ->{$sorted_genome_sets
			    ->[($position == scalar(@$sorted_genome_sets) ?
				($position - 1) : $position)]}},
		     $snp_index);
	      }
	  }
      }

    if(scalar(keys(%$equivalent_snps)) == 0)
      {warning("There is no remaining SNP data after optimization.  This ",
	       "could mean that the input SNP data was either invalid or ",
	       "haplotype awareness was turned on and the data is extremely ",
	       "divergent in the region of the current node of the tree.")}

#    #Figure out the max lengths of the genome names and SNP IDs
#    my $id_len = 0;
#    foreach my $id (@$genome_names)
#      {$id_len = length($id) if(length($id) > $id_len)}
#    my $snp_pos_len = 0;
#    foreach my $snp_id (@$snp_names)
#      {$snp_pos_len = length($snp_id) if(length($snp_id) > $snp_pos_len)}
#
#    my $snp_set_num = 1;

    #Sort the array reference keys based on the first SNP ID in each group of
    #equivalent SNPs, then eliminate the array reference keys entirely to
    #simply return an array of equivalent SNP ID arrays
    if(wantarray)
      {return(map {$equivalent_snps->{$_}}
	      sort {$equivalent_snps->{$a}->[0] <=>
		      $equivalent_snps->{$b}->[0]}
	      keys(%$equivalent_snps))}
    return([map {$equivalent_snps->{$_}}
	    sort {$equivalent_snps->{$a}->[0] <=>
		    $equivalent_snps->{$b}->[0]}
	    keys(%$equivalent_snps)]);

#    #$snp_set is an array reference to a set of equivalent SNP solutions
#    foreach my $snp_set
#      (sort {$equivalent_snps->{$a}->[0] <=> $equivalent_snps->{$b}->[0]}
#       keys(%$equivalent_snps))
#      {
#	print(join(' ',map {$snp_names->[$_]} @{$equivalent_snps->{$snp_set}}),
#	      "\n");
#	$snp_set_num++;
#      }
#
#    #Print the coordinate column headers
#    print(' ' x ($id_len),
#	  "\t",
#	  join(' ',
#	       map {' ' x ($snp_pos_len -
#			   length($snp_names->[$equivalent_snps->{$_}->[0]])) .
#			     $snp_names->[$equivalent_snps->{$_}->[0]]}
#	       sort {$equivalent_snps->{$a}->[0] <=>
#		       $equivalent_snps->{$b}->[0]}
#	       keys(%$equivalent_snps)),
#	  "\n\n");
#    my $cnt = 1;
#    foreach my $id (@$genome_names)
#      {
#	verbose("Printing row: $cnt") if($verbose);
#	print($id,                            #Genome ID
#	      ' ' x ($id_len - length($id)),  #Append with white space to even
#		                              #up columns
#	      "\t",                           #Tab over columns
#	      join(' ',  #This joins each column with one space
#	                 #The following line converts the SNP position to the
#	                 #SNP value prepended with white space to right justify
#		   map {' ' x ($snp_pos_len - 1) .
#			  getSNP($snp_data_buffer,
#				 ($cnt - 1),
#				 $equivalent_snps->{$_}->[0])}
#		   sort {$equivalent_snps->{$a}->[0] <=>
#			   $equivalent_snps->{$b}->[0]}
#		   keys(%$equivalent_snps)),
#	      "\n");
#	$cnt++;
#      }
  }



##
## Subroutine that prints warnings with a leader string
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

    #Read in the message
    my $verbose_message = join('',@_);

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
	    warning("Hard returns and tabs cause overwrite mode to not work ",
		    "properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if(!$overwrite_flag)
      {$verbose_length = 0}
    elsif($verbose_message =~ /\n([^\n]*)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

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

##
## Subroutine that prints warnings with a leader string
##
sub verboseOLD
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 0 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

    #Read in the message
    my $verbose_message = join('',@_);

    $overwrite_flag = 1 if($overwrite_flag ne '0' &&
			   $verbose_message =~ /\r$/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\t/)
	  {
	    warning("Tabs cause overwrite mode to not work properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if($verbose_message =~ /\n([^\n]+)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

    #Print the message to standard error
    print STDERR (($main::last_verbose_state ? "\n" : ''),
		  $verbose_message,
		  ($main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $verbose_length) : ''),
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }


sub getCommand
  {
    my $perl_path_flag = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\/)\s/)
	 {$arg = '"' . $arg . '"'}}

    my($command);
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }


#This subroutine represents code copied from statSNPSTI.pl which calculates the
#maximum number of independent solutions (i.e. solutions which don't share any
#SNPs.  This uses a greedy heuristic to calculate the maximum, so it's not 100%
#accurate
sub numIndepSolns
  {
    my @two_d_snp_array = @_;
    my $snp_usage = {};

    #Determine the SNP usage
    foreach my $solution (@two_d_snp_array)
      {
	foreach my $snp_index (@$solution)
	  {$snp_usage->{$snp_index}++}
      }

    #Sort the solutions in the 2D SNP array based on increasing SNP usage
    my @sorted_solutions =
      sort {sum(map {$snp_usage->{$_}} @$a) <=>
	      sum(map {$snp_usage->{$_}} @$b)}
	@two_d_snp_array;

    #Go through the sorted array and push solutions onto the independent
    #solutions array when all its SNPs are "unseen"
    my(@independent_solutions);
    my $seen_snps = {};
    while(scalar(@sorted_solutions))
      {
	#If any of the SNPs in the next solution have already been added in a
	#solution to the independent solutions array
	if(grep {exists($seen_snps->{$_})} @{$sorted_solutions[0]})
	  {shift(@sorted_solutions)}
	else
	  {
	    #Add the new solution with all unseen SNPs to the independent
	    #solutions array
	    push(@independent_solutions,shift(@sorted_solutions));

	    #Mark the SNPs in the new solution as seen
	    foreach my $added_snp (@{$independent_solutions[-1]})
	      {$seen_snps->{$added_snp} = 1}
	  }
      }

    return(scalar(@independent_solutions));
  }


sub sum
  {
    my $sum = 0;
    foreach(@_)
      {$sum += $_}
    return($sum);
  }
