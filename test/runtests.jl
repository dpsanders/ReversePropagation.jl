using ReversePropagation
using ModelingToolkit
using Test

@testset "ReversePropagation.jl" begin

    @testset "gradient" begin
        
        vars = @variables x, y

        @testset "Single variable" begin
            f( (x, ) ) = x + 1
            g = gradient( (x), f)
            @test g(3) == (4, (1,))
        end

        @testset "Two variables" begin
            h( (a, b) ) = (a + b) * (a + b)
            vars = @variables x, y
            ∇h = gradient( (x, y), h )
            @test ∇h( (1, 2) ) == (9, (6, 6))
        end


    end

end
