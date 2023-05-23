using Makie: RefValue, Axis, Consume, camera, pixelarea, Rectf, Vec2f, Automatic, ScrollEvent, deregister_interaction!, register_interaction!, Vec4f, Vec, Makie, widths, timed_ticklabelspace_reset, ispressed, events
import Makie: process_interaction

struct ScrollPan
    speed::Float32
    reset_timer::RefValue{Union{Nothing,Timer}}
    prev_xticklabelspace::RefValue{Union{Automatic,Float64}}
    prev_yticklabelspace::RefValue{Union{Automatic,Float64}}
    reset_delay::Float32
end

function ScrollPan(speed, reset_delay)
    return ScrollPan(speed, RefValue{Union{Nothing,Timer}}(nothing), RefValue{Union{Automatic,Float64}}(0.0), RefValue{Union{Automatic,Float64}}(0.0), reset_delay)
end

scrollzoomkey = Makie.Or(Makie.Keyboard.left_shift | Makie.Keyboard.right_shift)

function process_interaction(sp::ScrollPan, event::ScrollEvent, ax::Axis)


    if ispressed(ax.scene, scrollzoomkey)
        return Consume(false)
    end

    tlimits = ax.targetlimits

    scene = ax.scene
    cam = camera(scene)
    pa = pixelarea(scene)[]

    mp_axscene = Vec4f(sp.speed * event.x, sp.speed * -event.y, 0, 1)

    mp_axfraction = (cam.pixel_space[]*mp_axscene)[Vec(1, 2)] .* (-2 .* ((ax.xreversed[], ax.yreversed[])) .+ 1) .* 0.5 .+ 0.5

    xscale = ax.xscale[]
    yscale = ax.yscale[]

    transf = (xscale, yscale)
    tlimits_trans = Makie.apply_transform(transf, tlimits[])

    movement_frac = mp_axfraction
    xscale = ax.xscale[]
    yscale = ax.yscale[]

    transf = (xscale, yscale)
    tlimits_trans = Makie.apply_transform(transf, tlimits[])

    xori, yori = tlimits_trans.origin .- movement_frac .* widths(tlimits_trans)


    timed_ticklabelspace_reset(ax, sp.reset_timer, sp.prev_xticklabelspace, sp.prev_yticklabelspace, sp.reset_delay)

    inv_transf = Makie.inverse_transform(transf)
    newrect_trans = Rectf(Vec2f(xori, yori), widths(tlimits_trans))
    tlimits[] = Makie.apply_transform(inv_transf, newrect_trans)

    return Consume(true)
end


struct MakieExtrasScrollZoom
    speed::Float32
    reset_timer::RefValue{Union{Nothing,Timer}}
    prev_xticklabelspace::RefValue{Union{Automatic,Float64}}
    prev_yticklabelspace::RefValue{Union{Automatic,Float64}}
    reset_delay::Float32
end

function MakieExtrasScrollZoom(speed, reset_delay)
    return MakieExtrasScrollZoom(speed, RefValue{Union{Nothing,Timer}}(nothing), RefValue{Union{Automatic,Float64}}(0.0), RefValue{Union{Automatic,Float64}}(0.0), reset_delay)
end

# It appears that this needs to be re-implemented
function Makie.process_interaction(s::MakieExtrasScrollZoom, event::ScrollEvent, ax::Axis)

    if !ispressed(ax.scene, scrollzoomkey)
      return Consume(false)
    end

    # use vertical zoom
    zoom = event.y

    tlimits = ax.targetlimits
    xzoomlock = ax.xzoomlock
    yzoomlock = ax.yzoomlock
    xzoomkey = ax.xzoomkey
    yzoomkey = ax.yzoomkey

    scene = ax.scene
    e = events(scene)
    cam = camera(scene)

    if zoom != 0
        pa = pixelarea(scene)[]

        z = max(0.1f0, 1f0 - s.speed)^zoom

        mp_axscene = Vec4f((e.mouseposition[] .- pa.origin)..., 0, 1)

        # first to normal -1..1 space
        mp_axfraction =  (cam.pixel_space[] * mp_axscene)[Vec(1, 2)] .*
            # now to 1..-1 if an axis is reversed to correct zoom point
            (-2 .* ((ax.xreversed[], ax.yreversed[])) .+ 1) .*
            # now to 0..1
            0.5 .+ 0.5

        xscale = ax.xscale[]
        yscale = ax.yscale[]

        transf = (xscale, yscale)
        tlimits_trans = Makie.apply_transform(transf, tlimits[])

        xorigin = tlimits_trans.origin[1]
        yorigin = tlimits_trans.origin[2]

        xwidth = tlimits_trans.widths[1]
        ywidth = tlimits_trans.widths[2]

        newxwidth = xzoomlock[] ? xwidth : xwidth * z
        newywidth = yzoomlock[] ? ywidth : ywidth * z

        newxorigin = xzoomlock[] ? xorigin : xorigin + mp_axfraction[1] * (xwidth - newxwidth)
        newyorigin = yzoomlock[] ? yorigin : yorigin + mp_axfraction[2] * (ywidth - newywidth)

        timed_ticklabelspace_reset(ax, s.reset_timer, s.prev_xticklabelspace, s.prev_yticklabelspace, s.reset_delay)

        newrect_trans = if ispressed(scene, xzoomkey[])
            Rectf(newxorigin, yorigin, newxwidth, ywidth)
        elseif ispressed(scene, yzoomkey[])
            Rectf(xorigin, newyorigin, xwidth, newywidth)
        else
            Rectf(newxorigin, newyorigin, newxwidth, newywidth)
        end

        inv_transf = Makie.inverse_transform(transf)
        tlimits[] = Makie.apply_transform(inv_transf, newrect_trans)
    end

    # NOTE this might be problematic if if we add scrolling to something like Menu
    return Consume(true)
end

function set_scroll_to_pan!(ax::Axis)
    register_interaction!(ax, :scrollpan, ScrollPan(100.0, 0.5))
    deregister_interaction!(ax, :scrollzoom)
    register_interaction!(ax, :makieextrasscrollzoom, MakieExtrasScrollZoom(0.2     , 0.2))
end
