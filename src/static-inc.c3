// static-inc.c3

import std::io;

fn int static_inc()
{
    static int a = 0; // static local 
    a += 1;
    return a;
}

fn void main() 
{
    io::printfn("%d", static_inc()); // output: 1
    io::printfn("%d", static_inc()); // output: 2
    io::printfn("%d", static_inc()); // output: 3
}
