# Generics

In C3, generic types and generic functions are realized by generic modules.

A generic module is a module parameterized by one or more type markers, like `{T1, T2, ..}`, and all defitions in that module are accessed only by giving types respectively.

Let's look at a normal module and its usage.

```c3
module mx; // unparameterized module

faultdef ERROR_CODE;
struct MyStr { int a; }
interface MyIfc { }
const int I_CONST = 0;
int ivar;
fn void func() { }
fn void MyStr.method(&self) { }


module main;

import mx;

fn void main()
{
    MyStr a;
    MtIfc b;
    mx::ivar = mx::I_CONST;
    mx::func();
    a.method();

    // ivar = I_CONST; // Error: globals from other module must be prefixed with module:: name
    // func(); // Error: functions from other module must be prefixed with module:: name
}
```

Let's look at parameterized generic module and how it's being used.

```c3
module mz::aa {Type1, Type2}; // parameterized module

struct MyStr { Type1 a; } // generic type
interface MyIfc { }
const int I_CONST = 0;
int ivar;
fn void func(Type2 y) { } // generic function
fn void MyStr.method(&self, Type1 x) { }
// faultdef ERROR_CODE; // Error, faultdef is not allowed in generic module

// main 
module main;

import mz; // also imports submodule mz::aa

fn void main()
{    
    MyStr{char, char} a; // aa:: not necessary if not conflict
    MyIfc{int, bool} b; // aa:: not necessary if not conflict
    ivar{int, char} = I_CONST{int, int}; // aa:: not necessary if not conflict
    int x = ivar{char, char};
    func{char, int}(x); // aa:: not necessary if not conflict
    a.method('c');

    // MyStr a; // Error: defined in generic module, but no parameters were given.
    // ivar = I_CONST; // Error:: defined in generic module, but no parameters were given.        
    // func(x); // Error: defined in generic module, but no parameters were given.
    // func{char, char}(x); // Error: x type mismatch, should be in Type2, which is char
    // a.method(x); // Error: x type mismatch, should be in Type1, which is char
}

// module my {X, Y}; // Error: type parameter name must have 2 or more chars, starting with upper char

// struct S {  } // Error: struct name must have 2+ chars, starting with upper char
// int I; // Error: only const var can have all upper chars 
// struct MyStr { } // Error: Zero sized struct is not allowed
```

It is also possible to parameterize by an int or bool constant, for example:

```c3
module custom_type {Type, VALUE};

struct Example
{
    Type[VALUE] arr;
}

module main;

import custom_type;

fn void main() 
{
    Example{int, 3} a;
}
```

Code inside a generic module may use the generic parameters as if they were well-defined symbols:

```c3
module foo_test {Type1, Type2};

struct Foo
{
   Type1 a;
}

fn Type2 test(Type2 b, Foo* foo)
{
   return foo.a + b;
}
```

Importing a generic module works as usual:

```c3
import foo_test;

alias FooFloat = Foo{float, double};
alias test_float = foo_test::test{float, double};

FooFloat f;
double x = test_float(1.0, &f);

Foo{int, double} g;
double y = foo_test::test{int, double}(1.0, &g);
```

Just like for macros/functions, optional constraints (contracts) may be added to improve compile errors:

```c3
<*
 @require $assignable(1, TypeB) && $assignable(1, TypeC)
 @require $assignable((TypeB)1, TypeA) && $assignable((TypeC)1, TypeA)
*>
module vector {TypeA, TypeB, TypeC};

fn void testFunc() 
{
    // test here
}

/* .. code  .. */
module other;

import vector;

struct Bar {
    int a;
    int b;
}

alias testFunction = vector::testFunc{Bar, float, int}; // Error
// Parameter(s) failed validation:
//     @require "$assignable((TypeB)1, TypeA) && $assignable((TypeC)1, TypeA)" violated.
```


Back to [Table of Contents](0.table-of-contents.md)