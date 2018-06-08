using PackVec
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

v = [1.0,2.0,3.0]

n = @unpack!(v, a::Real, b::Real, c::Real)

@test n == 3
@test a == v[1] == 1.0
@test b == v[2] == 2.0
@test c == v[3] == 3.0

n =  @pack!(v, a+=1, b+=2, c+=3)

@test n == 3
@test a == v[1] == 2.0 
@test b == v[2] == 4.0 
@test c == v[3] == 6.0



v = randn(1+4*4)
X = zeros(4,4)
n = @unpack!(v, a::Real, X)

@test n == 1+4*4
@test a == v[1]
@test X[1:4*4] == v[2:1+4*4]

n = @pack!(v, X, a)
@test n == 1+4*4
@test X[1:4*4] == v[1:4*4]
@test a == v[4*4+1]


v = randn(100)
n = @unpack!(v,
             D = Diagonal(zeros(3)),
             U = UpperTriangular(zeros(3,3)),
             L = LowerTriangular(zeros(3,3)),
             S = Symmetric(zeros(3,3)),
             C = LinAlg.Cholesky(zeros(3,3),'U'))

@test n == 3 + 6 + 6 + 6 + 6
@test D[1,1] == v[1]
@test D[3,3] == v[3]
@test U[1,1] == v[3+1]
@test U[3,3] == v[3+6]
@test L[1,1] == v[3+6+1]
@test L[3,3] == v[3+6+6]
@test S[1,1] == v[3+6+6+1]
@test S[3,3] == v[3+6+6+6]
@test C[:U][1,1] == v[3+6+6+6+1]
@test C[:U][3,3] == v[3+6+6+6+6]

vv = zeros(n)
nn = @pack!(vv, D, U, L, S, C)
@test n == nn
@test vv == v[1:n]


using StaticArrays
n = @unpack!(v, X::SVector{3}, Y::SMatrix{2,4})

@test n == 3 + 2*4
@test X[1] == v[1]
@test X[3] == v[3]
@test Y[1,1] == v[3+1]
@test Y[2,4] == v[3+2*4]

vv = zeros(n)
nn = @pack!(vv, X, Y)
@test n == nn
@test vv == v[1:n]
