#!/bin/sh
#Purpose : Generate xml output using the given inputs
#Usage ./outputxml.sh failcount passcount outputfilename
#____________________________________________________________


failure_cnt=$1
pass_cnt=$2
outfile="$3.xml"
outdir=$4

#dateformat=$(date +"%m/%d/%YT  %H:%M:%S")


if [ $# -lt 3 ]
then
  echo "Check the arguments passed. Usage - ./outputxml.sh failcount passcount outputfilename"
  exit 1
else

mkdir -p $outdir 2>/dev/null
cd $outdir

  if [ -f $outfile ]
  then
	rm $outfile
  fi


  tests_cnt=$(($failure_cnt+$pass_cnt))
  
  exec 3>$outfile #Creating temporary file

  echo '<?xml version="1.0"?>' >&3
  echo "<testsuite name=\""com.tcs.hack.Test"\" tests=\"$tests_cnt\" time=\""0.123"\" skipped=\""0"\" errors=\""0"\" failures=\"$failure_cnt\"> " >&3
  echo ' <properties>' >&3
  echo '   <property name="browser.fullName" value="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/66.0.3359.181 Safari/537.36"/>' >&3
  echo ' </properties>' >&3
  
  for (( i=0; i<$pass_cnt; i++ ))
  do
  
  echo '     <testcase name="jenkinsValidations" classname="tcs.hackathon.devops.validationchecks" time="0"/> ' >&3
  done


  for (( j=0; j<$failure_cnt; j++ ))
  do

  echo '     <testcase name="jenkinsValidations" classname="tcs.hackathon.devops.validationchecks" time="0"> ' >&3
  echo '     <failure type="">There is a failure' >&3
  echo '     </failure>' >&3
  echo '     <system-out><![CDATA[  Nothing to write  ]]></system-out>' >&3
  echo '     </testcase>' >&3
  done


#  echo '     <failure type="">There is a failure.' >&3
#  echo '     </failure>' >&3
#  echo '     </testcase>' >&3
  echo ' </testsuite>' >&3
fi


