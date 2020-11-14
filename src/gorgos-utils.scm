;;need to include gorgos-core.scm
(define-library (gorgos utils)
   (import (scheme base)
           (gorgos core))
   (export gconst)
   (begin
     (define (gconst parser const-object)
       (lambda (x)
          (let-values (((v next) (parser x)))
            (if (gfail-object? v)
              (values v next)
              (values const-object next)))))))
