#!/bin/bash
sudo su
printf "$1"
printf "teste"
echo "$2"
exit
cd $1

#retira 4 caracteres em branco de todos os Tabs de cada arquivo php
for arquivo in *.php;
do
mv $arquivo ${arquivo}.tmp
cat ${arquivo}.tmp |expand -t4 > $arquivo
rm ${arquivo}.tmp
done

#retira 4 caracteres em branco de todos os Tabs de cada arquivo class
for arquivo in *.class;
do
mv $arquivo ${arquivo}.tmp
cat ${arquivo}.tmp |expand -t4 > $arquivo
rm ${arquivo}.tmp
done
