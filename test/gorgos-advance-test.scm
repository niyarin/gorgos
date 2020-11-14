(include "../src/gorgos-core.scm")
(include "../src/gorgos-charset.scm")
(include "../src/gorgos-advance.scm")

(import (scheme base)
        (scheme charset)
        (srfi 64)
        (gorgos core)
        (gorgos charset)
        (gorgos advance))

(begin;;g-dq-string-parser-test
   (test-begin "g-dq-string-parser-test")
   (let-values (((v next) (g-dq-string-parser "\"test\"hello")))
      (test-equal v "\"test\"")
      (test-equal next "hello"))
   (let-values (((v next) (g-dq-string-parser "abc\"test\"hello")))
      (test-assert (gfail-object? v)))
   (test-end "g-dq-string-parser-test"))
