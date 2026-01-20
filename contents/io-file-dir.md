# I/O, Files, Dirs, Streams

Here are primary ways to handle input and output.

```c3
import std::io;

Allocator allocx;

String? s = io::readline(allocx, stream = io::stdin());
String? s = io::treadline(stream = io::stdin());
usz? n = io::readline_to_stream(out_stream, in_stream = io::stdin());
usz? n = io::fprint(out, x);
usz? n io::fprintf(OutStream out, String format, args...) @format(1);
usz? n = io::fprintfn(OutStream out, String format, args...) @format(1) @maydiscard;
usz? n = io:;fprintn(out, x = "");
void io::print(x);
void io::printn(x = "");
void io::eprint(x);
void io::eprintn(x = "");
usz n = io::putchar_buf_size() @const;
usz? n = io::printf(String format, args...); @format(0) @maydiscard
usz? n = io::printfn(String format, args...) @format(0) @maydiscard;
usz? n = io::eprintf(String format, args...) @maydiscard;
usz? n = io::eprintfn(String format, args...) @maydiscard;
char[]? str = io::bprintf(char[] buffer, String format, args...) @maydiscard;
void io::putchar(char c) @inline;
File* f = io::stdout();
File* f = io::stderr();
File* f = io::stdin();
```

Basic Printing

