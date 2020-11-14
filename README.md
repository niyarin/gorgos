# Gorgos
[WIP] Parser combinator for Scheme.

This library is in the alpha version and will undergo breaking changes in the future.

## example
This is an example of an unsinged integer parser.

In Gorgos, you can use (scheme charset).
```scheme
(define unsigned-integer-parser
   (gconv (glist (gcharset char-set:digit)
                 (glist-of (gcharset char-set:digit)))
          (lambda (x)
             (string->number (list->string (cons (car x) (cadr x)))))))
```


This is an example of creating an integer-parser using the previous unsigned-integer.
```scheme
(define integer-parser
   (gconv (glist (goptional (gchar #\-))
                 unsigned-integer-parser)
          (lambda (x)
             (if (null? x)
               (cadr x)
               (- (cadr x))))))
```
See the example directory for details.
