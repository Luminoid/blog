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
A *value type* is a type whose value is copied when it’s assigned to a variable or constant, or when it’s passed to a function.
All of the basic types in Swift—integers, floating-point numbers, Booleans, strings, arrays and dictionaries—are value types, and are implemented as structures behind the scenes. All structures and enumerations are also value types.

> Collections defined by the standard library like arrays, dictionaries, and strings use an optimization to reduce the performance cost of copying. Instead of making a copy immediately, these collections share the memory where the elements are stored between the original instance and any copies. If one of the copies of the collection is modified, the elements are copied just before the modification. The behavior you see in your code is always as if a copy took place immediately.

### Reference Types
A *reference type* is not copied when it is assigned to a variable or constant, or when it is passed to a function. Rather than a copy, a reference to the same existing instance is used.
Classes, functions and closures are reference types.

### Optionals
An *optional* represents two possibilities: Either there is a value, and you can unwrap the optional to access that value, or there isn’t a value at all. Optionals of *any* type can be set to `nil`, not just object types.
The Swift language defines the postfix `?` as syntactic sugar for the named type `Optional<Wrapped>`, which is defined in the Swift standard library.

#### Forced Unwrapping
`optional!`: forced unwrapping of the optional’s value

#### Optional Binding
``` swift
if let constantName = someOptional {
    statements
}
```

#### Implicitly Unwrapped Optionals
*Implicitly unwrapped optionals* are useful when an optional’s value is confirmed to exist immediately after the optional is first defined and can definitely be assumed to exist at every point thereafter.
You write an implicitly unwrapped optional by placing an exclamation mark (`String!`) rather than a question mark (`String?`) after the type that you want to make optional. The Swift language defines the postfix `!` as syntactic sugar for the named type `Optional<Wrapped>` with the additional behavior that it’s automatically unwrapped when it’s accessed.
``` swift
let possibleString: String? = "An optional string."
let forcedString: String = possibleString!  // requires an exclamation mark

let assumedString: String! = "An implicitly unwrapped optional string."
let implicitString: String = assumedString  // no need for an exclamation mark
```

<!-- more -->

## Operators
### Range Operators
#### Closed Range Operator
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

#### Half-Open Range Operator
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

#### One-Sided Ranges
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

### Overflow Operators
`&+`: Overflow addition 
`&-`: Overflow subtraction
`&*`: Overflow multiplication
``` swift
var potentialOverflow = Int16.max
// potentialOverflow equals 32767, which is the maximum value an Int16 can hold
potentialOverflow += 1
// this causes an error

var signedOverflow = Int16.max
signedOverflow = signedOverflow &+ 1    // signedOverflow: Int16 = -32768

var unsignedOverflow = UInt8.max
// unsignedOverflow equals 255, which is the maximum value a UInt8 can hold
unsignedOverflow = unsignedOverflow &+ 1
// unsignedOverflow is now equal to 0
```

### Operator Methods
Classes and structures can provide their own implementations of existing operators. This is known as *overloading* the existing operators.
#### infix operator
``` swift
struct Vector2D {
    var x = 0.0, y = 0.0
}

extension Vector2D {
    static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
}

let vectorA = Vector2D(x: 3.0, y: 1.0)
let VectorB = Vector2D(x: 2.0, y: 4.0)
let combinedVector = vectorA + VectorB
// combinedVector is a Vector2D instance with values of (5.0, 5.0)
```

#### Prefix and Postfix Operators
``` swift
extension Vector2D {
    static prefix func - (vector: Vector2D) -> Vector2D {
        return Vector2D(x: -vector.x, y: -vector.y)
    }
}

let positive = Vector2D(x: 3.0, y: 4.0)
let negative = -positive
// negative is a Vector2D instance with values of (-3.0, -4.0)
```

#### Compound Assignment Operators
``` swift
extension Vector2D {
    static func += (left: inout Vector2D, right: Vector2D) {
        left = left + right
    }
}
```

### Custom Operators
``` swift
prefix operator +++

extension Vector2D {
    static prefix func +++ (vector: inout Vector2D) -> Vector2D {
        vector += vector
        return vector
    }
}

var toBeDoubled = Vector2D(x: 1.0, y: 4.0)
+++toBeDoubled  // toBeDoubled now has values of (2.0, 8.0)
```

## Strings
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

## Expressions
In Swift, there are four kinds of expressions: prefix expressions, binary expressions, primary expressions, and postfix expressions. Evaluating an expression returns a value, causes a side effect, or both.

### Prefix Expressions
#### Try Operator
``` swift
try expression
```

### Binary Expressions
#### Assignment Operator
``` swift
expression = value
```
#### Ternary Conditional Operator
``` swift
condition ? expression_used_if_true : expression_used_if_false
```
#### Type-Casting Operators
``` swift
expression is type
expression as type
```

### Primary Expressions
#### Literal Expression
 Literal | Type | Value
--|---|--
 `#file` | `String` | The name of the file in which it appears.
 `#line` | `Int` | The line number on which it appears.
 `#column` | `Int` | The column number in which it begins.
 `#function` | `String` | The name of the declaration in which it appears.

#### Self Expression
``` swift
self
self.member_name
self[subscript_index]
self(initializer_arguments)
self.init(initializer_arguments)
```

#### Closure Expression
``` swift
{ (parameters) -> return_type in
    statements
}
```

#### Capture Lists
By default, a closure expression captures constants and variables from its surrounding scope with strong references to those values. You can use a capture list to explicitly control how values are captured in a closure.
``` swift
var a = 1
var b = 1
let closure = { [a] in
    print(a, b)
}

a = 10
b = 10
closure()   // 1 10
```

If the type of the expression’s value is a class, you can mark the expression in a capture list with weak or unowned to capture a `weak` or `unowned` reference to the expression’s value.
``` swift
myFunction { print(self.title) }                    // implicit strong capture
myFunction { [self] in print(self.title) }          // explicit strong capture
myFunction { [weak self] in print(self!.title) }    // weak capture
myFunction { [unowned self] in print(self.title) }  // unowned capture
```

