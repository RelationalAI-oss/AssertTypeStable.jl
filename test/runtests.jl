using AssertTypeStable

using Test

f(x) = Var(x)

@test_throws AssertionError AssertTypeStable.assert_stable(f, (Int,))

f(x,y) = x+y

AssertTypeStable.assert_stable(f, (Int,Int))
