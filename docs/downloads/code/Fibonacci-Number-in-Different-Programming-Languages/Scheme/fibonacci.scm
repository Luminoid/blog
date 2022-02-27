(define (fib n)
  (define (iter a b n)
    (if (<= n 1)
        b
        (iter b (+ a b) (- n 1))))
  (iter 0 1 n))
