#lang racket/gui
(provide racket:text)

(require racket/class
         racket/gui/easy
         racket/gui/easy/operator
         framework)

(define racket:text-view%
  (class* racket:text% (view<%>)
    (init-field @code action font width height)
    (super-new)

    (define/augment (on-change)
      (action 'on-change (send this get-text)))

    (define/public (dependencies)
      (list @code))

    (define/public (create parent)
      (send this insert (obs-peek @code))
      (define canvas (new editor-canvas%
                          [parent parent]
                          [min-width width]
                          [min-height height]
                          [editor this]))
      canvas)

    (define/public (update v what val)
      (void))

    (define/public (destroy v)
      (void))))

(define (racket:text @code
                     [action #f]
                     #:font [font normal-control-font]
                     #:size [size '(400 400)])
  (match-define (list width height) size)
  (new racket:text-view%
       [@code @code]
       [action action]
       [font font]
       [width width]
       [height height]))

(module+ main
  (define @code
    (@ "#lang racket

(define (foo x)
  (add1 x))"))

  (define (update target)
    (λ (action text)
      (displayln action)
      (:= target text)))

  (render
   (window #:title "test racket:text"
           #:size '(800 400)
           (racket:text @code
                        (update @code)))))
