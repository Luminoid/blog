object Fibonacci {
  def fib(n: Int): Int = {
    if (n <= 1) {
      return n
    }

    var a: Int = 0
    var b: Int = 1

    for (_ <- 2 to n) {
      val c = a + b
      a = b
      b = c
    }
    b
  }

  def main(args: Array[String]): Unit = {
    val n = args(0).toInt
    println(s"fib(${n}) = ${fib(n)}")
  }
}
