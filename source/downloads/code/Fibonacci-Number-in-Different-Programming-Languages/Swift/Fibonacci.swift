import Foundation

func fib(_ n: Int) -> Int {
    if (n <= 1) {
        return n
    }
    
    var a = 0
    var b = 1
    
    for _ in 2...n {
        let c = a + b
        a = b
        b = c
    }
    return b
}

let args = CommandLine.arguments
if args.count == 2, let n = Int(args[1]) {
    print("fib(\(n)) = \(fib(n))")
} else {
    print("Usage: swift fibonacci.swift <number>")
}
