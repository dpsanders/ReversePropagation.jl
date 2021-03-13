
lhs(eq::Assignment) = eq.lhs
rhs(eq::Assignment) = value(eq.rhs)

op(eq::Assignment) = operation(rhs(eq))
args(eq::Assignment) = Num.(arguments(rhs(eq)))

name(var) = value(var).name
bar(var) = Variable(Symbol(var, "̄"))  # string contains overbar symbol (on top of first `"`)


# bar(op) = Variable()

# "Construct adjoint of a given Assignment with accumulation"
# function adj(eq::Assignment)
#     vars = args(eq)
#     adjoints = Adjoint(op(eq), vars)

#     bar_lhs = bar(lhs(eq))

#     eqns = map(zip(vars, adjoints)) do (var, adj)
#         barred = bar(var)

#         Assignment(barred, barred + bar_lhs * adj)
#     end

#     return eqns
# end


"Make a new variable by adding a number to an old variable, e.g. `x` -> `x3`"
function add_number(var, num)
    return Variable(var, num)   # Variable(Symbol(var, "_", num))
end


function numbered_variable!(num_times_used, var, increment=false)
    is_new = false

    if !haskey(num_times_used, var)
        is_new = true

        num = 0
        num_times_used[var] = 0
    else

        if increment
            num_times_used[var] += 1
        end

        num = num_times_used[var]
    end

    return is_new, add_number(var, num)
end


function adj(eq::Assignment)
    vars = value.(args(eq))

    bar_lhs = bar(lhs(eq))

    adjoints = adj(op(eq), bar_lhs, vars...)

    eqns = map(zip(vars, adjoints)) do (var, adj)
        @show var, adj, typeof(var)
        if var isa Sym{Tangent{Real}}  # for linearization pass
            barred = bar(var)

            Assignment(barred, barred + adj)
        end
    end

    return eqns
end

function adj(num_times_used, eq::Assignment)

    # @show num_times_used
    # @show eq

    vars = args(eq)
    # adjoints = Adjoint(op(eq), vars)

    # is_new, bar_lhs = numbered_variable!(num_times_used, bar(lhs(eq)))

    bar_lhs = bar(lhs(eq))
    is_new, numbered_bar_lhs = numbered_variable!(num_times_used, bar_lhs)

    adjoints = adj(op(eq), numbered_bar_lhs, vars...)

    eqns = Assignment[]

    # @show bar_lhs
    for (var, adj) in zip(vars, adjoints)

        # @show typeof(var)
        !isa(var, Num) && continue

        barred = bar(var)

        is_new, numbered = numbered_variable!(num_times_used, barred)

        if is_new # first use
            # Assignment(numbered, numbered_bar_lhs * adj)
            push!(eqns, Assignment(numbered, adj))

        else  # re-use so generate new variable
            new_num, barred_new = numbered_variable!(num_times_used, barred, true)
            # Assignment(barred_new, numbered + numbered_bar_lhs * adj)
            push!(eqns, Assignment(barred_new, numbered + adj))

        end
    end

    return eqns
end


function reverse_pass(vars, code, final)
    num_times_used = Dict{Num, Int}()

    num, final_bar = numbered_variable!(num_times_used, bar(final))
    reverse_code = [Assignment(final_bar, 1)]

    for eq in reverse(code)
        # @show eq
        append!(reverse_code, adj(num_times_used, eq))
    end

    final_vars = [numbered_variable!(num_times_used, bar(var))[2] for var in vars]
    return reverse_code, final_vars
end



"""
Return code for forward and reverse pass, as a vector of Assignments.
`final` is the output variable from the forward pass.
`gradient_vars` are the output variables from the reverse pass.
"""
function gradient_code(vars, ex)
    forward_code, final = cse_total(vars, ex)
    reverse_code, gradient_vars = reverse_pass(vars, forward_code, final)

    return forward_code, final, reverse_code, gradient_vars
end




make_tuple(args) = Expr(:tuple, args...)
make_tuple(s::Symbol) = make_tuple([s])

# toexpr(ex::Assignment) = toexpr(Equation(ex.lhs, ex.rhs))

function gradient_expr(vars, ex)
    forward_code, final, reverse_code, gradient_vars = gradient_code(vars, ex)

    code = Expr(:block, 
                toexpr.(forward_code)..., 
                toexpr.(reverse_code)...)

    return_tuple = make_tuple(toexpr.(gradient_vars))
    # push!(code.args, :(return $return_tuple))

    return code, final, return_tuple
end


function gradient(vars, ex::Num)

    code, final, return_tuple = gradient_expr(vars, ex)
    input_vars = make_tuple(Symbol.(vars))

    final2 = toexpr(final)

    quote
        ($input_vars, ) -> begin
            $code
            return $(final2), $return_tuple
        end
    end

end



function gradient(vars, f)
    code = gradient(vars, f(vars))
    return eval(code)
end
