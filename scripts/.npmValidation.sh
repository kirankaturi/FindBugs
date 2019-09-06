#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./npmValidation.sh jenkinitem projname multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 2 ]
then
  echo "Check the arguments passed. Usage - ./npmValidation.sh jenkinitem projname multifact"
  exit 1
else
  jitem=$1  
  projname=$2
  multiFactor=$3
  if [ -z "$multiFactor" ]; then 
	multiFactor=0
	echo "$multiFactor"
  fi


  case "$projname" in
  	node_todo_api| backend | angular_todo| frontend)
		echo "Valid project name"
		;;
    *)
		echo "Invalid Project name"
		exit 1 ;;
  esac

  echo "########################################"
#CHECK#1 : NODEJS PLUGIN ADDITION

  p_folder="$JENKINS_HOME"/plugins
  cd $p_folder 2>/dev/null


# CHECK#2 : JOB CHECK FOR NPM


  job_config="$JENKINS_HOME"/jobs/"$jitem"/config.xml

  chmod a+rwx $job_config  2>/dev/null 2>/dev/null

  i=0
  j=0
  if [ -f $job_config ]; then
   i=$(cat $job_config | grep "$projname" | wc -l)  2>/dev/null 

  case "$projname" in
  	node_todo_api| backend)
		j=$(cat $job_config | grep "npm install" | wc -l)  2>/dev/null
		;;
	angular_todo| frontend)
		j=$(cat $job_config | grep "npm run build" | wc -l)  2>/dev/null
    		k=$(cat $job_config | grep "npm run test" | wc -l)  2>/dev/null
		;;
    *)
		j=0 ;;
  esac
  fi

  if [ $i -ge 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  fi  

  if [ $j -ge 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  fi  

  if [ $k -ge 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  fi  


# CHECK#3 : CONSOLE OUTPUT CHECK FOR NPM

proj_folder="$JENKINS_HOME"/workspace/"$jitem"/"$projname"


x=0
if [ -f $proj_folder/package.json ]; then 
  x=$(ls "$proj_folder"/package.json | wc -l)
fi



  if [ $x -eq 1 ] ; then 
        pass=$(($pass+1))
    echo "Project Folder Check Done. Pass: $pass  Fail: $fail "
  else
  fail=$(($fail+1))
    echo "Project Folder Check Done. Pass: $pass  Fail: $fail "
  fi


# CHECK#4 : CONSOLE OUTPUT CHECK FOR NPM


  if [ -f $JENKINS_HOME/jobs/$jitem/nextBuildNumber ]; then
     nextbuildnum=`cat "$JENKINS_HOME"/jobs/"$jitem"/nextBuildNumber`
     buildnum=$((nextbuildnum-1))
  fi 
  
  build_config="$JENKINS_HOME"/jobs/"$jitem"/builds/"$buildnum"
  cd $build_config 2>/dev/null

  i=0 j=0 k=0 l=0 m=0 x=0
  if [ -f log ]; then
  	
     i=$(cat log | grep "npm install" | wc -l) 
     j=$(cat log | grep "$projname" | wc -l) 
     k=$(cat log | grep "npm run build" | wc -l)
     l=$(cat log | grep "Finished: SUCCESS" | wc -l) 
     m=$(cat log | grep "npm run test" | wc -l)

  fi
  


  if [[ $i -ge 1 || $k -ge 1 ]] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for npm Build Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for npm Build Check Done. Pass: $pass Fail: $fail "
  fi

    if [ $j -eq 1 ] ; then
    	pass=$(($pass+1))
        echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    else
    	fail=$(($fail+1))
    	echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    fi

    if [ $l -eq 1 ] ; then
    	pass=$(($pass+1))
        echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    else
    	fail=$(($fail+1))
    	echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    fi
  if [ $projname == frontend ] ; then 

    if [ $m -eq 1 ] ; then
    	pass=$(($pass+1))
        echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    else
    	fail=$(($fail+1))
    	echo "Log Check for npm run test Check Done. Pass: $pass Fail: $fail "
    fi
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