#### Implicit Member Expression
An implicit member expression is an abbreviated way to access a member of a type, such as an enumeration case or a type method, in a context where type inference can determine the implied type.
``` swift
var x = MyEnumeration.someValue
x = .anotherValue
```

#### Tuple Expression
``` swift
(identifier 1: expression 1, identifier 2: expression 2, ...)
```

#### Wildcard Expression
A wildcard expression is used to explicitly ignore a value during an assignment.
``` swift
(x, _) = (10, 20)
```

#### Key-Path Expression
A key-path expression refers to a property or subscript of a type. You use key-path expressions in dynamic programming tasks, such as key-value observing. They have the following form:
``` swift
\type_name.path
```
At compile time, a key-path expression is replaced by an instance of the `KeyPath` class. To access a value using a key path, pass the key path to the `subscript(keyPath:)` subscript, which is available on all types. For example:
``` swift
struct SomeStructure {
    var someValue: Int
}

let s = SomeStructure(someValue: 12)
let pathToProperty = \SomeStructure.someValue

let value = s[keyPath: pathToProperty]  // value: Int = 12
```
The path can include subscripts using brackets, as long as the subscript’s parameter type conforms to the Hashable protocol. 
``` swift
let greetings = ["hello", "hola", "bonjour", "안녕"]
let myGreeting = greetings[keyPath: \[String].[1]]  // myGreeting: String = "hola"
```

#### Selector Expression
A selector expression lets you access the selector used to refer to a method or to a property’s getter or setter in Objective-C. It has the following form:
``` swift
#selector(method_name)
#selector(getter: property_name)
#selector(setter: property_name)
```
The *method name* and *property name* must be a reference to a method or a property that is available in the Objective-C runtime. The value of a selector expression is an instance of the `Selector` type. For example:
``` swift
class SomeClass: NSObject {
    @objc let property: String
    @objc(doSomethingWithInt:)
    func doSomething(_ x: Int) {}

    init(property: String) {
        self.property = property
    }
}
let selectorForMethod = #selector(SomeClass.doSomething(_:))
let selectorForPropertyGetter = #selector(getter: SomeClass.property)
```

#### Key-Path String Expression
A key-path string expression lets you access the string used to refer to a property in Objective-C, for use in key-value coding and key-value observing APIs. It has the following form:
``` swift
#keyPath(property name)
```
The *property name* must be a reference to a property that is available in the Objective-C runtime. At compile time, the key-path string expression is replaced by a string literal. For example:
``` swift
class SomeClass: NSObject {
    @objc var someProperty: Int
    init(someProperty: Int) {
        self.someProperty = someProperty
    }
}

let c = SomeClass(someProperty: 12)
let keyPath = #keyPath(SomeClass.someProperty)

if let value = c.value(forKey: keyPath) {
    print(value)    // 12
}
```

### Postfix Expressions
#### Function Call Expression
``` swift
function name(argument name 1: argument value 1, argument name 2: argument value 2)
```

#### Initializer Expression
``` swift
expression.init(initializer_arguments)
```

#### Explicit Member Expression
``` swift
expression.member_name
```

#### Postfix Self Expression
``` swift
expression.self
type.self
```
The first form evaluates to the value of the *expression*. For example, `x.self` evaluates to `x`.
The second form evaluates to the value of the *type*. Use this form to access a type as a value. For example, because `SomeClass.self` evaluates to the `SomeClass` type itself, you can pass it to a function or method that accepts a type-level argument.

#### Subscript Expression
``` swift
expression[index_expressions]
```

#### Forced-Value Expression
``` swift
expression!
```

#### Optional-Chaining Expression
``` swift
expression?
```

## Statements
In Swift, there are three kinds of statements: simple statements, compiler control statements, and control flow statements. Simple statements are the most common and consist of either an expression or a declaration. Compiler control statements allow the program to change aspects of the compiler’s behavior and include a conditional compilation block and a line control statement. Control flow statements are used to control the flow of execution in a program.

### Control Flow Statements
Control flow statements include loop statements, branch statements, and control transfer statements.

> loop-statement → for-in-statement
loop-statement → while-statement
loop-statement → repeat-while-statement

> branch-statement → if-statement
branch-statement → guard-statement
branch-statement → switch-statement

> control-transfer-statement → break-statement
control-transfer-statement → continue-statement
control-transfer-statement → fallthrough-statement
control-transfer-statement → return-statement
control-transfer-statement → throw-statement

#### Switch Statement
No Implicit Fallthrough: `switch` statements in Swift do not fall through the bottom of each case and into the next one by default.

##### Tuple & Interval Matching
``` swift
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
```

##### Value Binding
A *value-binding pattern* binds matched values to variable or constant names.
``` swift
let anotherPoint = (9, 0)
switch anotherPoint {
case (let distance, 0), (0, let distance):
    print("On an axis, \(distance) from the origin")
default:
    print("Not on an axis")
}
// On an axis, 9 from the origin
```

#### Guard Statement
A `guard` statement is used to transfer program control out of a scope if one or more conditions aren’t met. A `guard` statement has the following form:
``` swift
guard condition else {
    statements
}
```
If the `guard` statement’s condition is met, code execution continues after the `guard` statement’s closing brace.
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

### Defer Statement
A `defer` statement is used for executing code just before transferring program control outside of the scope that the `defer` statement appears in.
The statements within the `defer` statement are executed no matter how program control is transferred. This means that a `defer` statement can be used, for example, to perform manual resource management such as closing file descriptors, and to perform actions that need to happen even if an error is thrown.
If multiple `defer` statements appear in the same scope, the order they appear is the reverse of the order they are executed. Executing the last `defer` statement in a given scope first means that statements inside that last `defer` statement can refer to resources that will be cleaned up by other `defer` statements.
``` swift
func f() {
    defer { print("First") }
    defer { print("Second") }
    defer { print("Third") }
}
f()
// Prints "Third"
// Prints "Second"
// Prints "First"
```

