#!/bin/bash

# CLI input variables
interactive=0
filename=

# File Output Variables
redis_master_ip=
file_prefix=
redis_port=
sentinel_port=


interactiveRun() {
    echo "### Please provide the following: ###"
    echo "IP address for redis master: "
    read redis_master_ip
    echo "Prefix/Country (i.e.: MY): "
    read file_prefix
    echo "Redis Port to use: "
    read  redis_port
    echo "Sentinel Port to use: "
    read sentinel_port
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

load_config_file() {
    eval "$(parse_yaml $filename)"
}

usage() {
    echo "Usage: redis-config-cli [OPTIONS] [arg ...]"
    echo "  -f <filename>       YAML config file path."
    echo "  -i <interactive>    Interactive mode."
    echo "  -h <help>           Output this help and exit."
}

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )            shift
                                filename=$1
                                ;;
        -i | --interactive )    interactive=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$interactive" -eq 1 ]
then
    interactiveRun
elif [ ! -z "$filename" ]
then
    load_config_file
fi


if [ -z "$redis_master_ip"  ]
then
    echo "Invalid config params"
else
    echo "Creating .conf files"
fi
