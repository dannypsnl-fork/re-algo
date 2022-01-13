#lang racket
(provide (all-from-out racket)
         define
         let
         trace!
         dump)

(require syntax/parse/define
         (rename-in racket
                    [define origin-define]
                    [let origin-let]))

(define m (make-hash))
(define (trace! name val)
  (hash-set! m name (append (hash-ref m name '())
                            (list val))))
(define (dump)
  m)

(define-syntax-parser let
  [(_ loop ([n e] ...) body ...)
   #'(origin-let loop ([n e] ...)
                 (trace! 'n n) ...
                 body ...)]
  [(_ ([n e] ...) body ...)
   #'(origin-let ([n e] ...)
                 (trace! 'n n) ...
                 body ...)])

(define-syntax-parser define
  [(_ n:id e)
   #'(begin (origin-define n e)
            (trace! 'n n))]
  [(_ anyway ...)
   #'(origin-define anyway ...)])

(module reader syntax/module-reader re-algo/inspect)