### Compiler Control Statements
> compiler-control-statement → conditional-compilation-block
compiler-control-statement → line-control-statement
compiler-control-statement → diagnostic-statement

#### Conditional Compilation Block
A conditional compilation block allows code to be conditionally compiled depending on the value of one or more compilation conditions.
``` swift
#if compilation condition
statements
#endif
```
Unlike the condition of an `if` statement, the *compilation condition* is evaluated at compile time. As a result, the statements are compiled and executed only if the *compilation condition* evaluates to `true` at compile time.

| Platform condition | Valid arguments |
|---|---|
| `os()` | `macOS`, `iOS`, `watchOS`, `tvOS`, `Linux` |
| `arch()` | `i386`, `x86_64`, `arm`, `arm64` |
| `swift()` | `>=` followed by a version number |
| `canImport()` | A module name |
| `targetEnvironment()` | `simulator` |

#### Line Control Statement
A line control statement is used to specify a line number and filename that can be different from the line number and filename of the source code being compiled. Use a line control statement to change the source code location used by Swift for diagnostic and debugging purposes.
``` swift
#sourceLocation(file: filename, line: line number)
#sourceLocation()
```

#### Compile-Time Diagnostic Statement
A compile-time diagnostic statement causes the compiler to emit an error or a warning during compilation. 
``` swift
#error("error message")
#warning("warning message")
```

### Availability Condition
An availability condition is used as a condition of an `if`, `while`, and `guard` statement to query the availability of APIs at runtime, based on specified platforms arguments.
``` swift
if #available(platform_name, version, ..., *) {
    // statements to execute if the APIs are available
} else {
    // fallback statements to execute if the APIs are unavailable
}
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
func someFunction(argumentLabel parameterName: parameterType) {}
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

## Enumerations, Structures and Classes
Classes, structures, and enumerations can all define properties, methods and subscripts. (Stored properties are provided only by classes and structures).

### Enumerations
#### Associated Values
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

#### Raw Values
``` swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
```

#### Recursive Enumerations
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

### Structures
#### Memberwise Initializers for Structure Types
All structures have an automatically generated *memberwise initializer*
``` swift
struct Resolution {
    var width = 0
    var height = 0
}
let vga = Resolution(width: 640, height: 480)
```

### Classes
Classes have additional capabilities that structures don’t have:
- Inheritance enables one class to inherit the characteristics of another.
- Type casting enables you to check and interpret the type of a class instance at runtime.
- Deinitializers enable an instance of a class to free up any resources it has assigned.
- Reference counting allows more than one reference to a class instance.

### Properties
#### Stored Properties
A constant or variable that is stored as part of an instance of a particular class or structure
``` swift
struct FixedLengthRange {
    var firstValue: Int
    let length: Int
}
```

#### Lazy Stored Properties
A *lazy stored property* is a property whose initial value is not calculated until the first time it is used. You indicate a lazy stored property by writing the `lazy` modifier before its declaration.

#### Computed Properties
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
// square.origin is now at (10.0, 10.0)
```

#### Property Observers
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

#### Type Properties
You define type properties with the `static` keyword. For computed type properties for class types, you can use the `class` keyword instead to allow subclasses to override the superclass’s implementation.

### Methods
#### Mutating Methods
Modifying value types from within instance methods
``` swift
struct Point {
    var x = 0.0, y = 0.0
    mutating func moveBy(x deltaX: Double, y deltaY: Double) {
        x += deltaX
        y += deltaY
    }
}
var somePoint = Point(x: 1.0, y: 1.0)
somePoint.moveBy(x: 2.0, y: 3.0)
print("The point is now at (\(somePoint.x), \(somePoint.y))")   // The point is now at (3.0, 4.0)
```
Assigning to self within a mutating method
``` swift
enum TriStateSwitch {
    case off, low, high
    mutating func next() {
        switch self {
        case .off:
            self = .low
        case .low:
            self = .high
        case .high:
            self = .off
        }
    }
}
var ovenLight = TriStateSwitch.low
ovenLight.next()    // ovenLight: TriStateSwitch = high
ovenLight.next()    // ovenLight: TriStateSwitch = off
```

### Subscripts
``` swift
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
var matrix = Matrix(rows: 2, columns: 2)
matrix[0, 1] = 1.5
matrix[1, 0] = 3.2  // [0, 1.5, 3.2, 0]
```

### Optional Chaining
You specify optional chaining by placing a question mark (`?`) after the optional value on which you wish to call a property, method or subscript if the optional is non-`nil`. This is very similar to placing an exclamation mark (`!`) after an optional value to force the unwrapping of its value. The main difference is that optional chaining fails gracefully when the optional is `nil`, whereas forced unwrapping triggers a runtime error when the optional is `nil`.

## Inheritance
Swift classes do not inherit from a universal base class. Classes you define without specifying a superclass automatically become base classes for you to build upon.

### Overriding
``` swift
class Vehicle {
    var currentSpeed = 0.0
    var description: String {
        return "traveling at \(currentSpeed) miles per hour"
    }
}
class Car: Vehicle {
    var gear = 1
    override var description: String {
        return super.description + " in gear \(gear)"
    }
}
let car = Car()
car.currentSpeed = 25.0
car.gear = 3
print("Car: \(car.description)")    // Car: traveling at 25.0 miles per hour in gear 3
```

### Preventing Overrides
Use the `final` modifier to prevent a method, property, or subscript from being overridden and class from being subclassed.

## Initialization
### Customizing Initialization
``` swift
struct Celsius {
    var temperatureInCelsius: Double
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
    init(_ celsius: Double) {
        temperatureInCelsius = celsius
    }
}
let freezingPointOfWater = Celsius(fromKelvin: 273.15)
let bodyTemperature = Celsius(37.0)
```

