#!/bin/sh -ex

PYTHON=${PYTHON:-python}
cd $(dirname $0)

rm -rf venv
${PYTHON} -m venv venv
. venv/bin/activate

pip install ..
pip install ./yowasp-runtime-test

yowasp-runtime-test-cat # warmup

# Check that relative paths above the workdir can be used.
FIXTURES1="/share/data.txt fixwork.txt ../fixdir2.txt ../../fixdir1.txt dir3/fixdir3.txt"
FIXTURES1="${FIXTURES1} notfound.txt"
(cd fixtures/test1/dir1/dir2/workdir && 
 yowasp-runtime-test-cat ${FIXTURES1} 2>&1) >output1.txt

# Check that resource mounts override OS mounts.
FIXTURES2="/share/data.txt"
(cd fixtures/test2 && 
 yowasp-runtime-test-cat ${FIXTURES2} 2>&1) >output2.txt

# Check basic YOWASP_MOUNT usage.
ENVIRON3="YOWASP_MOUNT=/mount=$(pwd)/fixtures/test3/target"
FIXTURES3="/mount/fixtarget.txt fixwork.txt"
(cd fixtures/test3/workdir && 
 env ${ENVIRON3} yowasp-runtime-test-cat ${FIXTURES3} 2>&1) >output3.txt

# Check that resource mounts override YOWASP_MOUNT mounts.
ENVIRON4="YOWASP_MOUNT=/share=$(pwd)/fixtures/test4"
FIXTURES4="/share/data.txt"
(env ${ENVIRON4} yowasp-runtime-test-cat ${FIXTURES4} 2>&1) >output4.txt

diff expected1.txt output1.txt
diff expected2.txt output2.txt
diff expected3.txt output3.txt
diff expected4.txt output4.txt
