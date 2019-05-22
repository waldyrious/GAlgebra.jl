using PyCall
import SymPy: symbols, sympy, Sym
using GAlgebra
using Test

py"""
def vector(ga, components):
    bases = ga.mv()
    return sum([components[i] * e for i, e in enumerate(bases)])
"""
const vector = py"vector"

@testset "GAlgebra.jl" begin
    # Write your own tests here.
    (x, y, z) = xyz = symbols("x,y,z",real=true)
    (o3d, ex, ey, ez) = galgebra.ga.Ga.build("e", g=[1, 1, 1], coords=xyz)

    V = o3d
    a = V.mv("a", "scalar")
    b = V.mv("b", "scalar")
    c = V.mv("c", "scalar")
    d = V.mv("d", "scalar")
    u = V.mv("u", "vector")
    v = V.mv("v", "vector")
    w = V.mv("w", "vector")

    @test v + w == w + v
    @test (u + v) + w == u + (v + w)
    @test v + 0 == v
    @test 0 * v == 0
    @test 1 * v == v
    @test a * (b * v) == (a * b) * v
    @test a * (v + w) == a * v + a * w
    @test (a + b) * v == a * v + b * v

    uu = vector(V, [1, 2, 3])
    vv = vector(V, [4, 5, 6])
    ww = vector(V, [5, 6, 7])

    @test uu + vv == 5 * ex + 7 * ey + 9 * ez
    @test 7 * uu + 2 * ww == 17 * ex + 26 * ey + 35 * ez
    @test 7 * uu - 2 * ww == -3 * ex + 2 * ey + 7 * ez
    @test 3 * uu + 2 * vv + ww == 16 * ex + 22 * ey + 28 * ez
    @test v + (-1) * v == 0

    vo = vector(V, [0, 0, 0])

    @test a * vo == vo
    @test (-a) * v == a * (-v)
    @test (-a) * v == - a * v
    @test (sympy.sqrt(2) * u + sympy.Rational(2, 3) * v) ⋅ ey == 
        sympy.sqrt(2) * (u ⋅ ey) + sympy.Rational(2, 3) * (v ⋅ ey)
    
    @test u ⋅ v == u | v

    @test u ⋅ v == (u < v)
    @test u ⋅ v == (u > v)

    @test u << v == u ⋅ v
    @test u >> v == u ∧ v
end
