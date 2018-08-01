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

## The Basics
### Value Types
A value type is a type whose value is copied when it’s assigned to a variable or constant, or when it’s passed to a function.
All of the basic types in Swift—integers, floating-point numbers, Booleans, strings, arrays and dictionaries—are value types, and are implemented as structures behind the scenes. All structures and enumerations are also value types.

> Collections defined by the standard library like arrays, dictionaries, and strings use an optimization to reduce the performance cost of copying. Instead of making a copy immediately, these collections share the memory where the elements are stored between the original instance and any copies. If one of the copies of the collection is modified, the elements are copied just before the modification. The behavior you see in your code is always as if a copy took place immediately.

### Reference Types
Reference types are not copied when they are assigned to a variable or constant, or when they are passed to a function. Rather than a copy, a reference to the same existing instance is used.
Classes, functions and closures are reference types.

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

<!-- more -->

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

### Identity Operators
`===`: Identical to 
`!==`: Not identical to

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

## Functions
### Functions with Multiple Return Values
``` swift
func minMax(array: [Int]) -> (min: Int, max: Int)? {
    if array.isEmpty { return nil }
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}

if let bounds = minMax(array: [8, -6, 2, 109, 3, 71]) {
    print("min is \(bounds.min) and max is \(bounds.max)")  // min is -6 and max is 109
}
```

### Function Argument Labels
``` swift
func someFunction(argumentLabel parameterName: Int) {}
```

Specifying Argument Labels
``` swift
func greet(person: String, from hometown: String) -> String {
    return "Hello \(person)!  Glad you could visit from \(hometown)."
}
print(greet(person: "Bill", from: "Cupertino")) // Hello Bill!  Glad you could visit from Cupertino.
```

Omitting Argument Labels
``` swift
func someFunction(_ firstParameterName: Int, secondParameterName: Int) {}
someFunction(1, secondParameterName: 2)
```

### Variadic Parameters
A variadic parameter accepts zero or more values of a specified type.
``` swift
func arithmeticMean(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
arithmeticMean(3, 8.25, 18.75)  // 10.0
```

### In-Out Parameters
An in-out parameter has a value that is passed in to the function, is modified by the function, and is passed back out of the function to replace the original value.
``` swift
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}
var a = 3
var b = 107
swapTwoInts(&a, &b)
print("a is now \(a), and b is now \(b)")   // a is now 107, and b is now 3
```

### Functions as Parameters
``` swift
func addTwoInts(_ a: Int, _ b: Int) -> Int {
    return a + b
}
func printMathResult(_ mathFunction: (Int, Int) -> Int, _ a: Int, _ b: Int) {
    print("Result: \(mathFunction(a, b))")
}
printMathResult(addTwoInts, 3, 5)   // Result: 8
```

## Closures
Closures take one of three forms:
- Global functions are closures that have a name and do not capture any values.
- Nested functions are closures that have a name and can capture values from their enclosing function.
- Closure expressions are unnamed closures written in a lightweight syntax that can capture values from their surrounding context.

Optimizations of Swift’s closure:
- Inferring parameter and return value types from context
- Implicit returns from single-expression closures
- Shorthand argument names
- Trailing closure syntax

### Closure Expressions
``` swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 } )
```

Shorthand Argument Names
``` swift
reversedNames = names.sorted(by: { $0 > $1 } )
```

Trailing Closure
``` swift
reversedNames = names.sorted() { $0 > $1 }
```

Trailing closure with the closure expression as the function or method’s only argument
``` swift
reversedNames = names.sorted { $0 > $1 }
```

Operator Methods
``` swift
reversedNames = names.sorted(by: >)
```

### Trailing Closures
Optimization when passing a closure expression to a function as the function’s final argument
``` swift
func someFunctionThatTakesAClosure(closure: () -> Void) {
    // function body goes here
}

someFunctionThatTakesAClosure() {
    // trailing closure's body goes here
}
```