### Class Inheritance and Initialization
#### Designated Initializers and Convenience Initializers
*Designated initializers* are the primary initializers for a class. A designated initializer fully initializes all properties introduced by that class and calls an appropriate superclass initializer to continue the initialization process up the superclass chain. Every class must have at least one designated initializer.
*Convenience initializers* are secondary, supporting initializers for a class. You can define a convenience initializer to call a designated initializer from the same class as the convenience initializer with some of the designated initializer’s parameters set to default values.

#### Initializer Delegation for Class Types
Three rules for delegation calls between initializers:
1. A designated initializer must call a designated initializer from its immediate superclass.
2. A convenience initializer must call another initializer from the same class.
3. A convenience initializer must ultimately call a designated initializer.

The above rules can be abbreviated as followed:
- Designated initializers must always delegate up.
- Convenience initializers must always delegate across.

#### Two-Phase Initialization
**Phase 1**
- A designated or convenience initializer is called on a class.
- Memory for a new instance of that class is allocated. The memory is not yet initialized.
- A designated initializer for that class confirms that all stored properties introduced by that class have a value. The memory for these stored properties is now initialized.
- The designated initializer hands off to a superclass initializer to perform the same task for its own stored properties.
- This continues up the class inheritance chain until the top of the chain is reached.
- Once the top of the chain is reached, and the final class in the chain has ensured that all of its stored properties have a value, the instance’s memory is considered to be fully initialized, and phase 1 is complete.

**Phase 2**
- Working back down from the top of the chain, each designated initializer in the chain has the option to customize the instance further. Initializers are now able to access self and can modify its properties, call its instance methods, and so on.
- Finally, any convenience initializers in the chain have the option to customize the instance and to work with self.

#### Automatic Initializer Inheritance
Assuming that you provide default values for any new properties you introduce in a subclass, the following two rules apply:
1. If your subclass doesn’t define any designated initializers, it automatically inherits all of its superclass designated initializers.
2. If your subclass provides an implementation of all of its superclass designated initializers—either by inheriting them as per rule 1, or by providing a custom implementation as part of its definition—then it automatically inherits all of the superclass convenience initializers.

#### Designated and Convenience Initializers in Action
``` swift
class Food {
    var name: String
    init(name: String) {
        self.name = name
    }
    convenience init() {
        self.init(name: "[Unnamed]")
    }
}

class RecipeIngredient: Food {
    var quantity: Int
    init(name: String, quantity: Int) {
        self.quantity = quantity
        super.init(name: name)
    }
    override convenience init(name: String) {
        self.init(name: name, quantity: 1)
    }
}

class ShoppingListItem: RecipeIngredient {
    var purchased = false
    var description: String {
        var output = "\(quantity) x \(name)"
        output += purchased ? " ✔" : " ✘"
        return output
    }
}

var breakfastList = [
    ShoppingListItem(),
    ShoppingListItem(name: "Bacon"),
    ShoppingListItem(name: "Eggs", quantity: 6),
]
breakfastList[0].name = "Orange juice"
breakfastList[0].purchased = true
for item in breakfastList {
    print(item.description)
}
// 1 x Orange juice ✔
// 1 x Bacon ✘
// 6 x Eggs ✘
```
Since `ShoppingListItem` provides a default value for all of the properties it introduces and does not define any initializers itself, it automatically inherits all of the designated and convenience initializers from its superclass.

The figure below shows the overall initializer chain for all three classes:
<img src="/blog/Swift-Features/DesignatedAndConvenienceInitializersInAction.png"  alt="Designated and Convenience Initializers in Action" style="width:576px;">

### Failable Initializers
A failable initializer creates an *optional* value of the type it initializes. You write `return nil` within a failable initializer to indicate a point at which initialization failure can be triggered.
``` swift
struct Animal {
    let species: String
    init?(species: String) {
        if species.isEmpty { return nil }
        self.species = species
    }
}
```

### Required Initializers
Write the `required` modifier before the definition of a class initializer to indicate that every subclass of the class must implement that initializer:
``` swift
class SomeClass {
    required init() {
        // initializer implementation goes here
    }
}
```

### Setting a Default Property Value with a Closure or Function
``` swift
class SomeClass {
    let someProperty: SomeType = {
        // create a default value for someProperty inside this closure
        // someValue must be of the same type as SomeType
        return someValue
    }()
}
```

### Deinitialization
A *deinitializer* is called immediately before a class instance is deallocated. Deinitializers are only available on class types.
``` swift
deinit {
    // perform the deinitialization
}
```

## Error Handling
In Swift, errors are represented by values of types that conform to the `Error` protocol. This empty protocol indicates that a type can be used for error handling.
There are four ways to handle errors in Swift: 
1. propagate the error from a function to the code that calls that function
2. handle the error using a do-catch statement
3. handle the error as an optional value
4. assert that the error will not occur

``` swift
enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

struct Item {
    var price: Int
    var count: Int
}

class VendingMachine {
    var inventory = [
        "Candy Bar": Item(price: 12, count: 7),
        "Chips": Item(price: 10, count: 4),
        "Pretzels": Item(price: 7, count: 11)
    ]
    var coinsDeposited = 0

    func vend(itemNamed name: String) throws {
        guard let item = inventory[name] else {
            throw VendingMachineError.invalidSelection
        }

        guard item.count > 0 else {
            throw VendingMachineError.outOfStock
        }

        guard item.price <= coinsDeposited else {
            throw VendingMachineError.insufficientFunds(coinsNeeded: item.price - coinsDeposited)
        }

        coinsDeposited -= item.price

        var newItem = item
        newItem.count -= 1
        inventory[name] = newItem

        print("Dispensing \(name)")
    }
}
```

