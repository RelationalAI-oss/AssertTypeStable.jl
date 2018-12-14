using AssertTypeStable

using Test

f(x) = Var(x)

@test_throws AssertionError @assert_stable f(5)

f(x,y) = x+y

@test (@assert_stable f(1,2)) == nothing
