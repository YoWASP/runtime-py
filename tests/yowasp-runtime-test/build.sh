#!/bin/sh -e

if [ -z "${WASI_SDK}" ]; then
	echo "WASI_SDK needs to point to wasi-sdk-11" >&2
	exit 1
fi

${WASI_SDK}/bin/clang --sysroot ${WASI_SDK}/share/wasi-sysroot \
	-o yowasp_runtime_test/cat.wasm cat.c
