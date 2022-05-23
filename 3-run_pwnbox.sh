#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

n_scan=1
n_scans=26


box_ip=$1
host=$2
new_ports=$3[@]
ports=("${!new_ports}")
wpapi=$4

##############################
# 		 Port Scans 	 	 #
##############################

port_scans () {
    printf "\n${GREEN}[${i_progress}/${t_progress}]${BLUE} Starting Port Scans... \n"


    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} rustscan \n"
    init_ports=$(docker run rustscan/rustscan -ga $box_ip | cut -f2 -d "[" | cut -f1 -d "]")
    printf "\n${YELLOW}${init_ports} \n"
    sed -i "s+init_ports=+init_ports=${init_ports}+gi" ${loc}/box_vars.sh
    n_scan=$((n_scan+1))


    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} masscan - tcp \n"
    sudo masscan -p0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-tcp.md -e $inf
    tcp=$(cat ${loc}/1-recon/masscan-tcp.md | grep -oP '(?<=Ports: )S*'| cut -f1 -d "/" | tr 'n' ',' | rev | cut -f2- -d "," | rev)
    printf "\n${YELLOW}${tcp} \n"
    sed -i "s+tcp=+tcp=${tcp}+gi" ${loc}/box_vars.sh
    n_scan=$((n_scan+1))


    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} masscan - udp \n"
    sudo masscan -pU:0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-udp.md -e $inf
    udp=$(cat ${loc}/1-recon/masscan-udp.md | grep -oP '(?<=Ports: )S*'| cut -f1 -d "/" | tr 'n' ',' | rev | cut -f2- -d "," | rev)
    sed -i "s+udp=+udp=${udp}+gi" ${loc}/box_vars.sh
    printf "\n${YELLOW}${udp} \n"
    n_scan=$((n_scan+1))


    declare -g all_ports="${tcp},${udp}"
    if [[ $all_ports == *, ]]; then
        all_ports=$(echo $all_ports | rev | cut -f2- -d "," | rev)
    fi
    sed -i "s+all_ports=+all_ports=${all_ports}+gi" ${loc}/box_vars.sh
}

port_scans

##############################
#  	    Init_Recon	         #
##############################

init_recon () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} AutoRecon \n"

    sudo python3 /opt/AutoRecon/autorecon.py $box_ip -p ${all_ports} -o ${loc}/misc-tools/autorecon/
    sudo python3 /opt/AutoRecon/autorecon.py $host -p ${all_ports} -o ${loc}/misc-tools/autorecon/

    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} Nmap TCP \n"

    nmap -Pn -vvv -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/ip_tcp.md $box_ip
    nmap -Pn -vvv -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/host_tcp.md $host

    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} Nmap UDP \n"

    sudo nmap -Pn -vvv -sU -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/ip_udp.md $box_ip
    sudo nmap -Pn -vvv -sU -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/host_udp.md $host

    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} Nmap Vuln \n"

    nmap -Pn -vvv -p ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/ip_vuln_tcp.md $box_ip
    nmap -Pn -vvv -p ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/host_vuln_tcp.md $host
    nmap -Pn -vvv -p -sU ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/ip_vuln_udp.md $box_ip
    nmap -Pn -vvv -p -sU ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/host_vuln_udp.md $host

    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} Nmap ALL ports (background) \n"

    nmap -Pn -vvv -p- -A -oN ${loc}/1-recon/nmap/ip_tcp_agress_all.md $box_ip &
    nmap -Pn -vvv -p- -A -oN ${loc}/1-recon/nmap/host_tcp_agress_all.md $host &
    sudo nmap -Pn -vvv -sU -p- -A -oN ${loc}/1-recon/nmap/ip_udp_agress_all.md $box_ip &
    sudo nmap -Pn -vvv -sU -p- -A -oN ${loc}/1-recon/nmap/host_udp_agress_all.md $host &
}
init_recon

