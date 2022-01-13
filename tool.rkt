#lang racket/base
(require racket/gui/easy
         racket/gui/easy/operator
         racket/sandbox
         (prefix-in gui: racket/gui))

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
      (cond
        [(void? r) ""]
        [else (format "~a" r)]))
    @code
    @test)))

(define win
  (window #:title "re-algo"
          #:size '(800 400)
          (hpanel (input #:margin '(0 0)
                         #:stretch '(#t #t)
                         @code
                         (λ (action text)
                           (:= @code text)))
                  (vpanel (input @test
                                 (λ (action text)
                                   (:= @test text)))
                          (input #:margin '(0 0)
                                 #:stretch '(#t #t)
                                 @result)))))

(render win)