### Propagating Errors Using Throwing Functions
Only throwing functions can propagate errors. Any errors thrown inside a nonthrowing function must be handled inside the function.
``` swift
let favoriteSnacks = [
    "Alice": "Chips",
    "Bob": "Licorice",
    "Eve": "Pretzels",
]
func buyFavoriteSnack(person: String, vendingMachine: VendingMachine) throws {
    let snackName = favoriteSnacks[person] ?? "Candy Bar"
    try vendingMachine.vend(itemNamed: snackName)
}
```

### Handling Errors Using Do-Catch
``` swift
var vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 8
do {
    try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
    print("Success! Yum.")
} catch VendingMachineError.invalidSelection {
    print("Invalid Selection.")
} catch VendingMachineError.outOfStock {
    print("Out of Stock.")
} catch VendingMachineError.insufficientFunds(let coinsNeeded) {
    print("Insufficient funds. Please insert an additional \(coinsNeeded) coins.")
} catch {
    print("Unexpected error: \(error).")
}
// Insufficient funds. Please insert an additional 2 coins.
```

### Converting Errors to Optional Values
Use `try?` to handle an error by converting it to an optional value. In the following code `x` and `y` have the same value and behavior:
``` swift
func someThrowingFunction() throws -> Int {
    // ...
}

let x = try? someThrowingFunction()

let y: Int?
do {
    y = try someThrowingFunction()
} catch {
    y = nil
}
```

### Disabling Error Propagation
``` swift
let photo = try! loadImage(atPath: "./Resources/John Appleseed.jpg")
```

### Specifying Cleanup Actions
You use a `defer` statement to execute a set of statements just before code execution leaves the current block of code. A `defer` statement defers execution until the current scope is exited.
``` swift
func processFile(filename: String) throws {
    if exists(filename) {
        let file = open(filename)
        defer {
            close(file)
        }
        while let line = try file.readline() {
            // Work with the file.
        }
        // close(file) is called here, at the end of the scope.
    }
}
```

## Type Casting
### Checking Type
Use the type check operator (`is`) to check whether an instance is of a certain subclass type.

### Downcasting
Use the type cast operator (`as?` or `as!`) to downcast an instance to the subclass 
``` swift
class MediaItem {
    var name: String
    init(name: String) {
        self.name = name
    }
}
class Movie: MediaItem {
    var director: String
    init(name: String, director: String) {
        self.director = director
        super.init(name: name)
    }
}
class Song: MediaItem {
    var artist: String
    init(name: String, artist: String) {
        self.artist = artist
        super.init(name: name)
    }
}

let library = [ // the type of "library" is inferred to be [MediaItem]
    Movie(name: "Casablanca", director: "Michael Curtiz"),
    Song(name: "Blue Suede Shoes", artist: "Elvis Presley"),
    Song(name: "The One And Only", artist: "Chesney Hawkes"),
    Movie(name: "Citizen Kane", director: "Orson Welles"),
]

for item in library {
    if let movie = item as? Movie {
        print("Movie: \(movie.name), dir. \(movie.director)")
    } else if let song = item as? Song {
        print("Song: \(song.name), by \(song.artist)")
    }
}
// Movie: Casablanca, dir. Michael Curtiz
// Song: Blue Suede Shoes, by Elvis Presley
// Song: The One And Only, by Chesney Hawkes
// Movie: Citizen Kane, dir. Orson Welles
```

### Type Casting for Any and AnyObject
`Any` can represent an instance of any type at all, including function types.
`AnyObject` can represent an instance of any class type.
``` swift
var things = [Any]()
things.append(0)
things.append(0.0)
things.append(42)
things.append(3.14159)
things.append("hello")
things.append((3.0, 5.0))
things.append(Movie(name: "Ghostbusters", director: "Ivan Reitman"))
things.append({ (name: String) -> String in "Hello, \(name)" })

for thing in things {
    switch thing {
    case 0 as Int:
        print("zero as an Int")
    case 0 as Double:
        print("zero as a Double")
    case let someInt as Int:
        print("an integer value of \(someInt)")
    case let someDouble as Double where someDouble > 0:
        print("a positive double value of \(someDouble)")
    case is Double:
        print("some other double value that I don't want to print")
    case let someString as String:
        print("a string value of \"\(someString)\"")
    case let (x, y) as (Double, Double):
        print("an (x, y) point at \(x), \(y)")
    case let movie as Movie:
        print("a movie called \(movie.name), dir. \(movie.director)")
    case let stringConverter as (String) -> String:
        print(stringConverter("Michael"))
    default:
        print("something else")
    }
}

// zero as an Int
// zero as a Double
// an integer value of 42
// a positive double value of 3.14159
// a string value of "hello"
// an (x, y) point at 3.0, 5.0
// a movie called Ghostbusters, dir. Ivan Reitman
// Hello, Michael
```

## Extensions
*Extensions* add new functionality to an existing class, structure, enumeration, or protocol type. This includes the ability to extend types for which you do not have access to the original source code (known as *retroactive modeling*).
Extensions in Swift can:
- Add computed instance properties and computed type properties
- Define instance methods and type methods
- Provide new initializers
- Define subscripts
- Define and use new nested types
- Make an existing type conform to a protocol

If you define an extension to add new functionality to an existing type, the new functionality will be available on all existing instances of that type, even if they were created before the extension was defined.

## Protocols
A *protocol* defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be *adopted* by a class, structure, or enumeration to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to *conform* to that protocol.

### Property Requirements
``` swift
protocol SomeProtocol {
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
}
```

### Protocols as Types
Protocols don’t actually implement any functionality themselves. Nonetheless, any protocol you create will become a fully-fledged type for use in your code.
Protocols can be used in many places where other types are allowed, including:
- As a parameter type or return type in a function, method, or initializer
- As the type of a constant, variable, or property
- As the type of items in an array, dictionary, or other container

