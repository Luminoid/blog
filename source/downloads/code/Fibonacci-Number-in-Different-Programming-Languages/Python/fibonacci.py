import sys


def fib(n):
    if n <= 1:
        return n

    a = 0
    b = 1

    for i in range(2, n + 1):
        c = a + b
        a = b
        b = c

    return b


if __name__ == '__main__':
    n = int(sys.argv[1])
    print(f"fib({n}) = {fib(n)}\n")
