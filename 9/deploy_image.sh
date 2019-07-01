#!/bin/sh

tag="otus_wrex_test_db"
name=$tag
init_file="schema.gz"
port=5432
run_container=0
docker_opts=""

while [ -n "$1" ]
do
case "$1" in
    -d) docker_opts="$2"
        shift ;;

    -n) name="$2"
        shift ;;

    -p) port="$2"
        shift ;;

    -t) tag="$2"
        shift ;;

    -R) run_container=1 ;;

    -h) echo "Deploy script for study case."
        echo "Script makes docker image using Dockerfile in current directory and optionally run one."
        echo "The image contains Postgresql DB with study case shema."
        echo
        echo "Usage: $0 [-R] [-t tag] [-n name] [-p port] [-d \"string of docker options\"]"
        echo "Just execute $0 in directory which contains appropriate Dockerfile."
        echo "Change behaviour with following options:"
        echo "-h            Show help message."
        echo "-d <options>  Additional docker options as space separated string. Default options are -d -p --name."
        echo "-n <name>     Image name. Default is otus_wrex_test_db."
        echo "-p <port>     External port. Default is 5432."
        echo "-t <tag>      Image tag. Default is otus_wrex_test_db."
        echo "-R            Run built container. Default is not run."
        exit 0 ;;

    *) echo "$1 is unknown option."
       exit 1 ;;
esac
shift
done

if [ $port -lt 1 ] || [ $port -gt 65355 ]
then
    echo "Wrong port value. Port has to belong to 1-65355 range.";
    exit 1 ;
fi

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

echo "Building image started.";
zcat $init_file > init.sql;
docker build -t $tag . ;
echo "Building image completed.";

if [ $run_container -eq 1 ]
then
    echo "Running container...";
    docker run -d -p $port:5432 --name $name $tag $docker_opts
fi

echo "Done."