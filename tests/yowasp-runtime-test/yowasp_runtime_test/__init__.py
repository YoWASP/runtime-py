import sys
import yowasp_runtime


def _run_cat():
	yowasp_runtime.run_wasm(__package__, "cat.wasm", resources=["share"],
		argv=sys.argv)
