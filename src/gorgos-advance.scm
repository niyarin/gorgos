(define-library (gorgos advance)
   (import (scheme base) (scheme charset)
           (gorgos core) (gorgos charset) (gorgos utils))
   (export g-dq-string-parser gstring )
   (begin
     (define (gstring str)
        (lambda (input)
          (if (or (< (string-length input) (string-length str))
                  (not (string=? str
                                 (substring input 0 (string-length str)))))
            (values (gfail-internal 'no-match input)
                    input)
            (values str (substring input (string-length str) (string-length input))))))

     (define g-dq-string-parser
       (gconv (glist (gchar #\")
                     (glist-of (gnotcharset (char-set #\")))
                     (gchar #\"))
              (lambda (v)
                (string-append "\"" (list->string (cadr v)) "\""))))
     ))
