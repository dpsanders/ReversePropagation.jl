module ReversePropagation

export gradient


using SymbolicUtils
# using SymbolicUtils: Sym, Term
using SymbolicUtils.Rewriters

using ModelingToolkit
using ModelingToolkit: value, istree, operation, arguments
const MTK = ModelingToolkit

using DataStructures

using ChainRules



struct Assignment 
    lhs 
    rhs 
end

Base.show(io::IO, eq::Assignment) = print(io, lhs(eq), " := ", rhs(eq))


include("chain_rules_interface.jl")
include("cse.jl")
include("reverse_diff.jl")

end