``` swift
protocol RandomNumberGenerator {
    func random() -> Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 47.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy:m))
        return lastRandom / m
    }
}

class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}
// Random dice roll is 4
// Random dice roll is 5
// Random dice roll is 1
// Random dice roll is 6
// Random dice roll is 1
```

### Delegation
Delegation is a design pattern that enables a class or structure to hand off (or delegate) some of its responsibilities to an instance of another type. This design pattern is implemented by defining a protocol that encapsulates the delegated responsibilities, such that a conforming type (known as a delegate) is guaranteed to provide the functionality that has been delegated.
``` swift
protocol DiceGame {
    var dice: Dice { get }
    func play()
}

protocol DiceGameDelegate: AnyObject {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}

class SnakesAndLadders: DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board: [Int]
    init() {
        board = Array(repeating: 0, count: finalSquare + 1)
        board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
        board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
    }
    weak var delegate: DiceGameDelegate?
    func play() {
        square = 0
        delegate?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self)
    }
}

class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            print("Started a new game of Snakes and Ladders")
        }
        print("The game is using a \(game.dice.sides)-sided dice")
    }
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Rolled a \(diceRoll)")
    }
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns")
    }
}

let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegate = tracker
game.play()
// Started a new game of Snakes and Ladders
// The game is using a 6-sided dice
// Rolled a 4
// Rolled a 6
// Rolled a 4
// Rolled a 4
// Rolled a 5
// The game lasted for 5 turns
```

### Adding Protocol Conformance with an Extension
You can extend an existing type to adopt and conform to a new protocol, even if you don’t have access to the source code for the existing type.
``` swift
protocol TextRepresentable {
    var textualDescription: String { get }
}

extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides)-sided dice"
    }
}

extension Array: TextRepresentable where Element: TextRepresentable {
    var textualDescription: String {
        let itemsAsText = self.map { $0.textualDescription }
        return "[" + itemsAsText.joined(separator: ", ") + "]"
    }
}

var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
let myDice = [d6, d12]
print(myDice.textualDescription)    // [A 6-sided dice, A 12-sided dice]
```

### Class-Only Protocols
You can limit protocol adoption to class types (and not structures or enumerations) by adding the `AnyObject` protocol to a protocol’s inheritance list. Use a class-only protocol when the behavior defined by that protocol’s requirements assumes or requires that a conforming type has reference semantics rather than value semantics.
``` swift
protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol {
    // class-only protocol definition goes here
}
```

### Optional Protocol Requirements
You can define *optional requirements* for protocols, These requirements don’t have to be implemented by types that conform to the protocol.
You can apply the `optional` modifier only to protocols that are marked with the `objc` attribute.
``` swift
@objc protocol CounterDataSource {
    @objc optional func increment(forCount count: Int) -> Int
    @objc optional var fixedIncrement: Int { get }
}

class Counter {
    var count = 0
    var dataSource: CounterDataSource?
    func increment() {
        if let amount = dataSource?.increment?(forCount: count) {
            count += amount
        } else if let amount = dataSource?.fixedIncrement {
            count += amount
        }
    }
}


class TowardsZeroSource: NSObject, CounterDataSource {
    func increment(forCount count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count < 0 {
            return 1
        } else {
            return -1
        }
    }
}

counter.count = -4
counter.dataSource = TowardsZeroSource()
for _ in 1...5 {
    counter.increment()
    print(counter.count)
}
// -3
// -2
// -1
// 0
// 0
```

### Protocol Extensions
Protocols can be extended to provide method, initializer, subscript, and computed property implementations to conforming types. This allows you to define behavior on protocols themselves, rather than in each type’s individual conformance or in a global function.
``` swift
extension Collection where Element: Equatable {
    func allEqual() -> Bool {
        for element in self {
            if element != self.first {
                return false
            }
        }
        return true
    }
}

let equalNumbers = [100, 100, 100, 100, 100]
let differentNumbers = [100, 100, 200, 100, 200]
print(equalNumbers.allEqual())      // true
print(differentNumbers.allEqual())  // false
```

## Generics
### Generic Functions
``` swift
func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var someInt = 3
var anotherInt = 107
swapTwoValues(&someInt, &anotherInt)

var someString = "hello"
var anotherString = "world"
swapTwoValues(&someString, &anotherString)
```

### Type Parameters
Type parameters specify and name a placeholder type. In most cases, type parameters have descriptive names, such as `Key` and `Value` in `Dictionary<Key, Value>` and `Element` in `Array<Element>`.

### Generic Types
``` swift
struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

var stackOfStrings = Stack<String>()
stackOfStrings.push("uno")
stackOfStrings.push("dos")
stackOfStrings.push("tres")
let fromTheTop = stackOfStrings.pop()   // fromTheTop: String = "tres"
```

### Type Constraints
``` swift
func findIndex<T: Equatable>(of valueToFind: T, in array:[T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

let doubleIndex = findIndex(of: 9.3, in: [3.14159, 0.1, 0.25])                  // doubleIndex: Int? = nil
let stringIndex = findIndex(of: "Andrea", in: ["Mike", "Malcolm", "Andrea"])    // stringIndex: Int? = 2
```

### Associated Types
An *associated type* gives a placeholder name to a type that is used as part of the protocol.
``` swift
protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

struct Stack<Element>: Container {
    // original Stack<Element> implementation
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    // conformance to the Container protocol
    mutating func append(_ item: Element) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Element {
        return items[i]
    }
}
```
The type parameter `Element` is used as the type of the `append(_:)` method’s `item` parameter and the return type of the subscript. Swift can therefore infer that `Element` is the appropriate type to use as the `Item` for this particular container.

#### Extending an Existing Type to Specify an Associated Type
Swift’s `Array` type already provides an `append(_:)` method, a `count` property, and a subscript with an `Int` index to retrieve its elements. These three capabilities match the requirements of the `Container` protocol. This means that you can extend `Array` to conform to the `Container` protocol simply by declaring that `Array` adopts the protocol. 
``` swift
extension Array: Container {}
```

