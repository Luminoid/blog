---
title: Fibonacci Number in Different Programming Languages
date: 2022-02-22 15:36:50
categories: Programming Languages
tags:
- C
- Scheme
- Ada
- Standard ML
- C++
- Python
- Java
- JavaScript
- Scala
- Swift
---

Implementations of the nth Fibonacci number in various programming languages.

## C (1972)
<!-- {% include_code lang:c Fibonacci-Number-in-Different-Programming-Languages/C/fibonacci.c %} -->
``` C
#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
    if(n <= 1) {
        return n;
    }

    int a = 0;
    int b = 1;

    for(int i = 2; i <= n; i++) {
        int c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    printf("fib(%d) = %d\n", n, fib(n));
    return 0;
}
```

``` shell-session
$ gcc fibonacci.c
$ ./a.out 1
fib(1) = 1
```

<!-- more -->

## Scheme (1975)
Tail recursion
<!-- {% include_code lang:scheme Fibonacci-Number-in-Different-Programming-Languages/Scheme/fibonacci.scm %} -->

``` scheme
(define (fib n)
  (define (iter a b n)
    (if (<= n 1)
        b
        (iter b (+ a b) (- n 1))))
  (iter 0 1 n))
```

``` shell-session
$ racket -f fibonacci.scm -e "(fib 2)"
1
```

## Ada (1980)
<!-- {% include_code lang:ada Fibonacci-Number-in-Different-Programming-Languages/Ada/fibonacci.adb %} -->

``` ada
with Ada.Text_IO;
with Ada.Command_Line;

procedure fibonacci is
    N : Integer := Integer'Value(Ada.Command_Line.Argument(Number => 1));
    function fib(
        N: in Integer)
        return Integer is
        A : Integer := 0;
        B : Integer := 1;
        C : Integer := 1;
    begin
        if (N <= 1)
        then
            return N;
        end if;
        for i in 2 .. N loop
            C := A + B;
            A := B;
            B := C;
        end loop;
        return B;
    end;
begin
    Ada.Text_IO.Put_Line("fib(" & Integer'Image(N) & ") = " & Integer'Image(fib(N)));
end fibonacci;
```

``` shell-session
$ gnatmake fibonacci.adb
$ ./fibonacci 3
fib( 3) =  2
```

## Standard ML (1983)
Tail recursion
<!-- {% include_code lang:sml Fibonacci-Number-in-Different-Programming-Languages/StandardML/fibonacci.sml %} -->

``` sml
fun fib n = 
    let fun iter (a, b, n) = if n <= 1 then b else iter (b, a + b, n - 1)
    in 
        iter(0, 1, n)
    end

val n_str = hd (CommandLine.arguments())
val n = valOf (Int.fromString n_str)
val res = fib n
val _ = print ("fib(" ^ Int.toString n ^ ") = " ^ Int.toString res)
val _ = OS.Process.exit(OS.Process.success)
```

``` shell-session
$ sml fibonacci.sml 4
fib(4) = 3
```

## C++ (1985)
<!-- {% include_code lang:cpp Fibonacci-Number-in-Different-Programming-Languages/C++/fibonacci.cpp %} -->

``` cpp
#include <iostream>

using namespace std;

int fib(int n) {
    if(n <= 1) {
        return n;
    }

    int a = 0;
    int b = 1;

    for(int i = 2; i <= n; i++) {
        int c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    cout << "fib(" << n << ")" << " = " <<  fib(n) << endl;
    return 0;
}
```

``` shell-session
$ g++ fibonacci.cpp
$ ./a.out 5
fib(5) = 5
```

## Python (1991)
<!-- {% include_code lang:python Fibonacci-Number-in-Different-Programming-Languages/Python/fibonacci.py %} -->

``` python
import sys


def fib(n):
    if n <= 1:
        return n

    a = 0
    b = 1

    for i in range(2, n + 1):
        c = a + b
        a = b
        b = c

    return b


if __name__ == '__main__':
    n = int(sys.argv[1])
    print(f"fib({n}) = {fib(n)}\n")
```

``` shell-session
$ python3 fibonacci.py 6
fib(6) = 8
```

## Java (1995)
<!-- {% include_code lang:java Fibonacci-Number-in-Different-Programming-Languages/Java/Fibonacci.java %} -->

``` java
public class Fibonacci {
    public static int fib(int n) {
        if(n <= 1) {
            return n;
        }

        int a = 0;
        int b = 1;

        for(int i = 2; i <= n; i++) {
            int c = a + b;
            a = b;
            b = c;
        }
        return b;
    }

    public static void main(String[] args) {
        int n = Integer.parseInt(args[0]);
        System.out.println("fib(" + n + ") = " + fib(n));
    }
}
```

``` shell-session
$ javac Fibonacci.java
$ java Fibonacci 7
fib(7) = 13
```

## JavaScript (1995)
<!-- {% include_code lang:js Fibonacci-Number-in-Different-Programming-Languages/JavaScript/fibonacci.js %} -->

``` js
function fib(n) {
    if (n <= 1) {
        return n
    }

    var a = 0
    var b = 1

    for (let i = 2; i <= n; i++) {
        c = a + b
        a = b
        b = c
    }
    return b
}

const n = process.argv[2]
console.log(`fib(${n}) = ${fib(n)}\n`)
```

``` shell-session
$ node fibonacci.js 8
fib(8) = 21
```

## Scala (2004)
<!-- {% include_code lang:scala Fibonacci-Number-in-Different-Programming-Languages/Scala/Fibonacci.scala %} -->

``` scala
object Fibonacci {
  def fib(n: Int): Int = {
    if (n <= 1) {
      return n
    }

    var a: Int = 0
    var b: Int = 1

    for (_ <- 2 to n) {
      val c = a + b
      a = b
      b = c
    }
    b
  }

  def main(args: Array[String]): Unit = {
    val n = args(0).toInt
    println(s"fib(${n}) = ${fib(n)}")
  }
}
```

``` shell-session
$ scala Fibonacci.scala 9
fib(9) = 34
```

## Swift (2014)
<!-- {% include_code lang:swift Fibonacci-Number-in-Different-Programming-Languages/Swift/Fibonacci.swift %} -->

``` swift
import Foundation

func fib(_ n: Int) -> Int {
    if (n <= 1) {
        return n
    }
    
    var a = 0
    var b = 1
    
    for _ in 2...n {
        let c = a + b
        a = b
        b = c
    }
    return b
}

let args = CommandLine.arguments
if args.count == 2, let n = Int(args[1]) {
    print("fib(\(n)) = \(fib(n))")
} else {
    print("Usage: swift fibonacci.swift <number>")
}
```

``` shell-session
$ swift fibonacci.swift 10
fib(10) = 55
```
