using MakieExtras
using Documenter

DocMeta.setdocmeta!(MakieExtras, :DocTestSetup, :(using MakieExtras); recursive=true)

makedocs(;
    modules=[MakieExtras],
    authors="Patrick Bouffard <bouffard@eecs.berkeley.edu> and contributors",
    repo="https://github.com/pbouffard/MakieExtras.jl/blob/{commit}{path}#{line}",
    sitename="MakieExtras.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://pbouffard.github.io/MakieExtras.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pbouffard/MakieExtras.jl",
    devbranch="main",
)
