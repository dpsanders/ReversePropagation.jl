# ReversePropagation.jl

A Julia package for reverse propagation along a syntax tree, using source-to-source transformation via [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl).


## Basic usage: Reverse-mode automatic differentiation

The `gradient` function calculates the gradient of an expression or function with respect to given variables:

```jl
julia> using Symbolics, ReversePropagation

julia> f( (x, y) ) = x + (x * y);

julia> vars = @variables x, y;

<<<<<<< HEAD
julia> ∇f = ReversePropagation.gradient(f, vars);
=======
julia> ∇f = ReversePropagation.gradient(vars, f);
>>>>>>> f3d42e46c16ebfbdf842b164444c0250a666791e

julia> ∇f( (1, 2) )
(3, (3, 1))
```

The `gradient` function returns both the value of the function and the gradient.

## Basic usage: Forward&ndash;backward contractor

The forward&ndash;backward contractor corresponding to an expression takes a box and tries to exclude parts of the box that do not satisfy a constraint.

The contractor is constructed from a symbolic version of the constraint expression:

```jl
julia> vars = @variables x, y 
    
julia> ex = x^2 + y^2
    
julia> C = forward_backward_contractor(ex, vars)  # construct the contractor

julia> constraint = 0..1
julia> X = IntervalBox(-10..10, 2)

julia> C(X, constraint)
```

Here the contractor corresponds to the constraint expression `x^2 + y^2`. 

The result of the final call tries to exclude regions of the input box `X` that do *not* satisfy `x^2 + y^2 ∈ 0..1`, where `0..1` denotes the interval [0, 1].
This call returns the contracted box, as well as the value of the original function over the input box.

Parameters may be included in the expression; their symbolic expressions must be passed in when constructing the contractor, and their numerical values when executing the contraction:

```jl
julia> @variables a

julia> ex = x^2 + a * y^2
    
julia> C = forward_backward_contractor(ex, vars, [a])

julia> aa = 1..1  # value of the variable `a` to use

julia> C(X, constraint, aa) == ( (-1..1, -1..1), 0..200 )




## Tracing and transformations

The package works by tracing an input Julia function into a `Symbolics.jl` expression. It then transforms that expression into a static single-assignment (SSA) form, before finally emitting Julia code.

The unexported `gradient_code` function can be used to inspect this process:

```jl
julia> ex = f(vars);  #  x + (x * y)

julia> code, final, gradient_vars = ReversePropagation.gradient_code(ex, vars);

julia> code
7-element Vector{Assignment}:
 Assignment(_a, x*y)
 Assignment(_b, _a + x)
 Assignment(_b̄, 1)
 Assignment(_ā, _b̄)
 Assignment(x̄, _b̄)
 Assignment(x̄, x̄ + _ā*y)
 Assignment(ȳ, _ā*x)
 ```


## License
The code is licensed under the MIT license.

Copyright: David P. Sanders, 2021
