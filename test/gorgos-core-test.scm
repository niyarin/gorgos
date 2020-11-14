(include "../src/gorgos-core.scm")

(import (scheme base)
        (srfi 64)
        (gorgos core))

(begin;;gchar-test
   (test-begin "gchar-test")
   (let-values (((v next) ((gchar #\t) "test")))
      (test-eq v #\t)
      (test-equal next "est"))

   (let-values (((v next) ((gchar #\t) "hello")))
      (test-assert (gfail-object? v)))

   (test-end "gchar-test"))

(begin;gor-test
   (test-begin "gor-test")
   (let ((parser (gor (gchar #\t) (gchar #\h))))
      (let-values (((v next) (parser "test")))
         (test-eq v #\t)
         (test-equal next "est")))

   (let ((parser (gor (gchar #\h) (gchar #\t))))
      (let-values (((v next) (parser "test")))
         (test-eq v #\t)
         (test-equal next "est")))

   (let ((parser (gor (gchar #\h) (gchar #\h))))
      (let-values (((v next) (parser "test")))
         (test-assert (gfail-object? v))))
   (test-end "gor-test"))

(begin;glist-test
  (test-begin "glist-test")
  (let ((parser (apply glist
                       (map gchar
                            (string->list "test")))))
    (let-values (((v next) (parser "test!")))
         (test-equal v (string->list "test"))
         (test-equal next "!")))
   (test-end "glist-test"))

(begin;glist-test
  (test-begin "glist-of-test")
  (let ((parser (glist-of (gchar #\a))))
    (let-values (((v next) (parser "aaab")))
         (test-equal v (string->list "aaa"))
         (test-equal next "b")))
  (test-end "glist-of-test"))