### Generic Where Clauses
``` swift
func allItemsMatch<C1: Container, C2: Container>
    (_ someContainer: C1, _ anotherContainer: C2) -> Bool
    where C1.Item == C2.Item, C1.Item: Equatable {

        if someContainer.count != anotherContainer.count {
            return false
        }

        for i in 0..<someContainer.count {
            if someContainer[i] != anotherContainer[i] {
                return false
            }
        }

        return true
}

extension Array: Container {}

var stackOfStrings = Stack<String>()
stackOfStrings.push("uno")
stackOfStrings.push("dos")
stackOfStrings.push("tres")

var arrayOfStrings = ["uno", "dos", "tres"]

allItemsMatch(stackOfStrings, arrayOfStrings)   // true
```

## Automatic Reference Counting
Swift provides two ways to resolve strong reference cycles when you work with properties of class type: weak references and unowned references. 
Use a weak reference when the other instance has a shorter lifetime—that is, when the other instance can be deallocated first. In contrast, use an unowned reference when the other instance has the same lifetime or a longer lifetime.

### Resolving Strong Reference Cycles Between Class Instances
#### Weak References
Because a weak reference does not keep a strong hold on the instance it refers to, it’s possible for that instance to be deallocated while the weak reference is still referring to it. Therefore, ARC automatically sets a weak reference to `nil` when the instance that it refers to is deallocated.
``` swift
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

var john: Person?
var unit4A: Apartment?

john = Person(name: "John Appleseed")
unit4A = Apartment(unit: "4A")

john!.apartment = unit4A
unit4A!.tenant = john

john = nil      // John Appleseed is being deinitialized
unit4A = nil    // Apartment 4A is being deinitialized
```

> In systems that use garbage collection, weak pointers are sometimes used to implement a simple caching mechanism because objects with no strong references are deallocated only when memory pressure triggers garbage collection. However, with ARC, values are deallocated as soon as their last strong reference is removed, making weak references unsuitable for such a purpose.

#### Unowned References
An unowned reference is expected to always have a value. As a result, ARC never sets an unowned reference’s value to `nil`, which means that unowned references are defined using nonoptional types.
``` swift
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit { print("\(name) is being deinitialized") }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) is being deinitialized") }
}

var john: Customer?
john = Customer(name: "John Appleseed")
john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)
john = nil
// Prints "John Appleseed is being deinitialized"
// Prints "Card #1234567890123456 is being deinitialized"
```

#### Unowned References and Implicitly Unwrapped Optional Properties
The `Person` and `Apartment` example shows a situation where two properties, both of which are allowed to be `nil`, have the potential to cause a strong reference cycle. This scenario is best resolved with a weak reference.
The `Customer` and `CreditCard` example shows a situation where one property that is allowed to be `nil` and another property that cannot be nil have the potential to cause a strong reference cycle. This scenario is best resolved with an unowned reference.
However, there is a third scenario, in which both properties should always have a value, and neither property should ever be `nil` once initialization is complete. In this scenario, it’s useful to combine an unowned property on one class with an implicitly unwrapped optional property on the other class.
``` swift
class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}

var country = Country(name: "Canada", capitalName: "Ottawa")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")   // Canada's capital city is called Ottawa
```

### Resolving Strong Reference Cycles for Closures
#### Defining a Capture List
``` swift
lazy var someClosure: (Int, String) -> String = {
    [unowned self, weak delegate = self.delegate!] (index: Int, stringToProcess: String) -> String in
    // closure body goes here
}
```

#### Weak and Unowned References
Define a capture in a closure as an unowned reference when the closure and the instance it captures will always refer to each other, and will always be deallocated at the same time.
Conversely, define a capture as a weak reference when the captured reference may become `nil` at some point in the future. Weak references are always of an optional type, and automatically become `nil` when the instance they reference is deallocated. This enables you to check for their existence within the closure’s body.
``` swift
class HTMLElement {
    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())  // <p>hello, world</p>
paragraph = nil             // p is being deinitialized
```

## Memory Safety
### Conflicting Access to In-Out Parameters
``` swift
var stepSize = 1

func increment(_ number: inout Int) {
    number += stepSize
}

increment(&stepSize)
// Error: conflicting accesses to stepSize
```

### Conflicting Access to Properties
``` swift
struct Player {
    var name: String
    var health: Int
    var energy: Int

    static let maxHealth = 10
    mutating func restoreHealth() {
        health = Player.maxHealth
    }
}

var holly = Player(name: "Holly", health: 10, energy: 10)
balance(&holly.health, &holly.energy)
// Error: conflicting accesses to properties of a structure that’s stored in a global variable
```
Memory safety is the desired guarantee, but exclusive access is a stricter requirement than memory safety—which means some code preserves memory safety, even though it violates exclusive access to memory. The compiler can prove that overlapping access to properties of a structure is safe if the following conditions apply:
- You’re accessing only stored properties of an instance, not computed properties or class properties.
- The structure is the value of a local variable, not a global variable.
- The structure is either not captured by any closures, or it’s captured only by nonescaping closures.

## Access Control
### Modules and Source Files
A *module* is a single unit of code distribution—a framework or application that is built and shipped as a single unit and that can be imported by another module with Swift’s `import` keyword.
A *source file* is a single Swift source code file within a module (in effect, a single file within an app or framework). Although it’s common to define individual types in separate source files, a single source file can contain definitions for multiple types, functions, and so on.

