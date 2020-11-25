# Common Subexpression elimination
# Original code by Shashi Gowda: 

const symbol_numbers = Dict{Symbol, Int}()


function make_tuple(args)
    return Expr(:tuple, args...)
end


make_tuple(s::Symbol) = make_tuple([s])


"""Return a new, unique symbol like _z3_"""
function make_symbol(s::Symbol)  # default is :z

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

# newsym() = Sym{Number}(gensym("cse"))
# newsym() = make_symbol()



## Remove powers

# "Replace powers by repeated multiplies"
# function remove_powers(ex)

#     ex2 = MTK.to_symbolic(ex)

#     rule = @rule((~y)^2 => (~y) * (~y))
#     rule2 = @rule((~y)^(~n) => (~y) * (~y)^(~n - 1))

#     ex3 = Fixpoint(Postwalk(Chain([rule, rule2])))(ex2)

#     ex4 = MTK.to_mtk(ex3)

#     @show ex4
    
#     return ex4
# end


"Common subexpression elimination"
function cse(expr)

    # expr = remove_powers(expr)

    dict = OrderedDict()
    r = @rule ~x::(x -> x isa Term) => haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()
    final = Postwalk(Chain([r]))(expr)
    [var => ex for (ex, var) in pairs(dict)], final
end

"Common subexpression elimination"
function cse(vars, expr)
    # @show vars
    dict = OrderedDict{Any, Any}(v => v for v in vars)

    r = @rule ~x::(x -> x isa Term) => haskey(dict, ~x) ? dict[~x] : dict[~x] = make_symbol()
    final = Postwalk(Chain([r]))(expr)
    [var => ex for (ex, var) in pairs(dict)], final
end


make_equation(p::Pair) = Equation(p[1], p[2])


cse_total(vars, ex::Num) = cse_total(vars, value(ex))

"Perform CSE and return `MTK.Equation`s"
function cse_total(vars, ex)
    ex2, final = cse(vars, ex)
    ex3 = make_equation.(ex2)

    # remove redefinitions of input variables:
    ex4 = [eq for eq in ex3 if !(any(x -> isequal(x, eq.lhs), vars))]

    return ex4, final
end