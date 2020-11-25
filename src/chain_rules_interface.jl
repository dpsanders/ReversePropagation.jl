# Interface for using ChainRules.jl

Base.conj(x::Num) = x   # assuming reals
Base.complex(x::Num) = x

adj(f, z̄, x)    = (rrule(f, x)[2](z̄))[2]

function adj(f, z̄, x, y) 
    @show f, z̄, x, y
    @show typeof.( (f, x, y) )
    @show rrule(f, x, y)
    return (rrule(f, x, y)[2])(z̄)[2:end]
end
