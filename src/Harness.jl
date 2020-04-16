include("QuickFind.jl")
include("QuickUnion.jl")
include("WQuickUnion.jl")
include("DisjointSet.jl")

using BenchmarkTools
using StatsBase
using JLD

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 2500
BenchmarkTools.DEFAULT_PARAMETERS.samples = 500000

function twoVals(n)
    s = sample(Base.OneTo(n), 2, replace = false)
    return (s[1], s[2])
end

function QuickFindSetup(n, frac)
    qf = QuickFind(n)

    while num_groups(qf) / length(qf) > frac
        vals = twoVals(n)
        unite!(qf, vals[1], vals[2])
    end
    return qf
end

function QuickUnionSetup(n, frac)
    qf = QuickUnion(n)

    while num_groups(qf) / length(qf) > frac
        vals = twoVals(n)
        unite!(qf, vals[1], vals[2])
    end
    return qf
end

function WQuickUnionSetup(n, frac)
    qf = WQuickUnion(n)

    while num_groups(qf) / length(qf) > frac
        vals = twoVals(n)
        unite!(qf, vals[1], vals[2])
    end
    return qf
end

function DisjointSetSetup(n, frac)
    qf = DisjointSet(n)

    while num_groups(qf) / length(qf) > frac
        vals = twoVals(n)
        unite!(qf, vals[1], vals[2])
    end
    return qf
end;

ns = [100, 1000, 2500, 5000, 10000, 50000, 100000, 250000, 500000]
percents = [0, 0.1, 0.25, 0.5, 0.75, 0.9]

benchmarkFindValuesQF =
    Array{BenchmarkTools.Trial,2}(undef, Base.length(ns), Base.length(percents))
benchmarkUniteValuesQF = similar(benchmarkFindValuesQF)
benchmarkRootValuesQU =
    Array{BenchmarkTools.Trial,2}(undef, Base.length(ns), Base.length(percents))
benchmarkFindValuesQU = similar(benchmarkRootValuesQU)
benchmarkUniteValuesQU = similar(benchmarkFindValuesQU)
benchmarkRootValuesWQU =
    Array{BenchmarkTools.Trial,2}(undef, Base.length(ns), Base.length(percents))
benchmarkFindValuesWQU = similar(benchmarkRootValuesWQU)
benchmarkUniteValuesWQU = similar(benchmarkFindValuesWQU)
benchmarkRootValuesDJU =
    Array{BenchmarkTools.Trial,2}(undef, Base.length(ns), Base.length(percents))
benchmarkFindValuesDJU = similar(benchmarkRootValuesDJU)
benchmarkUniteValuesDJU = similar(benchmarkFindValuesDJU)

for (nsi, n) in enumerate(ns), (pi, p) in enumerate(percents)
    qf = QuickFindSetup(n, 1 - p)
    ft = @benchmark find($qf, t) setup = (t = twoVals($n))
    benchmarkFindValuesQF[nsi, pi] = ft

    ut = @benchmark unite!(f[1], f[2]) setup =
        (f = (deepcopy($qf), twoVals($n)))
    benchmarkUniteValuesQF[nsi, pi] = ut
end

for (nsi, n) in enumerate(ns), (pi, p) in enumerate(percents)
    rt = @benchmark root(f[1], f[2][1]) setup =
        (f = (QuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkRootValuesQU[nsi, pi] = rt

    ft = @benchmark find(f[1], f[2][1], f[2][2]) setup =
        (f = (QuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkFindValuesQU[nsi, pi] = ft

    ut = @benchmark unite!(f[1], f[2][1], f[2][2]) setup =
        (f = (QuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkUniteValuesQU[nsi, pi] = ut
end

for (nsi, n) in enumerate(ns), (pi, p) in enumerate(percents)
    rt = @benchmark root(f[1], f[2][1]) setup =
        (f = (WQuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkRootValuesWQU[nsi, pi] = rt

    ft = @benchmark find(f[1], f[2][1], f[2][2]) setup =
        (f = (WQuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkFindValuesWQU[nsi, pi] = ft

    ut = @benchmark unite!(f[1], f[2][1], f[2][2]) setup =
        (f = (WQuickUnionSetup($n, 1 - $p), twoVals($n)))
    benchmarkUniteValuesWQU[nsi, pi] = ut
end

for (nsi, n) in enumerate(ns), (pi, p) in enumerate(percents)
    rt = @benchmark root!(f[1], f[2][1]) setup =
        (f = (DisjointSetSetup($n, 1 - $p), twoVals($n)))
    benchmarkRootValuesDJU[nsi, pi] = rt

    ft = @benchmark find!(f[1], f[2][1], f[2][2]) setup =
        (f = (DisjointSetSetup($n, 1 - $p), twoVals($n)))
    benchmarkFindValuesDJU[nsi, pi] = ft

    ut = @benchmark unite!(f[1], f[2][1], f[2][2]) setup =
        (f = (DisjointSetSetup($n, 1 - $p), twoVals($n)))
    benchmarkUniteValuesDJU[nsi, pi] = ut
end

save(
    "benchmark.jld",
    "benchmarkFindValuesQF",
    benchmarkFindValuesQF,
    "benchmarkUniteValuesQF",
    benchmarkUniteValuesQF,
    "benchmarkRootValuesQU",
    benchmarkRootValuesQU,
    "benchmarkFindValuesQU",
    benchmarkFindValuesQU,
    "benchmarkUniteValuesQU",
    benchmarkUniteValuesQU,
    "benchmarkRootValuesWQU",
    benchmarkRootValuesWQU,
    "benchmarkFindValuesWQU",
    benchmarkFindValuesWQU,
    "benchmarkUniteValuesWQU",
    benchmarkUniteValuesWQU,
    "benchmarkRootValuesDJU",
    benchmarkRootValuesDJU,
    "benchmarkFindValuesDJU",
    benchmarkFindValuesDJU,
    "benchmarkUniteValuesDJU",
    benchmarkUniteValuesDJU,
)
