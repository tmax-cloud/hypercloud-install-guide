#!/bin/bash

dir=""

if [ $# -eq 1 ];  then
        dir=$1
else
        echo "[$0] ERROR!! Invalid argument count"
        echo "[$0] [Usage] $0 ${KF_DIR}/kustomize"
        exit 1
fi

module_num=$(ls ${dir} | wc -l)
echo "[$0] The number of modules: ${module_num}"

i=1
ls ${dir} | while read line
do
	echo "[$0] [ ${i} / ${module_num} ] $line"
        let i+=1
	
        kubectl apply -k ${dir}/$line
done

echo "[$0] Done"