# wordlists for fuzzing
seclist_dir=$(find / -type d -name "SecLists" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
if [ -z "$seclist_dir" ]; then
	git clone https://github.com/danielmiessler/SecLists.git
	seclist_dir=$(find / -type d -name "SecLists" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
fi

##############################
#  	       DNS	             #
##############################

# Shot in the dark

printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} DNS Recon \n"
host -l $host $box_ip | tee ${loc}/2-enum/dns/host.md
nslookup $host -q=any | tee ${loc}/2-enum/dns/nslookup_ip.md
nslookup $box_ip -q=any | tee ${loc}/2-enum/dns/nslookup_host.md
dnsrecon -a -n $box_ip -d $host -t axfr | tee ${loc}/2-enum/dns/dnsrecon.md
dig -p  $box_ip @${box_ip} | tee ${loc}/2-enum/dns/dig.md
printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} DNS Enumeration \n"
dig axfr $host @${box_ip} | tee ${loc}/2-enum/dns/dig.md
dnsenum $host -o ${loc}/2-enum/dns/dnsenum.md
dnsenum $host --noreverse -o ${loc}/2-enum/dns/dnsenum_noreverse.md
dnsrecon -a -n $box_ip -d $host -D ${seclist_dir}/Discovery/DNS/subdomains-top1million-110000.txt -t brt | tee ${loc}/2-enum/dns/dnsrecon_brute.md

# parse nmap for more domains, and then run dnsenum on them

yeet_dns () {
    domain = $1

    mkdir -p ${loc}/2-enum/dns/${domain}
    dir = ${loc}/2-enum/dns/${domain}

    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} DNS Recon \n"
    host -l $1 $box_ip | tee ${dir}/host.md
    nslookup $1 -q=any | tee ${dir}/nslookup_ip.md
    nslookup $box_ip -q=any | tee ${dir}/nslookup_host.md
    dnsrecon -d $1 -t axfr | tee ${dir}/dnsrecon.md
    dig -n $box_ip -d $1 | tee ${dir}/dig.md
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} DNS Enumeration \n"
    dig axfr $1 @${box_ip} | tee ${dir}/dig_records.md
    dnsenum $1 -o ${dir}/dnsenum.md
    dnsenum $1 --noreverse -o ${dir}/dnsenum_noreverse.md
    dnsrecon -d $1 -D ${seclist_dir}/Discovery/DNS/subdomains-top1million-110000.txt -t brt | tee ${dir}/dnsrecon_brute.md
}

##############################
#  	   Enum Services	     #
##############################

ports=$(cat ip_tcp.md | grep open | cut -f1 -d "/")
services=$(cat ip_tcp.md | grep open | cut -f4 -d " ")
arr_ports=($ports)
arr_services=($services)

http_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} HTTP Enumeration on $port \n"
    printf "\n${YELLOW} For directory brute forcing, refer to:\n ${loc}/cmds2run/6-brute_forcing.md \n\n"
    box_ip = $1
    host = $2
    port = $3
    loc = $4
    wpapi_token = $5

    whatweb ${box_ip}:${port}  | tee ${loc}/2-enum/web/whatweb_ip.md

    whatweb ${host}:${port}  | tee ${loc}/2-enum/web/whatweb_host.md

    nikto -h $box_ip -port $web1 -o ${loc}/2-enum/web/nikto_ip.txt

    for i in {5..10}; do
        touch ${loc}/misc-tools/cewl/cewl_ip_${i}.md
        touch ${loc}/misc-tools/cewl/cewl_words_host_${i}.md
        cewl -d 10 -m $i -w ${loc}/misc-tools/cewl/cewl_ip_${i}.md ${ipurl}:${port}   
        cewl -d 10 -m $i -w ${loc}/misc-tools/cewl/cewl_words_host_${i}.md ${hosturl}:${port}   
    done

    if [[ -z wpapi_token ]]; then
        docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${ipurl}:${port}   -f cli-no-color -o ${loc}/2-enum/web/wpscan_ip.md  --enumerate u,m,ap,at,tt,cb,dbe --plugins-detection mixed

        docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${hosturl}:${port}   -f cli-no-color -o ${loc}/2-enum/web/wpscan_host.md  --enumerate u,m,ap,at,tt,cb,dbe --plugins-detection mixed

        docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${ipurl}:${port}   -U enum/box_users.md -P /usr/share/wordlists/rockyou.txt -o enum/web/wpscan_ip_brute.md

        docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${hosturl}:${port} -U enum/box_users.md -P /usr/share/wordlists/rockyou.txt -o enum/web/wpscan_host_brute.md
    fi

    tpls=("dns" "cves" "cnvd" "takeovers" "vulnerabilities" "file" "fuzzing" "miscellaneous" "exposed-panels")
    for tpl in ${tpls[@]}; do 
        docker run projectdiscovery/nuclei -t $tpl -u ${ipurl}:${port} -o ${loc}/misc-tools/nuclei/${tpl}.md
        docker run projectdiscovery/nuclei -t $tpl -u ${hosturl}:${port} -o ${loc}/misc-tools/nuclei/${tpl}.md
    done

    python3 /opt/Photon/photon.py -u ${ipurl}:${port} -l 10 --dns --clone --headers --keys -v -o ${loc}/misc-tools/photon_ip/
    python3 /opt/Photon/photon.py -u ${hosturl}:${port} -l 10 --dns --clone --headers --keys -v -o ${loc}/misc-tools/photon_host/
}

