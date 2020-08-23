---
title: 'RxSwift Concepts'
date: 2018-09-24 14:55:56
updated:
categories: iOS
tags:
- Rx
- Swift
- RxSwift
- WIP
---

## ReactiveX
http://reactivex.io/

Observables fill the gap by being the ideal way to access asynchronous sequences of multiple items.
|               | single items          | multiple items            |
|---------------|-----------------------|---------------------------|
| synchronous   | `T getData()`         | `Iterable<T> getData()`   |
| asynchronous  | `Future<T> getData()` | `Observable<T> getData()` |


An Observable is the asynchronous/push [dual](https://en.wikipedia.org/wiki/Dual_(category_theory)) to the synchronous/pull Iterable
| event             | Iterable (pull)       | Observable (push)     |
|-------------------|-----------------------|-----------------------|
| retrieve data     | `T next()`            | `onNext(T)`           |
| discover error    | throws `Exception`    | `onError(Exception)`  |
| complete          | `!hasNext()`          | `onCompleted()`       |
