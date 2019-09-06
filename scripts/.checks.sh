# !/bin/sh

curr_dir=pwd

. ./scripts/.gitValidation.sh ${1} ${2} gitvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.npmValidation.sh ${1} angular_todo ${2} npmfrontvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.npmValidation.sh ${1} node_todo_api ${2} npmbackvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.lintValidation.sh ${1} node_todo_api ${2} lintbackvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.lintValidation.sh ${1} angular_todo ${2} lintfrontvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.cloverValidation.sh ${1} angular_todo ${2} cloverfrontvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.cloverValidation.sh ${1} node_todo_api ${2} cloverbackvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.unittestValidation.sh ${1} angular_todo ${2} unittestfrontvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.unittestValidation.sh ${1} node_todo_api ${2} unittestbackvalidation ${3} ${4} ${5}
cd $curr_dir
. ./scripts/.securityValidation.sh ${1} ${2} securityvalidation ${3} ${4} ${5}

cd $curr_dir
s=`cat ${4}|awk '{s+=$1} END {print s}'`
f=`cat ${5}|awk '{s+=$1} END {print s}'`
t=$(($s+$f))
echo $s, $f, $t

