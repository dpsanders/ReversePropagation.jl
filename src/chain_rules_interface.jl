# Interface for using ChainRules.jl

Base.conj(x::Num) = x   # assuming reals
Base.complex(x::Num) = x
Base.float(x::Num) = x

@scalar_rule(^(x::Num, n::Integer), (n*x^(n-1), Zero()))

adj(f, z̄::Num, x::Num) = (rrule(f, x)[2](z̄))[2]
adj(f, z̄, x) = adj(f, Num(z̄), Num(x))


Num(x::Real) = x

adj(f, z̄::Num, x, y) = simplify( (rrule(f, x, y)[2])(z̄)[2:end] )
adj(f, z̄, x, y) = adj(f, Num(z̄), Num(x), Num(y))

struct Tangent{T <: Real} <: Real
end



# tangent(var) = Variable(Symbol(value(var), "̇"))
# tangent(var::Num) = Sym{Tangent{Real}}(Symbol(var, "̇"))
tangent(var::Num) = tangent(value(var))
tangent(var::Sym) = Sym{Tangent{Real}}(Symbol(var, "̇"))
tangent(x::Real) = 0  # derivative of a constant

function tangent(eq::Equation)
    
    vars = args(eq)
    rhs_tangents = Num.(tangent.(args(eq)))
    lhs_tangent = Num(tangent(lhs(eq)))

    return Equation(lhs_tangent,
                    frule( (Zero(), rhs_tangents...), 
                    op(eq), vars...)[2]
    )
end



# julia> frule((Zero(), ẋ, ẏ), *, x, y)
# (x * y, (ẋ * y) + (x * ẏ))

# julia> dargs = Num.(dotify.(args(eq)))

# julia> a = Num.(args(eq))
# 2-element Vector{Num}:
#  x
#  y

# julia> frule( (Zero(), dargs...), op(eq), a...)
# (x * y, (ẋ * y) + (x * ẏ))

