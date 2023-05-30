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