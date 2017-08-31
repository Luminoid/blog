---
title: Sorting Algorithm Analysis
date: 2017-06-12 19:51:09
updated:
categories: Algorithm
tags: Sorting algorithm
keywords:
  - Sorting algorithm
  - time complexity
---

|Algorithm | Worst-case running time | Average-case / expected running time | In-place | Stable |
| :------- | :------- | :------ | :------ | :------ |
| Insertion sort[^1] | $\Theta(n^2)$ | $\Theta(n^2)$ | Yes | Yes |
| Shell sort | $\Theta(n^2)$ |  | Yes | No |
| Selection sort | $\Theta(n^2)$ | $\Theta(n^2)$ | Yes | No |
| Heapsort | $\Theta(nlgn)$ | $\Theta(nlgn)$ | Yes | No |
| Bubble sort | $\Theta(n^2)$ | $\Theta(n^2)$ | Yes | Yes |
| Quicksort | $\Theta(n^2)$ | $\Theta(nlgn)$ (expected) | Yes | No |
| Counting sort | $\Theta(k+n)$ | $\Theta(k+n)$ | No | Yes |
| Radix sort[^2] | $\Theta(d(n+k))$ | $\Theta(d(n+k))$ | No  | Yes |
| Bucket sort | $\Theta(n^2)$ | $\Theta(n)$ (average-case) | No | Yes |
| Merge sort | $\Theta(nlgn)$ | $\Theta(nlgn)$ | No | Yes |

<!-- more -->
[^1]: n: the number of items to sort.
[^2]: For radix sort, each item is a d-digit number, where each digit takes on k possible values.
