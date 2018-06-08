module PackVec

export @pack!, @unpack!

using Requires

if VERSION < v"0.7.0-"
    using Compat
end


"""
    @pack!(vec, A, B, C, ...)

Pack the objects `A`, `B`, `C` etc. into `vec`.

Each object requires a `pack!` method. It returns the number of objects inserted.
"""
macro pack!(vec, args...)
    blk = Expr(:block)
    push!(blk.args, :(offset = 0))
    for X in args
        push!(blk.args, :(offset = pack!($(esc(vec)), offset, $(esc(X)))))
    end
    blk
end

"""
    @unpack!(vec, A[::spec], B[::spec], ...)

Unpack the vector into objects named `A`, `B`, etc.

If a `spec` is defined, it creates a new object of that type by calling
`unpack`. Otherwise it requires that the object already exist and mutates it by calling
`unpack!`.
"""
macro unpack!(vec, args...)
    blk = Expr(:block)
    push!(blk.args, :(offset = 0))
    for ex in args
        if ex isa Expr && ex.head == :(::)
            X = ex.args[1]
            spec = ex.args[2]
            push!(blk.args, :(($(esc(X)), offset) = unpack($(esc(vec)), offset, $(esc(spec)))))
        else
            X = ex
            push!(blk.args, :(offset = unpack!($(esc(vec)), offset, $(esc(X)))))
        end
    end
    push!(blk.args, :(offset))
    blk
end

"""
    nextoffset = pack!(vec, offset, obj)

This is called by `@pack!`. It should pack the object into `vec`, starting at `offset+1`,
returning the index of the final insertion.
"""
function pack! end

"""
    nextoffset = unpack!(vec, offset, obj)

This is called by `@unpack!`. It should unpack `vec` (starting at `offset+1`) into `obj`,
returning the next offset.

See also `unpack`.
"""
function unpack! end


"""
    obj, nextoffset = unpack(vec, offset, T)

This is called by `@unpack!`. It should unpack `vec` (starting at `offset+1`) into a new
object of type `T`, returning a tuple of the object and next offset.

See also `unpack`.
"""
function unpack end




function pack!(vec, offset, obj::Real)
    vec[offset += 1] = obj
    return offset
end
function unpack(vec, offset, ::Type{T}) where {T<:Real}
    obj = T(vec[offset += 1])
    return obj, offset
end


function pack!(vec, offset, obj::AbstractArray)
    n = length(obj)
    copyto!(vec, offset+1, obj, 1, n)
    return offset+n
end
function unpack!(vec, offset, obj::AbstractArray{T}) where {T<:Real}
    n = length(obj)
    copyto!(obj, 1, vec, offset+1, n)
    return offset+n
end


pack!(vec, offset, obj::Diagonal) = pack!(vec, offset, obj.diag)
unpack!(vec, offset, obj::Diagonal) = unpack!(vec, offset, obj.diag)

function pack!(vec, offset, obj::UpperTriangular)
    n = size(obj,1)
    for i = 1:n
        copyto!(vec, offset+1, obj.data, (i-1)*n+1, i)
        offset += i
    end
    return offset
end
function unpack!(vec, offset, obj::UpperTriangular)
    n = size(obj,1)
    for i = 1:n
        copyto!(obj.data, (i-1)*n+1, vec, offset+1, i)
        offset += i
    end
    return offset
end

function pack!(vec, offset, obj::LowerTriangular)
    n = size(obj,1)
    for i = 1:n
        ii = n-i+1
        copyto!(vec, offset+1, obj, (i-1)*n+i, ii)
        offset += ii
    end
    return offset
end
function unpack!(vec, offset, obj::LowerTriangular)
    n = size(obj,1)
    for i = 1:n
        ii = n-i+1
        copyto!(obj, (i-1)*n+i, vec, offset+1, ii)
        offset += ii
    end
    return offset
end

function pack!(vec, offset, obj::Symmetric)
    if obj.uplo == 'U'
        pack!(vec, offset, UpperTriangular(obj.data))
    else
        pack!(vec, offset, LowerTriangular(obj.data))
    end
end
function unpack!(vec, offset, obj::Symmetric)
    if obj.uplo == 'U'
        unpack!(vec, offset, UpperTriangular(obj.data))
    else
        unpack!(vec, offset, LowerTriangular(obj.data))
    end
end


function pack!(vec, offset, obj::LinAlg.Cholesky)
    if obj.uplo == 'U'
        pack!(vec, offset, UpperTriangular(obj.factors))
    else
        pack!(vec, offset, LowerTriangular(obj.factors))
    end
end
function unpack!(vec, offset, obj::LinAlg.Cholesky)
    if obj.uplo == 'U'
        unpack!(vec, offset, UpperTriangular(obj.factors))
    else
        unpack!(vec, offset, LowerTriangular(obj.factors))
    end
end


@require StaticArrays begin
    using StaticArrays
    function unpack(vec, offset, ::Type{SVector{N}}) where {N}
        obj = SVector{N}(@view vec[offset+1:offset+N])
        return obj, offset+N
    end
    function unpack(vec, offset, ::Type{SMatrix{M,N}}) where {M,N}
        obj = SMatrix{M,N}(@view vec[offset+1:offset+M*N])
        return obj, offset+M*N
    end
end

end # module
