(include "../src/core.scm")
(include "../src/gorgos-utils.scm")

(import (scheme base)
        (srfi 64)
        (gorgos core) (gorgos utils))

(begin;;gconst-test
   (test-begin "gconst-test")
   (let-values (((v next) ((gconst (gchar #\t) 'character-t) "test")))
      (test-eq v 'character-t)
      (test-equal next "est"))
   (let-values (((v next) ((gconst (gchar #\t) 'character-t) "hello")))
      (test-assert (gfail? v)))
   (test-end "gconst-test"))

(begin;;gconv-test
   (test-begin "gconv-test")
   (let-values (((v next) ((gconv (gchar #\t) char->integer) "test")))
      (test-eq v (char->integer #\t))
      (test-equal next "est"))
   (let-values (((v next) ((gconv (gchar #\t) char->integer) "hello")))
      (test-assert (gfail? v)))
   (test-end "gconv-test"))
