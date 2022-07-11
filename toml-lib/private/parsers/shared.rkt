#lang racket/base

(require racket/list
         racket/function
         racket/match
         racket/math

         "../parsack.rkt"
         "../misc.rkt"
         "../stx.rkt")

(provide (all-defined-out))

(define (has-bits-set? mask)
  (satisfy
   (λ (i)
     (define computed-mask (for/list ([c mask])
                             (match c
                               [#\0 #f]
                               [#\1 #t]
                               [_ (void)])))
     (for/and ([bit (in-list computed-mask)]
               [idx (in-range 7 -1 -1)])
       (or (not (boolean? bit))
           (eq? bit (bitwise-bit-set? i idx)))))
   #:read read-byte
   #:peek peek-byte))

(define (bytes->char . the-bytes)
  (string-ref (bytes->string/utf-8 (list->bytes the-bytes)) 0))

(define $non-ascii
  (<?>
   (try
    (<or>
     (pdo (b1 <- (has-bits-set? "110xxxxx"))
          (b2 <- (has-bits-set? "10xxxxxx"))
          (return (bytes->char b1 b2)))
     (pdo (b1 <- (has-bits-set? "1110xxxx"))
          (b2 <- (has-bits-set? "10xxxxxx"))
          (b3 <- (has-bits-set? "10xxxxxx"))
          (return (bytes->char b1 b2 b3)))
     (pdo (b1 <- (has-bits-set? "11110xxx"))
          (b2 <- (has-bits-set? "10xxxxxx"))
          (b3 <- (has-bits-set? "10xxxxxx"))
          (b4 <- (has-bits-set? "10xxxxxx"))
          (return (bytes->char b1 b2 b3 b4)))))
   "Valid non-ascii (UTF-8)"))