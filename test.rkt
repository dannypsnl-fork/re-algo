#lang racket/base

(define (binary-search key l)
  (let loop ([low 0]
             [high (sub1 (length l))])
    (define c (<= low high))
    (define mid (floor (/ (+ low high) 2)))
    (define v (list-ref l mid))
    (cond
      [(and (< v key)
            c)
       (loop (add1 mid) high)]
      [(and (> v key)
            c)
       (loop low (sub1 mid))]
      [c mid]
      [else -1])))
