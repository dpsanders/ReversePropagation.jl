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

## Content
Currently implemented: simple, scalar reverse-mode AD. 

In preparation: Interval constraint propagation

## License
The code is licensed under the MIT license.

Copyright: David P. Sanders, 2020
