# ReversePropagation.jl

A Julia package for reverse propagation along a syntax tree, using source-to-source transformation via [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl).


## Basic usage

```jl
julia> using Symbolics, ReversePropagation

julia> f( (x, y) ) = x + (x * y);

julia> vars = @variables x, y;

julia> ∇f = gradient(vars, f);

julia> ∇f( (1, 2) )
(3, (3, 1))
```

The `gradient` function returns both the value of the function and the gradient.

## Tracing and transformations

The package works by tracing an input function into a `ModelingToolkit` object. It then transforms those, before finally emitting Julia code.

The unexported `gradient_code` function can be used to inspect this process:

```jl
julia> ex = f(vars);  #  x + (x * y)

julia> forward_code, final, reverse_code, gradient_vars = ReversePropagation.gradient_code(vars, ex);

julia> forward_code
2-element Vector{Assignment}:
 Assignment(_g, x * y)
 Assignment(_h, x + _g)

julia> reverse_code
5-element Vector{Assignment}:
 Assignment(_h̄₀, 1)
 Assignment(x̄₀, _h̄₀)
 Assignment(_ḡ₀, _h̄₀)
 Assignment(x̄₁, x̄₀ + (_ḡ₀ * y))
 Assignment(ȳ₀, x * _ḡ₀)
 ```

## Content
Currently implemented: simple, scalar reverse-mode AD. 

In preparation: Interval constraint propagation

## License
The code is licensed under the MIT license.

Copyright: David P. Sanders, 2021
