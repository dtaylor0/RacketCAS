# Symbolic Differentiation

Computer algebra system in Racket that can be run in the REPL or used in Racket programs.  When using this CAS, equations should be entered in list form.

For example:

```
'(+ (^ x 9) (cos (* 2 x)) 5)
```
is the list form of:
```
x^9 + cos(2x) + 5
```

### Important Info

#### how to use each operation when writing an equation

'(+ a b c ...) takes two or more arguments, translates to a + b + c + ...

'(- a b c ...) takes two or more arguments, translates to a - b - c - ...

'(\* a b c ...) takes two or more arguments, translates to a * b * c * ...

'(/ a b) takes two arguments, translates to a / b

'(^ a b) takes two arguments, translates to a ^ b

'(sin a) takes one argument, translates to sin(a)

The other 5 trig functions are supported as well.

Integration only supports + and * (except for * requiring integration by parts).

### Currently supported features:

#### deriv

Takes a function f(x), returns the derivative.

```
> (deriv '(* 3 (cos (^ x -6))))
'(* 3 (* (* -6 1 (^ x -7)) (* -1 (sin (^ x -6)))))
```

Note: Simplification of the output is not implemented yet.

#### deriv-at-point

Takes a function f(x) and a value of x, returns the value of the derivative of f(x) at x = input value

```
> (deriv-at-point '(+ (* 3 (^ x -5)) (sin x) (^ x 9) x 3) 2)
2304.3494781634527
```

#### nth-deriv

Takes a function f(x) and a number n, returns the nth derivative of f(x)

```
> (nth-deriv '(^ x 5) 3)
'(* 5 (* 1 (* 4 (* 1 (* 3 1 (^ x 2))))))
```

#### nth-deriv-at-point

Takes a function f(x), a number n, and a value of x, and returns the value at x of the nth derivative of f(x)

```
> (nth-deriv-at-point '(^ x 9) 4 2)
96768
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
> (evaluate '(* 3 (^ x 2)) 5)
75
```

#### evaluate-rec

Takes an equation with no x, returns the value

```
> (evaluate '(* 3 (^ 5 2)) 5)
75
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
```

#### contains?

Takes a function f(x) and a number or operator, returns true if the number/operator is in the function and false otherwise

```
> (contains? '(+ (* 2 (^ x 4)) (/ (* 4 x) (sin x))) 'sin)
#t
```

#### print-equation

Takes a function f(x), prints it using equation-\>string

#### equation->string

Takes a function f(x), turns it into a string in a readable form

```
> (equation->string '(+ (* 2 (^ x (* 5 x))) (/ x (sin x))))
"2*x^(5*x) + x/(sin(x))"
```

#### simplify

Takes a function f(x), greatly simplifies it by removing nested + and * calls as well as combining all numbers in + and * calls

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

#### integral

Takes a function f(x), returns the integral of f(x) + C

```
> (integral '(+ x 5))
'(+ (+ (* 0.5 (^ x 2)) (* 5 x)) C)
```

#### integral-rec

Takes a function f(x), returns the integral of f(x) without the + C.  Useful if the equation will be needed for any other subsequent operation.

```
> (integral-rec '(+ x 5))
'(+ (* 0.5 (^ x 2)) (* 5 x))
```

#### def-integral

Takes a function f(x), a value i, and a value j, and returns the definite integral of f(x) from i to j.

```
> (def-integral '(+ x 3) 0 2)
8.0
```
