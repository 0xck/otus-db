#!/bin/sh

tag_name="otus_wrex_test_db"
init_file="schema.gz"

while [ -n "$1" ]
do
case "$1" in

    -n) tag_name="$2"
        shift ;;

    -h) echo "Build script for study case."
        echo "Script makes docker image using Dockerfile in current directory."
        echo "The image contains Postgresql DB with study case shema."
        echo
        echo "Usage: $0 [-n tag_name]"
        echo "Just execute $0 in directory which contains appropriate Dockerfile."
        echo "Change behaviour with following options:"
        echo "-n <name> image tag. Default is otus_wrex_test_db."
        exit 0 ;;

    *) echo "$1 is unknown option."
       exit 1 ;;
esac
shift
done


if ! [ `which zcat` ]
then
    echo "Zcat (part of gzip) was not found. Please install one first.";
    exit 1 ;
fi

if ! [ `which docker` ]
then
    echo "Docker was not found. Please install one first.";
    exit 1;
fi

if ! [ -r $init_file ]
then
    echo "DB init file $init_file was not found in current directory. Please add one.";
    exit 1 ;
fi

zcat $init_file > init.sql;
docker build -t $tag_name . ;

echo "Done."