
(define deriv
  (lambda (equation)
    (cond
     [(number? equation) 0]
     [(eq? equation 'x) 1]
     [(not (list? equation)) (display "error: bad input\n")]
     [(null? equation) 0]
     [(eq? (car equation) '+) (cond
                               [(null? (cddr equation)) (deriv (cadr equation))]
                               [else (list '+ (deriv (cadr equation)) (deriv (cons '+ (cddr equation))))])]
     [(eq? (car equation) '*) (cond
                               [(null? (cddr equation)) (deriv (cadr equation))]
                               [else (if (number? (cadr equation))
                                         (list '* (cadr equation) (deriv (cons '* (cddr equation))))
                                         (list '* (deriv (cadr equation)) (deriv (cons '* (cddr equation)))))])]
     [(eq? (car equation) 'sin) (list '* (deriv (cadr equation)) (list 'cos (cadr equation)))]
     [(eq? (car equation) 'cos) (list '* (deriv (cadr equation)) (list '* -1 (list 'sin (cadr equation))))]
     [(eq? (car equation) 'tan) (list '* (deriv (cadr equation)) (list '^ (list 'sec (cadr equation)) 2))]
     [(eq? (car equation) '^) (list '*
                                    (caddr equation)
                                    (deriv (cadr equation))
                                    (list '^ (cadr equation) (- (caddr equation) 1)))]
     [(eq? (car equation) 'x) 1]
     [(number? (car equation)) 0]
     [else (display "error: \"")
           (display (car equation))
           (display "\" is not supported as an operator\n")]
     )))

(define deriv-at-point
  (lambda (equation point)
    (evaluate (deriv equation) point)))

(define evaluate
  (lambda (equation value)
    (let ([eq (replace-x equation value)])
      (evaluate-rec eq value))))

(define evaluate-rec
  (lambda (equation value)
    (cond
     [(number? equation) equation]
     [(not (list? equation)) (display "error\n")]
     [(null? equation) 0]
     [(eq? (car equation) '+) (cond
                               [(null? (cddr equation)) (evaluate-rec (cadr equation) value)]
                               [else (+ (evaluate-rec (cadr equation) value)
                                        (evaluate-rec (cons '+ (cddr equation)) value))])]
     [(eq? (car equation) '*) (cond
                               [(null? (cddr equation)) (evaluate-rec (cadr equation) value)]
                               [else (* (evaluate-rec (cadr equation) value)
                                        (evaluate-rec (cons '* (cddr equation)) value))])]
     [(eq? (car equation) 'sin) (sin (evaluate-rec (cadr equation) value))]
     [(eq? (car equation) 'cos) (cos (evaluate-rec (cadr equation) value))]
     [(eq? (car equation) 'tan) (tan (evaluate-rec (cadr equation) value))]
     [(eq? (car equation) '^) (expt (evaluate-rec (cadr equation) value) (evaluate-rec (caddr equation) value))]
     [else (display "error: \"")
           (display (car equation))
           (display "\" is not supported as an operator\n")])))

(define replace-x
  (lambda (equation value)
    (map (lambda (i) (cond
                      [(eq? i 'x) value]
                      [(list? i) (replace-x i value)]
                      [else i])) equation)))
