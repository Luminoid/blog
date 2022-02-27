fun fib n = 
    let fun iter (a, b, n) = if n <= 1 then b else iter (b, a + b, n - 1)
    in 
        iter(0, 1, n)
    end

val n_str = hd (CommandLine.arguments())
val n = valOf (Int.fromString n_str)
val res = fib n
val _ = print ("fib(" ^ Int.toString n ^ ") = " ^ Int.toString res)
val _ = OS.Process.exit(OS.Process.success)
