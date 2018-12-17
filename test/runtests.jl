using AssertTypeStable

using Test


@testset "@assert_typestable" begin
    @testset "basic tests" begin
        # Type instability
        f(x) = Val(x)
        @test_throws AssertionError @assert_typestable f(5)

        # Type stable
        f(x,y) = x+y
        @test (@assert_typestable f(1,2)) == nothing

        # "expected" small union "instability":
        u(x) = x > 0 ? Int(round(x)) : float(x)
        @test_broken (@assert_typestable u(-3.5) == nothing)
    end
end

@testset "@istypestable" begin
    f(x,y) = x+y
    @test @istypestable f(2,3)

    f(x) = Val(x)
    @test @istypestable(f(3)) == false
end
