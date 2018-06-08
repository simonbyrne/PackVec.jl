# PackVec.jl

[![Build Status](https://travis-ci.org/simonbyrne/PackVec.jl.svg?branch=master)](https://travis-ci.org/simonbyrne/PackVec.jl)

[![Coverage Status](https://coveralls.io/repos/simonbyrne/PackVec.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/simonbyrne/PackVec.jl?branch=master)

[![codecov.io](http://codecov.io/github/simonbyrne/PackVec.jl/coverage.svg?branch=master)](http://codecov.io/github/simonbyrne/PackVec.jl?branch=master)


Many package interfaces expect vectors, e.g. [Optim.jl](https://github.com/JuliaNLSolvers/Optim.jl) and [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl).

But sometimes you want to work with more complicated objects. This provides simple functionality for packing and unpacking Julia objects into vectors.

The `@pack!` macro packs Julia objects into vectors:

```
using PackVec
vec = zeros(1 + 2 + 4 + 10) 

a = 1.0
b = [2.0, 3.0]
c = [4.0 5.0; 6.0 7.0]
d = UpperTriangular(ones(4,4))

@pack!(vec, a, b, c, d)
```

To unpack, use `@unpack!`: mutable objects (such as arrays) should be predefined, and immutable ones specified with a type specifier:
```
b = zeros(2)
c = zeros(2,2)
d = UpperTriangular(zeros(4,4))

@unpack!(vec, a::Real, b, c, d)
```

Immutable objects can be directly defined in the macro
```
@unpack!(vec, a::Real, b=zeros(2), c=zeros(2,2), d=UpperTriangular(4,4))
```
