# Error Handling

There has been different ways of erro handlings.

### errno in C

Traditionally in C language, if a function returns a non-zero or negative integer, and it sets the `errno` value as a global variable.

```c 
int r = a_func();
if (r < 0) {
    printf("error: %s", strerror(errno));
}
```

So there are two separate values involved, but they are often ignored and that caused problems.

### Exceptions in C++/Java

Exceptions in C++/Java ask mandatory handling to reduce the risk of ignoring, but they cause other issues. Exceptions are propagated across stacks which isn't same as normal return paths.

### No exception, two value returning in Go 

After years of experience, Go lang claimes that exception is bad and goes back to traditional way, but in more explicit way, returning two values.

