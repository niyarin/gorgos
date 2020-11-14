;;need to include gorgos-core.scm

(define-library (gorgos charset)
   (import (scheme base)
           (scheme charset)
           (gorgos core))
   (export gcharset)
   (begin
     (define (gcharset charset)
        (lambda (input)
          (if (zero? (string-length input))
            (values gfail input)
            (let ((rchar (string-ref input 0)))
               (if (char-set-contains? charset rchar)
                  (values rchar (substring input 1 (string-length input)))
                  (values gfail input))))))))
