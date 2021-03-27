using IntervalContractors
using IntervalArithmetic


@testset "forward_backward_contractor" begin

    vars = @variables x, y 
    @variables a

    ex = x^2 + y^2
    
    C = forward_backward_contractor(ex, vars)
    @test C(IntervalBox(-10..10, -10..10), 0..1) == ( (-1..1, -1..1), 0..200 )


    ex = x^2 + a * y^2
    
    C = forward_backward_contractor(ex, vars, [a])
    @test C(IntervalBox(-10..10, -10..10), 0..1, 1..1) == ( (-1..1, -1..1), 0..200 )


end