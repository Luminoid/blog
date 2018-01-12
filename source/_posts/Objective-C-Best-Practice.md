---
title: Objective-C Best Practice
date: 2018-01-03 23:58:17
updated:
categories: iOS
tags: Objective-C
keywords: Objective-C
---

Collecting from *Effective Objective-C 2.0 52 Specific Ways to Improve Your iOS and OS X Programs*

<!-- TOC -->

## Minimize importing other header files in header
- Foward declare classes in a header and import their corresponding headers in an implementation
- Move the protocol-conformance declaration to the class-continuation category if possible

### @class vs. #import
Using forward declaring(`@class`) has following advantages:
- Defer the import to where it is required (implementation file), and decrease compile time
- Alleviate the problem of both classes refferring to each other

<!-- more -->

## Use Literal Syntax over the equivalent methods
Good Ways
``` objectivec
NSNumber *intNum = @1;
NSNumber *floatNum = @1.2f;
NSNumber *doubleNum = @1.23;
NSArray *arr = @[@"a", @"bb", @"ccc"];
NSString *item = arr[1];
NSDictionary *dict = @{@"Name" : @"Tom",
                       @"Age" : @20};
NSString *name = dict[@"Name"];
```

Bad Ways
``` objectivec
NSNumber *num = [NSNumber numberWithInt:1];
NSArray *arr = [NSArray arrayWithObjects:@"a", @"bb", @"ccc", nil];
NSString *item = [arr objectAtIndex:1];
NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Tom", @"Name",
                          @20, @"Age",
                          nil];
NSString *name = [dict objectForKey:@"Name"];
```

## Use Typed Constants over Preprocessor #define
### Translation-unit Constant
``` objectivec
// .m
static const NSTimeInterval kAnimationDuration = 0.3;
```
`static`: The constant will not be exposed in the global symbol table.
### Global Constant
``` objectivec
// .h
extern const NSTimeInterval ClassNamePrefixAnimationDuration;
// .m
const NSTimeInterval ClassNamePrefixAnimationDuration = 0.3;
```

## Use Enumerations for States, Options and Status Code
### Normal Enumeration type
``` objectivec
typedef NS_ENUM(NSUInteger, ConnectionState) {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected,
};
```
### Enumeration for options
``` objectivec
typedef NS_OPTIONS(NSUInteger, PermittedDirection) {
    PermittedDirectionUp    = 1 << 0,
    PermittedDirectionDown  = 1 << 1,
    PermittedDirectionLeft  = 1 << 2,
    PermittedDirectionRight = 1 << 3,
};
```

## Property
### Declared property
``` objectivec
// .h
@property (<#attributes#>) <#type#> <#name#>; // Declare Property
// .m
@synthesize // Create implementations that match the specification you gave in the property declaration
@dynamic    // Suppress a warning if the compiler can’t find an implementation of accessor methods
```
