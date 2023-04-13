;; Contains a home service for the bspwm window manager. The service manages
;; configuration files and installation of packages.
(define-module (ellis home services bspwm)
  #:use-module (ellis util) (replace-char generate-config)
  #:export (home-bspwm-service-type))


;;; Field Serialization.


;; Generate the bspc setting name from a scheme symbol. We do this by
;; replacing all hyphens with underscores.
(define (bspc-setting-name name-sym)
  (replace-char #\- #\_ (symbol->string name-sym)))

;; Serializer for settings that will be converted to a 'bspc config' command.
(define (serialize-bspc-config field-name value)
  #~(string-append
      "bspc config "
      #$(bspc-field-name field-name)
      " "
      (object->string #$value)
      "\n"))

;; Serializer for setting the number of desktops.
(define (serialize-bspc-desktops _ value)
  #~(string-append
      (string-join
	(list
	  "bspc monitor"
          "-d"
	  #$@(map object->string value)))
      "\n"))

;; Serializer to start 'sxhkd'.
(define (serialize-sxhkd-runner _ value)
  "pgrep -x sxhkd > /dev/null || sxhkd &\n")


;;; Configuration Definition


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
    (serializer serialize-bspc-desktops)))


;;; Services and Extensions


;; Service extension for loading the appropriate packages.
(define packages-ext
  (service-extension
    home-profile-service-type
    (lambda _ (list bspwm sxhkd)))) ; TODO: only include sxhkd if it is used in config.


;; Service extension for creating the config files (bspwmrc).
(define config-ext
  (service-extension
    home-xdg-configuration-files-service-type
    (lambda (config)
      (generate-config
	config
	home-bspwm-configuration-fields
	"bspwm/bspwmrc"))))


;; Home service definition for bspwm. Combines config and package handling.
(define home-bspwm-service-type
  (service-type
    (name 'home-bspwm)
    (extensions (list config-ext packages-ext))
    (default-value (home-bspwm-configuration))
    (description "Installs and configures the bspwm window manager.")))
