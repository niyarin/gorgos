(define-library (gorgos advance)
   (import (scheme base) (scheme charset)
           (gorgos core) (gorgos charset))
   (export g-dq-string-parser)
   (begin
     (define %g-dq-string-parser
       (glist (gchar #\")
              (glist-of (gnotcharset (char-set #\")))
              (gchar #\")))

     (define (g-dq-string-parser input)
       (let-values (((v next)
                     (%g-dq-string-parser input)))
         (if (gfail-object? v)
            (values v input)
            (values (string-append "\"" (list->string (cadr v)) "\"")
                    next))))
     ))
