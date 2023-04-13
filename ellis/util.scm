;; Contains various helper utilities that are not specific to any specific
;; package or service.
(define-module (ellis util)

  #:use-module (guix gexp)
  #:use-module (gnu services configuration)

  #:export (
    replace-char
    generate-config))


;; Replace any 'old' characters with 'new' in 'str'.
(define (replace-char old new str)
  (string-map (lambda (c)
                (if (char=? c old) new c)) str))


;; ?
(define (generate-config config fields filepath)
  `((,filepath ,(mixed-text-file
		 (replace-char #\/ #\- filepath)
		 (serialize-configuration config fields)))))
