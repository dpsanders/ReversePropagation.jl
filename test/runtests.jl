using ReversePropagation
using ModelingToolkit
using Test

@testset "ReversePropagation.jl" begin

    @testset "gradient" begin
        
        vars = @variables x, y

        @testset "Single variable" begin
            f( (x, ) ) = x + 1
            g = gradient( (x,), f )
            @test g(3) == (4, (1,))

            f2( (x, ) ) = x^2 + x
            g2 = gradient( (x,), f2 )
            @test g2(3) == (12, (7,))
        end

        @testset "Two variables" begin
            h( (a, b) ) = (a + b) * (a + b)
            vars = @variables x, y
            ∇h = gradient( (x, y), h )
            @test ∇h( (1, 2) ) == (9, (6, 6))

            h2( (a, b) ) = a^2 + b^2
            vars = @variables x, y
            ∇h2 = gradient( (x, y), h2 )
            @test ∇h2( (1, 2) ) == (5, (2, 4))
        end


    end

end
