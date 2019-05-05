# Symbolic Differentiation

Computer algebra system in Racket that can be run in the REPL.  When using this CAS, equations should be entered in list form.

For example:

```
'(+ (^ x 9) (cos (* 2 x)) 5)
```
is the list form of:
```
x^9 + cos(2x) + 5
```

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

#### evaluate

Takes a function f(x) and a value of x, returns the value of f(x) at x = input value

```
> (evaluate '(* 3 (^ x 2)) 5)
75
```
