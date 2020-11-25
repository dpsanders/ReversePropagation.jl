# Reverse interval constraint propagation using ModelingToolkit

using ModelingToolkit

import Base: ∩, ∪

@register x ∩ y
@register x ∪ y

struct Reverse{op}
end

Reverse(op) = Reverse{op}()
Reverse(op, args...) = Reverse(op)(args...)
Reverse(op, args) = Reverse(op)(args...)

# reverse contraction function

function (::Reverse{+})(z, x, y)   # z = x + y
    return (
            z - y,  # new value for x
            z - x   # new value for y
           )
end

(::Type{Reverse{T}})(vars...) = Reverse{T}()(vars...)



Expr.((Reverse{+})()(z, x, y))


function rev(eq::Equation)
    vars = args(eq)
    reverse = Reverse(op(eq), [lhs(eq); vars]...)

    eqns = map(zip(vars, reverse)) do (var, rev)
        Equation(var, var ∩ rev)
    end

    return eqns
end

rev(eq)

eq

vars = args(eq)
reverse = Reverse(op(eq), [lhs(eq); vars]...)


# difference between reverse mode AD and reverse propagation:
# reverse mode AD introduces *new* variables
# reverse propagation can use the *same* variables

@variables x, y, z
x ~ x ∩ (z - y)
