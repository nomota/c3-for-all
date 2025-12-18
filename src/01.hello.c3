// plain hello world

import std::io;

fn void main() 
{
    io::printf("Hello, world!\n");
}

/*

// args and return

import std::io;

fn int main(String[] args) 
{
   io::printf("Hello, world!\n");

   for (usz i = 0; i < args.len; i++) {
        io::printf("%s\n", arg);
    }

    return 0;
}

// Windows

import std::io;

fn void main() @winmain
{
    io::printf("Hello, world!\n");
}

*/