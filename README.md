# Gorgos
[WIP] Parser combinator for Scheme.

This library is in the alpha version and will undergo breaking changes in the future.

## examples
This is an example of an unsinged integer parser.

In Gorgos, you can use (scheme charset).
```scheme
(define unsigned-integer-parser
   (gconv (gpair (gcharset char-set:digit)
                 (glist-of (gcharset char-set:digit)))
          (lambda (x) (string->number (list->string x)))))
```


This is an example of creating an integer-parser using the previous unsigned-integer.
```scheme
(define integer-parser
   (gconv (gpair (goptional (gchar #\-))
                 unsigned-integer-parser)
          (lambda (x)
             (if (null? (car x)) (cdr x) (- (cdr x))))))
```
See the examples directory for details.
