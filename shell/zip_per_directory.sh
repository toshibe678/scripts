#! /bin/sh

IFS="
"

for dir in `find ./ -type d`
do
    dir=`basename $dir`
    if [ $dir != `basename ./` ]
    then
        zip -r $1$dir.zip $1$dir
    fi
done