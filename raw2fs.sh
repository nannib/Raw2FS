#!/bin/bash 
# Raw2Fs -  From Carved names or keyword offsets to file system names
# Recovery file name from carved file by Nanni Bassetti - digitfor@gmail.com - http://www.nannibassetti.com - http://www.cfitaly.net

logo ()
{
echo "**********************************************************" 
echo "              Raw2Fs 1.2 - by Nanni Bassetti              " 
echo "															" 
echo " With this script it's possible to retrieve file names  " 
echo " from the names of the carved files with the Foremost tool  " 
echo " or find out all the keywords in a device/bitstream file  " 
echo " and to retrieve file names or slack spaces where they "
echo " are.														"  
echo "**********************************************************" 
}

menu ()
{
loop="1"
while [ "$loop"="1" ] 
do
choice="z"
echo "Choose among these options:"

if [ "$init_x" -eq 1 ]
then
if [ "$slack" = "no" ]
then
echo "1-Save the file found"
fi
echo "2-File names from carved space - run it again"
fi
echo "3-File names from carved space on new device"
echo "4-Quit to the main menu"

read answer
echo " "
echo " "	
while [ "$choice" = "z" ] 
do
	case $answer in
		3)	init
			choice="a";;
		2)  if [ "$init_x" -eq 1 ] 
			then
			init_same $imm $outputdir
			fi
			choice="a";;
		4)	echo "Goodbye!"
			cd $outputdir
			if [ "$init_x" -eq 1 -a "$slack" = "no" ]
			then
			p11="<html><head><title>Results</title></head><body><center><h1>Files found</h1></center>"
			for l in $(ls *.html)
			do
			p12=$p12."<a href='$l'>$l</a><br>"
			done
			p13="<br><br><br><a href='index.html'>BACK to INDEX</a>"
			p14="</body></html>"
			echo $p11$p12$p13$p14 > index.html
			fi
			cd ..
			echo "File saved in "$outputdir
			mainmenu;;
		1)	if [ "$init_x" -eq 1 -a "$slack" = "no" ]
			then
			#ext=${f##*.}                        
			icat -f $fs -o $offs $imm $ind > $outputdir/${f##*/}
			p1="<html><head><title>Results</title></head><body><center><h1>Files found</h1></center>"
			p2="<a href='${f##*/}'>$f</a><br>Cluster: $d<br>I-Node: $inode<br>"
			p3="<br><br><br><a href='index.html'>BACK to INDEX</a>"
			p4="</body></html>"
			echo $p1$p2$p3$p4 > $outputdir/$tdate.html
			echo "File saved!"
			fi
			choice="a";;
		*) 	echo "Wrong type of choice, write one of the values indicated above."
			read answer
			echo " "
			choice="z";;
	esac	
done
done
}

init_x=0

init ()
{
init_x=1
echo "Insert the image file or the device: "
read imm 
tdate=$( date | sed 's/ //g' | sed 's/://g')
echo "Insert the output directory:"
read outputdir
mkdir $outputdir
#########################
echo "Insert carved file name (eg. 00032456):"
read fn1
fn=$(echo "$fn1" | bc)
offcarv=$(($fn * 512 | bc))
if ! (mmls $imm > /dev/null ) 2>/dev/null
then
echo "0">$outputdir/offs.txt
echo "The starting sector is 0"
else
mmls $imm | grep ^[0-9] | grep '[[:digit:]]'| awk '{print $3,$4}' > $outputdir/mmls.txt

j=-1
cat $outputdir/mmls.txt | while read line
do
j=$(( j+1 )) 
startsect0=$(echo $line | awk '{print $1}')
startsect=$(echo "$startsect0" | bc)
endsect0=$(echo $line | awk '{print $2}')
endsect=$(echo "$endsect0" | bc)
startoff=$(($startsect * 512 | bc))
endoff=$(($endsect * 512 | bc))
	if [ $offcarv -ge $startoff ] && [ $offcarv -le $endoff ]
	then
	mmls $imm
	echo "The file is in $startoff <= "$offcarv" <= $endoff"
	echo "Expressed in sectors: Starting sector" $startsect " Ending sector: "$endsect
	echo "Partition number: "$j
	echo $startsect>$outputdir/offs.txt
	fi
done
fi

offs=$(cat $outputdir/offs.txt)
fsstat -o $offs $imm | grep -ia "File System Type:\|cluster size\|block size\|sector size"
echo " "
echo "Insert the sector size (eg. 4096):"
read ss

echo "Insert the file system type:"
fls -f list
echo " "
read fs
offbytepart=$(($offs * 512 | bc))
d=$((($offcarv - $offbytepart) / $ss | bc))
echo "Cluster: "$d
#echo $d>$outputdir/cluster.txt
inode=$(ifind -f $fs -o $offs -d $d $imm)
#echo $inode>$outputdir/inodes.txt
slack="no"
if [ "$inode" != "Inode not found" ]
then
echo "I-Node: "$inode
ind=$(echo $inode | awk '{print $1}')
f=$(ffind -f $fs -o $offs $imm $ind)
echo "FILE NAME: "$f
else
slack=$(blkcat -f $fs -o $offs $imm $d | xxd -l $ss)
echo -e "CarvedFileName:$offcarv\n------------------------------\n $slack \n------------------------------------\nCluster: $d Partition offset: $offs\n " >>$outputdir/slacks.txt
fi	
#echo -e "Cluster: $d\nI-Node: $inode\nFile name: $f\n" > $outputdir/filename.txt
rm $outputdir/offs.txt

menu
} # end init