### Access Levels
Swift provides five different *access levels* for entities within your code.
- *Open access* and *public access* enable entities to be used within any source file from their defining module, and also in a source file from another module that imports the defining module. You typically use open or public access when specifying the public interface to a framework.
- *Internal access*(default access level) enables entities to be used within any source file from their defining module, but not in any source file outside of that module. You typically use internal access when defining an app’s or a framework’s internal structure.
- *File-private access* restricts the use of an entity to its own defining source file. Use file-private access to hide the implementation details of a specific piece of functionality when those details are used within an entire file.
- *Private access* restricts the use of an entity to the enclosing declaration, and to extensions of that declaration that are in the same file. Use private access to hide the implementation details of a specific piece of functionality when those details are used only within a single declaration.

Open access applies only to classes and class members, and it differs from public access as follows:
- Classes with public access, or any more restrictive access level, can be subclassed only within the module where they’re defined.
- Class members with public access, or any more restrictive access level, can be overridden by subclasses only within the module where they’re defined.
- Open classes can be subclassed within the module where they’re defined, and within any module that imports the module where they’re defined.
- Open class members can be overridden by subclasses within the module where they’re defined, and within any module that imports the module where they’re defined.

### Guiding Principle of Access Levels
No entity can be defined in terms of another entity that has a lower (more restrictive) access level. 
For example:
- A public variable can’t be defined as having an internal, file-private, or private type, because the type might not be available everywhere that the public variable is used.
- A function can’t have a higher access level than its parameter types and return type, because the function could be used in situations where its constituent types are unavailable to the surrounding code.

## Reference
### Declarations
#### Type Alias Declaration
A type alias declaration introduces a named alias of an existing type into your program.
``` swift
typealias name = existing_type
```

#### Declaration Modifiers
Declaration modifiers are keywords or context-sensitive keywords that modify the behavior or meaning of a declaration. You specify a declaration modifier by writing the appropriate keyword or context-sensitive keyword between a declaration’s attributes (if any) and the keyword that introduces the declaration.

`dynamic`: Apply this modifier to any member of a class that can be represented by Objective-C. When you mark a member declaration with the `dynamic` modifier, access to that member is always dynamically dispatched using the Objective-C runtime.

### Attributes
Attributes provide more information about a declaration or type. There are two kinds of attributes in Swift, those that apply to declarations and those that apply to types.
You specify an attribute by writing the `@` symbol followed by the attribute’s name and any arguments that the attribute accepts:
``` swift
@attribute name
@attribute name(attribute arguments)
```

#### Declaration Attributes
`available`: Apply this attribute to indicate a declaration’s lifecycle relative to certain Swift language versions or certain platforms and operating system versions.
You can use the `renamed` argument in conjunction with the `unavailable` argument and a type alias declaration to indicate to clients of your code that a declaration has been renamed.
``` swift
// First release
protocol MyProtocol {
    // protocol definition
}
// Subsequent release renames MyProtocol
protocol MyRenamedProtocol {
    // protocol definition
}

@available(*, unavailable, renamed: "MyRenamedProtocol")
typealias MyProtocol = MyRenamedProtocol
```
The shorthand syntax for `available` attributes allows for availability for multiple platforms to be expressed concisely.
``` swift
@available(iOS 10.0, macOS 10.12, *)
class MyClass {
    // class definition
}
```

`discardableResult`: Apply this attribute to a function or method declaration to suppress the compiler warning when the function or method that returns a value is called without using its result.

`inlinable`: Apply this attribute to a function, method, computed property, subscript, convenience initializer, or deinitializer declaration to expose that declaration’s implementation as part of the module’s public interface. The compiler is allowed to replace calls to an inlinable symbol with a copy of the symbol’s implementation at the call site.

`objc`: Apply this attribute to any declaration that can be represented in Objective-C. The `objc` attribute tells the compiler that a declaration is available to use in Objective-C code.
The `objc` attribute optionally accepts a single attribute argument, which consists of an identifier. The identifier specifies the name to be exposed to Objective-C for the entity that the `objc` attribute applies to. The example below exposes the getter for the `enabled` property of the `ExampleClass` to Objective-C code as `isEnabled` rather than just as the name of the property itself.
``` swift
class ExampleClass: NSObject {
    @objc var enabled: Bool {
        @objc(isEnabled) get {
            // Return the appropriate value
        }
    }
}
```

`UIApplicationMain`: Apply this attribute to a class to indicate that it’s the application delegate. Using this attribute is equivalent to calling the `UIApplicationMain` function and passing this class’s name as the name of the delegate class.

##### Declaration Attributes Used by Interface Builder
Interface Builder attributes are declaration attributes used by Interface Builder to synchronize with Xcode. Swift provides the following Interface Builder attributes: `IBAction`, `IBOutlet`, `IBDesignable`, and `IBInspectable`. Applying the Interface Builder attribute also implies the `objc` attribute.

#### Type Attributes
`autoclosure`: This attribute is used to delay the evaluation of an expression by automatically wrapping that expression in a closure with no arguments.

`convention`: Apply this attribute to the type of a function to indicate its calling conventions. The attribute arguments include `swift`, `block` and `c`.

`escaping`: Apply this attribute to a parameter’s type in a method or function declaration to indicate that the parameter’s value can be stored for later execution.

### Patterns
A *pattern* represents the structure of a single value or a composite value.

#### Optional Pattern
An *optional pattern* matches values wrapped in a `some(Wrapped)` case of an `Optional<Wrapped>` enumeration.
Because optional patterns are syntactic sugar for `Optional` enumeration case patterns, the following are equivalent:
``` swift
let someOptional: Int? = 42
// Match using an enumeration case pattern.
if case .some(let x) = someOptional {
    print(x)
}

// Match using an optional pattern.
if case let x? = someOptional {
    print(x)
}
```

The optional pattern provides a convenient way to iterate over an array of optional values in a `for-in` statement, executing the body of the loop only for non-`nil` elements.
``` swift
let arrayOfOptionalInts: [Int?] = [nil, 2, 3, nil, 5]
// Match only non-nil values.
for case let number? in arrayOfOptionalInts {
    print("Found a \(number)")
}
// Found a 2
// Found a 3
// Found a 5
```
