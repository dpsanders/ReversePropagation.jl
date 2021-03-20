module ReversePropagation

export gradient

import Symbolics: toexpr



using SymbolicUtils
using SymbolicUtils: Sym, Term
using SymbolicUtils.Rewriters

using Symbolics
using Symbolics: value, 
                istree, operation, arguments, 
                Assignment

using DataStructures


using ChainRules



# struct Assignment 
#     lhs 
#     rhs 
# end

# Base.show(io::IO, eq::Assignment) = print(io, lhs(eq), " := ", rhs(eq))

include("make_variable.jl")
include("chain_rules_interface.jl")
# include("cse.jl")
include("cse_new.jl")
include("reverse_diff.jl")

end
