(define-library (gorgos core)
   (import (scheme base))
   (export gfail? gchar gor glist glist-of goptional gpair
           make-gfail-object gfail g-error-explain
           gfail-internal)
   (begin
      (define-record-type <gfail>
        (make-gfail-object reason)
        gfail?
        (reason %gfail-reason))

      (define-record-type <greason>
        (make-greason type rest)
        greason?
        (type greason-type)
        (rest greason-rest))

      (define (gfail-internal type rest)
        (make-gfail-object (make-greason type rest)))

      (define *gfail-object* (make-gfail-object #f))
      (define gfail *gfail-object*)

      (define (g-parser-explain parser))

      (define (%calc-string-position input)
        (let loop ((i 0)
                   (line 1)
                   (col 0))
          (cond
            ((= i (string-length input)) `((line ,line) (colmn ,col) (char ,i)))
            ((char=? (string-ref input i) #\newline)
             (loop (+ i 1) (+ line 1) 0))
            (else (loop (+ i 1) line (+ col 1))))))

      (define (g-error-explain gfail . input-opt)
        (let ((reason (and (gfail? gfail)
                           (greason? (%gfail-reason gfail))
                           (%gfail-reason gfail)))
              (input (if (null? input-opt) #f (car input-opt))))
          (if reason
            (let* ((rest (and (greason-rest reason)
                              (not (string=? "" (greason-rest reason)))
                              (greason-rest reason)))
                   (read-input (and input rest
                                    (substring input 0
                                               (- (string-length input)
                                                  (string-length rest))))))
                `((pos ,(and read-input (%calc-string-position read-input)))
                  (explain ,(case (greason-type reason)
                                  ((no-input) "No input.")
                                  ((no-match) "No match.")
                                  (else #f)))))
            #f)))

      (define (gchar c)
        (lambda (input)
          (if (zero? (string-length input))
            (values (gfail-internal 'no-input "")  input)
            (let ((rchar (string-ref input 0)))
              (if (char=? rchar c)
                  (values c (substring input 1 (string-length input)))
                  (values (gfail-internal 'g-unmatch input) input))))))

      (define (goptional parser)
        (lambda (input)
           (let-values (((v ne) (parser input)))
              (if (gfail? v)
                (values '() input)
                (values v ne)))))

      (define (gor . parsers)
        (lambda (input)
           (let loop ((ps parsers))
             (if (null? ps)
               (values (gfail-internal 'no-match input) input)
               (let-values (((v ne) ((car ps) input)))
                  (if (gfail? v)
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
                  (if (gfail? v)
                    (values v input)
                    (loop (cdr ps) (cons v res) ne)))))))

      (define (glist-of parser)
        (lambda (input)
          (let loop ((next input)(res '()))
            (let-values (((v ne) (parser next)))
               (if (gfail? v)
                 (values (reverse res) ne)
                 (loop ne (cons v res)))))))

      (define (gpair parser1 parser2)
        (lambda (input)
          (let-values (((x next1) (parser1 input)))
            (if (gfail? x)
              (values x input)
              (let-values (((y next2) (parser2 next1)))
                  (if (gfail? y)
                    (values y input)
                    (values (cons x y) next2)))))))
      ))
