(include "../src/gorgos-core.scm")
(include "../src/gorgos-charset.scm")

(import (scheme base)
        (scheme charset)
        (srfi 64)
        (gorgos core)
        (gorgos charset))

(begin;;gchar-test
   (test-begin "gcharset-test")
   (let-values (((v next) ((gcharset (char-set #\t #\a)) "test")))
      (test-eq v #\t)
      (test-equal next "est"))

   (let-values (((v next) ((gcharset (char-set #\a #\b)) "test")))
      (test-assert (gfail-object? v)))
   (test-end "gcharset-test"))
