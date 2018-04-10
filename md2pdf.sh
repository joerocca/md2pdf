#!/bin/bash

sourcePath="$HOME/Documents/Notes"
destPath="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notes"
hashFilePath="$sourcePath/.note_hashes" #must delete .note_hashes if changing destination path or else files will not be added to new destination
numOfJobs=0

declare -A hashes
if [ -f "$hashFilePath" ]; then
	source $hashFilePath
fi

for file in $sourcePath/*.md; do
	newHash=$(shasum $file | awk '{print $1}')
	oldHash=${hashes[$file]}
	
	if [ "$newHash" != "$oldHash" ]; then
		#File has been changed!
		hashes[$file]=$newHash
		
		if [ ! -d "$destPath" ]; then
			mkdir "$destPath"
		fi
		
		baseFileNameExt=$(basename $file)
		baseFileName=${baseFileNameExt%%.*}
		
		cp "$file" "$destPath/$baseFileNameExt" 

		pandoc $file -s -o "$destPath/$baseFileName.pdf" &

		numOfJobs=$(($numOfJobs+1))	
	fi
done

if (($numOfJobs > 0)); then		
	declare -p hashes > $hashFilePath

	echo "Converting $numOfJobs files..."
	wait
	echo "Done!"
else
	echo "Up to date!"
fi
