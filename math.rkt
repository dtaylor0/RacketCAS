#lang racket/gui

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

;gets listOfTerms for input equation (in list form) and returns a list with the correct changes to the numbers in that list
(define derivative
  (lambda (equation)
    (eqToString (map (lambda (term)
           (list (* (car term) (cadr term)) (- (cadr term) 1))) (listOfTerms equation)))))

;takes input equation in string form and translates it into a list in this format:
;
;"34x^65+2x^5+10x^2" => '((34 65) (2 5) (10 2))
(define listOfTerms
  (lambda (equation)
    (map (lambda (i)
           (map string->number i)) (map (lambda (x)
                                          (string-split x "x^")) (string-split equation "+")))))
;removes spaces, other stuff from the inputted equation string
(define formatEq
  (lambda (equation)
    (string-replace (string-replace equation " " "") "-" "+-")))

;in the result string, this removes instances of "+-" as well as a "+" at the end of the string
(define formatAns
  (lambda (ans)
    (let ([revisedAns (string-replace ans "+-" "-")])
    (substring revisedAns 0 (- (string-length revisedAns) 1)))))

;takes output equation in list form and turns it into a string
;
;'((10 4) (3 8)) => "10x^4+3x^8"
(define eqToString
  (lambda (eqList)
    (let ([eqStrList (map (lambda (i) (map number->string i)) eqList)])
      (string-join (map termToString eqStrList) ""))))

;helper function for eqToString, makes a string out of an individual term
;
;'(10 4) => "10x^4+"
(define termToString
  (lambda (term)
    (if (null? term) "" (string-append (car term) "x^" (second term) "+"))))
