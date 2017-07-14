#!/bin/sh

a=`uname -r |cut -b 1-5`
cd /etc/yum.repos.d/;

if [ $a == '3.10.' ]
then
rm -rf CentOS-Base.repo epel.repo;
wget -O CentOS-Base.repo http://yum.example.com/CentOS-Base.repo.el7;
wget -O epel.repo http://yum.example.com/epel.repo.el7;
wget -O saltstack.repo http://yum.example.com/saltstack.repo.el7;
fi

cd /etc/yum.repos.d/;
if [ $a == '2.6.3' ]
then
rm -rf CentOS-Base.repo epel.repo;
wget -O CentOS-Base.repo http://yum.example.com/CentOS-Base.repo.el6 
wget -O epel.repo http://yum.example.com/epel.repo.el6;
wget -O saltstack.repo http://yum.example.com/saltstack.repo.el6;
fi

cd /etc/yum.repos.d/;
if [ $a == '2.6.1' ]
then
rm -rf CentOS-Base.repo epel.repo;
wget -O CentOS-Base.repo http://yum.example.com/CentOS-Base.repo.el5
wget -O epel.repo http://yum.example.com/epel.repo.el5;
wget -O saltstack.repo http://yum.example.com/saltstack.repo.el5;
fi

rm -rf k8s.repo;
wget -O k8s.repo http://yum.example.com/k8s.repo
