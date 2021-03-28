
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

make_variable(s) = Variable(make_symbol(s))

let current_symbol = 'a'

    """Make a new symbol like `_c`. 
    Cycles through the alphabet and adds numbers if necessary.
    """
    global function make_variable()
        current_sym = current_symbol

        if current_sym < 'z'
            current_symbol += 1
        else
            current_symbol = 'a'
        end

        return make_variable(current_sym)

    end
end