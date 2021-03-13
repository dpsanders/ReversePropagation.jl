# Reverse interval constraint propagation using Symbolics

using Symbolics
using Symbolics: toexpr, Sym


using ReversePropagation: op, args, lhs, rhs, Assignment, cse_total, make_symbol, make_tuple
using ReversePropagation

using IntervalContractors

cd("/Users/dpsanders/Dropbox/packages/ReversePropagation")
include("cse_new.jl")

@register rev(a::Any, b, c, d)
@register rev(a::Any, b, c)

# Possibly should replace all calls to `rev` with calls to the actual 
# reverse functions instead for speed

remove_constant(s) = (s isa Num || s isa Sym) ? s : Variable(:_)

function rev(eq::Assignment)

    @show eq

    vars = tuple(args(eq)...)
    return_vars = Symbolics.MakeTuple( remove_constant.(tuple(lhs(eq), vars...)) )
    

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
    f_rev = Symbol(f, :_rev)
    @eval rev(::typeof($f), z::Real, x::Real) = $f_rev(z, x)
end

vars = @variables x, y
forward_code, final = cse(3x^2 + 4y)

rev.(forward_code)
toexpr.(rev.(forward_code))



function forward_backward_code(vars, ex)
    forward_code, final = cse_equations(ex)
    reverse_code = rev.(reverse(forward_code))

    return forward_code, final, reverse_code
end

function forward_backward_expr(vars, ex)
    forward_code, final, reverse_code = forward_backward_code(vars, ex)

    code = Expr(:block, 
                toexpr.(forward_code)..., 
                toexpr.(reverse_code)...)

    return_tuple = toexpr(Symbolics.MakeTuple(vars))
    # push!(code.args, :(return $return_tuple))

    return code, final, return_tuple
end


function forward_backward_contractor(vars, ex)

    code, final, return_tuple = forward_backward_expr(vars, ex)
    input_vars = toexpr(Symbolics.MakeTuple(vars))

    final2 = toexpr(final)

    return eval(
        quote
            ($input_vars, ) -> begin
                $code
                return $(final2), $return_tuple
            end
        end
    )


end



vars = @variables x, y
ex = 3x^2 + 4x^2 * y


code, final, return_tuple = forward_backward_code(vars, 3x^2 + 4x^2 * y)

expr = forward_backward_expr(vars, ex)

C = forward_backward_contractor(vars, ex)


using IntervalArithmetic

C( (1..2, 3..4) )

ex = x^2 + y^2

C( (-10..10, -10..10) )