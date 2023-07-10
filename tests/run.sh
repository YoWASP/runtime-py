#!/bin/sh -ex

PYTHON=${PYTHON:-python}
cd $(dirname $0)

./yowasp-runtime-test/build.sh

rm -rf venv
${PYTHON} -m venv venv
. venv/bin/activate

pip install ..
pip install ./yowasp-runtime-test

yowasp-runtime-test-cat # warmup

# Check that relative paths above the workdir can be used.
FIXTURES1="/share/data.txt fixwork.txt ./fixwork.txt ../fixdir2.txt ../../fixdir1.txt"
FIXTURES1="${FIXTURES1} dir3/fixdir3.txt notfound.txt"
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

# Check that /tmp mount overrides OS mounts.
touch /tmp/yowasp_tmp_test_file.txt
FIXTURES5="/tmp/yowasp_tmp_test_file.txt"
(yowasp-runtime-test-cat ${FIXTURES5} 2>&1) >output5.txt

# Check that /tmp mount overrides YOWASP_MOUNT mounts.
ENVIRON6="YOWASP_MOUNT=/tmp=$(pwd)/fixtures/test6"
FIXTURES6="/tmp/yowasp_tmp_test_file.txt"
(env ${ENVIRON6} yowasp-runtime-test-cat ${FIXTURES6} 2>&1) >output6.txt

# Check that absolute paths work (on Unix systems).
FIXTURES7="$(pwd)/fixtures/test7/fixwork.txt"
(yowasp-runtime-test-cat ${FIXTURES7} 2>&1) | sed "s:$(pwd):PWD:" >output7.txt

set +e
diff expected1.txt output1.txt
diff expected2.txt output2.txt
diff expected3.txt output3.txt
diff expected4.txt output4.txt
diff expected5.txt output5.txt
diff expected6.txt output6.txt
diff expected7.txt output7.txt
