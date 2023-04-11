set batDir [pwd]
set tclDir $batDir/tcl/

# read project name from "info.txt"
set fid [open $tclDir/info.txt r]
set xprName [read $fid]
close $fid

set xprDir $batDir/$xprName/

# source $tclDir/open_xpr.tcl 
# source $tclDir/wr_xpr_tcl.tcl 
source $tclDir/recover_xpr.tcl 

