#lang racket/base
(require racket/gui/easy
         racket/gui/easy/operator
         racket/sandbox
         (prefix-in gui: racket/gui)
         "racket-text.rkt")

(define user-eventspace
  (parameterize ([current-custodian (make-custodian)]
                 [current-namespace (gui:make-gui-namespace)])
    (gui:make-eventspace)))

(define @code
  (@ "#lang racket

(define (foo x)
  (add1 x))"))
(define @test
  (@ "(foo 2)"))

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
          (make-module-evaluator code)))
      (define r (eval test))
      (format "return ~a" r))
    @code
    @test)))

(define font-pragmata (font "PragmataPro Mono Liga" 14))
(define (update target)
  (λ (action text)
    (:= target text)))

(render
 (window #:title "re-algo"
         #:size '(800 400)
         (hpanel (racket:text #:font font-pragmata
                              @code
                              (update @code))
                 (vpanel (input #:font font-pragmata
                                @test
                                (update @test))
                         (input #:margin '(0 0)
                                #:stretch '(#t #t)
                                @result)))))
