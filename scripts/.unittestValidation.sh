#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./unittestValidation.sh jenkinitem projname multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 2 ]
then
  echo "Check the arguments passed. Usage - ./unittestValidation.sh jenkinitem projname multifact"
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
#CHECK#1 : JUNIT PLUGIN ADDITION

  p_folder="$JENKINS_HOME"/plugins
  cd $p_folder 2>/dev/null
  x=0
  x=$(ls -l|grep drw|grep junit | wc -l) 2>/dev/null

  if [ $x -gt 1 ] ; then 
        pass=$(($pass+1))
  	echo "Junit Plugin Check Done. Pass: $pass  Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Junit Plugin Check Done. Pass: $pass  Fail: $fail "
  fi


  #CHECK#2  :  TEST REPORT XML CHECK


  projfolder="$JENKINS_HOME"/workspace/"$jitem"/"$projname"

  cd $projfolder 2>/dev/null
  if [ -f test-report.xml ]; then
     x=1
  fi

  if [ $x -eq 1 ] ; then
      pass=$(($pass+1))
      echo "lint XML Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "lint XML Check Done. Pass: $pass  Fail: $fail "
  fi




  #CHECK#3  :  FAILURES CHECK


  projfolder="$JENKINS_HOME"/workspace/"$jitem"/"$projname"

  cd $projfolder 2>/dev/null
  
  failures=0 
  failures_cnt=0
  if [ -f test-report.xml ]; then
     failures=$(cat test-report.xml | grep "failures" | sed 's/^.*failures=\"/failures=\"/' | cut -c 11-11) 2>/dev/null
  fi
 
  failures_cnt=$(echo $failures | grep -v "0")

  if [ -z $failures_cnt ]; then
      pass=$(($pass+1))
      echo "Report Failures Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "Report Failures Check Done. Pass: $pass  Fail: $fail "
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


