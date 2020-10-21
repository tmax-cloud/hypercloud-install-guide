#!/bin/bash

image_num=$(cat imagelist | wc -l)
echo "[$0] Pull ${image_num} images & Save as tar files"

mkdir ./images

i=1
cat imagelist | while read line
do
	echo "[$0] [ ${i} / ${image_num} ] $line"
	sudo docker pull $line
	name=`echo $line |tr '/' '-'`
        sudo docker save $line > ./images/${name}.tar
	let i+=1
done

echo "[$0] Done"
