(define-library (gorgos advance)
   (import (scheme base) (scheme charset)
           (gorgos core) (gorgos charset))
   (export g-dq-string-parser gstring )
   (begin
     (define (gstring str)
        (lambda (input)
          (if (or (< (string-length input) (string-length str))
                  (not (string=? str
                                 (substring input 0 (string-length str)))))
            (values gfail input)
            (values str (substring input (string-length str) (string-length input))))))

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
