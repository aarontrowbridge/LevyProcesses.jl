using DifferentialEquations
using CairoMakie

set_theme!(theme_dark())

function plot_ensemble_comparison(ensemble)
    fig = Figure(resolution=(600,300))
    ax1 = Axis(fig[1,1])
    for sol in ensemble
        X = [Xᵢ for (Xᵢ, Mᵢ) in sol.u]
        lines!(ax1, sol.t, X;)
    end
    ax2 = Axis(fig[1,2])
    for sol in ensemble
        M = [Mᵢ for (Xᵢ, Mᵢ) in sol.u]
        lines!(ax2, sol.t, M;)
    end
    fig
end

function plot_ensemble_transformation(ensemble; colormap=:heat)
    colormap = Reverse(colormap)
    ends = [sol.u[end][2] for sol in ensemble]
    max = maximum(ends)
    min = 0
    colorrange = (min, max)
    fig = Figure(resolution=(1000,500))
    ax1 = Axis(fig[1,1])
    ax2 = Axis(fig[1,2])
    for sol in ensemble
        M = sol.u[end][2]
        X = [Xᵢ for (Xᵢ, Mᵢ) in sol.u]
        lines!(ax1, sol.t, X; colormap=colormap,
                              color=min*ones(length(X)), colorrange=colorrange,
                              linewidth=1.0)
        lines!(ax2, sol.t, X; colormap=Reverse(colormap),
                              color=M*ones(length(X)), colorrange=colorrange,
                              linewidth=1.0)
    end
    fig
end

μ = 1.5
σ = 1.0

function f(du, u, p, t)
    du[1] = μ
    du[2] = 0
end

function g(du, u, p, t)
    du[1] = σ
    du[2] = - μ / σ * u[2]
end

X₀ = [0.0, 1.0]

dt = 0.001
tspan = (0.0, 1.0)

W = WienerProcess(0.0, 0.0, 0.0)

prob = SDEProblem(f, g, X₀, tspan, noise=W)

ensembleprob = EnsembleProblem(prob)

n_trajectories = 20

sim = solve(ensembleprob, EM(), EnsembleThreads(); trajectories=n_trajectories, dt=dt)

sim[1].u

# plot_ensemble_comparison(sim)
plot_ensemble_transformation(sim)
