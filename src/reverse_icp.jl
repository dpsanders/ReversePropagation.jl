# Reverse interval constraint propagation using Symbolics

using Symbolics
using Symbolics: toexpr, Sym

using ReversePropagation: op, args, lhs, rhs, Assignment, cse_total, make_variable, make_tuple
using ReversePropagation

using IntervalContractors
using IntervalArithmetic

IntervalArithmetic.configure!(directed_rounding=:fast, powers=:fast)


import Base: ∩
import Base: ∪


cd("/Users/dpsanders/Dropbox/packages/ReversePropagation")
include("cse_new.jl")

@register rev(a::Any, b, c, d)
@register rev(a::Any, b, c)
@register a ∩ b
@register a ∪ b

# Possibly should replace all calls to `rev` with calls to the actual 
# reverse functions instead for speed

remove_constant(s) = (s isa Num || s isa Sym) ? s : Variable(:_)

function rev(eq::Assignment)

    @show eq

    vars = tuple(args(eq)...)
    return_vars = Symbolics.MakeTuple( remove_constant.(tuple(lhs(eq), vars...)) )
    # return_vars = remove_constant.(tuple(lhs(eq), vars...)) 
    

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


"Generate code (as Symbolics.Assignment) for forward--backward (HC4Revise) contractor"
function forward_backward_code(vars, ex)

    final_var = make_variable(:value)  # to record the output of running the forward interval function
    constraint_var = make_variable(:constraint)   # symbolic constraint variable

    forward_code, last = cse_equations(ex)

    @show constraint_var, final_var

    constraint_code = [Assignment(final_var, last),
                        Assignment(last, last ∩ constraint_var)]

    reverse_code = rev.(reverse(forward_code))

    code = forward_code ∪ constraint_code ∪ reverse_code

    return code, final_var, constraint_var
end


Symbolics.toexpr(t::Tuple) = Symbolics.toexpr(Symbolics.MakeTuple(t))

vars = @variables x, y

ex = x^2 + y^2

code, final, constraint = forward_backward_code(vars, ex)

code
final
constraint

dump(toexpr.(code))

# function forward_backward_expr(vars, ex)
#     symbolic_code, final, constraint = forward_backward_code(vars, ex)

#     code = toexpr.(symbolic_code)

#     return_tuple = toexpr(vars)
#     # push!(code.args, :(return $return_tuple))

#     return code, final, return_tuple
# end

"Build Julia code for forward_backward contractor"
function forward_backward_expr(vars, ex)
    symbolic_code, final_var, constraint_var = forward_backward_code(vars, ex)

    @show symbolic_code

    code = toexpr.(symbolic_code)
    all_code = Expr(:block, code...)

    return all_code, toexpr(final_var), toexpr(constraint_var)
end

forward_backward_expr(vars, ex)


function forward_backward_contractor(vars, ex)

    code, final_var, constraint_var = forward_backward_expr(vars, ex)
    input_vars = toexpr(vars)
    final = toexpr(final_var)

    return eval(
        quote
            ($input_vars, $constraint_var) -> begin
                $code
                return $(final), $input_vars
            end
        end
    )


end

C = forward_backward_contractor(vars, ex)

const CC = forward_backward_contractor(vars, ex)


using BenchmarkTools

@btime CC((-10..10, -10..10), 0..1)

@code_native C((-10..10, -10..10), 0..1)

vars = @variables x, y
ex = 3x^2 + 4x^2 * y


code, final, return_tuple = forward_backward_code(vars, 3x^2 + 4x^2 * y)

expr = forward_backward_expr(vars, ex)

C = forward_backward_contractor(vars, ex)


using IntervalArithmetic

C( (1..2, 3..4) )

ex = x^2 + y^2

C( (-10..10, -10..10) )