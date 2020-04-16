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
mutable struct QuickFind{T<:Integer}
    ids::Vector{T}
    nGroups::T
end

# Construction type 1
# Notation: collect(Base.OneTo(n)) == list(range(n)) in Python
QuickFind(n::T) where {T <: Integer} =
    QuickFind{T}(collect(Base.OneTo(n)), n)

# Construction type 2
QuickFind{T}(n::Integer) where {T <: Integer} =
    QuickFind{T}(collect(Base.OneTo(n)), n)

# The length or "size" of a UnionFind is the length of either of its vectors
length(uf::QuickFind) = Base.length(uf.ids)

"""
    num_groups(uf::QuickFind)
Get a number of groups.
"""
num_groups(uf::QuickFind) = uf.nGroups

"""
    find(uf::QuickFind{T}, x::T, y::T)
Determine if x and y belong to the same group
"""
function find(uf::QuickFind{T}, x::T, y::T) where {T <: Integer}
    return uf.ids[x] == uf.ids[y]
end

"""
    find(uf::QuickFind{T}, t::Tuple{T,T})
Determine if x and y belong to the same group
"""
function find(uf::QuickFind{T}, t::Tuple{T,T}) where {T <: Integer}
    return uf.ids[t[1]] == uf.ids[t[2]]
end

"""
    unite(uf::QuickFind{T}, x::T, y::T)
Merges two groups together
"""
function unite!(uf::QuickFind{T}, x::T, y::T) where {T <: Integer}
    # We cannot guarantee x,y are in bounds
    pid = uf.ids[x]
    tid = uf.ids[y]
    # We can guarantee the below loop is in bounds, so we
    # can turn bounds checking off
    @inbounds for i = 1:length(uf)
        if uf.ids[i] == pid
            uf.ids[i] = tid
        end
    end
    # Groups are merged so decrement
    uf.nGroups -= 1
end

"""
    unite(uf::QuickFind{T}, t::Tuple{T,T})
Merges two groups together
"""
function unite!(uf::QuickFind{T}, t::Tuple{T,T}) where {T <: Integer}
    # We cannot guarantee x,y are in bounds
    pid = uf.ids[t[1]]
    tid = uf.ids[t[2]]
    # We can guarantee the below loop is in bounds, so we
    # can turn bounds checking off
    @inbounds for i = 1:length(uf)
        if uf.ids[i] == pid
            uf.ids[i] = tid
        end
    end
    # Groups are merged so decrement
    uf.nGroups -= 1
end
