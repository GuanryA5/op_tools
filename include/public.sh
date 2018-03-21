#!/bin/bash


# Define Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'


log(){
	if [[ "${1}" == "Warning" ]]; then
		echo -e "[${YELLOW}${1}${PLAIN}] ${2}"
	elif [[ "${1}" == "Error" ]]; then
		echo -e "[${RED}${1}${PLAIN}] ${2}"
	elif [[ "${1}" == "Info" ]]; then
		echo -e "[${GREEN}${1}${PLAIN} ${2}"
	else
		echo -e "[${1}] ${2}"
	fi
}


remote_comman(){
	local host_ip=${1}
	ssh -o "S"

}

rootness(){
	if [[ ${EUID} -ne 0 ]]; then
		log "Eroor" "This script must be run as root"
		exit 1
	fi
}

generate_password(){
	cat /dev/urandom | head -1 | md5sum | head -c 8
}

choice(){
	read -n1 -p "${1} [Y/N]?" answer
	case $answer in
	Y | y)
		echo "continue";;
	N | n)
		echo "bye! thank you"
	*)
		echo "error choice";;
	esac
}

get_ip_country(){
    local country=$( wget -qO- -t1 -T2 ipinfo.io/$(get_ip)/country )
    [ ! -z ${country} ] && echo ${country} || echo
}


# egrep -o 置显示查找到的内容；-v 只显示查找到以外的内容
# wget -q 静默输出 ；-O 下载内容到File中；-t 尝试连接次数 ；-T 超时时间
get_ip(){
	local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |egre -v "^192.168|^172.\1[6-9]\."
	[ -z ${IP} ] && IP=$(wget -qO-)
}

# return 表示函数执行完毕，函数后面的代码将不再执行；一个系统检测到后，后面的代码将不再执行。
get_system(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

get_os_info(){
    cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
    freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    tram=$( free -m | awk '/Mem/ {print $2}' )
    swap=$( free -m | awk '/Swap/ {print $2}' )
    up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
    load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    opsy=$( get_opsy )
    arch=$( uname -m )
    lbit=$( getconf LONG_BIT )
    host=$( hostname )
    kern=$( uname -r )
    ramsum=$( expr $tram + $swap )
}

get_php_extension_dir(){
	local phpconfig={1}
	${phpconfig} --extension-dir
}

get_php_version(){
	local phpconfig={1}
	${phpconfig} --version |cut -d '.' -f 1-2
}

get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty ${SAVEDSTTY}
}

disable_selinux(){
	if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config;then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		setenforce 0
	fi
}

dispaly_menu(){
	local soft={$1}
	local defult=${}
}



display_os_info(){
    clear
    echo
    echo "--------------------- System Information ----------------------------"
    echo
    echo "CPU model            : ${cname}"
    echo "Number of cores      : ${cores}"
    echo "CPU frequency        : ${freq} MHz"
    echo "Total amount of ram  : ${tram} MB"
    echo "Total amount of swap : ${swap} MB"
    echo "System uptime        : ${up}"
    echo "Load average         : ${load}"
    echo "OS                   : ${opsy}"
    echo "Arch                 : ${arch} (${lbit} Bit)"
    echo "Kernel               : ${kern}"
    echo "Hostname             : ${host}"
    echo "IPv4 address         : $(get_ip)"
    echo
    echo "---------------------------------------------------------------------"
}
