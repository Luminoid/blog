function fib(n) {
    if (n <= 1) {
        return n
    }

    var a = 0
    var b = 1

    for (let i = 2; i <= n; i++) {
        c = a + b
        a = b
        b = c
    }
    return b
}

const n = process.argv[2]
console.log(`fib(${n}) = ${fib(n)}\n`)