These are the most common functions for standard output. The suffix n typically denotes that a newline is automatically appended.
* `io::print()` / `io::printn()`: Standard output.
* `io::eprint()` / `io::eprintn()`: Standard error (stderr).
* `io::printf()` / `io::printfn()`: Formatted output (similar to C's `printf()`).

Stream & File Writing

C3 uses `OutStream` and `File` pointers for more explicit I/O control.
* `io::fprint()`: Prints a single value to a specific stream.
* `io::fprintf()`: Formatted print to a specific stream.
* `io::bprintf()`: Formatted print into a provided buffer (char array), which is great for avoiding heap allocations.

Reading Input

Reading in C3 often requires an `Allocator` because strings are dynamically sized.
* `io::readline()`: Reads a line from a stream using a provided allocator.
* `io::treadline()`: A "temporary" read, using a temporary allocator.
* `io::readline_to_stream()`: Pipes input directly from one stream to another (e.g., from stdin to a file).

Direct File Access

C3 provides global accessors for the standard Unix-style streams:
| Function | Return Type | Purpose |
|---|---|---|
| `io::stdin()` | `File*` | Standard Input |
| `io::stdout()` | `File*` | Standard Output |
| `io::stderr()` | `File*` | Standard Error |

Important Attributes in C3

You noticed several @ tags in the code; these are Attributes that tell the compiler how to handle the function:
* `@format(index)`: Tells the compiler to check the format string at the specified argument index against the following arguments (similar to __attribute__((format)) in C).
* `@maydiscard`: Indicates that the return value does not have to be used by the caller.
 * `@const`: Marks a function that returns a constant value known at compile-time or one that has no side effects.

### Path

`std::io::path` module provides a comprehensive suite for filesystem manipulation and path string parsing. It handles everything from basic metadata checks to complex directory traversal.
* One of the key strengths of this module is how it differentiates between heap-allocated paths (requiring an allocator) and temporary paths (prefixed with t, like `to_tpath()` or `tappend()`).

```c3
import std::io::path;

Path? p = path::new(allocx, String path, PathEnv path_env = DEFAULT_ENV);
Path? p = str.to_path(allocx);
Path? p = str.to_tpath();
void p.free();

Path? p = path::temp(String path, PathEnv path_env = DEFAULT_ENV);
Path? p = path::cwd(allocx);
bool b = path::is_dir(Path path);
bool b = path::is_file(Path path);
usz? n = path::file_size(Path path);
bool b = path::exists(Path path);
Path? p = path::tcwd();
void? path::chdir(path);
Path? p = path::temp_directory(allocx);
Path? p = path::home_directory(allocx);
Path? p = path::desktop_directory(allocx);
Path? p = path::videos_directory(allocx);
Path? p = path::music_directory(allocx);
Path? p = path::documents_directory(allocx);
Path? p = path::screenshots_directory(allocx);
Path? p = path::saved_games_directory(allocx);
Path? p = path::downloads_directory(allocx);
Path? p = path::pictures_directory(allocx);
Path? p = path::templates_directory(allocx);
Path? p = path::public_share_directory(allocx);
void? path::delete(Path path);
bool b = path::@is_pathlike(#path) @const;
bool b = path::is_separator(char c, PathEnv path_env = DEFAULT_ENV);
PathList? ps = path::ls(allocx, Path dir, bool no_dirs = false, bool no_symlinks = false, String mask = "");
bool? b = path::mkdir(path, bool recursive = false, MkdirPermissions permissions = NORMAL|USER_ONLY|USER_AND_ADMIN);
bool? b = path::rmdir(path);
void? path::rmtree(Path path);
Path? p = path::from_wstring(allocx, WString path);

Path p;
bool b = p.equals(Path p2) @operator(==);
Path? p = p.append(allocx, String filename);
Path? p = p.tappend(String filename);

String str;
bool? b = str.is_absolute_path();
bool? b = p.is_absolute();
Path? p = str.to_absolute_path(allocx);
Path? p = p.absolute(allocx);
String? base = str.file_basename(allocx);
String? base = str.file_tbasename();
String base = p.basename();
String? dir = str.path_tdirname();
String? dir = str.path_dirname(allocx);
String dir = p.dirname();
bool b = p.has_extension(String extension);
String? ext = p.extension();
String vol = p.volume_name();
Path? p = p.parent();
String? str = path::normalize(String path_str, PathEnv path_env = DEFAULT_ENV);
String str = p.root_directory();
String str = p.str_view() @inline;
bool b = p.has_suffix(String str);
bool b = path::is_reserved_path_char(char c, PathEnv path_env = DEFAULT_ENV);

alias PathWalker = bool? (Path, bool is_dir, void*);
alias TraverseCallback = bool? (Path, bool is_dir, any data);

bool? b = p.walk(PathWalker w, void* data);
bool? b = path::traverse(Path path, TraverseCallback callback, any data);
```

Path Creation & Management

Paths can be created from strings, wide strings (useful for Windows interop), or retrieved from the operating system environment.
* `path::new()`: Standard way to initialize a path using a specific allocator.
* `str.to_path()` / `str.to_tpath()`: Convenient extensions to convert a `String` directly into a `Path` object.
* `p.free()`: Manual memory management for paths created with an allocator.

Standard System Locations

C3 provides cross-platform access to common OS-specific directories without needing to manually resolve environment variables like $HOME or %USERPROFILE%.
| Directory Type | Function |
|---|---|
| User Core | home_directory, desktop_directory, documents_directory |
| Media | music_directory, videos_directory, pictures_directory |
| System | temp_directory, downloads_directory, cwd (Current Working Directory) |

Filesystem Operations

These functions interact directly with the disk:
* `path::ls()`: Returns a `PathList` of files in a directory, with optional masking (e.g., `*.txt`) and filtering for directories or symlinks.
* `path::mkdir()`: Supports recursive creation (making parent folders) and granular permissions.
* `path::rmtree()`: A powerful "remove-all" function that deletes a directory and all its contents recursively.
* `path::exists()` / `path::is_file()` / `path::is_dir()`: The primary "stat" checks.

Path Parsing & Components

These functions decompose a path string into its logical parts:
* Basename: The file name (e.g., test.txt).
* Dirname: The parent directory path.
* Extension: The file suffix (e.g., .c3).
* Volume Name: The drive letter on Windows (e.g., C:) or the root on Unix.

Traversal & Walking

C3 offers two main ways to iterate through a directory tree:
* `p.walk(PathWalker)`: Uses a function pointer and a raw void* for data context.
* `path::traverse(Path, TraverseCallback)`: Uses the any type for a more type-safe data passing mechanism during the recursive search.

### File 

`std::io::file` provides the handle-based interface for file manipulation in C3. While `std::io::path` focuses on the location and metadata, `std::io::file` focuses on access and content.

```c3
import std::io::file;

File? f = file::open(String filename, String mode);
File? f = file::open_path(Path path, String mode);
bool b = file::exists(String file);
File f = file::from_handle(CFile file);
bool b = file::is_file(String path);
bool b = file::is_dir(String path);
usz? n = file::get_size(String path);
void? file::delete(String filename);

File f;
void? f.reopen(String filename, String mode);
usz? n = f.seek(isz offset, Seek seek_mode = Seek.SET|CURSOR|END) @dynamic;
void? f.flush();
```

Opening and Closing Files

The `file::open()` functions return an optional `File?`, meaning you must handle the case where the file cannot be opened (e.g., permission denied or file not found).
* `file::open()`: Standard opening using a string path.
* `file::open_path()`: Accepts a `Path` object (from the path module), which is the preferred way to handle complex or cross-platform paths.
* `file::from_handle()`: Wraps a raw C-style file handle (`CFile`), allowing for easy interoperability with legacy C code or libraries.

File Modes

When opening a file, the `String mode` follows the standard C conventions:
* "r": Read (fails if file doesn't exist).
* "w": Write (creates or truncates file).
* "a": Append (writes to the end of the file).
* "r+": Read/Write.

Navigation and Seeking

Once a file is open, you can move the internal "cursor" to read or write at specific positions.
The `f.seek()`` method uses the Seek enum to determine the starting point:
* `Seek.SET`: Beginning of the file.
* `Seek.CURSOR`: Current position of the file pointer.
* `Seek.END`: End of the file (useful for determining size or appending).

Utility Functions

The module also provides shorthand versions of filesystem checks that don't require manual path construction:
* `file::get_size()`: Directly returns the size in bytes (usz).
* `file::delete()`: Deletes the file at the specified string path.
* `f.reopen()`: Closes the current file handle and opens a new one using the same object—useful for switching modes on the fly.


### Streams, Readers&Writers

C3 defines two interfaces to standardize reading and writing.

```c3
interface InStream
{
    fn void? close() @optional;
    fn usz? seek(isz offset, Seek seek) @optional;
   fn usz len() @optional;
    fn usz? available() @optional;
    fn usz? read(char[] buffer);
    fn char? read_byte();
    fn usz? write_to(OutStream out) @optional;
    fn void? pushback_byte() @optional;
}

interface OutStream
{
    fn void? destroy() @optional;
    fn void? close() @optional;
    fn void? flush() @optional;
    fn usz? write(char[] bytes);
    fn void? write_byte(char c);
    fn usz? read_to(InStream in) @optional;
}
```

* Note that only `read()/read_byte()` and `write()/write_byte()` are mandatory to implement these interfaces. all others are `@optional`.

Available readers & writers

Following readers and writers are often used patterns of implementing stream interfaces. They are all defined in `std::io` module. (in lib/std/io/stream folder.)

* `TeeReader`: on reading an `InStream`, you want it to be automatically mirrored written to another `OutStream`.
* `Scanner`: provides a way to read delimited data (with newlines as the default).
* `MultiWriter`: if you want to write same thing out to multiple `OutStream`s.
* `MultiReader`: if you want to read mutiple `InStream`s one after another, as if a single long consecutive stream.
* `LimitReader`: if you want to read up to certain limit.
* `ByteReader`: regard a byte array as an `InStream`.
* `ByteWriter`: regard a byte array as an `OutStream`.
* `ByteBuffer`: regard a fixed array of bytes as a buffer. You can write and read over it, within the limit size.
* `Buffer`: no size limit. You can write or read over it, as a buffer.

### Libc I/O Functions

C3 language interfaces with standard C library (libc) I/O functions.

```c3 
import libc;

CInt r = libc::close(CInt fd) @if(!env::WIN32);
CInt r = libc::fclose(CFile stream);
CFile f = libc::fdopen(CInt fd, ZString mode) @if(!env::WIN32);
CInt f = libc::feof(CFile stream);
CInt e = libc::ferror(CFile stream);
CInt r = libc::fflush(CFile stream);
CInt c = libc::fgetc(CFile stream);
ZString zs = libc::fgets(char* string, CInt n, CFile stream);
CInt r = libc::fgetpos(CFile stream, Fpos_t* pos);
Fd d = libc::fileno(CFile stream) @if(!env::WIN32);
CFile f = libc::fopen(ZString filename, ZString mode);
CInt r = libc::fprintf(CFile stream, ZString format, ...);
CInt n = libc::fputc(CInt c, CFile stream);
CInt n = libc::fputs(ZString string, CFile stream);
usz n = libc::fread(void* ptr, usz size, usz nmemb, CFile stream);
CFile f = libc::freopen(ZString filename, ZString mode, CFile stream);
CInt r = libc::fscanf(CFile stream, ZString format, ...);
CInt r = libc::fseek(CFile stream, SeekIndex offset, CInt whence) @if(!env::WIN32);
CInt r = libc::fsetpos(CFile stream, Fpos_t* pos);
SeekIndex idx = lbc::ftell(CFile stream) @if(!env::WIN32);
usz n = libc::fwrite(void* ptr, usz size, usz nmemb, CFile stream);
CInt c = libc::getc(CFile stream);
CInt c = libc::getchar();
ZString zs = libc::gets(char* buffer);
void libc::perror(ZString string);
CInt r = libc::printf(ZString format, ...);
CInt r = libc::putc(CInt c, CFile stream);
CInt r = libc::putchar(CInt c);
CInt r = libc::puts(ZString str);
isz n = libc::read(Fd fd, void* buf, usz nbyte) @if(!env::WIN32);
isz n = libc::readlink(ZString pathname, char* buf, int bufsize) @if(!env::WIN32);
CInt r = libc::rename(ZString old_name, ZString new_name);
void libc::rewind(CFile stream);
CInt r = libc::scanf(ZString format, ...);
ZString zs = libc::tmpnam(ZString str);
CFile f = libc::tmpfile();
CInt r = libc::ungetc(CInt c, CFile stream);
isz n = libc::write(Fd fd, void* buffer, usz count) @if(!env::WIN32);
CFile f = libc::fmemopen(void* ptr, usz size, ZString mode);
isz n = libc::getline(char** linep, usz* linecapp, CFile stream);
CFile f = libc::stdin();
CFile f = libc::stdout();
CFile f = libc::stderr();
int r = libc::fcntl(CInt socket, int cmd, ...);
```

Conditional Compilation (@if)

C3 uses the `@if` attribute to handle platform-specific logic directly in the declaration.
* Unix vs. Windows: Functions like `libc::close()`, `libc::fdopen()`, and `libc::read()` are often tied to POSIX standards. By using `@if(!env::WIN32)`, the code ensures these aren't called (or don't cause linker errors) on Windows, where I/O often follows different patterns or requires different headers.

Stream vs. Low-Level I/O

The list distinguishes between two primary ways of handling data:
| Type | Data Type | Key Functions | Characteristics |
|---|---|---|---|
| Buffered (Stream) | `CFile` | `fopen(), fread(), fprintf()` | High-level, uses a buffer for efficiency, managed by `libc`. |
| Unbuffered (Low-level) | `Fd` / `CInt` | `read(), write(), close()` | Direct system calls, works with File Descriptors. |

Key Function Groups

* Formatted I/O: `printf(), fprintf(), scanf(), fscanf()`. These handle string interpolation and parsing.
* Character/String I/O: `fgetc(), fgets(), fputs(), putchar()`. Efficient for processing text line-by-line or character-by-character.
* File Positioning: `fseek, ftell(), rewind(), fsetpos()`. These allow you to "jump" to specific bytes within a file.
* Error & State: `feof()` (checks for end-of-file), `ferror()` (checks for errors), and `perror()` (prints a human-readable error message to stderr).

Special Streams

The snippet ends with the standard I/O streams:
 * `libc::stdin()`: Standard Input (usually keyboard).
 * `libc::stdout()`: Standard Output (the terminal).
 * `libc::stderr()`: Standard Error (for logs and error messages).

Notable Syntax Observation

In C3, you see types like `usz` (unsigned size) and `isz` (signed size). These are C3's cleaner versions of C's `size_t` and `ssize_t`.


Back to [Table of Content](0.table-of-content.md)

