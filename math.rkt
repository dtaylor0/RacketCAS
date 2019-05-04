
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
     [else (display "error\n")]
     )))

(define deriv-at-point
  (lambda (equation point)
    ))
