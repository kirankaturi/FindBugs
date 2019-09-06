#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./lintValidation.sh jenkinitem projname multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 2 ]
then
  echo "Check the arguments passed. Usage - ./lintValidation.sh jenkinitem projname multifact"
  exit 1
else
  jitem=$1  
  projname=$2
  multiFactor=$3
  if [ -z "$multiFactor" ]; then 
	multiFactor=0
	echo "$multiFactor"
  fi
  echo "########################################"

#CHECK#1 : JOB CHECK FOR ESLINT

job_config="$JENKINS_HOME"/jobs/"$jitem"/config.xml

  chmod a+rwx $job_config  2>/dev/null

  i=0 j=0
  if [ -f $job_config ]; then
    i=$(cat $job_config | grep "lint" | wc -l)  2>/dev/null
  fi


  if [ $i -ge 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml for lint Check Done. Pass: $pass Fail: $fail "

  else
        fail=$(($fail+1))
        echo "Config xml for lint Check Done. Pass: $pass Fail: $fail "
  fi  


  x=0
  if [ -f $job_config ]; then
x=$(grep -q "<failedTotalAll>10</failedTotalAll>"  "$job_config" && 
    grep -q "<failedTotalHigh>10</failedTotalHigh>" "$job_config" && 
    grep -q "<failedTotalNormal>10</failedTotalNormal>" "$job_config" && 
    grep -l "<failedTotalLow>10</failedTotalLow>" "$job_config" | wc -l) 2>/dev/null
  fi

  if [ $x -eq 1 ] ; then
        pass=$(($pass+1))
        echo "Thresolds on Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Thresolds on Config xml Check Done. Pass: $pass Fail: $fail "
  fi  

  #CHECK#2 : BUILD LOG CHECK

  if [ -f $JENKINS_HOME/jobs/$jitem/nextBuildNumber ]; then
     nextbuildnum=`cat "$JENKINS_HOME"/jobs/"$jitem"/nextBuildNumber`
     buildnum=$((nextbuildnum-1))
  fi 
  
  build_config="$JENKINS_HOME"/jobs/"$jitem"/builds/"$buildnum"
  if [ -d $build_config ]; then
      cd $build_config 2>/dev/null
  fi

  i=0 j=0
  if [ -f log ]; then
     i=$(cat log | grep "lint" | wc -l) 
     j=$(cat log | grep "Finished: SUCCESS" | wc -l) 
  fi
  
  if [ $i -ge 1 ] ; then 
  pass=$(($pass+1))
    echo "Log Check for lint Check Done. Pass: $pass Fail: $fail "
  else
  fail=$(($fail+1))
    echo "Log Check for lint Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $j -ge 1 ] ; then 
  pass=$(($pass+1))
    echo "Log Check for lint Check Done. Pass: $pass Fail: $fail "
  else
  fail=$(($fail+1))
    echo "Log Check for lint Check Done. Pass: $pass Fail: $fail "
  fi

#CHECK#3  :  ESLINT/TSLINT XML CHECK


  projfolder="$JENKINS_HOME"/workspace/"$jitem"/"$projname"
  x=0
  cd $projfolder 2>/dev/null
  if [ -f lint.xml ];then
    x=$(ls lint.xml | wc -l)
  fi

  if [ $x -eq 1 ] ; then
      pass=$(($pass+1))
      echo "lint XML Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "lint XML Check Done. Pass: $pass  Fail: $fail "
  fi

  pass_score=$(($pass*$multiFactor))
  fail_score=$(($fail*$multiFactor))

  echo "Pass_score: $pass_score, fail_score: $fail_score"
  echo "                                        "

cd $curr_dir
  echo $pass_score >> $6
  echo $fail_score >> $7
. ./scripts/.outputxml.sh "$fail_score" "$pass_score" ${4} ${5} 2>/dev/null

fi
