---
title: Swift Features
date: 2018-07-31 09:15:40
updated:
categories: iOS
tags: Swift
keywords: Swift
---

References:
- [The Swift Programming Language](https://docs.swift.org/swift-book/)

This post is based on Swift 4.2

## Operators
### Closed Range Operator
``` swift
for i in 1...5 {
    print("\(i) times 5 is \(i * 5)")
}
// 1 times 5 is 5
// 2 times 5 is 10
// 3 times 5 is 15
// 4 times 5 is 20
// 5 times 5 is 25
```

### Half-Open Range Operator
``` swift
let names = ["Anna", "Alex", "Brian", "Jack"]
let count = names.count
for i in 0..<count {
    print("Person \(i + 1) is called \(names[i])")
}
// Person 1 is called Anna
// Person 2 is called Alex
// Person 3 is called Brian
// Person 4 is called Jack
```

### One-Sided Ranges
``` swift
for name in names[2...] {
    print(name)
}
// Brian
// Jack

for name in names[...2] {
    print(name)
}
// Anna
// Alex
// Brian

let range = ..<5
range.contains(7)   // false
range.contains(5)   // false
range.contains(4)   // true
range.contains(-1)  // true
```

## String
### String Indices
``` swift
let greeting = "Hello!"
let index = greeting.index(greeting.startIndex, offsetBy: 4)
print("\(greeting[greeting.startIndex])") // H
print("\(greeting[index])")               // o
```

### Substrings
``` swift
let greeting = "Hello, world!"
let index = greeting.index(of: ",") ?? greeting.endIndex
let beginning = greeting[..<index]  // beginning is an instance of Substring
print("\(beginning)")               // Hello
let newString = String(beginning)
```

### String Equality
Two String values (or two Character values) are considered equal if their extended grapheme clusters are canonically equivalent.
``` swift
"caf\u{E9}" == "caf\u{65}\u{301}"   // café
"\u{41}" != "\u{0410}"              // А
```

## Collection Types
### Array
``` swift
// Create an Array with an Array Literal
var alphabet = ["A", "B", "C", "D", "E"]    // ["A", "B", "C", "D", "E"]

// Append an array
alphabet += ["F", "G"]                      // ["A", "B", "C", "D", "E", "F", "G"]

// Modify an array
alphabet[3...5] = ["M", "N"]                // ["A", "B", "C", "M", "N", "G"]
```

### Set
``` swift
// Set Operations
let oddDigits: Set = [1, 3, 5, 7, 9]
let evenDigits: Set = [0, 2, 4, 6, 8]
let singleDigitPrimeNumbers: Set = [2, 3, 5, 7]

oddDigits.union(evenDigits).sorted()                            // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
oddDigits.intersection(evenDigits).sorted()                     // []
oddDigits.subtracting(singleDigitPrimeNumbers).sorted()         // [1, 9]
oddDigits.symmetricDifference(singleDigitPrimeNumbers).sorted() // [1, 2, 9]
```

### Dictionary
``` swift
// Create a Dictionary with a Dictionary Literal
let romanNumeral = ["I": 1, "V": 5, "X": 10]

// Iterate Over a Dictionary
for (symbol, value) in romanNumeral {
    print("\(symbol): \(value)")
}
// X: 10
// I: 1
// V: 5
```

## Control Flow
### Switch
No Implicit Fallthrough
``` swift
// Tuple & Interval Matching
let somePoint = (1, 1)
switch somePoint {
case (0, 0):
    print("\(somePoint) is at the origin")
case (_, 0):
    print("\(somePoint) is on the x-axis")
case (0, _):
    print("\(somePoint) is on the y-axis")
case (-2...2, -2...2):
    print("\(somePoint) is inside the box")
default:
    print("\(somePoint) is outside of the box")
}
// (1, 1) is inside the box

// Value Binding
let anotherPoint = (9, 0)
switch anotherPoint {
case (let distance, 0), (0, let distance):
    print("On an axis, \(distance) from the origin")
default:
    print("Not on an axis")
}
// On an axis, 9 from the origin
```

### Early Exit
``` swift
func greet(person: [String: String]) {
    guard let name = person["name"] else {
        print("Hello, stranger!")
        return
    }
    print("Hello \(name)!")
}
greet(person: ["name": "John"])     // Hello John!
greet(person: ["gender": "male"])   // Hello, stranger!
```
