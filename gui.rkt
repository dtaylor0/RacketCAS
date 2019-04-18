#lang racket/gui
(require racket/include)

(include "math.rkt")
;makes new frame for the GUI
(define frame (new frame% [label "dy/dx"] [width 500] [height 500]))

(define msg (new message% [parent frame]
                 [label "Enter an equation:"]))

;text field to enter equation
(define field1 (new text-field% [label "f(x) = "]
                    [parent frame]
                    [horiz-margin 20]))

;button that finds the derivative of the equation typed into the text field when pressed
(define calculateButton (new button% [parent frame]
                             [label "Calculate"]
                             [callback (lambda (button event)
                                         (send originalEq set-label (string-append "f(x) = "(send field1 get-value)))
                                         (send answer set-label (string-append "df(x)/dx = "(formatAns (derivative (formatEq (send field1 get-value))))))
                                         (send field1 set-value ""))]))

;after button press, displays input equation
(define originalEq (new message% [parent frame]
                    [label "                                                                                                                                       "]
                    [horiz-margin 40]))

;after button press, displays derivative of input equation
(define answer (new message% [parent frame]
                    [label "                                                                                                                                       "]
                    [horiz-margin 40]))
(send frame show #t)
