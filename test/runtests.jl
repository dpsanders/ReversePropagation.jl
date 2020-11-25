using ReversePropagation
using Test

@testset "ReversePropagation.jl" begin
    # Write your tests here.
end



# code = gradient(vars, ex)


# vars = @variables x, y

# f( (x, y ) ) = x + x * y + (x * y) * (x * y)

# g = gradient([x, y], f)

# g( (3, 4))

# # f( (x, y) ) = cos(x + x * y + (x * y) * (x * y))

# f( (x, y) ) = x + (x + y)^2

# forward_code, final, reverse_code, gradient_vars = gradient_code(vars, f( (x, y)) )

# forward_code
# final
# reverse_code
# gradient_vars

# g = gradient([x, y], f)

# g( (1, 2))





# @variables x, y, z

# eq = z ~ x * y
# op(eq)

# bar(first(args(eq)))






# const num_times_used = Dict{Operation, Int}()

# @variables x, y, z, w

# eq = z ~ y + x

# eq = z ~ y * x
# adj(num_times_used, eq)

# eq2 = w ~ z * x
# adj(num_times_used, eq2)


# bar(lhs(eq))

# adj(eq)

# adj(num_times_used, eq2)

# lhs(eq)

# Expr(bar(x) ~ 0)



# adj(y ~ sqr(x))


# vars = @variables x, y

# wengert, final = cse_total(vars, x + x * y + x * (x + y))

# wengert
# final



# reverse_code, final_vars = reverse_pass(vars, wengert, final)

# reverse_code

# reverse(wengert)



# vars = @variables x, y
# ex = x + (x * y)

# forward_code, final, reverse_code, gradient_vars = gradient_code(vars, ex)

# forward_code
# final
# reverse_code
# gradient_vars

# code, return_tuple = gradient_expr(vars, ex)