smb_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} SMB Enumeration\n"
    box_ip = $1
    host = $2
    port = $3
    loc = $4

    nmblookup -A $box_ip | tee ${loc}/2-enum/smb/nmblookup_ip.md
    nbtscan -i $box_ip | tee ${loc}/2-enum/smb/nbtscan_ip.md
    nmap --script nbstat.nse $box_ip | tee ${loc}/2-enum/smb/nbstat_ip.md
    nmap --script smb-os-discovery.nse $box_ip | tee ${loc}/2-enum/smb/smb-os-discovery_ip.md
    nmap --script smb-enum-shares.nse $box_ip | tee ${loc}/2-enum/smb/smb-enum-shares_ip.md
    nmap --script smb-vuln* $box_ip | tee ${loc}/2-enum/smb/smb-vuln_ip.md
}

ftp_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} FTP Enumeration on $port \n"
    box_ip = $1
    host = $2
    port = $3
    loc = $4
    
    nmap -Pn -p $port --script banner -oN ${loc}/2-enum/ftp/ftp_anon.md $box_ip
    nmap -Pn -p $port --script ftp-anon -oN ${loc}/2-enum/ftp/ftp_anon.md $box_ip

}

snmp_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} SNMP Enumeration on $port \n"
    box_ip = $1
    host = $2
    port = $3
    loc = $4

    snmp-check ${box_ip} | tee ${loc}/2-enum/snmp/snmp-check.md
    nmap --script snmp-brute $box_ip | tee ${loc}/2-enum/snmp/snmp-brute.md
    nmap -sU --script snmp-brute $box_ip | tee ${loc}/2-enum/snmp/snmp-brute-udp.md
    nmap --script snmp-interfaces $box_ip | tee ${loc}/2-enum/snmp/snmp-interfaces.md
    nmap -sU --script snmp-interfaces $box_ip | tee ${loc}/2-enum/snmp/snmp-interfaces-udp.md

    onsixtyone -c ${seclist_dir}/Discovery/SNMP/snmp-onesixtyone.txt ${box_ip} -o ${loc}/2-enum/snmp/onsixtyone-1.md
    onsixtyone -c ${seclist_dir}/Discovery/SNMP/common-snmp-community-strings.txt ${box_ip} -o ${loc}/2-enum/snmp/onsixtyone-2.md
    onsixtyone -c ${seclist_dir}/Discovery/SNMP/snmp.txt ${box_ip} -o ${loc}/2-enum/snmp/onsixtyone-3.md
}

ldap_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} LDAP Enumeration \n"
    box_ip = $1
    host = $2
    port = $3
    loc = $4

    w1="${seclist_dir}/Fuzzing/LDAP-active-directory-attributes.txt"
    w2="${seclist_dir}/Fuzzing/LDAP-active-directory-classes.txt"
    w2="${seclist_dir}/Fuzzing/LDAP-openldap-attributes.txt"
    w2="${seclist_dir}/Fuzzing/LDAP-openldap-classes.txt"
}


