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

[Objective-C](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)
[Clang](http://clang.llvm.org/docs/)

## Minimize importing other header files in header
- Forward declare classes in a header and import their corresponding headers in an implementation
- Move the protocol-conformance declaration to the class-continuation category if possible

### @class vs. #import
Using forward declaring(`@class`) has following advantages:
- Defer the import to where it is required (implementation file), and decrease compile time
- Alleviate the problem of both classes referring to each other

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
Autosynthesis: Clang provides default synthesis of declared properties not declared @dynamic and not having user provided backing getter and setter methods.

### Property Attribute
``` objectivec
@property (nonatomic, readwrite, copy) NSString *name;
```

#### Memory-Management Semantic
**assign**: The setter is a simple assign operation used for scalar types, such as `CGFloat` or `NSInteger`.
**strong**: This designates that the property defines an owning relationship. When a new value is set, it is first retained, the old value is released, and then the value is set.
**weak**: This designates that the property defines a nonowning relationship. When a new value is set, it is not retained; nor is the old value released. This is similar to what `assign` does, but the value is also nilled out when the object pointed to by the property at any time is destroyed.
**unsafe_unretained**: This has the same semantics as `assign` but is used where the type is an object type to indicate a nonowning relationship (unretained) that is not nilled out (unsafe) when the target is destroyed, unlike `weak`.
**copy**: This designates on owning relationship similar to `strong`; however, instead of retaining the value, it is copied.

## Access Instance Variables
- Read data directly through instance variables internally; Write data through properties internally
- Read and write data directly through instance variables within initializers and `dealloc`
- Read data through properties when that data is being lazily initialized

## Class Cluster
``` objectivec
+ (UIButton)buttonWithType:(UIButtonType)buttonType;
```
- The Class Cluster pattern can be used to hide implementation detail behind an abstract base class.
- There is no init family method defined in the interface

## Associated Object
Associated Object can attach custom data to existing classes, but it should be used only when other approaches are not possible, since it can cause retain cycles.
``` objectivec
#import <objc/runtime.h>
static void *AlertViewKey = "AlertViewKey";
- (void)popUpAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Do you want to continue?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue", nil];
    void (^block)(NSInteger) = ^(NSInteger buttonIndex){
        if (buttonIndex == 0) {
            [self doCancel];
        } else {
            [self deContinue];
        }
    };

    object_setAssociatedObject(alert, AlertViewKey, block, OBJC_ASSOCIATION_COPY);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)(NSInteger) = object_getAssociatedObject(alertView, AlertViewKey);
    block(buttonIndex);
}
```
