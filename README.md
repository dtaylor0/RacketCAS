# Symbolic Differentiation

Computer algebra system in Racket that can be run in the REPL.  Takes equations in list form and returns derivative, more functionality will be introduced over time.

### Example use:

```
> (deriv '(* 3 (cos (^ x -6))))
'(* 3 (* (* -6 1 (^ x -7)) (* -1 (sin (^ x -6)))))
```

Simplification not complete yet.
