# RacketCAS

Computer algebra system in Racket that can be run in the REPL or used in Racket programs.  When using this CAS, equations should be entered in list form.

For example:

```
'(+ (^ x 9) (cos (* 2 x)) 5)
```
is the list form of:
```
x^9 + cos(2x) + 5
```

### Important Info:

#### how to start using this program

Just go to the directory with math.rkt, and then:

```
~/path/to/file $ racket
Welcome to Racket v7.2.
> (load "math.rkt")
```

From here, you can use any of the functions below.  It is also a good idea to start by storing equations for repeated use:

```
> (define equation-1 '(+ (* 3 (cos x)) (* 5 (^ x 6)) 9))
```

#### how to use each operation when writing an equation

'(+ a b c ...) takes two or more arguments, translates to a + b + c + ...

'(- a b c ...) takes two or more arguments, translates to a - b - c - ...

'(\* a b c ...) takes two or more arguments, translates to a * b * c * ...

'(/ a b) takes two arguments, translates to a / b

'(^ a b) takes two arguments, translates to a ^ b

'(sin a) takes one argument, translates to sin(a)

The other 5 trig functions are supported as well.

Integration only supports +, -, ^ with no x in the exponent and only x or (\* constant x) in the base, some trig functions, 

### Currently supported features:


#### print-equation

Takes a function f(x), prints it using equation-\>string

#### equation->string

Takes a function f(x), turns it into a string in a readable form

```
> (equation->string '(+ (* 2 (^ x 4)) (/ (* 3 (cos x)) (* 5 x))))
"2*x^4 + (3*cos(x))/(5*x)"
```
#### deriv

Takes a function f(x), returns the derivative simplified

Supports the power rule and quotient rule

```
> (deriv '(- (^ (sin x) 5) (* 5 (^ x 3)) (* 3 x) 2))
'(+ (* 5 (^ (sin x) 4) (cos x)) (* -15 (^ x 2)) -3)
```

#### deriv-rec

Takes a function f(x), returns the derivative unsimplified

#### simplify

Takes a function f(x), greatly simplifies it by removing nested + and * calls as well as combining all numbers in +, \*, and ^ calls

```
> (deriv-rec '(+ (* 2 (^ x 4)) (/ (* 3 (cos x)) (* 5 x))))
'(+
  (* 2 (* 4 1 (^ x 3)))
  (/
   (+ (* (* 3 (* 1 (* -1 (sin x)))) (* 5 x)) (* -1 (* 3 (cos x)) (* 5 1)))
   (^ (* 5 x) 2)))

> (simplify (deriv-rec '(+ (* 2 (^ x 4)) (/ (* 3 (cos x)) (* 5 x)))))
'(+ (* 8 (^ x 3)) (/ (+ (* -15 x (sin x)) (* -15 (cos x))) (^ (* 5 x) 2)))

```

#### deriv-at-point

Takes a function f(x) and a value of x, returns the value of the derivative of f(x) at x = input value

```
> (deriv-at-point '(- (^ (sin x) 5) (* 5 (^ x 3)) (* 3 x) 2) 5)
-376.800752837073
```

#### nth-deriv

Takes a function f(x) and a number n, returns the nth derivative of f(x)

```
> (nth-deriv '(+ (* 4 (^ x 10)) (* 3 (cos (* 2 x)))) 3)
'(+ (* 2880 (^ x 7)) (* 24 (sin (* 2 x))))
```

#### nth-deriv-at-point

Takes a function f(x), a number n, and a value of x, and returns the value at x of the nth derivative of f(x)

```
> (nth-deriv-at-point '(+ (* 4 (^ x 10)) (* 3 (cos (* 2 x)))) 3 2)
368621.83674011263
```

#### increasing-at-point?

Takes a function f(x) and a value of x, returns true if the derivative of f(x) is positive at the value of x, false otherwise

```
> (increasing-at-point? '(^ x 2) -9)
#f
```


#### decreasing-at-point?

Takes a function f(x) and a value of x, returns true if the derivative of f(x) is negative at the value of x, false otherwise

```
> (decreasing-at-point? '(^ x 2) -9)
#t
```

#### evaluate

Takes a function f(x) and a value of x, returns the value of f(x) at x = input value

```
> (evaluate '(+ (* 5 (^ (sin x) 4) (cos x)) (* -15 (^ x 2)) -3) 4)
-244.07211470503478
```

#### evaluate-rec

Takes an equation with no x, returns the value

```
> (evaluate-rec '(+ (* 5 (^ (sin 4) 4) (cos 4)) (* -15 (^ 4 2)) -3))
-244.07211470503478
```

#### replace-x

Takes a function f(x) and a value of x, replaces all occurrences of x with the value

```
> (replace-x '(- (sin x) (^ x 5) (* 2 x)) 999)
'(- (sin 999) (^ 999 5) (* 2 999))
```

#### contains-x?

Takes a function f(x), returns true if there is an x in the function and false otherwise

```
> (contains-x? '(+ (* 2 (^ x 4)) (/ (* 4 x) (sin x))))
#t
> (contains-x? '(+ (* 5 (^ (sin 4) 4) (cos 4)) (* -15 (^ 4 2)) -3))
#f
```

#### contains?

Takes a function f(x) and a number or operator, returns true if the number/operator is in the function and false otherwise

```
> (contains? '(+ (* 2 (^ x 4)) (/ (* 4 x) (sin x))) 'sin)
#t
```

#### contains-trig?

Takes a function f(x), returns true if f(x) contains a trig function and false otherwise

```
> (contains-trig? '(+ (* 5 (^ (sin x) 4) (cos x)) (* -15 (^ x 2)) -3))
#t
```

#### append-lists-in-list

Takes a list of lists lst, returns each sublist appended into one big list

```
> (append-lists-in-list '((a b c) (d e) () (f g h i j) (k l m n) (o p)))
'(a b c d e f g h i j k l m n o p)
```

#### integral

Takes a function f(x), returns the integral of f(x) simplified

Supports +, -, * (except for f(x)\*g(x) which requires integration by parts), ^ (with no x in the exponent and either x or '(\* constant x) as the base), sin(x), cos(x), and sec^2(x)

```
> (integral '(+ (* 5 (^ (* 2 x) 3)) (* 3 x) 2))
'(+ (* 10 (^ x 4)) (* 3/2 (^ x 2)) (* 2 x))
```

#### integral-rec

Takes a function f(x), returns the integral of f(x) unsimplified

```
> (integral-rec '(+ (* 5 (^ (* 2 x) 3)) (* 3 x) 2))
'(+ (* 5 (* 2 (^ x 4))) (+ (* 3 (* 1/2 (^ x 2))) (* 2 x)))
```

#### def-integral

Takes a function f(x), a value i, and a value j, and returns the definite integral of f(x) from i to j.

```
> (def-integral '(+ (* 5 (^ (* 2 x) 3)) (* 3 x) 2) 0 5)
12595/2
```
