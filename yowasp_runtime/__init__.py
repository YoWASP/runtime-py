import os
import sys
import wasmtime
import pathlib
import hashlib
import appdirs
try:
    from importlib import resources as importlib_resources
    importlib_resources.files
except (ImportError, AttributeError):
    import importlib_resources


def run_wasm(__package__, wasm_filename, *, resources, argv):
    # load the WebAssembly application
    module_binary = importlib_resources.read_binary(__package__, wasm_filename)
    module_digest = hashlib.sha1(module_binary).hexdigest()

    wasi_cfg = wasmtime.WasiConfig()

    # inherit standard I/O handles
    wasi_cfg.inherit_stdin()
    wasi_cfg.inherit_stdout()
    wasi_cfg.inherit_stderr()

    # use provided argv
    wasi_cfg.argv = argv

    # preopens for package resources
    for resource in resources:
        wasi_cfg.preopen_dir(str(importlib_resources.files(__package__) / resource), 
                             "/" + resource)

    # preopens for absolute paths
    if os.name == "nt":
        for letter in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ":
            wasi_cfg.preopen_dir(letter + ":\\", letter + ":")
    else:
        wasi_cfg.preopen_dir("/", "/")

    # preopens for relative paths
    wasi_cfg.preopen_dir(".", ".")
    for level in range(len(pathlib.Path().cwd().parts)):
        wasi_cfg.preopen_dir(str(pathlib.Path("").joinpath(*[".."] * level)),
                             "/".join([".."] * level))

    # compute path to cache
    default_cache_path = appdirs.user_cache_dir("YoWASP", appauthor=False)
    cache_path = pathlib.Path(os.getenv("YOWASP_CACHE_DIR", default_cache_path))
    cache_filename = (cache_path / __package__ / wasm_filename / module_digest)

    # compile WebAssembly to machine code, or load cached
    engine = wasmtime.Engine()
    if cache_filename.exists():
        module = wasmtime.Module.deserialize_file(engine, str(cache_filename))
    else:
        print("Preparing to run {}. This might take a while...".format(argv[0]), file=sys.stderr)
        module = wasmtime.Module(engine, module_binary)
        cache_filename.parent.mkdir(parents=True, exist_ok=True)
        with cache_filename.open("wb") as cache_file:
            cache_file.write(module.serialize())

    # run compiled code
    linker = wasmtime.Linker(engine)
    linker.define_wasi()
    store = wasmtime.Store(engine)
    store.set_wasi(wasi_cfg)
    app = linker.instantiate(store, module)
    linker.define_instance(store, "app", app)
    try:
        app.exports(store)["_start"](store)
        return 0
    except wasmtime.ExitTrap as trap:
        return trap.code
