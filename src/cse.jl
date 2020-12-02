# Common Subexpression elimination

# Original version together with Shashi Gowda:
# https://github.com/JuliaSymbolics/SymbolicUtils.jl/issues/121

const symbol_numbers = Dict{Symbol, Int}()

"""Return a new, unique symbol like _z3.
Updates the global dict `symbol_numbers`"""
function make_symbol(s::Symbol)

    i = get(symbol_numbers, s, 0)
    symbol_numbers[s] = i + 1

    if i == 0
        return Symbol("_", s)
    else
        return Symbol("_", s, i)
    end
end

make_symbol(c::Char) = make_symbol(Symbol(c))

let current_symbol = 'a'

    """Make a new symbol like `_c`. 
    Cycles through the alphabet and adds numbers if necessary.
    """
    global function make_symbol()
        current_sym = current_symbol

        if current_sym < 'z'
            current_symbol += 1
        else
            current_symbol = 'a'
        end

        return Variable(make_symbol(current_sym))

    end
end


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

"CSE with pre-existing dict"
function cse(vars, expr, dict::OrderedDict=initialize_dict(vars))

    orig_length = length(dict)

    r = @rule ~x::(x -> x isa Term) => 
        haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()

    final = Postwalk(Chain([r]))(expr)  # modifies dict
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



make_equation(p::Pair) = Equation(p[1], p[2])


cse_total(vars, ex::Num) = cse_total(vars, value(ex))
cse_total(vars, ex::Num, dict::OrderedDict) = cse_total(vars, value(ex), dict)

"Perform CSE and return a vector of `Equation`s"
function cse_total(vars, ex, dict=initialize_dict(vars))
    ex2, final = cse(vars, ex, dict)
    ex3 = make_equation.(ex2)

    # remove redefinitions of input variables:
    ex4 = [eq for eq in ex3 if !(any(x -> isequal(x, eq.lhs), vars))]

    return ex4, final
end

function cse_total(vars, eq::Equation, dict::OrderedDict)
    eqns, final = cse_total(vars, rhs(eq), dict)
    
    # replace final equation with the correct variable 
    # from the left-hand side of eq:

    # this currently "wastes" a generated variable
    # eqns[end] = Equation(lhs(eq), rhs(eqns[end]))

    # alternative: add a new equation:
    push!(eqns, Equation(lhs(eq), final))

    return eqns
end


function cse_total(vars, eqs::Vector{Equation})
    dict = initialize_dict(vars)

    all_eqns = []

    for eq in eqs
        push!(all_eqns, cse_total(vars, eq, dict))
        # modifies dict
        # @show dict
    end

    return reduce(vcat, all_eqns)
end