enum_services_init () {

    # http

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "http" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} HTTP Enum \n"
            http-enum ${arr_services[$i]} ${arr_ports[$i]} ${loc}
        fi
        o+=1
    done

    # smb

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "smb" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} SMB Enum \n"
            smb-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/smb/smb-enum-shares${o}.md
        fi
        o+=1
    done

    # ftp

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "ftp" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} FTP Enum \n"
            ftp-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/ftp/ftp-enum-users${o}.md
        fi
        o+=1
    done

    # tftp

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "tftp" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} TFTP Enum \n"
            tftp-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/tftp/tftp-enum-users${o}.md
        fi
        o+=1
    done

    # smtp

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "smtp" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} SMTP Enum \n"
            smtp-user-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/smtp/smtp-user-enum${o}.md
        fi
        o+=1
    done

    # snmp

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "snmp" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} SNMP Enum \n"
            snmp-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/snmp/snmpenum${o}.md
        fi
        o+=1
    done

    # imap

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "imap" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} IMAP Enum \n"
            imap-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/imap/imap-enum${o}.md
        fi
        o+=1
    done

    # pop3

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "pop3" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} POP3 Enum \n"
            pop3-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/pop3/pop3-enum${o}.md
        fi
        o+=1
    done

    # mssql

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "mssql" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} MSSQL Enum \n"
            mssql-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/mssql/mssql-enum-users${o}.md
        fi
        o+=1
    done

    # mysql

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "mysql" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} MYSQL Enum \n"
            mysql-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/mysql/mysql-enum${i}${o}.md
        fi
        o+=1
    done

    # mongodb

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "mongodb" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} MONGODB Enum \n"
            mongodb-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/mongodb/mongodb-enum${o}.md
        fi
        o+=1
    done

    # rdp

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "rdp" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} RDP Enum \n"
            rdp-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/rdp/rdp-enum${o}.md
        fi
        o+=1
    done

    # vnc

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "vnc" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} VNC Enum \n"
            vnc-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/vnc/vnc-enum${o}.md
        fi
        o+=1
    done

    # telnet

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "telnet" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} TELNET Enum \n"
            telnet-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/telnet/telnet-enum${o}.md
        fi
        o+=1
    done

    # ldap

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "ldap" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} LDAP Enum \n"
            ldap-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/ldap/ldap-enum${o}.md
        fi
        o+=1
    done

    # kerberos

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "kerberos" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} KERBEROS Enum \n"
            kerberos-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/kerberos/kerberos-enum${o}.md 
        fi
        o+=1
    done

    # nfs

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "nfs" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} NFS Enum \n"
            nfs-enum4  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/nfs/nfs-enum${o}.md
        fi
        o+=1
    done

    # msrpc

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "msrpc" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} MSRPC Enum \n"
            msrpc-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/msrpc/msrpc-enum${o}.md
        fi
        o+=1
    done

    # rmi

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "rmi" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} RMI Enum \n"
            rmi-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/rmi/rmi-enum${o}.md
        fi
        o+=1
    done

    # redis 

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "redis" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} REDIS Enum \n"
            redis-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/redis/redis-enum${o}.md
        fi
        o+=1
    done

    # mountd

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "mountd" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} MOUNTD Enum \n"
            mountd-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/mountd/mountd-enum${o}.md
        fi
        o+=1
    done
    
    # irc

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "irc" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} IRC Enum \n"
            irc-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/irc/irc-enum${o}.md
        fi
        o+=1
    done

    # cups

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "cups" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} CUPS Enum \n"
            cups-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/cups/cups-enum${o}.md
        fi
        o+=1
    done

    # cassandra

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "cassandra" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} CASSANDRA Enum \n"
            cassandra-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/cassandra/cassandra-enum${o}.md
        fi
        o+=1
    done

    # distccd

    o = 1
    for i in ${!arr_services[@]}; do
        if [[ ${arr_services[$i]} =~ "distccd" ]]; then
            printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} DISTCCD Enum \n"
            distccd-enum  ${arr_services[$i]}  ${arr_ports[$i]}  ${loc}/2-enum/distccd/distccd-enum${o}.md
        fi
        o+=1
    done






}
enum_services_init


##############################
#  	   MISC Services	     #
##############################

misc_service_enum () {
    printf "\n${GREEN}[${n_scan}/${n_scans}]${BLUE} enum4linux \n"

    enum4linux -a $box_ip | tee ${loc}/2-enum/2-enum4linux.md &


}
misc_service_enum