init_same ()
{
init_x=1
imm=$1 
tdate=$( date | sed 's/ //g' | sed 's/://g')
outputdir2=$2

#########################
echo "Insert carved file name (eg. 00032456):"
read fn1
fn=$(echo "$fn1" | bc)
offcarv=$(($fn * 512 | bc))
if ! (mmls $imm > /dev/null ) 2>/dev/null
then
echo "0">$outputdir2/offs.txt
echo "The starting sector is 0"
else
mmls $imm | grep ^[0-9] | grep '[[:digit:]]'| awk '{print $3,$4}' > $outputdir2/mmls.txt

j=-1
cat $outputdir2/mmls.txt | while read line
do
j=$(( j+1 )) 
startsect0=$(echo $line | awk '{print $1}')
startsect=$(echo "$startsect0" | bc)
endsect0=$(echo $line | awk '{print $2}')
endsect=$(echo "$endsect0" | bc)
startoff=$(($startsect * 512 | bc))
endoff=$(($endsect * 512 | bc))
	if [ $offcarv -ge $startoff ] && [ $offcarv -le $endoff ]
	then
	mmls $imm
	echo "The file is in $startoff <= "$offcarv" <= $endoff"
	echo "Expressed in sectors: Starting sector" $startsect " Ending sector: "$endsect
	echo "Partition number: "$j
	echo $startsect>$outputdir2/offs.txt
	fi
done
fi

offs=$(cat $outputdir2/offs.txt)
fsstat -o $offs $imm | grep -ia "File System Type:\|cluster size\|block size\|sector size"
echo " "
echo "Insert the sector size (eg. 4096):"
read ss

echo "Insert the file system type:"
fls -f list
echo " "
read fs
offbytepart=$(($offs * 512 | bc))
d=$((($offcarv - $offbytepart) / $ss | bc))
echo "Cluster: "$d
#echo $d>$outputdir2/cluster.txt
inode=$(ifind -f $fs -o $offs -d $d $imm)
#echo $inode>$outputdir2/inodes.txt
slack="no"
if [ "$inode" != "Inode not found" ]
then
echo "I-Node: "$inode
ind=$(echo $inode | awk '{print $1}')
f=$(ffind -f $fs -o $offs $imm $ind)
echo "FILE NAME: "$f
else
slack=$(blkcat -f $fs -o $offs $imm $d | xxd -l $ss)
echo -e "CarvedFileName:$offcarv\n------------------------------\n $slack \n------------------------------------\nCluster: $d Partition offset: $offs\n " >>$outputdir/slacks.txt
fi	
rm $outputdir2/offs.txt
#echo -e "Cluster: $d\nI-Node: $inode\nFile name: $f\n" > $outputdir2/filename.txt
menu
}

