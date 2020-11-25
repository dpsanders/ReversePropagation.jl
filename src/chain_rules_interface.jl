# Interface for using ChainRules.jl

Base.conj(x::Num) = x   # assuming reals
Base.complex(x::Num) = x

adj(f, z̄, x) = (rrule(f, x)[2](z̄))[2]
adj(f, z̄, x, y) = (rrule(f, x, y)[2])(z̄)[2:end]

