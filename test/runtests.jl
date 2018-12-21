using AssertTypeStable

using Test

@testset "Outer" begin

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

@testset "Recursive functions" begin
    recursive_factorial(x) = x * (x>1 ? recursive_factorial(x-1) : 1)
    @assert recursive_factorial(10) == factorial(10)

    @test AssertTypeStable.@istypestable recursive_factorial(3)
end

@testset "No methods matching" begin
    f(x::Integer, y::Integer) = true
    f(x::Int64, y::Any) = false

    # Calling f(1,2) is ambiguous.
    @assert (try f(1,2) catch e; e end) isa MethodError

    # So it won't have _any_ methods in @code_typed.
    @test_logs (:warn, r".*no methods.*") AssertTypeStable.@assert_typestable f(1,2)
end

end