sk()
{
echo "Insert the image file or the device: "
read imm 
echo "Insert the output directory for the keywords:"
read outdir
mkdir "key_"$outdir
outputdir="key_"$outdir
j=-1
echo "Do you have a file named keys.txt,composed by two fields only: 'offset:keyword', containing keywords in $outputdir? (y/n)"
read kyn
if [ "$kyn" != "y" ]
then
echo "Insert the keywords separated by commas (eg. guns,apple,sky)"
read k
kk=$(echo $k | sed 's/,/\\|/g')
echo "The search for the keywords has begun...hold on"
grep -iaob $kk $imm > $outputdir/keys.txt
fi
	check_offs_zero=0
	pck=0
	search=0
		for offkk in $(grep ":" $outputdir/keys.txt)
		do
		search=1
		offk=$(echo $offkk | awk -F ":" '{print $1}')
		k_name=$(echo $offkk | awk -F ":" '{print $2}' | uniq )
		offcarv=$(($offk | bc))
		if ! (mmls $imm > /dev/null ) 2>/dev/null
	then
	echo "0">$outputdir/offs.txt
	echo "The starting sector is 0"
	else
	
	mmls $imm | grep ^[0-9] | grep '[[:digit:]]'| awk '{print $3,$4}' > $outputdir/mmls.txt
		cat $outputdir/mmls.txt | while read line
		do
		j=$(( j+1 )) 
		startsect0=$(echo $line | awk '{print $1}')
		startsect=$(echo "$startsect0" | bc)
		endsect0=$(echo $line | awk '{print $2}')
		endsect=$(echo "$endsect0" | bc)
		startoff=$(($startsect * 512 | bc))
		endoff=$(($endsect * 512 | bc))
			if [ $offcarv -ge $startoff ] && [ $offcarv -le $endoff ]
			then
			mmls $imm
			echo "The file is in $startoff <= "$offcarv" <= $endoff"
			echo "Expressed in sectors: Starting sector" $startsect " Ending sector "$endsect
			echo "Partition number: "$j
			echo $startsect>$outputdir/offs.txt
			fi 
			
		done
			j=-1
			fi
			
offs=$(cat $outputdir/offs.txt)			
if [ "$pck" -eq "0" ]
then
pck=$offs
fi

if [ "$offs" -ge "0" -a "$check_offs_zero" -eq "0" ]
then
fsstat -o $offs $imm | grep -ia "File System Type:\|cluster size\|block size\|sector size"
echo " "
echo "Insert the sector size (eg. 4096):"
read ss
echo "Insert the file system type:"
fls -f list
echo " "
read fs
check_offs_zero=1
fi

if [ "$pck" != "$offs" -a "$pck" -gt "0" ]
then
fsstat -o $offs $imm | grep -ia "File System Type:\|cluster size\|block size\|sector size"
echo " "
echo "Insert the sector size (eg. 4096):"
read ss
echo "Insert the file system type:"
fls -f list
echo " "
read fs
pck=$offs
fi
offbytepart=$(($offs * 512 | bc))
d=$((($offcarv - $offbytepart) / $ss | bc))
echo "Cluster: "$d
inode=$(ifind -f $fs -o $offs -d $d $imm)
if [ "$inode" != "Inode not found" ]
then
echo "I-Node: "$inode
ind=$(echo $inode | awk '{print $1}')
f=$(ffind -f $fs -o $offs $imm $ind)
echo "FILE NAME: "$f
	echo -e "Keyword:$k_name FILE NAME: $f I-node:$inode Cluster: $d Partition offset: $offs\nfor saving it: icat -f $fs -o $offs $imm $ind > $outputdir/${f##*/}\n" >>$outputdir/keys_in.txt	
else
slack=$(blkcat -f $fs -o $offs $imm $d | xxd -l $ss)
echo -e "Keyword: $k_name $slack Cluster: $d Partition offset: $offs\n ">>$outputdir/keys_in.txt
fi	
		done #end readline key.txt
		if [ "$search" -eq 0 ]
		then
		echo "No keywords found!"
		fi
# da fare: controllo errore quando la keyword � nello slack space, uscita in html, verifica partizioni

}


mainmenu()
{
logo
loop="1"
while [ "$loop"="1" ] 
do
choice="z"
echo "Choose among these options:"

echo "1-File names from carved space on new device"
echo "2-Search for the keywords"
echo "3-Quit"

read answer
echo " "
echo " "	
while [ "$choice" = "z" ] 
do
	case $answer in
		2)	sk
			choice="a";;
		1)	init
			choice="a";;
		3)	echo "Goodbye!"
			echo "File are in "$outputdir
			exit;;
		*) 	echo "Wrong type of choice, write one of the values indicated above."
			read answer
			echo " "
			choice="z";;
	esac	
done
done
}
mainmenu
exit 
