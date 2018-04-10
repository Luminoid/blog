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

Docs:
- [Babel](https://babeljs.io/learn-es2015)
- [MDN JavaScript Docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

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
