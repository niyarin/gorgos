(define-library (gorgos core)
   (import (scheme base) (scheme charset))
   (export gfail? gchar gnot-char gor glist glist-f glist-of goptional gpair
           make-gfail-object gfail g-error-explain
           gfail-internal gfirst-char)
   (begin
      (define-record-type <gfail>
        (make-gfail-object reason)
        gfail?
        (reason %gfail-reason))

      (define-record-type <greason>
        (make-greason type rest first-char)
        greason?
        (type greason-type)
        (rest greason-rest)
        (first-char greason-first-char))

      (define (gfail-internal type rest)
        (make-gfail-object (make-greason type rest #f)))

      (define (gfail-first-char chr)
        (make-gfail-object (make-greason 'check-first-char "" chr)))

      (define *gfail-object* (make-gfail-object #f))
      (define gfail *gfail-object*)

      (define *state* (make-parameter #f))

      (define (gfirst-char parser)
        (parameterize ((*state* 'check-first-char))
          (let-values (((err rest) (parser "")))
            (and (gfail? err)
                 (%gfail-reason err)
                 (greason-first-char (%gfail-reason err))))))

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
          (cond
            ((eq? (*state*) 'check-first-char) (values (gfail-first-char c) ""))
            ((zero? (string-length input)) (values (gfail-internal 'no-input "")  input))
            (else
              (let ((rchar (string-ref input 0)))
                (if (char=? rchar c)
                    (values c (substring input 1 (string-length input)))
                    (values (gfail-internal 'g-unmatch input) input)))))))

      (define (gnot-char c);;untested
        (lambda (input)
          (if (zero? (string-length input))
            (values (gfail-internal 'no-input "")  input)
            (let ((rchar (string-ref input 0)))
              (if (not (char=? rchar c))
                  (values rchar (substring input 1 (string-length input)))
                  (values (gfail-internal 'g-unmatch input) input))))))

      (define (goptional parser)
        (lambda (input)
           (let-values (((v ne) (parser input)))
              (if (gfail? v)
                (values '() input)
                (values v ne)))))

      (define (%gor input parsers)
         (let loop ((ps parsers))
           (if (null? ps)
             (values (gfail-internal 'no-match input) input)
             (let-values (((v ne) ((car ps) input)))
                (if (gfail? v)
                  (loop (cdr ps))
                  (values v ne))))))

      (define (%gor-first-char parsers)
        (let loop ((ps parsers)
                   (res (char-set)))
          (if (null? ps)
            (gfail-first-char res)
            (let ((fc (gfirst-char (car ps))))
              (cond
                ((char? fc)
                 (loop (cdr ps)
                       (char-set-adjoin res fc)))
                (else
                  (loop (cdr ps)
                        (char-set-union res fc))))))))

      (define-syntax gor
        (syntax-rules ()
          ((_ _parsers ...)
            (lambda (input)
              (let ((parsers (list _parsers ...)))
                (cond
                  ((eq? (*state*) 'check-first-char)
                   (values (%gor-first-char parsers) ""))
                  (else (%gor input parsers))))))))

      (define (%glist input parsers)
          (let loop ((ps parsers)
                     (res '())
                     (next input))
            (if (null? ps)
              (values (reverse res) next)
              (let-values (((v ne) ((car ps) next)))
                  (if (gfail? v)
                    (values v input)
                    (loop (cdr ps) (cons v res) ne))))))

      (define (glist-f . parsers)
        (lambda (input)
          (%glist input parsers)))

      (define-syntax glist
         (syntax-rules ()
            ((_ in ...)
             (lambda (input)
               (%glist input (list in ...))))))

      (define (glist-of parser)
        (lambda (input)
          (let loop ((next input)(res '()))
            (let-values (((v ne) (parser next)))
               (if (gfail? v)
                 (values (reverse res) ne)
                 (loop ne (cons v res)))))))


      (define (gpair% input parser1 parser2)
        (let-values (((x next1) (parser1 input)))
          (if (gfail? x)
            (values x input)
            (let-values (((y next2) (parser2 next1)))
                (if (gfail? y)
                  (values y input)
                  (values (cons x y) next2))))))

      (define-syntax gpair
        (syntax-rules ()
          ((_ parser1 parser2)
           (lambda (input)
             (gpair% input parser1 parser2)))))))
