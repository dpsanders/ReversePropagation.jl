# Reverse interval constraint propagation using Symbolics

using Symbolics
using Symbolics: toexpr


using ReversePropagation: op, args, lhs, rhs, Assignment, cse_total
using ReversePropagation

using IntervalContractors

@register rev(a::Any, b, c, d)


remove_constant(s) = (s isa Num) ? s : Variable(:_)

function rev(eq::Assignment)

    @show eq

    vars = tuple(args(eq)...)
    return_vars = remove_constant.(vars)

    reverse = rev(op(eq), lhs(eq), vars...)

    return Assignment(return_vars, reverse)

end


# difference between reverse mode AD and reverse propagation:
# reverse mode AD introduces *new* variables
# reverse propagation can use the *same* variables

@variables x, y, z
# x ~ x ∩ (z - y)


# reverse ops from IntervalContractors:


const binary_functions = Dict(
                    :+     => :plus_rev,
                    :-     => :minus_rev,
                    :*     => :mul_rev,
                    :/     => :div_rev,
                    :^     => :power_rev,
                    );

for (f, f_rev) in binary_functions 
    @eval rev(::typeof($f), z::Real, x::Real, y::Real) = $f_rev(z, x, y)
end


const unary_functions = [:sqrt, :abs,
            :exp, :exp2, :exp10, :expm1,
            :log, :log2, :log10, :log1p,
            :sin, :cos, :tan,
            :asin, :acos, :atan,
            :sinh, :cosh, :tanh,
            :asinh, :acosh, :atanh,
            :inv, :sign, :max, :min];

for f in unary_functions
    f_rev = Symbol(f, :rev)
    @eval rev(::typeof($f), z::Real, x::Real) = $f_rev(z, x)
end

vars = @variables x, y
forward_code, final = ReversePropagation.cse_total(vars, 3x^2 + 4y)

rev.(forward_code)
toexpr.(rev.(forward_code))

function forward_backward_code(vars, ex)
    forward_code, final = cse_total(vars, ex)
    reverse_code = rev.(forward_code)

    return forward_code, final, reverse_code
end

function forward_backward_expr(vars, ex)
    forward_code, final, reverse_code = forward_backward_code(vars, ex)

    code = Expr(:block, 
                toexpr.(forward_code)..., 
                toexpr.(reverse_code)...)

    return_tuple = make_tuple(toexpr.(vars))
    # push!(code.args, :(return $return_tuple))

    return code, final, return_tuple
end


forward_backward_code(vars, 3x^2 + 4x^2 * y)

forward_code, final = cse_total(vars, 3x^2 + 4x^2 * y)