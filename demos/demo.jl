using GLMakie
using MakieExtras

"""Demonstrates set_trackpad_pan!"""
function demo_trackpad_pan()
    GLMakie.activate!(; inline=false, focus_on_show = true)
    fig, ax, plt = scatter(rand(10), rand(10))
    ax.title = "Trackpad pan with 2 fingers, hold shift to zoom"
    set_trackpad_pan!(ax)
    display(fig)
    return fig, ax, plt
end

function demo_plotseries()
    GLMakie.activate!(; inline=false, focus_on_show = true)
    t = 1:1000
    x = cumsum(randn(12, 1000), dims = 2)
    fig, ax = plotseries!(t, x)
    ax.title = "Plot series"
    ax.xlabel = "Time"
    ax.ylabel = "Value"
    DataInspector(ax)
    display(fig)
    return fig, ax
end