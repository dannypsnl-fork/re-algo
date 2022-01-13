#lang racket/base
(require racket/match
         racket/string
         racket/format
         racket/gui/easy
         racket/gui/easy/operator
         racket/sandbox
         (prefix-in gui: racket/gui)
         "racket-text.rkt")

(define user-eventspace
  (parameterize ([current-custodian (make-custodian)]
                 [current-namespace (gui:make-gui-namespace)])
    (gui:make-eventspace)))

(define @code
  (@ "(define (binary-search key l)
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
      [else -1])))"))
(define @test
  (@ "(binary-search 2 (list 1 2 5 6 9 10 15))"))

(define @result
  (obs-debounce
   #:duration 500
   (obs-combine
    (λ (code test)
      (define eval
        (parameterize ([sandbox-output 'string]
                       [sandbox-error-output 'string]
                       ;; print error to error-output
                       [sandbox-propagate-exceptions #f]
                       ;; allow GUI
                       [sandbox-gui-available #t]
                       [sandbox-path-permissions `((read ,(current-directory)))]
                       [gui:current-eventspace user-eventspace])
          (make-evaluator 're-algo/inspect code)))
      (define r (eval test))
      (define local-vars
        (hash-map (eval "(dump)")
                  (λ (name vals)
                    (format "~a = ~a\n" name
                            (string-join (map ~a vals) "|")))))
      (format "~areturn ~a"
              (apply string-append local-vars)
              r))
    @code
    @test)))

(define font-pragmata (font "PragmataPro Mono Liga" 14))
(define (update target)
  (λ (action text)
    (:= target text)))

(render
 (window
  #:title "re-algo"
  #:size '(800 500)
  (hpanel (racket:text
           #:font font-pragmata
           @code
           (update @code))
          (vpanel (input
                   #:font font-pragmata
                   @test
                   (update @test))
                  (input
                   #:font font-pragmata
                   #:margin '(0 0)
                   #:stretch '(#t #t)
                   @result)))))

