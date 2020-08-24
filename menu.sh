#!/bin/sh
#Shell menu
#Author qinliang

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
pwd=/etc/zabbix
pwd1=/etc/zabbix/zabbix_agentd.d

function Install_Zabbix_agent () {
            sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
            setenforce 0
            yum install nmap wget vim -y
      if grep -q 7. /etc/redhat-release; then
            rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
            yum -y install zabbix-sender zabbix-agent zabbix-get
            rm -rf /etc/zabbix/zabbix_agentd.conf
            rm -rf /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
      else
            rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
            yum -y install zabbix-sender zabbix-agent zabbix-get
            rm -rf /etc/zabbix/zabbix_agentd.conf
            rm -rf /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
      fi
      
      cd $pwd
      if [ -e zabbix_agentd.conf ]; then
          echo "zabbix_agentd.conf [found]"
          rm -rf zabbix_agentd.conf
      else
          echo "zabbix_agentd.conf not found!!!download now..."
          if ! wget -c https://raw.githubusercontent.com/learning2016/centos-initialize/master/zabbix_agentd.conf; then
              echo "Failed to download zabbix_agentd.conf, please download it to ${pwd} directory manually and try again."
              exit 1
          fi
      fi
      
      read -p "请输入Zabbix-Agent的Hostname:" Hostname
      echo "Hostname=$Hostname"
      echo "Hostname=$Hostname">>/etc/zabbix/zabbix_agentd.conf

      if grep -q 7. /etc/redhat-release; then
            systemctl start zabbix-agent.service
            systemctl enable zabbix-agent.service
            systemctl restart zabbix-agent.service
            systemctl status zabbix-agent;
      else
            chkconfig zabbix-agent on
            /etc/init.d/zabbix-agent start
            /etc/init.d/zabbix-agent restart
      fi
}

function menu () {
    cat << EOF
----------------------------------------
|***************菜单主页***************|
----------------------------------------
`echo -e "\033[33m 1)Zabbix-agent安装(必选)\033[0m"`
`echo -e "\033[33m 2)Pass服务监控\033[0m"`
`echo -e "\033[33m 6)退出\033[0m"`
EOF
read -p "请输入对应产品的数字：" num1
case $num1 in
#安装Zabbix-agent。
    1)
      #clear
      Install_Zabbix_agent
      menu
      ;;
#Pass服务监控。
    2)
      #clear
      Mysql_monitoring
      menu
      ;;
#退出
    6)
      exit 0
esac
}
menu
