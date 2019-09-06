#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./securityValidation.sh jenkinitem multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 2 ]
then
  echo "Check the arguments passed. Usage - ./securityValidation.sh jenkinitem multifact"
  exit 1
else
  jitem=$1  
  multiFactor=$2

  if [ -z "$multiFactor" ]; then 
	multiFactor=0
	echo "$multiFactor"
  fi

  echo "########################################"
 #CHECK#1 : WARNING PLUGIN ADDITION

  p_folder="$JENKINS_HOME"/plugins
  cd $p_folder 2>/dev/null
  x=0
  if [ -d nodejs ];then
      x=$(ls -l|grep drw|grep dependency-check-jenkins-plugin | wc -l) 2>/dev/null
  fi
  
  if [ $x -ge 1 ] ; then 
        pass=$(($pass+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  fi

  #CHECK#2  :  TEST REPORT XML CHECK

  projfolder="$JENKINS_HOME"/workspace/"$jitem"

  cd $projfolder 2>/dev/null
  x=0 
  y=0
  
  x=`ls *-report.xml|wc -l` 2>/dev/null

  if [ $x -ge 1 ] ; then
      pass=$(($pass+1))
      echo "XML Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "XML Check Done. Pass: $pass  Fail: $fail "
  fi

  if [ -d dependency-check-data ] ; then
      y=$(ls -d dependency-check-data | wc -l) 2>/dev/null
  fi
  if [ $x -ge 1 ] ; then
      pass=$(($pass+1))
      echo "Dependency Folder Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "Dependency Folder Check Done. Pass: $pass  Fail: $fail "
  fi


# CHECK#3 : JOB CHECK FOR VULNERABILITIES


  job_config="$JENKINS_HOME"/jobs/"$jitem"/config.xml

  chmod a+rwx $job_config  2>/dev/null
  i=0 
  if [ -f $job_config ]; then
   i=$(cat $job_config | grep "report.xml" | wc -l)  2>/dev/null 
  fi

  if [ $i -ge 1 ] ; then
      pass=$(($pass+1))
      echo "Config Check Done. Pass: $pass  Fail: $fail "
  else
      fail=$(($fail+1))
      echo "Config Check Done. Pass: $pass  Fail: $fail "
  fi

# CHECK#4 : CONSOLE OUTPUT CHECK FOR VULNERABILITIES


  projfolder="$JENKINS_HOME"/workspace/"$jitem"

  cd $projfolder 2>/dev/null
  
  i=0
  j=0 
  k=0
  if [ -f log ]; then
  	
     i=$(cat log | grep -i "'Invoke Dependency-Check analysis' changed build result to SUCCESS" | wc -l) 
     k=$(cat log | grep -i "'[DependencyCheck]" | wc -l) 
     j=$(cat log | grep -i "Finished: SUCCESS" | wc -l)
  fi
  


  if [ $i -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $j -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $k -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  fi

# CHECK#5 : VULNERABILITIES LIMITS CHECK

  if [ -f $JENKINS_HOME/jobs/$jitem/nextBuildNumber ]; then
     nextbuildnum=`cat "$JENKINS_HOME"/jobs/"$jitem"/nextBuildNumber`
     buildnum=$((nextbuildnum-1))
  fi 
  
  build_config="$JENKINS_HOME"/jobs/"$jitem"/builds/"$buildnum"
  cd $build_config 2>/dev/null

  x=0
  if [ -f $job_config ] ; then
 	x=$(grep -q "<unstableTotalAll></unstableTotalAll>" "$job_config" && 
		grep -q "<unstableTotalHigh></unstableTotalHigh>" "$job_config" && 
        grep -q "<unstableTotalNormal></unstableTotalNormal>" "$job_config" && 
        grep -q "<unstableTotalLow></unstableTotalLow>" "$job_config" && 
        grep -q "<unstableNewAll></unstableNewAll>" "$job_config" && 
        grep -q "<unstableNewHigh></unstableNewHigh>" "$job_config" && 
        grep -q "<unstableNewNormal></unstableNewNormal>" "$job_config" && 
        grep -q "<unstableNewLow></unstableNewLow>" "$job_config" && 
        grep -q "<failedTotalAll>5</failedTotalAll>" "$job_config" && 
        grep -q "<failedTotalHigh>5</failedTotalHigh>" "$job_config" && 
        grep -q "<failedTotalNormal>3</failedTotalNormal>" "$job_config" && 
        grep -q "<failedTotalLow>5</failedTotalLow>" "$job_config" && 
        grep -q "<failedNewAll>1</failedNewAll>" "$job_config" && 
        grep -q "<failedNewHigh>1</failedNewHigh>" "$job_config" && 
        grep -q "<failedNewNormal>1</failedNewNormal>" "$job_config" && 
        grep -l "<failedNewLow>1</failedNewLow>" "$job_config" | wc -l) 2>/dev/null
  fi

  if [ $x -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Threshold Check for Dependency Report Check Done. Pass: $pass Fail: $fail "

  else
	  fail=$(($fail+1))
  	echo "Threshold Check for Dependency Report Check Done. Pass: $pass Fail: $fail "
  fi

  pass_score=$(($pass*$multiFactor))
  fail_score=$(($fail*$multiFactor))

  echo "Pass_score: $pass_score, fail_score: $fail_score"
  echo "                                        "

cd $curr_dir
  echo $pass_score >> $5
  echo $fail_score >> $6
. ./scripts/.outputxml.sh "$fail_score" "$pass_score" ${3} ${4} 2>/dev/null


fi

