#!/bin/bash

registry=""

if [ $# -eq 1 ];  then
	registry=$1
else 
	echo "[$0] ERROR!! Invalid argument count"
	echo "[$0] [Usage] $0 192.168.6.110:5000"
	exit 1
fi

image_num=$(cat imagelist | wc -l)
echo "[$0] Load ${image_num} images & Push to ${registry}"

i=1
cat imagelist | while read line
do
	echo "[$0] [ ${i} / ${image_num} ] $line"
	name=`echo $line |tr '/' '-'`
	sudo docker load < ./images/${name}.tar
	sudo docker tag $line ${registry}/$line
	sudo docker push ${registry}/$line
	let i+=1
done

echo "[$0] Done"
