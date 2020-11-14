(define-library (gorgos core)
   (import (scheme base))
   (export gfail-object? gchar gor glist glist-of goptional gpair
           make-gfail-object gfail)
   (begin
      (define-record-type <gfail-object>
          (make-gfail-object)
          gfail-object?)

      (define *gfail-object* (make-gfail-object))
      (define gfail *gfail-object*)

      (define (gchar c)
        (lambda (input)
          (if (zero? (string-length input))
            (values *gfail-object* input)
            (let ((rchar (string-ref input 0)))
              (if (char=? rchar c)
                  (values c (substring input 1 (string-length input)))
                  (values *gfail-object* input))))))

      (define (goptional parser)
        (lambda (input)
           (let-values (((v ne) (parser input)))
              (if (gfail-object? v)
                (values '() input)
                (values v ne)))))

      (define (gor . parsers)
        (lambda (input)
           (let loop ((ps parsers))
             (if (null? ps)
               (values *gfail-object* input)
               (let-values (((v ne) ((car ps) input)))
                  (if (gfail-object? v)
                    (loop (cdr ps))
                    (values v ne)))))))

      (define (glist . parsers)
        (lambda (input)
          (let loop ((ps parsers)
                     (res '())
                     (next input))
            (if (null? ps)
              (values (reverse res) next)
              (let-values (((v ne) ((car ps) next)))
                  (if (gfail-object? v)
                    (values *gfail-object* input)
                    (loop (cdr ps) (cons v res) ne)))))))

      (define (glist-of parser)
        (lambda (input)
          (let loop ((next input)(res '()))
            (let-values (((v ne) (parser next)))
               (if (gfail-object? v)
                 (values (reverse res) ne)
                 (loop ne (cons v res)))))))

      (define (gpair parser1 parser2)
        (lambda (input)
          (let-values (((x next1) (parser1 input)))
            (if (gfail-object? x)
              (values x input)
              (let-values (((y next2) (parser2 next1)))
                  (if (gfail-object? y)
                    (values y input)
                    (values (cons x y) next2)))))))
      ))
