module ReversePropagation

export gradient, forward_backward_contractor

import Symbolics: toexpr

using SymbolicUtils
using SymbolicUtils: Sym, Term
using SymbolicUtils.Rewriters

using Symbolics
using Symbolics: value, 
                istree, operation, arguments, 
                Assignment

using IntervalContractors

import Base: ∩
import Base: ∪

@register a ∩ b
@register a ∪ b

using OrderedCollections

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
include("reverse_icp.jl")

end
