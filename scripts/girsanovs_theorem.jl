using DifferentialEquations
using CairoMakie

function plot_ensemble(ensemble)
    ends = [sol.u[end] for sol in ensemble]
    max = maximum(ends)
    min = minimum(ends)
    colorrange = (min, max)
    fig = Figure()
    ax = Axis(fig[1,1])
    for sol in ensemble
        lines!(ax, sol.t, sol.u; colormap=Reverse(:matter), color=sol.u[end]*ones(length(sol.u)), colorrange=colorrange)
    end
    fig
end

μ = 1.5
σ = 1.0

X₀ = 0.0

f(X, p, t) = μ
g(X, p, t) = σ

dt = 0.001
tspan = (0.0, 1.0)

prob = SDEProblem(f, g, X₀, tspan)

ensembleprob = EnsembleProblem(prob)

sim = solve(ensembleprob, EM(), EnsembleThreads(); trajectories=10, dt=dt)

# sol = solve(prob, EM(), dt=dt)

plot_ensemble(sim)

xs = 0:0.01:10
ys = 0.5 .* sin.(xs)

lines(xs, ys, linewidth = 5, color=0.5, colormap=:blues)
