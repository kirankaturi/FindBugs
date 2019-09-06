#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./gitValidation.sh jenkinitem multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 1 ]
then
  echo "Check the arguments passed. Usage - ./gitValidation.sh jenkinitem multifact"
  exit 1
else
  jitem=$1  
  multiFactor=$2
  if [ -z "$multiFactor" ]; then 
	multiFactor=0
	echo "$multiFactor"
  fi
  echo "########################################"
#CHECK#1 : GIT PLUGIN ADDITION

  p_folder="$JENKINS_HOME"/plugins
  cd $p_folder 2>/dev/null
  x=0
  x=$(ls -l|grep drw|grep git | wc -l) 2>/dev/null

  if [ $x -gt 1 ] ; then 
        pass=$(($pass+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  fi


# CHECK#2 : GIT REPO

  git_config="$JENKINS_HOME"/workspace/"$jitem"/.git/config 
  chmod a+rwx $git_config 2>/dev/null

  if [ -f $git_config ]; then
     gitr=$(cat $git_config | grep "code.fresco.me")
  fi

  git_repo=`echo "$gitr" | awk -F"= " '{print $2}'`

  x=0
  if [ -f $git_config ]; then
     x=$(cat $git_config | grep "code.fresco.me" | wc -l)  2>/dev/null
  fi
  
  if [ $x -ge 1 ] ; then
	
        pass=$(($pass+1))
  	echo "Git Repo Check Done. Pass: $pass Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Git Repo Check Done. Pass: $pass Fail: $fail "
  fi


# CHECK#3 : JOB CHECK FOR GIT


  job_config="$JENKINS_HOME"/jobs/"$jitem"/config.xml

  chmod a+rwx $job_config  2>/dev/null 2>/dev/null

  x=0
  if [ -f $job_config ]; then
    x=$(cat $job_config | grep "hudson.plugins.git.GitSCM" | wc -l)  2>/dev/null
  fi

  if [ $x -eq 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  fi  

# CHECK#4 : CHECK FOR POLL SCM

  i=0
  j=0
  if [ -f $job_config ]; then
    i=$(cat $job_config | grep "hudson.triggers.SCMTrigger" | wc -l) 2>/dev/null
    j=$(cat $job_config | grep "H/15 * * * *" | wc -l) 2>/dev/null
  fi
  
  
  if [ $i -ge 1 ] ; then
        pass=$(($pass+1))
        echo "SCM Polling Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "SCM Polling Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $j -ge 1 ] ; then
        pass=$(($pass+1))
        echo "SCM Polling Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "SCM Polling Check Done. Pass: $pass Fail: $fail "
  fi


  job_path="$JENKINS_HOME"/jobs
  cd $job_path 2>/dev/null

  x=0
  if [ -d $jitem ]; then
    x=$(ls -d "$jitem"  | wc -l) 2>/dev/null
  fi
  
  if [ $x -eq 1 ] ; then
        pass=$(($pass+1))
        echo "Job Creation Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Job Creation Check Done. Pass: $pass Fail: $fail "
  fi

  

  if [ -f $JENKINS_HOME/jobs/$jitem/nextBuildNumber ]; then
     nextbuildnum=`cat "$JENKINS_HOME"/jobs/"$jitem"/nextBuildNumber`
     buildnum=$((nextbuildnum-1))
  fi 
  build_config="$JENKINS_HOME"/jobs/"$jitem"/builds/"$buildnum"
  cd $build_config 2>/dev/null


  i=0 j=0 k=0
  if [ -f log ]; then
     i=$(cat log | grep -E "git checkout" | wc -l) 
     j=$(cat log | grep -E "git fetch --tags --progress $git_repo" | wc -l) 
     k=$(cat log | grep -E "Finished: SUCCESS" | wc -l) 
  fi
  
  if [ $i -ge 1 ] ; then 
	pass=$(($pass+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $j -ge 1 ] ; then 
	pass=$(($pass+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $k -ge 1 ] ; then 
	pass=$(($pass+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Log Check for git Check Done. Pass: $pass Fail: $fail "
  fi

  x=0
  poll_folder="$JENKINS_HOME"/jobs/"$jitem"
  cd $poll_folder 2>/dev/null
  
  if [ -f scm-polling.log ];then
    x=$(ls scm-polling.log | wc -l) 2>/dev/null
  fi

  if [ $x -eq 1 ] ; then
	pass=$(($pass+1))
  	echo "Polling Log check Done. Pass: $pass Fail: $fail "
 else
	fail=$(($fail+1))
  	echo "Polling Log check Done. Pass: $pass Fail: $fail "
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


