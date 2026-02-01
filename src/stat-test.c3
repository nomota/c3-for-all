module stat::test;

import std::io;

fn void test_stat()
{
    // Test with detailed error handling
    ulong? size = stat::file_size("test.txt");
    if (catch err = size) {
        io::printfn("%s", err);
    } else {
        io::printfn("File size: %d bytes", size);
    }
    
    // Test basic checks - these now safely return false on path errors
    if (stat::file_exists("test.txt")) {
        io::printn("File exists!");
        
        if (stat::is_readable("test.txt")) {
            io::printn("File is readable");
        }
        
        if (stat::is_writeable("test.txt")) {
            io::printn("File is writeable");
        }
        
        if (stat::is_executable("test.txt")) {
            io::printn("File is executable");
        }
    }
    
    // Test with very long path - safely returns false instead of panic
    char[2000] long_path;
    for (int i = 0; i < 1999; i++) {
        long_path[i] = 'a';
    }
    long_path[1999] = 0;
    String long_str = (String)&long_path;
    
    if (stat::file_exists(long_str)) {
        io::printn("Impossible - path too long!");
    } else {
        io::printn("Long path correctly handled (returns false)");
    }
    
    // Test directory check
    if (stat::is_dir("/tmp")) {
        io::printn("/tmp is a directory");
    }
    
    // Test symbolic link reading with error handling
    if (stat::is_link("mylink")) {
        char[1024] target;
        usz? len = stat::read_link("mylink", &target);
        if (catch err = len) {
            io::printn(err);
        } else {
            io::printfn("Link target: %s", (ZString)&target[0]);
        }
    }
    
    // Test modification time with error handling
    long? mtime = stat::last_modified("test.txt");
    if (catch err = mtime) {
        io::printfn("Cannot get modification time: %s", err);
    } else {
        io::printfn("Last modified: %d", mtime);
    }
}


fn void main() {
    test_stat();
}

