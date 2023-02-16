YoWASP runtime
==============

This package is an internal support package for the [YoWASP project][yowasp]. It handles interfacing with the [WebAssembly][] runtime and the supported operating systems. Do not depend on this package in your own code.

[webassembly]: https://webassembly.org/
[yowasp]: https://yowasp.github.io/


Configuration
-------------

The YoWASP runtime can be configured through environment variables:

### `YOWASP_CACHE_DIR`

YoWASP ships application code as architecture-independent WebAssembly and compiles it to architecture-specific machine code on first run. To make subsequent runs faster, it saves the generated machine code to a cache, which by default is located at `%LocalAppData%\YoWASP\Cache` (on Windows), `$HOME/.cache/YoWASP` (on Linux), or `$HOME/Library/Caches/YoWASP` (on macOS). This location can be customized by setting the `YOWASP_CACHE_DIR` environment variable.


License
-------

This package is covered by the [ISC license](LICENSE.txt).
