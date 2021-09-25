(include "../src/core.scm")
(include "../src/gorgos-charset.scm")
(include "../src/gorgos-utils.scm")
(include "../src/gorgos-advance.scm")

(define-library (gorgos-sample calculator)
   (import (scheme base) (scheme charset)
           (gorgos core) (gorgos charset) (gorgos advance) (gorgos utils))
   (export expr-parser)
   (begin
     (define expr-parser
        (gconv (gpair term-parser
                        (goptional (glist (gor (gchar #\+) (gchar #\-)) expr-parser)))
        (lambda (res)
          (cond
            ((null? (cdr res)) (car res))
            ((eq? (cadr res) #\+) (+ (car res) (list-ref res 2)))
            ((eq? (cadr res) #\-) (- (car res) (list-ref res 2)))
            (else res))))

     (define term-parser
       (gconv (gpair factor-parser
                     (goptional (glist (gor (gchar #\*) (gchar #\/)) term-parser)))
              (lambda (res)
                (cond
                  ((null? (cdr res)) (car res))
                  ((eq? (cadr res) #\*) (* (car res) (list-ref res 2)))
                  ((eq? (cadr res) #\/) (/ (car res) (list-ref res 2)))
                  (else res)))))

     (define unsigned-integer-parser
        (gconv (gpair (gcharset char-set:digit)
                      (glist-of (gcharset char-set:digit)))
               (lambda (x) (string->number (list->string x)))))

     (define paren-parser
       (gconv (glist (gchar #\()
                     expr-parser
                     (gchar #\)))
              cadr))

     (define factor-parser
       (gor unsigned-integer-parser paren-parser))))

;(import (scheme base) (scheme write) (gorgos-sample calculator))
;(let-values (((v next) (expr-parser "1+2*(3+4)-21/7")))
;  (write v)(newline))
