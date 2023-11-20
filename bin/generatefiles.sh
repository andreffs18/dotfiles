#!/bin/bash

if [ $# -ne 4 -a $# -ne 5 ]
then
echo "Usage:  generatefiles <depth> <num of folders per depth> <num of files per folder> <max size of file> [<min size of file>]"
echo "Examples:"
echo "$ generatefiles.sh 1  0 10 1024 1024      # Generate 1 root folder with 1 folder with 10 files between 1024 bytes and 1024 bytes"
echo "$ generatefiles.sh 1  1 1  1024 1024      # Generate 1 root folder with 1 folder with 1 file between 1024 bytes and 1024 bytes"
echo "$ generatefiles.sh 10 1 1  5120           # Generate 1 folder until 10 levels deep, with 1 file each with max 5120 bytes in size"

exit -1
fi

declare path=$(pwd)
declare numDepth=$1
declare numFolders=$2
declare numFiles=$3
declare maxSize=$4
declare minSize=0


CreateFolders(){
local depth=$1
local folderRoot=$2
local name=$3
CreateFiles $folderRoot folder$name
if [ $depth -eq $numDepth ]
then
    return;
fi
local newDepth=$((depth + 1))

local folderIndex=1;
for (( ; folderIndex <= $numFolders; folderIndex++ ))
do
    local folderName=$name-$folderIndex
    fullFolderName=$folderRoot/folder$folderName
    mkdir $fullFolderName
    echo fullFolderName: $fullFolderName

    local newRoot=$folderRoot/folder$folderName
    CreateFolders "$newDepth" "$newRoot" "$folderName"
done
}

CreateFiles()
{
    local folderRoot=$1
    local folderName=$2
    local fileIndex=1;
    for (( ; fileIndex <= $numFiles; fileIndex++ ))
    do
        local fileName=file$folderName-$fileIndex.txt
        CreateFile "$fileName" "$folderRoot"
    done
}

CreateFile()
{
    local fileName=$1
    local folderRoot=$2
    local fullFileName=$folderRoot/$fileName
    echo fullFileName: $fullFileName
    random32=$(( ( ($RANDOM & 3)<<30 | $RANDOM<<15 | $RANDOM ) & 0x7FFFFFFF ))
    randomSize=$((random32%$maxSize))
    if [ $randomSize -lt $minSize ]
    then
        randomSize=$minSize
    fi
    echo randomSize:$randomSize maxSize:$maxSize
    perl -pe 'binmode(STDIN, ":bytes"); tr/A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+=//dc;' < /dev/urandom | head -c $randomSize > $fullFileName
}


if [ $# -eq 5 ]
then
    minSize=$5
fi

echo path: $path numDepth: $numDepth numFolders: $numFolders numFiles: $numFilesecho maxSize: $maxSize minSize: $minSize

time=$(date -u | tr ": " "--")
echo $time
Syncpoint=$path/$time
mkdir $Syncpoint
CreateFolders "0" "$Syncpoint" ""
