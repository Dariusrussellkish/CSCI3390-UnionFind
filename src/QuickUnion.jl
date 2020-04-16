#=
Authors:
Darius Russell Kish

Created: April 14, 2020
Modified: April 14, 2020

This implementation is based strongly in the Disjoint Set implementation
in JuliaCollections' DataStructures which is under active development. It
represents proper implementation of data structures for Julia and much of the
typing and integration into the language is taken from their implementation,
however the function implementations are my own.
https://github.com/JuliaCollections/DataStructures.jl/blob/master/src/disjoint_set.jl

Implementations for collections of arbitrary inputs are *not* provided here
and it is assumed this low-level data structure will be wrapped for such
functionality. This avoids issues of key-value association time complexity for
conversion between elements and their index value in analyses of this data
structure.
=#

#=
Notation T <: Integer :: T is a subtype of Integer

An example type tree:
abstract type Number end
abstract type Real     <: Number end
abstract type AbstractFloat <: Real end
abstract type Integer  <: Real end
abstract type Signed   <: Integer end
abstract type Unsigned <: Integer end
=#
mutable struct QuickUnion{T<:Integer}
    ids::Vector{T}
    nGroups::T
end

# Construction type 1
# Notation: collect(Base.OneTo(n)) == list(range(n)) in Python
QuickUnion(n::T) where {T <: Integer} =
    QuickUnion{T}(collect(Base.OneTo(n)), n)

# Construction type 2
QuickUnion{T}(n::Integer) where {T <: Integer} =
    QuickUnion{T}(collect(Base.OneTo(n)), n)

# The length or "size" of a UnionFind is the length of either of its vectors
length(uf::QuickUnion) = Base.length(uf.ids)

"""
    num_groups(uf::QuickUnion)
Get a number of groups.
"""
num_groups(uf::QuickUnion) = uf.nGroups

"""
    root(uf::QuickUnion{T}, x::T)
Finds the root node of node x
"""
function root(uf::QuickUnion{T}, x::T) where {T <: Integer}
    root = uf.ids[x]
    # extracting one iteration of the loop
    # allows ensuring inbounds for the rest
    @inbounds while root != uf.ids[root]
        root = uf.ids[root]
    end
    return root
end

"""
    find(uf::QuickUnion{T}, x::T, y::T)
Determine if x and y belong to the same group
"""
function find(uf::QuickUnion{T}, x::T, y::T) where {T <: Integer}
    return root(uf, x) == root(uf, y)
end

"""
    unite(uf::QuickUnion{T}, x::T, y::T)
Merges two groups together
"""
function unite!(uf::QuickUnion{T}, x::T, y::T) where {T <: Integer}
    pid = root(uf, x)
    tid = root(uf, y)

    uf.ids[pid] = tid

    uf.nGroups -= 1
end
