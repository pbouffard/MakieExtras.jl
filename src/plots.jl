using Colors
using Makie

"""
Plot timeseries from rows of a matrix x, with time vector t. Each series is plotted in a different color. A legend and data inspector are added to the axis.
"""
function plotseries!(ax, t::AbstractVector, x::AbstractMatrix; name = "", names = [], plot_args...)
    cs = distinguishable_colors(size(x, 1), [RGB(1, 1, 1), RGB(0, 0, 0)], dropseed = true)
    for (i, row) in enumerate(eachrow(x))
        if length(names) == size(x, 1)
            label = names[i]
        else
            label =
                name * (length(name) > 0 ? " " : "") * string(i) * "/" * string(size(x, 1))
        end
        # label=name * " " * string(i)
        lines!(
            ax,
            t,
            x[i, :];
            color = cs[i],
            inspector_label = (s, i, p) -> "$label\n$i\n$p",
            label,
            plot_args...,
        )
    end
    axislegend(ax)
end

"""
plotseries! with default arguments for a new figure and axis.
"""
function plotseries!(t, x; kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    plotseries!(ax, t, x; kwargs...)
    return fig, ax
end