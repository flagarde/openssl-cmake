# openssl-cmake

[LC]: https://github.com/flagarde/openssl-cmake/actions/workflows/Linux-Clang.yml
[LCB]: https://github.com/flagarde/openssl-cmake/actions/workflows/Linux-Clang.yml/badge.svg

[LG]: https://github.com/flagarde/openssl-cmake/actions/workflows/Linux-GCC.yml
[LGB]: https://github.com/flagarde/openssl-cmake/actions/workflows/Linux-GCC.yml/badge.svg

[MC]: https://github.com/flagarde/openssl-cmake/actions/workflows/MacOS-Clang.yml
[MCB]: https://github.com/flagarde/openssl-cmake/actions/workflows/MacOS-Clang.yml/badge.svg

[MG]: https://github.com/flagarde/openssl-cmake/actions/workflows/MacOS-GCC.yml
[MGB]: https://github.com/flagarde/openssl-cmake/actions/workflows/MacOS-GCC.yml/badge.svg

[MS]: https://github.com/flagarde/openssl-cmake/actions/workflows/Windows-MSYS2.yml
[MSB]: https://github.com/flagarde/openssl-cmake/actions/workflows/Windows-MSYS2.yml/badge.svg

[MM]: https://github.com/flagarde/openssl-cmake/actions/workflows/Windows-MSVC.yml
[MMB]: https://github.com/flagarde/openssl-cmake/actions/workflows/Windows-MSVC.yml/badge.svg

## Builds
|        | Linux Clang | Linux GCC | MacOS Clang | MacOS GCC | Windows M2sys | Windows MSVC |
|--------|-------------|-----------|-------------|-----------|---------------|--------------|
| Github |[![Linux Clang][LCB]][LC]|[![Linux GCC][LGB]][LG]|[![MacOS Clang][MCB]][MC]|[![MacOS GCC][MGB]][MG]|[![Windows MSYS2][MSB]][MS]|[![Windows MSVC][MMB]][MM]|

Build `OpenSSL` with `CMake` on `Linux`, `MacOS`, `Win32`, `Win64` and cross compile for `Android`, `IOS`.

This download the `OpenSSL` package from the official repo and apply the patch taken from https://github.com/janbar/openssl-cmake

## This only require CMake, no need for Perl, Python etc ...
