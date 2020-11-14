(include "../src/gorgos-core.scm")
(include "../src/gorgos-charset.scm")
(include "../src/gorgos-advance.scm")
(include "../src/gorgos-utils.scm")

(define-library (gorgos-sample simple-json-like)
   (import (scheme base) (scheme charset)
           (gorgos core) (gorgos charset) (gorgos advance) (gorgos utils))
   (export json-like-parser)
   (begin
      (define json-const
        (gor (gconst (gstring "true") #t)
             (gconst (gstring "false") #f)
             (gconst (gstring "null") '())))

      (define unsigned-integer-parser
        (gconv (glist (gcharset char-set:digit)
                      (glist-of (gcharset char-set:digit)))
               (lambda (x)
                 (string->number (list->string (cons (car x) (cadr x)))))))

      (define integer-parser
        (gconv (glist (goptional (gchar #\-))
                      unsigned-integer-parser)
               (lambda (x)
                 (if (null? x)
                   (cadr x)
                   (- (cadr x))))))

      (define json-like-parser
        (lambda (x)
           ((gor g-dq-string-parser list-parser json-const integer-parser dict-parser) x)))

      (define %dict-pair-parser;xxxx:fooo
         (gconv (glist g-dq-string-parser (gchar #\:) json-like-parser)
                (lambda (x)
                  (cons (car x)
                        (list-ref x 2)))))

      (define dict-parser
        (gconv (glist (gchar #\{)
                      %dict-pair-parser
                      (glist-of (glist (gchar #\,) %dict-pair-parser))
                      (gchar #\}))
               (lambda (x)
                 (cons (cadr x)
                       (map cadr (list-ref x 2))))))

      (define list-parser
        (gconv (glist (gchar #\[)
                      json-like-parser
                      (glist-of (glist (gchar #\,) json-like-parser))
                      (gchar #\]))
               (lambda (x)
                  (apply vector
                         (cons (cadr x) (map cadr (list-ref x 2)))))))))

;(import (scheme base) (scheme write) (gorgos-sample simple-json-like))
;(let-values (((value _) (json-like-parser "{\"abc\":[-12,34,\"def\"],\"ghi\":true}")))
;   (write value);(("\"abc\"" . #(-12 -34 "\"def\"")) ("\"ghi\"" . #t))
;   (newline))
