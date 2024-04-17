using IntervalContractors
using IntervalArithmetic


@testset "forward_backward_contractor" begin

    vars = @variables x, y
    @variables a  # parameter

    C = forward_backward_contractor(x + 1, x)
    @test C(IntervalBox(-10..10), 2..3)[1] == (1..2, )

    C = forward_backward_contractor(x + (2..3), x)
    @test C(IntervalBox(-10..10), 5..6)[1] == (2..4, )

    C = forward_backward_contractor(x + (2..3), x)
    @test C(IntervalBox(3..10), 5..6)[1] == (3..4, )

    ex = x^2 + y^2

    C = forward_backward_contractor(ex, vars)
    @test C(IntervalBox(-10..10, -10..10), 0..1) == ( (-1..1, -1..1), 0..200 )


    ex = x^2 + a * y^2

    C = forward_backward_contractor(ex, vars, [a])
    @test C(IntervalBox(-10..10, -10..10), 0..1, 1..1) == ( (-1..1, -1..1), 0..200 )


end