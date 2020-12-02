module ReversePropagation

export gradient


using SymbolicUtils
# using SymbolicUtils: Sym, Term
using SymbolicUtils.Rewriters

using ModelingToolkit
using ModelingToolkit: value
const MTK = ModelingToolkit

using DataStructures

using ChainRules


include("chain_rules_interface.jl")
include("cse.jl")
include("reverse_diff.jl")


# better printing for Equation:
Base.show(io::IO, eq::Equation) = print(io, lhs(eq), " := ", rhs(eq))

end
