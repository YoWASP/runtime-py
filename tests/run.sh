#!/bin/sh -ex

PYTHON=${PYTHON:-python}
cd $(dirname $0)

rm -rf venv
${PYTHON} -m venv venv
. venv/bin/activate

pip install ..
pip install ./yowasp-runtime-test

yowasp-runtime-test-cat # warmup

FIXTURES="/share/data.txt fixwork.txt ../fixdir2.txt ../../fixdir1.txt dir3/fixdir3.txt"
FIXTURES="${FIXTURES} notfound.txt"
(cd fixtures/dir1/dir2/workdir && yowasp-runtime-test-cat ${FIXTURES} 2>&1) >output.txt

diff output.txt expected.txt
