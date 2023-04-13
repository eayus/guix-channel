;; Contains various helper utilities that are not specific to any specific
;; package or service.
(define-module (ellis util))


;; Replace any 'old' characters with 'new' in 'str'.
(define (replace-char old new str)
  (string-map (lambda (c)
                (if (char=? c old) new c)) str))


;; ?
(define (generate-config config fields filepath)
  `((filepath ,(mixed-text-file
		 filepath
		 (serialize-configuration config fields)))))
