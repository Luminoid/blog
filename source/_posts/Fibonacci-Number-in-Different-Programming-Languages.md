---
title: Fibonacci Number in Different Programming Languages
date: 2022-02-22 15:36:50
updated:
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

Programs for getting the nth Fibonacci number in different programming languages.

## C (1972)
{% include_code lang:c Fibonacci-Number-in-Different-Programming-Languages/C/fibonacci.c %}

``` shell-session
$ gcc fibonacci.c
$ ./a.out 1
fib(1) = 1
```

<!-- more -->

## Scheme (1975)
Tail recursion
{% include_code lang:scheme Fibonacci-Number-in-Different-Programming-Languages/Scheme/fibonacci.scm %}

``` shell-session
$ racket -f fibonacci.scm -e "(fib 2)"
1
```

## Ada (1980)
{% include_code lang:ada Fibonacci-Number-in-Different-Programming-Languages/Ada/fibonacci.adb %}

``` shell-session
$ gnatmake fibonacci.adb
$ ./fibonacci 3
fib( 3) =  2
```

## Standard ML (1983)
Tail recursion
{% include_code lang:sml Fibonacci-Number-in-Different-Programming-Languages/StandardML/fibonacci.sml %}

``` shell-session
$ sml fibonacci.sml 4
fib(4) = 3
```

## C++ (1985)
{% include_code lang:cpp Fibonacci-Number-in-Different-Programming-Languages/C++/fibonacci.cpp %}

``` shell-session
$ g++ fibonacci.cpp
$ ./a.out 5
fib(5) = 5
```

## Python (1991)
{% include_code lang:python Fibonacci-Number-in-Different-Programming-Languages/Python/fibonacci.py %}

``` shell-session
$ python3 fibonacci.py 6
fib(6) = 8
```

## Java (1995)
{% include_code lang:java Fibonacci-Number-in-Different-Programming-Languages/Java/Fibonacci.java %}

``` shell-session
$ javac Fibonacci.java
$ java Fibonacci 7
fib(7) = 13
```

## JavaScript (1995)
{% include_code lang:js Fibonacci-Number-in-Different-Programming-Languages/JavaScript/fibonacci.js %}

``` shell-session
$ node fibonacci.js 8
fib(8) = 21
```

## Scala (2004)
{% include_code lang:scala Fibonacci-Number-in-Different-Programming-Languages/Scala/Fibonacci.scala %}

``` shell-session
$ scala Fibonacci.scala 9
fib(9) = 34
```

## Swift (2014)
{% include_code lang:swift Fibonacci-Number-in-Different-Programming-Languages/Swift/Fibonacci.swift %}

``` shell-session
$ swift fibonacci.swift 10
fib(10) = 55
```
