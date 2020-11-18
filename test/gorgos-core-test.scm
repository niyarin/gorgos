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
      (test-assert (gfail? v)))

   (test-end "gchar-test"))

(begin;;goptional-test
   (test-begin "goptional-test")
   (let-values (((v next) ((goptional (gchar #\t)) "test")))
      (test-eq v #\t)
      (test-equal next "est"))
   (let-values (((v next) ((goptional (gchar #\t)) "hello")))
      (test-eq v '())
      (test-equal next "hello"))
   (test-end "goptional-test"))

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
         (test-assert (gfail? v))))
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

(begin
  (test-begin "gpair-test")
  (let-values (((v next) ((gpair (gchar #\t) (gchar #\e)) "test")))
      (test-equal v (cons #\t #\e))
      (test-equal next "st"))
  (let-values (((v next) ((gpair (gchar #\x) (gchar #\e)) "test")))
      (test-assert (gfail? v))
      (test-equal next "test"))
  (let-values (((v next) ((gpair (gchar #\t) (gchar #\x)) "test")))
      (test-assert (gfail? v))
      (test-equal next "test"))
  (test-end "gpair-test"))
