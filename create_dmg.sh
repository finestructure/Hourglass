#! /bin/sh

appname=PdbX

if [[ -z $VERSION ]]; then
  VERSION=$(./getVersion.py)
fi
size=10  # Mbytes
fileSystem=HFS+
volumeName=${appname}_${VERSION}
imageName=${volumeName}.dmg

fileSet[0]="build/Release/${appname}.app"
fileSet[1]="Release Notes.txt"


echo
echo Creating $volumeName disk image
echo

rm -f $imageName

hdiutil create $imageName -ov -fs $fileSystem -megabytes $size \
    -volname $volumeName > /dev/null 2>&1

echo Mounting $imageName

device=`hdid $imageName \
    | grep '/dev/disk[0-9]*' \
    | grep "$volumeName" \
    | cut -d ' ' -f 1`

echo Copying files

for file in "${fileSet[@]}"; do
    echo Copying $file ...
    /Developer/Tools/CpMac -r "$file" /Volumes/$volumeName
done


echo Image file list:
ls -l /Volumes/$volumeName
echo

echo Ejecting $imageName

hdiutil eject $device > /dev/null 2>&1

echo Compressing $imageName ...
echo

echo mv $imageName ${imageName}.2.dmg
mv $imageName ${imageName}.2.dmg

hdiutil convert ${imageName}.2.dmg -format UDCO -o ${imageName} \
    | grep "File size"
rm ${imageName}.2.dmg

echo