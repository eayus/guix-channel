(define-module (ellis home services bspwm))

(define (replace-char old new str)
  (string-map
    (lambda (c) (if (char=? c #\-) #\_ c))
    str))


(define (bspc-field-name name-sym)
  (replace-char
    #\-
    #\_
    (symbol->string name-sym)))


(define (serialize-bspc-config field-name value)
    #~(string-append "bspc config " #$(bspc-field-name field-name) " " (object->string #$value) "\n"))

(define (serialize-bspc-desktops _ value)
    #~(string-append (string-join (list "bspc monitor" "-d" #$@(map object->string value))) "\n"))

(define (serialize-sxhkd-runner _ value)
    "pgrep -x sxhkd > /dev/null || sxhkd &\n")


(define-configuration home-bspwm-configuration
  (start-sxhkd
    (boolean #f)
    "Whether to run sxhkd when bspwm starts"
    (serializer serialize-sxhkd-runner))

  (border-width
    (integer 0)
    "Window border width."
    (serializer serialize-bspc-config))

  (window-gap
    (integer 0)
    "Size of the gap that separates windows."
    (serializer serialize-bspc-config))

  (split-ratio
    (integer 50)
    "Default split ratio."
    (serializer serialize-bspc-config))

  (gapless-monocle
    (boolean #t)
    "Remove gaps of tiled windows for the monocle desktop layout."
    (serializer serialize-bspc-config))

  (desktops
    (list '())
    "List of desktop names to create upon startup."
    (serializer serialize-bspc-desktops))
)


(define (bspwm-config-service config)
  (let ((cfg-str (serialize-configuration config home-bspwm-configuration-fields)))
    `(("bspwm/bspwmrc" ,(mixed-text-file "bspwmrc" cfg-str)))))

(define (bspwm-packages-service config)
  (list bspwm sxhkd)) ; TODO: only include sxhkd if it is used in config.


(define home-bspwm-service-type
  (service-type
   (name 'home-bspwm)
   (extensions (list
		 (service-extension home-xdg-configuration-files-service-type bspwm-config-service)
		 (service-extension home-profile-service-type bspwm-packages-service)
	))
   (default-value (home-bspwm-configuration))
   (description
    "Run Redshift, a program that adjusts the color temperature of display
according to time of day.")))
