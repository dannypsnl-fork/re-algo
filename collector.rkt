#lang racket/gui

(require drracket/check-syntax
         syntax/modread)

(define collector%
  (class (annotations-mixin object%)
    (init-field src text)

    (define ids (mutable-set))

    (define/override (syncheck:find-source-object stx)
      (and (equal? src (syntax-source stx))
           src))

    (define/override (syncheck:add-arrow/name-dup
                      start-src-obj start-left start-right
                      end-src-obj end-left end-right
                      actual? level require-arrow? name-dup?)
      (define id (string->symbol (send text get-text end-left end-right)))
      (unless require-arrow?
        (set-add! ids (list id start-left start-right))))

    (define/public (build-record)
      ids)
    (super-new)))

(define (collect-from path)
  (define text (new text%))
  (send text load-file path)
  (define collector
    (new collector%
         [src path]
         [text text]))
  (define-values (src-dir file dir?)
    (split-path path))
  (define in (open-input-string (send text get-text)))

  (define ns (make-base-namespace))
  (define-values (add-syntax done)
    (make-traversal ns src-dir))
  (parameterize ([current-annotations collector]
                 [current-namespace ns]
                 [current-load-relative-directory src-dir])
    (define stx (expand (with-module-reading-parameterization
                          (λ () (read-syntax path in)))))
    (add-syntax stx))
  (send collector build-record))

(collect-from (normalize-path "./test.rkt"))
