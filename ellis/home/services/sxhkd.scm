;; Contains a home service for the sxhkd hotkey daemon. The service manages
;; configuration files and installation of packages.
(define-module (ellis home services sxhkd)

  #:use-module (ellis util)
  #:use-module (guix gexp)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (srfi srfi-1)

  #:export (
    home-sxhkd-service-type
    home-sxhkd-configuration
    hotkey))


;;; Field Serialization.


(define (serialize-modifiers _ value)
  #~(string-join (list #$@(map symbol->string value)) " + "))

(define (serialize-key _ value)
  #~(string-append " + " #$(symbol->string value) "\n\t"))

(define (serialize-action _ value)
  value)

(define (serialize-hotkey config)
  #~(string-append #$(serialize-configuration config hotkey-fields) "\n\n"))

(define (serialize-hotkeys _ value)
  #~(string-append #$@(map serialize-hotkey value)))

;;; Configuration Definition


(define-configuration hotkey
  (modifiers
    (list '(super))
    "List of modifier keys"
    (serializer serialize-modifiers))
  (key
    (symbol)
    "Key name"
    (serializer serialize-key))
  (action
    (string)
    "Shell script action to perform on press"
    (serializer serialize-action)))

(define (hotkey-list? xs) (every hotkey? xs))

(define-configuration home-sxhkd-configuration
  (hotkeys
    (hotkey-list '())
    "List of hotkeys and their associated commands"
    (serializer serialize-hotkeys)));serialize-hotkeys))


;;; Services and Extensions


;; Service extension for loading the appropriate packages.
(define packages-ext
  (service-extension
    home-profile-service-type
    (lambda _ (list sxhkd)))) ; TODO: only include sxhkd if it is used in config.


;; Service extension for creating the config files (bspwmrc).
(define config-ext
  (service-extension
    home-xdg-configuration-files-service-type
    (lambda (config)
      (generate-config
	config
	home-sxhkd-configuration-fields
	"sxhkd/sxhkdrc"))))


;; Home service definition for bspwm. Combines config and package handling.
(define home-sxhkd-service-type
  (service-type
    (name 'home-sxhkd)
    (extensions (list config-ext packages-ext))
    (default-value (home-sxhkd-configuration))
    (description "Installs and configures the sxhkd hotkey daemon.")))
