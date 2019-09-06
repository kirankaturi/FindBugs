#!/bin/bash
#Purpose: Search a particular pattern and increment the counter
#Usage: ./cloverValidation.sh jenkinitem projname multifact
#-----------------------------------------------------------------------

#jenkins_home=$("echo $JENKINS_HOME")

curr_dir=`pwd`
pass=0
fail=0
pass_score=0
fail_score=0

if [ $# -lt 2 ]
then
  echo "Check the arguments passed. Usage - ./cloverValidation.sh jenkinitem projname multifact"
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

  #CHECK#1 : CLOVER PLUGIN ADDITION

  p_folder="$JENKINS_HOME"/plugins
  cd $p_folder 2>/dev/null
  x=0
  if [ -d nodejs ];then
      x=$(ls -l|grep drw|grep clover | wc -l) 2>/dev/null
  fi
  
  if [ $x -gt 1 ] ; then 
        pass=$(($pass+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  else
	fail=$(($fail+1))
  	echo "Plugin Check Done. Pass: $pass  Fail: $fail "
  fi


  # CHECK#2 : JOB CHECK FOR CLOVER


  job_config="$JENKINS_HOME"/jobs/"$jitem"/config.xml

  chmod a+rwx $job_config  2>/dev/null 2>/dev/null

  i=0 j=0 k=0 l=0
  if [ -f $job_config ]; then
   i=$(cat $job_config | grep "$projname" | wc -l)  2>/dev/null 



  case "$projname" in
  	node_todo_api| backend| angular_todo| frontend)
		j=$(cat $job_config | grep "<cloverReportFileName>clover.xml</cloverReportFileName>" | wc -l)  2>/dev/null
        	k=$(cat $job_config | grep "<cloverReportDir>frontend/coverage</cloverReportDir>" | wc -l)  2>/dev/null
		l=$(cat $job_config | grep "hudson.plugins.clover.CloverPublisher" | wc -l)  2>/dev/null
		;;
    *)
		j=0 k=0 l=0 ;;
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

  if [ $l -ge 1 ] ; then
        pass=$(($pass+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  else
        fail=$(($fail+1))
        echo "Config xml Check Done. Pass: $pass Fail: $fail "
  fi 



# CHECK#3 : CONSOLE OUTPUT CHECK FOR CLOVER

proj_folder="$JENKINS_HOME"/workspace/"$jitem"/"$projname"


i=0 j=0 
#if [ -f pom.xml ]; then echo "I am here"
if [ -d $proj_folder/coverage ];then
  i=1
fi

if [ -f $proj_folder/coverage/clover.xml ];then
  j=1
fi

#fi



  if [ $i -ge 1 ] ; then 
        pass=$(($pass+1))
    echo "Clover Folder Check Done. Pass: $pass  Fail: $fail "
  else
  fail=$(($fail+1))
    echo "Clover Folder Check Done. Pass: $pass  Fail: $fail "
  fi

  if [ $j -ge 1 ] ; then 
        pass=$(($pass+1))
    echo "Clover Folder Check Done. Pass: $pass  Fail: $fail "
  else
  fail=$(($fail+1))
    echo "Clover Folder Check Done. Pass: $pass  Fail: $fail "
  fi



# CHECK#4 : CONSOLE OUTPUT CHECK FOR CLOVER

  if [ -f $JENKINS_HOME/jobs/$jitem/nextBuildNumber ]; then
     nextbuildnum=`cat "$JENKINS_HOME"/jobs/"$jitem"/nextBuildNumber`
     buildnum=$((nextbuildnum-1))
  fi 
  
  build_config="$JENKINS_HOME"/jobs/"$jitem"/builds/"$buildnum"
  cd $build_config 2>/dev/null

  i=0 j=0
  if [ -f log ]; then
  	
     i=$(cat log | grep "Publishing Clover" | wc -l) 
     j=$(cat log | grep "Finished: SUCCESS" | wc -l)
  fi
  


  if [ $j -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for Clover Report Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for Clover Report Check Done. Pass: $pass Fail: $fail "
  fi

  if [ $i -ge 1 ] ; then 
  	pass=$(($pass+1))
  	echo "Log Check for Clover Report Check Done. Pass: $pass Fail: $fail "
  else
	  fail=$(($fail+1))
  	echo "Log Check for Clover Report Check Done. Pass: $pass Fail: $fail "
  fi

#CHECK#5 : CHECK FOR THRESHOLDS


x=0 i=0 j=0 k=0 l=0

if [ -f index.html ]; then
   x=$(cat index.html | grep "strong" | awk '{ print $2 }'  | cut -c 16- | sed 's/%//' )
fi


#if [ `echo $i | awk '{ print $1}'` -ge 100 ] &&
#	[ `echo $i | awk '{ print $3}'` -ge 100 ] && 
#	[ `echo $i | awk '{ print $4}'` -ge 100 ] ; then  

i=`echo $x | awk -F" " '{if($1 > 90) print $1 }'`
j=`echo $x | awk -F" " '{if($2 > 90) print $2 }'`
k=`echo $x | awk -F" " '{if($3 > 90) print $3 }'`
l=`echo $x | awk -F" " '{if($4 > 90) print $4 }'`


#Statements (i) / Branches (j) / Functions (k) / Lines (l)

if [ -z $i ]; then
    fail=$((fail+1)) 
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
else
	pass=$(($pass+1))
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
fi

if [ -z $j ]; then
    fail=$((fail+1)) 
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
else
	pass=$(($pass+1))
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
fi

if [ -z $k ]; then
    fail=$((fail+1)) 
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
else
	pass=$(($pass+1))
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
fi

if [ -z $l ]; then
    fail=$((fail+1)) 
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
else
	pass=$(($pass+1))
    echo "Thresolds on Clover Coverage Check Done. Pass: $pass Fail: $fail "
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

