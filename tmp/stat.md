# Issues with struct Stat

I was looking for `long? last_modified(String file)`, and found that it's missing in the standard library. I looked around and found some issues are there with `struct Stat`.

`struct Stat` is used for following functions.

* `bool file_exists(String file)`
* `long? file_size(String file)`
* `long? last_modified(String file)` missing
* `bool is_dir(String path)`
* `bool is_file(String path)`
* `bool is_link(String path)`  missing
* `bool is_readable(String file)`  missing
* `bool is_writeable(String path)`  missing
* `bool is_executable(String file)`  missing
* `usz? read_link(String path, char[] output)`  missing

Currently `std/io/path.c3` has following functions.
* `bool is_dir(Path path)`
* `bool is_file(Path path)`
* `usz? file_size(Path path)`
* `bool exists(Path path)`

Current `std/io/file.c3` has following functions.
* `bool exists(String file)`
* `bool is_file(String file)`
* `bool is_dir(String file)`
* `usz? get_size(String file)`

To implement missing functions, you need properly defined `struct Stat` and proper access to Windows native functions. 

Current `struct Stat` definitions are at these files.
```
./lib/std/libc/os/openbsd.c3:struct Stat @if(env::X86_64)
./lib/std/libc/os/openbsd.c3:struct Stat @if(!env::X86_64)
./lib/std/libc/os/linux.c3:struct Stat @if(env::X86_64)
./lib/std/libc/os/linux.c3:struct Stat @if(!env::X86_64)
./lib/std/libc/os/freebsd.c3:struct Stat @if(env::X86_64)
./lib/std/libc/os/freebsd.c3:struct Stat @if(!env::X86_64)
./lib/std/libc/os/netbsd.c3:struct Stat
./lib/std/libc/os/android.c3:struct Stat @if(env::X86_64)
./lib/std/libc/os/android.c3:struct Stat @if(!env::X86_64)
./lib/std/libc/os/darwin.c3:struct Stat
```

As you can see ArchType was considered only either `X84_64` or not, but in reality `struct Stat` is a lot divergent than that.

Take look at [stat.def.c3](https://github.com/nomota/ext_libc.c3l/blob/main/src%2Fstat.def.c3). Every combination of OS and ArchType differs slightly in some way.

So here's my patch instruction.

1. Remove all `struct Stat` from `std/libc/os/*.c3`
2. Add this to `std/libc/os` and rename module name as `libc`
  * [stat.def.c3](https://github.com/nomota/ext_libc.c3l/blob/main/src%2Fstat.def.c3)
3. Add these files to `std/io/os` and change module name as `std::io`
  * [stat.posix.c3](https://github.com/nomota/ext_libc.c3l/blob/main/src%2Fstat.posix.c3)
  * [stat.win32.c3](https://github.com/nomota/ext_libc.c3l/blob/main/src%2Fstat.win32.c3) (This implements all functions Win-natively, without relying on Stat).
4. That˚s all.

Then we can access `io::last_modified()` ... etc.

Anybody do PR this on behalf of me?

Why don't do it myself? I've only a Galaxy phone, no testing environment. 

