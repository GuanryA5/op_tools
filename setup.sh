#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=`pwd`

include(){
    local include={$1}
    if [[ -s ${cur_dir}/include/${include}.sh]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error: \" ${cur_dir}/include/${include}.sh \" dosen't found ! shell can not be executed." 
    fi
}

tools(){
    include public
    include config
    include lamp
    include mysql
    include php
}

tools 2>&1 |tee ${cur_dir}/log/{$1}log