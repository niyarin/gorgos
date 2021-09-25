;;need to include gorgos-core.scm
(define-library (gorgos utils)
   (import (scheme base)
           (gorgos core))
   (export gwrap gconst gconv)
   (begin
     (define-syntax gwrap
      (syntax-rules ()
         ((_ (val-s next-s) parser body)
          (lambda (x)
            (let-values (((val-s next-s) (parser x)))
               (if (gfail? val-s)
                  (values val-s next-s)
                  (values body next-s)))))))

     (define (gconst parser const-object)
       (gwrap (v next)
         parser
         const-object))

    (define (gconv parser proc)
      (gwrap (v next)
         parser
         (proc v)))))
