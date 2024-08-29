
@testset "gradient" begin

    vars = @variables x, y

    @testset "Single variable" begin
        f( (x, ) ) = x + 1
        g = ReversePropagation.gradient( f, (x,))
        @test g(3) == (4, (1,))

        f2( (x, ) ) = x^2 + x
        g2 = ReversePropagation.gradient( f2, (x,) )
        @test g2(3) == (12, (7,))
    end

    @testset "Two variables" begin
        h( (a, b) ) = (a + b) * (a + b)
        vars = @variables x, y
        ∇h = ReversePropagation.gradient( h, (x, y) )
        @test ∇h( (1, 2) ) == (9, (6, 6))

        h2( (a, b) ) = a^2 + b^2
        vars = @variables x, y
        ∇h2 = ReversePropagation.gradient( h2, (x, y) )
        @test ∇h2( (1, 2) ) == (5, (2, 4))
    end


end