# Raw2FS
Bash script for computer forensics - It's possible to resolve the file name starting from the carved file name generated by 
the Foremost tool and save it, it generates an HTML report. It's possible to resolve the 
file name starting from the offset of a "grep" keywords search. The tool identifies automatically 
the change of the partition and, if the keyword is contained into 
the slack space, saves the sector/cluster/block where it is. 
(remember that for fat -> sector, ntfs -> cluster, ext2/3 -> block) (The SleuthKit based)
