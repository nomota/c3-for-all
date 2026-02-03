# Fault and optional

In order to provide a very simple and effective error handling, C3 introduced the concepts of `fault` and `optional`.

### Fault

A fault is a symbolic error name all in upper case like `FILE_NOT_FOUND` or `NAME_TOO_LONG`. Traditionally in C, it's a constant or an enum, or system defined `errno`. In C3 language, they are neither a constant nor an enum.

A fault is a special symbol and the internal representation is a pointer-sized unique number, which is not used by user. Unlike enum or const, the number may vary to different number, but it's guaranteed to be unique.

Faults must be defined before actual use, by using `faultdef`. And the type of a fault is `fault`. Just like other type definitions, `faultdef` comes always in global scope, and you cannot put it in a function.

```c3
import std::io;

faultdef ERROR1, ERR_UNKNOWN, MY_FAULT;

fn void test_fault()
{
    fault x = ERROR1; // assign a fault to a fault variable
    fault y = x;

    io::printfn("%s", y); // prints ERROR1

    fault z = MY_ERROR; // Compile error, MY_ERROR is not defined as a fault
}
```

### Optional

An optional is some kind of union of a value and a fault. It can be either a value or a fault, but not both at the same time. An optional is marked as `Type?`, with a question mark as an indication.

An optional is in a superimposed state and you need to 'unwrap' to see whether it's a fault or a value. So you cannot use an optional variable directly in a non-optional context. To assign a FAULT to an optional, you need to add '~', like 'FAULT~'. This visually distinguishes faults from enums or constants.

```c3
import std::io;

faultdef ERROR1, ERROR2, ERROR3;

fn void test_optional()
{
    int? x = 10; // assign a value to an optional
    int? y = ERROR1~; // assign a fault to an optional, you need to add '~'

    io:;printfn("%s", x); // Compile error, unwrap x first
    io:;printfn("%s", y); // Compile error, unwrap y first
}
```

#### Unwrapping an optional

There are several ways to unwrap an optional to a value or to a fault. The most frequent ones are using `if (try)` or `if(catch err)`, and they have a few variations.

```c3 
import std::io;

faultdef ERROR1, ERROR2, ERROR3;

fn void test_unwrap()
{
    int? x = 10; // assign a value to an optional
    int? y = ERROR1~; // assign a fault to an optional

    if (try x) {
        // here x becomes a value, unwrapped
        io::printfn("int: %d", x);
        assert($typeof(x) == int);
    } else {
        // here x is still optional
    }
    // here x is still optional
    
    if (catch err = y) {
        // here err is a fault, unwrapped
        io::printfn("fault: %s", err);
        assert($typeof(err) == fault);
        // y is still optional here
    } else {
        // here y becomes a value, unwrapped
        io::printfn("int: %d", y);
        assert($typeof(y) == int);
    }
    // y is still optional here
}
```

When the `if (catch err)` block ends with `return`, `continue` or `break` then the optional becomes unwrapped at the following region, even without `else` scope. This does not work with `if (try)` block.

```c3 
import std::io;

faultdef ERROR1, ERROR2, ERROR3;

fn void test_unwrap_return()
{
    int? x = 10; // assign a value to an optional
    int? y = ERROR1~; // assign a fault to an optional
    
    if (try x) {
        // here x becomes a value, an int value in this case
        io::printfn("int: %d", x);
    io::printfn("int: %d", x);
        return; // or break or continue
    }
    // x is still optional here
    
    if (catch err = y) {
        // here err is a fault, unwrapped
        io::printfn("fault: %s", err);
        return; // or break or continue
    }
    // here y becomes a value, unwrapped
    io::printfn("int: %d", y);
}
```

### Optional in non-optional context

When an optional is placed in a non-optional context, the whole context (or expression) becomes optional.

For example, when an optional is given to a non-optional function then it turns into optional.

```c3
import std::io;

fn int incr(int x) // non-optional function
{
    return x+1;
}

fn void test_non_optional()
{
    int? x = 3;
    
    int y = incr(x); // Compile error. Optiinal argument x changes the whole function call to be optional

    int? z = incr(x); // Ok 
    if (try z) {
        io::printfn("%d", z); // prints 4
    }
}
```

### More on unwrapping optional

Two builtin macro deals with optionals, but not affect the optional's wrapping.

```c3 
faultdef ERROR1, ERROR2;

fn void test_ok_catch()
{
    int? x = 3;
    int? y = ERROR1~;
    
    bool a = @ok(x); // true 
    bool b = @ok(y); // false 
    
    fault m = @catch(x); // null
    fault n = @catch(y); // ERROR1
    
    if (@ok(x)) {
        // x is still optional
    }
    
    if (fault err = @catch(y)) {
        // process unwrapped err
    } else {
        // y is still optional 
    }
}
```

#### Rethrow, panic and or_else operators

There are three symbolic operators related to optionals.

* `!` rethrow operator, means "or return fault"
* `!!` panic operator, means "or panic"
* `??` or_else operator, means "or else"

```c3
fn int? test_int()
{
    // return int or FAULT~;
}

fn void test_rethrow()
{
    int x = test()!; // Compile error. test_rethrow() is not optional
}

fn void? test_optional_operators() // needs to be "void?"
{
    int x = test()!; // if test() returns value, assign it, or otherwise rethrow the FAULT~
    int y = test()!!; // if test() returns value, assign it, or otherwise panic and print stacktrace
    int z = test() ?? 0; // if test() returns value, assign it, or else, assign 0 as default value
}
```

For `main()` cannot be returning optional, you cannot use `!` rethrow operator in `main()`. Use `!!` panic operator instead.

```c3
fn void main() 
{
    int x = test()!; // Compiler error, it's not "void? main()"
    int y = test()!!; // if test() returns value, assign it, or otherwise panic and print stacktrace
}
```


Back to [Table of Contents](0.table-of-contents.md)

