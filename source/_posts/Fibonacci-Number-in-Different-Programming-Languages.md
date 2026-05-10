---
title: "Fibonacci across ten languages"
date: 2022-02-22 15:36:50
categories:
  - Programming Languages
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

The same trivial algorithm in ten languages, ordered by year of birth. Beyond "syntax differs," the interesting part is what each language insists you write down: type signatures, memory ownership, package envelopes, entry-point ceremony. The shape of the boilerplate is the language's taste.

<!-- more -->

## C (1972)

```c
#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
    if (n <= 1) {
        return n;
    }

    int a = 0;
    int b = 1;

    for (int i = 2; i <= n; i++) {
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

```bash
gcc fibonacci.c
./a.out 1
# fib(1) = 1
```

C asks little of the programmer up front: no module system, no type inference to fight, no runtime to satisfy. In return it gives you `int` (overflow at fib(46)), manual `argv` parsing, and `atoi` with no error path. The minimalism is real, and so is the cost.

## Scheme (1975)

```scheme
(define (fib n)
  (define (iter a b n)
    (if (<= n 1)
        b
        (iter b (+ a b) (- n 1))))
  (iter 0 1 n))
```

```bash
racket -f fibonacci.scm -e "(fib 2)"
# 1
```

Tail recursion replaces the loop entirely; no `for`, no mutable accumulator. Integer arithmetic is bignum by default, so fib(1000) returns the right answer without a library.

## Ada (1980)

```ada
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
        if (N <= 1) then
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

```bash
gnatmake fibonacci.adb
./fibonacci 3
# fib( 3) =  2
```

Every parameter has a mode (`in`, `out`, `in out`), every variable has a declared type, every package import is explicit. Even the assignment operator (`:=`) is different from equality (`=`), so a typo can't quietly become a comparison.

## Standard ML (1983)

```sml
fun fib n =
    let fun iter (a, b, n) = if n <= 1 then b else iter (b, a + b, n - 1)
    in
        iter (0, 1, n)
    end

val n_str = hd (CommandLine.arguments())
val n = valOf (Int.fromString n_str)
val res = fib n
val _ = print ("fib(" ^ Int.toString n ^ ") = " ^ Int.toString res)
val _ = OS.Process.exit(OS.Process.success)
```

```bash
sml fibonacci.sml 4
# fib(4) = 3
```

`let`-binding and pattern matching stand in for the imperative loop. Type inference fills in everything that isn't a calling convention. The price: the runtime really does want you to handle `Option` types (`valOf` will raise if the argument can't be parsed).

## C++ (1985)

```cpp
#include <iostream>

int fib(int n) {
    if (n <= 1) {
        return n;
    }

    int a = 0;
    int b = 1;

    for (int i = 2; i <= n; i++) {
        int c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main(int argc, char *argv[]) {
    int n = std::atoi(argv[1]);
    std::cout << "fib(" << n << ") = " << fib(n) << "\n";
    return 0;
}
```

```bash
g++ fibonacci.cpp
./a.out 5
# fib(5) = 5
```

Same skeleton as C plus `std::` prefixes and stream insertion. (`using namespace std;` makes the body terser and hides which symbols come from where; the qualified form scales.) Modern C++ would reach for `std::format` and `<charconv>`, but the bones haven't changed in forty years.

## Python (1991)

```python
import sys


def fib(n):
    if n <= 1:
        return n

    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


if __name__ == '__main__':
    n = int(sys.argv[1])
    print(f"fib({n}) = {fib(n)}")
```

```bash
python3 fibonacci.py 6
# fib(6) = 8
```

Tuple swap (`a, b = b, a + b`) replaces the temporary. The `if __name__ == '__main__':` guard exists because every Python file is both a module and a script, so the entry point has to be opt-in. Integers are arbitrary-precision, so overflow is not a thing.

## Java (1995)

```java
public class Fibonacci {
    public static int fib(int n) {
        if (n <= 1) {
            return n;
        }

        int a = 0;
        int b = 1;

        for (int i = 2; i <= n; i++) {
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

```bash
javac Fibonacci.java
java Fibonacci 7
# fib(7) = 13
```

Code lives inside a class even when there is nothing to encapsulate. The filename and the class name have to match. Other JVM languages spent twenty years deleting this ceremony; Java itself eventually got `var` (Java 10) and records (Java 14), but the class envelope remains.

## JavaScript (1995)

```js
function fib(n) {
    if (n <= 1) {
        return n;
    }

    let a = 0;
    let b = 1;

    for (let i = 2; i <= n; i++) {
        const c = a + b;
        a = b;
        b = c;
    }
    return b;
}

const n = process.argv[2];
console.log(`fib(${n}) = ${fib(n)}`);
```

```bash
node fibonacci.js 8
# fib(8) = 21
```

No class envelope, no entry point, no type signatures. The discipline JavaScript skips is the same discipline TypeScript was invented to add back; the choice between them is whether you want compile-time errors to find typos or whether you want to ship right now.

## Scala (2004)

```scala
@main def fibonacci(n: Int): Unit =
  def fib(n: Int): BigInt =
    if n <= 1 then n
    else
      var a: BigInt = 0
      var b: BigInt = 1
      for _ <- 2 to n do
        val c = a + b
        a = b
        b = c
      b

  println(s"fib($n) = ${fib(n)}")
```

```bash
scala-cli run fibonacci.scala -- 9
# fib(9) = 34
```

Scala 3's `@main` annotation collapses the historical `object Fibonacci { def main(args: Array[String]) ... }` boilerplate down to a top-level function. The `var` loop here exists for cross-language parity; the idiomatic Scala for this problem is a lazy stream, `lazy val fibs: LazyList[BigInt] = 0 #:: 1 #:: fibs.zip(fibs.tail).map { (a, b) => a + b }`, which is a different post.

## Swift (2014)

```swift
func fib(_ n: Int) -> Int {
    if n <= 1 {
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
guard args.count == 2, let n = Int(args[1]) else {
    print("Usage: swift fibonacci.swift <number>")
    exit(1)
}
print("fib(\(n)) = \(fib(n))")
```

```bash
swift fibonacci.swift 10
# fib(10) = 55
```

`let` vs `var` is a hard distinction baked into the compiler, not a convention. Argument labels are part of the function signature (`_ n: Int` opts out of the external label). Optionals in argument parsing have to be unwrapped before use, so the `guard` is mandatory rather than defensive.
