
(define deriv
  (lambda (equation)
    (simplify (deriv-rec equation))))

(define deriv-rec
  (lambda (equation)
    (let ([op (if (list? equation) (car equation) (void))]
          [second (if (list? equation) (if (not (null? (cdr equation))) (cadr equation) '()) '())]
          [third-to-end (if (list? equation)
                          (if (not (null? (cdr equation))) (cddr equation)
                            '())
                          '())])
      ;'(op second a b c d) - '(a b c d) is third-to-end
      (cond
        [(number? equation) 0]
        [(eq? equation 'x) 1]
        [(not (list? equation)) (error "error: deriv - unknown variable")]
        [(null? equation) 0]
        [(eq? op '+) (cond
                       [(null? third-to-end) (deriv-rec second)]
                       [else (list '+ (deriv-rec second) (deriv-rec (cons '+ third-to-end)))])]
        [(eq? op '*) (cond
                       [(null? third-to-end) (deriv-rec second)]
                       [else (if (number? second)
                               (list '* second (deriv-rec (cons '* third-to-end)))
                               (list '+ (list '* (deriv-rec second) (cons '* third-to-end))
                                     (list '* second (deriv-rec (cons '* third-to-end)))))])]
        [(eq? op '/) (cond
                       [(or (> (length equation) 3) (< (length equation) 2)) (error (string-append "error: deriv - \""
                                                                                                   (symbol->string op)
                                                                                                   "\" should have exactly two args"))]
                       [(null? third-to-end) (deriv-rec second)]
                       [else (list '/ (list '+ (list '* (deriv-rec second) (car third-to-end))
                                            (list '* -1 second (deriv-rec (car third-to-end))))
                                   (list '^ (car third-to-end) 2))])]
        [(eq? op '-) (cond
                       [(null? third-to-end) (list '* -1 (deriv-rec second))]
                       [else (deriv-rec (cons '+ (cons second (map (lambda (i)
                                                                     (list '* -1 i)) third-to-end))))])]
        [(eq? op 'sin) (list '* (deriv-rec second) (list 'cos (cadr equation)))]
        [(eq? op 'cos) (list '* (deriv-rec second) (list '* -1 (list 'sin second)))]
        [(eq? op 'tan) (list '* (deriv-rec second) (list '^ (list 'sec second) 2))]
        [(eq? op 'csc) (list '* (deriv-rec second) (list '* -1 (list 'csc second) (list 'cot second)))]
        [(eq? op 'sec) (list '* (deriv-rec second) (list '* (list 'sec second) (list 'tan second)))]
        [(eq? op 'cot) (list '* (deriv-rec second) (list '* -1 (list '^ (list 'csc second) 2)))]
        [(eq? op '^) (list '*
                           (caddr equation)
                           (deriv-rec second)
                           (list '^ second (- (caddr equation) 1)))]
        [(eq? op 'x) 1]
        [(number? op) 0]
        [else (display "error: \"")
              (display op)
              (display "\" is not supported\n")]
        ))))

(define simplify
  (lambda (equation)
    (cond
      [(number? equation) equation]
      [(eq? equation 'x) equation]
      ;[(not (list? equation)) (display "error: bad input\n")]
      [(null? equation) equation]
      [(eq? (car equation) '+) (cond
                                 [(null? (cddr equation)) (simplify (cadr equation))]
                                 [else (let ([nested-plus-lists (filter (lambda (i)
                                                                          (if (list? i)
                                                                            (eq? (car i) '+)
                                                                            #f)) equation)]
                                             [new-list (filter (lambda (i)
                                                                 (not (or (if (list? i)
                                                                            (eq? (car i) '+)
                                                                            #f)
                                                                          (number? i)))) equation)]
                                             [number (reduce + (filter number? equation) 0)])
                                         (cond
                                           [(> (length nested-plus-lists) 0) (simplify (append new-list
                                                                                               (filter (lambda (i) (not (eq? i '+)))
                                                                                                       (append-lists-in-list nested-plus-lists))
                                                                                               (if (eq? number 0)
                                                                                                 '()
                                                                                                 (list number))))]
                                           [else (cons '+ (map simplify (append (cdr new-list) (if (eq? number 0)
                                                                                                 '()
                                                                                                 (list number)))))]))])]
      [(eq? (car equation) '*) (cond
                                 [(null? (cddr equation)) (simplify (cadr equation))]
                                 [else (let ([nested-times-lists (filter (lambda (i)
                                                                           (if (list? i)
                                                                             (eq? (car i) '*)
                                                                             #f)) equation)]
                                             [new-list (filter (lambda (i)
                                                                 (not (or (if (list? i)
                                                                            (eq? (car i) '*)
                                                                            #f)
                                                                          (number? i)))) equation)]
                                             [number (reduce * (filter number? equation) 1)])
                                         (cond
                                           [(> (length nested-times-lists) 0) (simplify (append new-list
                                                                                                (filter (lambda (i) (not (eq? i '*)))
                                                                                                        (append-lists-in-list nested-times-lists))
                                                                                                (if (eq? number 1) '() (list number))))]
                                           [else (cons '* (map simplify (append (if (eq? number 1) '() (list number)) (cdr new-list))))]))])]
      [else (cons (car equation) (map simplify (cdr equation)))])))

(define append-lists-in-list
  (lambda (lst)
    (cond
      [(not (list? lst)) (display "error\n")]
      [(null? (cdr lst)) (car lst)]
      [else (append (car lst) (append-lists-in-list (cdr lst)))])))

(define deriv-at-point
  (lambda (equation point)
    (evaluate (deriv equation) point)))

(define nth-deriv
  (lambda (equation n)
    (cond
      [(< n 0) (display "error: cannot take negative derivative\n")]
      [(eq? n 0) equation]
      [else (nth-deriv (deriv equation) (- n 1))])))

(define nth-deriv-at-point
  (lambda (equation n point)
    (evaluate (nth-deriv equation n) point)))

(define increasing-at-point?
  (lambda (equation point)
    (> (deriv-at-point equation point) 0)))

(define decreasing-at-point?
  (lambda (equation point)
    (< (deriv-at-point equation point) 0)))

(define evaluate
  (lambda (equation value)
    (cond
      [(number? equation) equation]
      [(eq? equation 'x) value]
      [(not (list? equation)) (display "error: bad input\n")]
      [else (let ([eq (replace-x equation value)])
              (evaluate-rec eq))])))

(define evaluate-rec
  (lambda (equation)
    (cond
      [(number? equation) equation]
      [(not (list? equation)) (display "error\n")]
      [(null? equation) 0]
      [(eq? (car equation) '+) (cond
                                 [(null? (cddr equation)) (evaluate-rec (cadr equation))]
                                 [else (+ (evaluate-rec (cadr equation))
                                          (evaluate-rec (cons '+ (cddr equation))))])]
      [(eq? (car equation) '*) (cond
                                 [(null? (cddr equation)) (evaluate-rec (cadr equation))]
                                 [else (* (evaluate-rec (cadr equation))
                                          (evaluate-rec (cons '* (cddr equation))))])]
      [(eq? (car equation) '/) (cond
                                 ;[(not (eq? (length equation) 3)) (display "error: \"")
                                 ;                                 (display (car equation))
                                 ;                                 (display "\" should have exactly two arguments\n")]
                                 [(null? (cddr equation)) (evaluate-rec (cadr equation))]
                                 [else (/ (evaluate-rec (cadr equation))
                                          (evaluate-rec (cons '* (cddr equation))))])]
      [(eq? (car equation) 'sin) (sin (evaluate-rec (cadr equation)))]
      [(eq? (car equation) 'cos) (cos (evaluate-rec (cadr equation)))]
      [(eq? (car equation) 'tan) (tan (evaluate-rec (cadr equation)))]
      [(eq? (car equation) 'csc) (/ 1 (sin (evaluate-rec (cadr equation))))]
      [(eq? (car equation) 'sec) (/ 1 (cos (evaluate-rec (cadr equation))))]
      [(eq? (car equation) 'cot) (/ 1 (tan (evaluate-rec (cadr equation))))]
      [(eq? (car equation) '^) (expt (evaluate-rec (cadr equation)) (evaluate-rec (caddr equation)))]
      [else (display "error: \"")
            (display (car equation))
            (display "\" is not supported\n")]
      )))

(define replace-x
  (lambda (equation value)
    (map (lambda (i) (cond
                       [(eq? i 'x) value]
                       [(list? i) (replace-x i value)]
                       [else i])) equation)))

(define contains-x?
  (lambda (equation)
    (cond
      [(not (list? equation)) (eq? equation 'x)]
      [(null? equation) #f]
      [else (or (contains-x? (car equation)) (contains-x? (cdr equation)))])))

(define contains?
  (lambda (equation target)
    (cond
      [(not (list? equation)) (eq? equation target)]
      [(null? equation) #f]
      [else (or (contains? (car equation) target) (contains? (cdr equation) target))])))

(define integral
  (lambda (equation)
    (simplify (integral-rec equation))))

(define integral-rec
  (lambda (equation)
    (cond
      [(eq? equation 0) 0]
      [(number? equation) (list '* equation 'x)]
      [(eq? equation 'x) (list '* 1/2 (list '^ 'x 2))]
      [(not (list? equation)) (display "error\n")]
      [(null? equation) (display "error\n")]
      [(eq? (car equation) 0) 0]
      [(number? (car equation)) (list '* (car equation) 'x)]
      [(eq? (car equation) 'x) (list '* 1/2 (list '^ 'x 2))]
      [(eq? (car equation) '+) (cond
                                 [(not (contains-x? equation)) (integral-rec (evaluate-rec equation))]
                                 [(null? (cddr equation)) (integral-rec (cadr equation))]
                                 [else (list '+
                                             (integral-rec (cadr equation))
                                             (integral-rec (cons '+ (cddr equation))))])]
      [(eq? (car equation) '*) (cond
                                 [(not (contains-x? equation)) (integral-rec (evaluate-rec equation))]
                                 [(null? (cddr equation)) (integral-rec (cadr equation))]
                                 [(and (contains-x? (cadr equation))
                                       (contains-x? (cons '*
                                                          (cddr equation)))) (display "error: integration by parts not supported\n")]
                                 [(not (contains-x? (cadr equation))) (list '*
                                                                            (evaluate-rec (cadr equation))
                                                                            (integral-rec (cons '* (cddr equation))))]
                                 [(not (contains-x? (cons '* (cddr equation)))) (list '*
                                                                                      (evaluate-rec (cons '* (cddr equation)))
                                                                                      (integral-rec (cadr equation)))]
                                 [else (display "error?\n")])]
      [(eq? (car equation) '^) (cond
                                 [(contains-x? (caddr equation)) (display "error: exponents containing x are not supported\n")]
                                 [(contains-x? (cadr equation)) (cond
                                                                  [(contains-trig? (cadr equation)) (display "error: only x^n or (a*x)^n is supported\n")]
                                                                  #|[(eq? ((cadr equation) 'x)) (list '*
                                                                                                    (/ 1
                                                                                                       (+ 1
                                                                                                          (evaluate-rec (caddr equation))))
                                                                                                    (list '^
                                                                                                          'x
                                                                                                          (+ 1
                                                                                                             (evaluate-rec (caddr equation)))))]|#
                                                                  [else (list '*
                                                                              (/ (evaluate equation 1)
                                                                                 (+ 1
                                                                                    (evaluate-rec (caddr equation))))
                                                                              (list '^
                                                                                    'x
                                                                                    (+ 1
                                                                                       (evaluate-rec (caddr equation)))))])]
                                 [else (integral-rec (evaluate-rec equation))])]
      [else (display "error: \"")
            (display (car equation))
            (display "\" is not supported\n")]
      )))

(define contains-trig?
  (lambda (equation)
    (or (contains? equation 'sin)
        (contains? equation 'cos)
        (contains? equation 'tan)
        (contains? equation 'csc)
        (contains? equation 'sec)
        (contains? equation 'cot))))

(define def-integral
  (lambda (equation start end)
    (let ([integ (integral-rec equation)])
      (- (evaluate integ end) (evaluate integ start)))))

(define print-equation
  (lambda (equation)
    (display (equation->string equation))))

(define equation->string
  (lambda (equation)
    (cond
      [(number? equation) (number->string equation)]
      [(eq? equation 'x) "x"]
      [(not (list? equation)) (display "error\n")]
      [(null? equation) (display "error\n")]
      [(number? (car equation)) (number->string (car equation))]
      [(eq? (car equation) 'x) "x"]
      [(eq? (car equation) '+) (cond
                                 [(null? (cddr equation)) (equation->string (cadr equation))]
                                 [else (string-append (equation->string (cadr equation))
                                                      " + " 
                                                      (equation->string (cons '+ (cddr equation))))])]
      [(eq? (car equation) '-) (cond
                                 [(null? (cddr equation)) (equation->string (cadr equation))]
                                 [else (string-append (equation->string (cadr equation))
                                                      " - "
                                                      (equation->string (cons '- (cddr equation))))])]
      [(eq? (car equation) '*) (cond
                                 [(null? (cddr equation)) (if (or (contains? (cadr equation) '+) (contains? (cadr equation) '-))
                                                            (string-append "(" (equation->string (cadr equation)) ")")
                                                            (equation->string (cadr equation)))]
                                 [else (string-append (if (or (contains? (cadr equation) '+)
                                                              (contains? (cadr equation) '-))
                                                        (string-append "("
                                                                       (equation->string (cadr equation))
                                                                       ")")
                                                        (equation->string (cadr equation)))
                                                      "*"
                                                      (equation->string (cons '* (cddr equation))))])]
      [(eq? (car equation) '/) (cond
                                 [(null? (cddr equation)) (string-append "(" (equation->string (cadr equation)) ")")]
                                 [else (string-append (if (list? (cadr equation))
                                                        (string-append "("
                                                                       (equation->string (cadr equation))
                                                                       ")")
                                                        (equation->string (cadr equation)))
                                                      "/"
                                                      (equation->string (cons '/ (cddr equation))))])]
      [(eq? (car equation) '^) (string-append (if (list? (cadr equation))
                                                (string-append "(" (equation->string (cadr equation)) ")")
                                                (equation->string (cadr equation)))
                                              "^"
                                              (if (list? (caddr equation))
                                                (string-append "(" (equation->string (caddr equation)) ")")
                                                (equation->string (caddr equation))))]
      [(eq? (car equation) 'sin) (string-append "sin(" (equation->string (cadr equation)) ")")]
      [(eq? (car equation) 'cos) (string-append "cos(" (equation->string (cadr equation)) ")")]
      [(eq? (car equation) 'tan) (string-append "tan(" (equation->string (cadr equation)) ")")]
      [(eq? (car equation) 'csc) (string-append "csc(" (equation->string (cadr equation)) ")")]
      [(eq? (car equation) 'sec) (string-append "sec(" (equation->string (cadr equation)) ")")]
      [(eq? (car equation) 'cot) (string-append "cot(" (equation->string (cadr equation)) ")")]
      [else (display "error\n")]
      )))

(define reduce
  (lambda (op l id)
    (if (null? l)
      id
      (op (car l) (reduce op (cdr l) id)))))
