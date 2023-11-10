cd $xprDir
# open project 
open_project $xprName.xpr 

cd ..

# save project to .tcl
write_project_tcl -use_bd_files -force $xprName.tcl



# save project name
# set fid [open info.txt w+]
# puts $fid $xprName
# close $fid