### Capturing Values
``` swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
let incrementByTen = makeIncrementer(forIncrement: 10)
let incrementBySeven = makeIncrementer(forIncrement: 7)
incrementByTen()        // 10
incrementByTen()        // 20
incrementBySeven()      // 7
incrementByTen()        // 30
```
Every incrementer has its own stored reference to a new, separate `runningTotal` variable.

### @escaping and @autoclosure
`@escaping`: A closure is said to escape a function when the closure is passed as an argument to the function, but is called after the function returns.
`@autoclosure`: An autoclosure is a closure that is automatically created to wrap an expression that’s being passed as an argument to a function.

``` swift
var customersInLine = ["Alex", "Barry", "Chris"]
var customerProviders: [() -> String] = []
func collectCustomerProviders(_ customerProvider: @autoclosure @escaping () -> String) {
    customerProviders.append(customerProvider)
}
collectCustomerProviders(customersInLine.remove(at: 0))
collectCustomerProviders(customersInLine.remove(at: 0))

for customerProvider in customerProviders {
    print("Now serving \(customerProvider())!")
}
// Now serving Alex!
// Now serving Barry!
```

## Enumerations
### Associated Values
``` swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}
var productBarcode = Barcode.upc(8, 85909, 51226, 3)
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
    print("UPC : \(numberSystem), \(manufacturer), \(product), \(check).")
case let .qrCode(productCode):
    print("QR code: \(productCode).")
}
// UPC : 8, 85909, 51226, 3.
```

### Raw Values
``` swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
```

### Recursive Enumerations
``` swift
indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case let .number(value):
        return value
    case let .addition(left, right):
        return evaluate(left) + evaluate(right)
    case let .multiplication(left, right):
        return evaluate(left) * evaluate(right)
    }
}

let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.addition(five, four)
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))
print(evaluate(product))    // 18
```

## Structures and Classes
Classes have additional capabilities that structures don’t have:
- Inheritance enables one class to inherit the characteristics of another.
- Type casting enables you to check and interpret the type of a class instance at runtime.
- Deinitializers enable an instance of a class to free up any resources it has assigned.
- Reference counting allows more than one reference to a class instance.

### Memberwise Initializers for Structure Types
All structures have an automatically generated *memberwise initializer*
``` swift
struct Resolution {
    var width = 0
    var height = 0
}
let vga = Resolution(width: 640, height: 480)
```

## Properties
### Stored Property
A constant or variable that is stored as part of an instance of a particular class or structure
``` swift
struct FixedLengthRange {
    var firstValue: Int
    let length: Int
}
```

### Computed Properties
Computed properties do not actually store a value. Instead, they provide a getter and an optional setter to retrieve and set other properties and values indirectly.
``` swift
struct Point {
    var x = 0.0, y = 0.0
}
struct Size {
    var width = 0.0, height = 0.0
}
struct Rect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}
var square = Rect(origin: Point(x: 0.0, y: 0.0),
                  size: Size(width: 10.0, height: 10.0))
square.center = Point(x: 15.0, y: 15.0)
print("square.origin is now at (\(square.origin.x), \(square.origin.y))")
// Prints "square.origin is now at (10.0, 10.0)"
```

### Property Observers
``` swift
class StepCounter {
    var totalSteps: Int = 0 {
        willSet {
            print("About to set totalSteps to \(newValue)")
        }
        didSet {
            if totalSteps > oldValue  {
                print("Added \(totalSteps - oldValue) steps")
            }
        }
    }
}
let stepCounter = StepCounter()
stepCounter.totalSteps = 200
// About to set totalSteps to 200
// Added 200 steps
stepCounter.totalSteps = 360
// About to set totalSteps to 360
// Added 160 steps
```

### Type Properties
You define type properties with the `static` keyword. For computed type properties for class types, you can use the `class` keyword instead to allow subclasses to override the superclass’s implementation.
