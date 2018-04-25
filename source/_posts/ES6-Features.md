---
title: ES6 Features
date: 2018-04-11 00:38:02
updated:
categories:
- Web
- JavaScript
tags:
keywords:
- ES6
---

<!-- TOC -->

Docs:
- [MDN JavaScript Docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [Babel](https://babeljs.io/learn-es2015)

## Data structures
- Primitive: Boolean, null, undefined, Number, String, Symbol
- Object

## Let & Const
Block-scoped binding constructs.
``` js
let var1 [= value1];
const name1 = value1;
```

## Destructuring
``` js
// Array matching
let [a, ,c] = [1,2,3];
a === 1;
c === 3;

// Object matching
let { a, b } = { a: 1, b: 2 };
a === 1;
b === 2;

// Default arguments
function add({a, b, c = 3, d = 4}) {
    return a + b + c + d;
}
add({a:1, b:2}) === 10;

// Swap values
let x = 1;
let y = 2;
[x, y] = [y, x];

// Multiple return values
function colorWhite(){
    return {
        red: 255,
        green: 255,
        blue: 255,
    }
}
```

<!-- more -->

## String
### Unicode
``` js
"𠮷" === "\u{20BB7}";
"𠮷" === "\uD842\uDFB7";
```

### Template Strings
``` js
let tem_str = "Template Strings";
let s = `${tem_str} supports multiline strings
and interpolate variable bindings.`;
```

## RegExp
``` js
// String method: match
const reg = /abc+/ig;
const str = "abdabcdeabccdef";
const arr = str.match(reg);
arr; // [ 'abc', 'abcc' ]

// RegExp method: test
const reg1 = /abc+/i;
const reg2 = /abc*/i;
const str = "ababab"
reg1.test(str) === false;
reg2.test(str) === true;

// u (unicode) flag:
/^.$/.test('😀') === false;
/^.$/u.test('😀') === true;

// s (dotAll) flag
/^.$/.test('\n') === false;
/^.$/s.test('\n') === true;

// lookahead
('1$ and 2¢').match(/\d+(?=\$)/g); // [ '1' ]

// negative lookahead
('1$ and 2¢').match(/\d+(?!\$)/g); // [ '2' ]

// lookbehind
('$1 and ¢2').match(/(?<=\$)\d+/g); // [ '1' ]

// negative lookbehind
('$1 and ¢2').match(/(?<!\$)\d+/g); // [ '2' ]

// Named Capture Groups
const regDate = /(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})/;
const matchObj = regDate.exec('1987-12-31');
const year = matchObj.groups.year;      // 1987
const month = matchObj.groups.month;    // 12
const day = matchObj.groups.day;        // 31

// Destructuring with named capture groups
const regDate = /(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})/;
const {groups: {day, year}} = regDate.exec('1987-12-31');
day === '31';
year === '1987';

// replace() with named capture groups
const regDate = /(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})/;
'1987-12-31'.replace(regDate, '$<month>/$<day>/$<year>') === '12/31/1987';

// Backreferences
const regTwice = /^(?<word>[a-z]+)!\k<word>$/;
regTwice.test('abc!abc') === true;
regTwice.test('abc!ab') === false;
```

## Number
``` js
// Binary and Octal Literals
0b101 === 5;
0o101 === 65;

// Number method
Number.parseInt('12.34') === 12;
Number.parseFloat('12.34') === 12.34;

// Number.EPSILON: the difference between 1 and the smallest floating point number greater than 1
Number.EPSILON === Math.pow(2, -52);

0.1 + 0.2 - 0.3 !== 0;
0.1 + 0.2 - 0.3 < Number.EPSILON;

// Exponentiation operator
2 ** 3 === 8;
```

## Function
``` js
// Default parameter values
function add(x, y = 1) {
  return x + y;
}
add(2) === 3;

// Rest
function add(...values) {
  let sum = 0;
  for (let val of values) {
    sum += val;
  }
  return sum;
}
add(1, 2, 3) === 6;

// Arrow function
// Arrow functions share the same lexical this as their surrounding code.
let sum = (num1, num2) => num1 + num2;
sum(1, 2) === 3;
let result = [3, 2, 1].sort((a, b) => a - b); // [ 1, 2, 3 ]

// Tail Recursion
function tailFactorial(n, acc) {
    "use strict";
    if (n === 1) return acc;
    return tailFactorial(n - 1, n * acc);
}
function factorial(n) {
    return tailFactorial(n, 1);
}
factorial(5) === 120;
```

## Array
``` js
// Spread
function add(a, b, c, d) {
    return a + b + c + d;
}
add(1, ...[2, 3, 4]) === 10;
Math.max(...[12, 34, 5]) === 34;

// Copy an array
const arr1 = [1, 2, 3];
const arr2 = [...arr1]; // one level deep copy
arr1 !== arr2;

// Concatenate arrays
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const arr = [...arr1, ...arr2]; // [ 1, 2, 3, 4, 5, 6 ]

// Destructuring
const [head, ...tail] = [1, 2, 3, 4, 5];
tail; // [ 2, 3, 4, 5 ]

// Array.from(): create a new Array instance from an array-like or iterable object.
Array.from({length: 5}, (v, i) => i * i); // [ 0, 1, 4, 9, 16 ]

// Array.of(): create a new Array instance with a variable number of arguments.
Array.of(3);        // [ 3 ]
Array.of(1, 2, 3);  // [ 1, 2, 3 ]

// Array Iterator
for (let index of ['a', 'b'].keys()) {
    console.log(index);
}
// 0
// 1

for (let elem of ['a', 'b'].values()) {
    console.log(elem);
}
// 'a'
// 'b'

for (let [index, elem] of ['a', 'b'].entries()) {
    console.log(index, elem);
}
// 0 'a'
// 1 'b'
```

## Object
``` js
// Property shorthand
let x = 0, y = 0;
const obj = { x, y }; // equals to: obj = { x: x, y: y };

// Object.is(): determines whether two values are the same value.
+0 === -0;
NaN !== NaN;
Object.is(+0, -0) === false;
Object.is(NaN, NaN) === true;

// Merge objects
let dest = { a: 0 };
let src1 = { b: 1, c: 2 };
let src2 = { b: 3, d: 4 };
Object.assign(dest, src1, src2);
dest; // { a: 0, b: 3, c: 2, d: 4 }

// Deep clone
obj1 = {a: 1, b: {c: 2}};
obj2 = Object.assign({}, obj1);
obj3 = JSON.parse(JSON.stringify(obj1));
obj2.b === obj1.b
obj3.b !== obj1.b
```

### Enumeration
| Method | enumerable property | non-enumerable property | Symbol | own | prototype chain |
| ------ | ------------------- | ----------------------- | ------ | --- | --------------- |
| `Object.keys()` | Yes | No | No | Yes | No |
| `Object.getOwnPropertyNames()` | Yes | Yes | No | Yes | No |
| `Object.getOwnPropertySymbols()` | No | No | Yes | Yes | No |
| `for...in` | Yes | No | No | Yes | Yes |
| `Reflect.ownKeys()` | Yes | Yes | Yes | Yes | No |

## Symbol
``` js
Symbol("foo") !== Symbol("foo")
Symbol.for("bar") === Symbol.for("bar")

// Symbol as an identifier for object properties
const foo = Symbol("foo");
let obj = {};
obj[foo] = "hello";
obj; // { [Symbol(foo)]: 'hello' }

// Symbol as a const value
const shapeType = {
    triangle: Symbol()
    rectangle: Symbol()
};
```

## Set & Map
``` js
// Set
let s = new Set(["a"]);
s.add("b").add("a");
s; // Set { 'a', 'b' }
s.size === 2;
s.has("a") === true;

// Remove duplicated elements in an array
let arr = [1, 2, 1, 3];
[...new Set(arr)]; // [ 1, 2, 3 ]

// Union, Intersect & Difference
let a = new Set([1, 2, 3]);
let b = new Set([2, 3, 4]);
let union = new Set([...a, ...b]);                          // Set { 1, 2, 3, 4 }
let intersect = new Set([...a].filter(x => b.has(x)));      // Set { 2, 3 }
let difference = new Set([...a].filter(x => !b.has(x)));    // Set { 1 }

// Map
let m = new Map();
let s = Symbol();
m.set("foo", 1);
m.set(s, 2);
m.get(s) === 2;
m.size === 2;

// Weak Sets & Weak Maps
// WeakSet: collection of objects only and not of arbitrary values of any type.
// - References to objects in the collection are held weakly.
// - WeakSets are not enumerable.
const obj = {foo: 1};
let ws = new WeakSet();
ws.add(obj); // WeakSet {}
ws.has(obj) === true;

let wm = new WeakMap();
wm.set(obj, 123); // WeakMap {}
wm.get(obj) === 123;
```

## Meta-Programming
### Proxy
The Proxy object is used to define custom behavior for fundamental operations (e.g. property lookup, assignment, enumeration, function invocation, etc).
``` js
let target = {};
let handler = {
    get: function (obj, prop) {
        return `Hello, ${prop}!`;
    }
};
let p = new Proxy(target, handler);
p.world === "Hello, world!";
```

### Reflect
Reflect is a built-in object that provides methods for interceptable JavaScript operations. The methods are the same as those of proxy handlers.
``` js
// Reflect.defineProperty(): Similar to Object.defineProperty(). Returns a Boolean.
// Reflect.construct(): The new operator as a function. Equivalent to calling new target(...args).
// Reflect.deleteProperty(): The delete operator as a function. Equivalent to calling delete target[name].
// Reflect.has(): The in operator as function.

let obj = { a: 1 };
Reflect.defineProperty(obj, "b", { value: 2 });
obj[Symbol("c")] = 3;
Reflect.ownKeys(obj); // [ 'a', 'b', Symbol(c) ]
```
