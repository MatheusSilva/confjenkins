#!/bin/bash

cd /var/lib/jenkins/jobs/buildcommit/workspace


changeset=$(echo 'r' | svn info | cut -d: -f2 | head -n9 | tail -1 | sed 's/^[ \t]*//')

usu='UsuarioTrac'
pas='SenhaTrac'


resultado=$(svn log --username $usu --password $pas --verbose -r $changeset | cut -d: -f3 |sed 1d | sed 2d |sed '$ d'| cut -d# -f3 | sed 's/\/SGL\/trunk\/SGL\///g' | sed 1d| sed 's/   M//g')


resultadophpmd=$(svn log --username $usu --password $pas --verbose -r $changeset | cut -d: -f3 |sed 1d | sed 2d|sed '$ d'| cut -d# -f3 | sed 's/\/SGL\/trunk\/SGL\///g'  |sed 's/ /,/g' | sed 1d| sed 's/,,,M,/ ,/g') 

touch temp
touch build.xml
chmod 777 temp
chmod 777 build.xml

echo "$resultadophpmd"|tail -c +3 > temp
phpmd=`cat temp`


echo '<?xml version="1.0" encoding="UTF-8"?>

 <project name="name-of-project" default="build" basedir=".">
  
 <property name="source1" value="'$resultado'"/>

 <property name="source2" value="'\'$phpmd\''" />

 <target name="build" depends="prepare,phploc,phpmd-ci,phpcs-ci,phpcpd,phpdcd-ci"/>
 
 <target name="build-parallel" depends="prepare,tools-parallel"/>

 <target name="tools-parallel" description="Run tools in parallel">
 	<parallel threadCount="2">
   		<sequential>
    			<antcall target="phpmd-ci"/>
   		</sequential>
		<antcall target="phpcpd"/> 
   		<antcall target="phpcs-ci"/>
   		<antcall target="phploc"/>
   		<antcall target="phpdcd-ci"/>
  	</parallel>
 </target>

 <target name="prepare" description="Prepare for build">
 	<exec executable="mkdir">
   		<arg line="-p ${basedir}/build/logs" />
 	</exec>

	<exec executable="mkdir">
   		<arg line="-p ${basedir}/build/pdepend" />
 	</exec>
 </target>


  <target name="phploc" description="Measure project size using PHPLOC">
 	<exec executable="phploc">
   		<arg line="--log-xml ${basedir}/build/logs/phploc.xml ${source1} " />
 	</exec>
 </target>


 <target name="phpdcd-ci" description="Find duplicate code using PHPDCD">
 	<exec executable="phpdcd">
  		<arg line=" ${source1} " />
 	</exec>
 </target>

 
 <target name="phpcs-ci"
        description="Find coding stbuildcommit.xmlandard violations using PHP_CodeSniffer">
 	<exec executable="phpcs">
		<arg line="--report=checkstyle 
		--report-file=${basedir}/build/logs/checkstyle-result.xml 
		--standard=Zend  ${source1} " />
 	</exec>
 </target>

 <target name="phpmd-ci" description="Perform project mess detection using PHPMD creating a log file for the continuous integration server">
 	<exec executable="phpmd">
		<arg line=" ${source2} xml cleancode --reportfile ${basedir}/build/logs/phpmd.xml" />
	</exec>
 </target>
 
 <target name="phpcpd" description="Find duplicate code using PHPCPD">
  <exec executable="phpcpd">
  <arg line=" --log-pmd ${basedir}/build/logs/phpcpd.xml ${source1} " />
  </exec>
 </target>

</project>' > build.xml

rm temp

if [ -z $resultado ] || [ -z $phpmd ] ; then
  rm build.xml
fi

exit
