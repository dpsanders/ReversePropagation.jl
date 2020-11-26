# ReversePropagation.jl

A Julia package for reverse propagation along a syntax tree, using source-to-source transformation via [ModelingToolkit.jl](https://github.com/SciML/ModelingToolkit.jl).


## Basic usage

```jl
julia> using ModelingToolkit, ReversePropagation

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
julia> ex = x + (x * y);

julia> forward_code, final, reverse_code, gradient_vars = ReversePropagation.gradient_code(vars, ex);

julia> forward_code
2-element Vector{Equation}:
 Equation(_g, x * y)
 Equation(_h, x + _g)

julia> reverse_code
5-element Vector{Equation}:
 Equation(_h̄₀, 1)
 Equation(x̄₀, _h̄₀)
 Equation(_ḡ₀, _h̄₀)
 Equation(x̄₁, x̄₀ + (_ḡ₀ * y))
 Equation(ȳ₀, x * _ḡ₀)
 ```

## Content
Currently implemented: simple, scalar reverse-mode AD. 

In preparation: Interval constraint propagation

## License
The code is licensed under the MIT license.

Copyright: David P. Sanders, 2020
