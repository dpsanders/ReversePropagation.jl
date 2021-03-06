# Common Subexpression elimination

# Original version together with Shashi Gowda:
# https://github.com/JuliaSymbolics/SymbolicUtils.jl/issues/121

## Works by keeping track of a dict of expressions that have already been seen
## Each new expression is assigned a fresh symbolic name 




## Remove powers

# "Replace powers by repeated multiplies"
# function remove_powers(ex)

#     rule = @rule((~y)^2 => (~y) * (~y))
#     rule2 = @rule((~y)^(~n) => (~y) * (~y)^(~n - 1))

#     ex2 = Fixpoint(Postwalk(Chain([rule, rule2])))(ex)
    
#     return ex2
# end


# "Common subexpression elimination"
# function cse(expr)

#     # expr = remove_powers(expr)

#     dict = OrderedDict()

#     r = @rule ~x::(x -> x isa Term) => 
#         haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()

#     final = Postwalk(Chain([r]))(expr)

#     return [var => ex for (ex, var) in pairs(dict)], final
# end

cse(vars, ex::Num) = cse(vars, value(ex))
cse(vars, ex::Num, dict::OrderedDict) = cse(vars, value(ex), dict)

"Common subexpression elimination.
This version starts with the given variables"
# function cse(vars, expr)

#     dict = OrderedDict{Any, Any}(v => v for v in vars)

#     r = @rule ~x::(x -> x isa Term) => 
#         haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()

#     final = Postwalk(Chain([r]))(expr)
#     [var => ex for (ex, var) in pairs(dict)], final
# end
3
"CSE with pre-existing dict"
function cse(vars, expr, dict::OrderedDict=initialize_dict(vars))

    orig_length = length(dict)

    rules = [
        @rule ~x::(x -> (istree(x) || x isa Sym)) => 
            haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()
    ]

    final = Postwalk(Chain(rules))(expr)  # *modifies* dict
    # @show final
    # @show dict

    if length(dict) > orig_length
        new_additions = dict.keys[orig_length+1:end]
    else
        new_additions = []
    end

    [dict[var] => var for var in new_additions], final
end



initialize_dict(vars) = OrderedDict{Any, Any}(v => v for v in value.(vars))



make_Assignment(p::Pair) = Assignment(p[1], p[2])


cse_total(vars, ex::Num) = cse_total(vars, value(ex))
cse_total(vars, ex::Num, dict::OrderedDict) = cse_total(vars, value(ex), dict)

"Perform CSE and return a vector of `Assignment`s"
function cse_total(vars, ex, dict=initialize_dict(vars))
    ex2, final = cse(vars, ex, dict)
    ex3 = make_Assignment.(ex2)

    # remove redefinitions of input variables:
    ex4 = [eq for eq in ex3 if !(any(x -> isequal(x, eq.lhs), vars))]

    return ex4, final
end

function cse_total(vars, eq::Assignment, dict::OrderedDict)
    eqns, final = cse_total(vars, rhs(eq), dict)
    
    # replace final Assignment with the correct variable 
    # from the left-hand side of eq:

    # this currently "wastes" a generated variable
    # eqns[end] = Assignment(lhs(eq), rhs(eqns[end]))

    # alternative: add a new Assignment:
    push!(eqns, Assignment(lhs(eq), final))

    return eqns
end


function cse_total(vars, eqs::Vector{Assignment})
    dict = initialize_dict(vars)

    all_eqns = []

    for eq in eqs
        push!(all_eqns, cse_total(vars, eq, dict))
        # modifies dict
        # @show dict
    end

    return reduce(vcat, all_eqns)
end
