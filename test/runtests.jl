using AssertTypeStable

using Test


@testset "@assert_typestable" begin
    @testset "basic tests" begin
        f(x) = Val(x)
        @test_throws AssertionError @assert_typestable f(5)

        f(x,y) = x+y
        @test (@assert_typestable f(1,2)) == nothing
    end
end

@testset "@test_typestable" begin
    f(x,y) = x+y
    @test_typestable f(1,2)

    f(x) = Val(x)
    @test_broken @test_typestable f(3)
end
