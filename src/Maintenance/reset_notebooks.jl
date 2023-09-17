"""

This function provides:

1. Reset a Pluto notebook by removing Project and Manifest sections. This will
ensure the latest version of packages will be used.
2. During development work on projects and packages I often use `Pkg.activate()` and work
in a project environment to have updates installed. This function comments out such a line,
typically before I merge the project back to Github.

$(SIGNATURES)

"""
function reset_notebook!(fname::AbstractString;
    display_actions=true, reset_activate=true, set_activate=false) 

    if !isfile(fname)
        @warn "Notebook $fname does not exist!"
    end

    if reset_activate && set_activate
        @warn "Both `reset_activate` and `set_activate` are true. No action will be taken."
    end

    f = open(fname)
    c = readlines(f)
    display_actions && length(c) |> display

    d = Vector{String}()
    blocked = false
    done = false

    for i in 1:length(c)

        if reset_activate && !set_activate
            if contains(c[i], "Pkg.activate(") && !contains(c[i], "#Pkg.activate(")
                c[i] = "#" * c[i]
                @info "Disabled `Pkg.activate()` on line $i in $(split(fname, "/")[end])."
            elseif contains(c[i], "#Pkg.activate(")
                @info "`Pkg.activate()` on line $i in $(split(fname, "/")[end]) already commented out."
            end
        end

        if set_activate && !reset_activate
            if contains(c[i], "#Pkg.activate(")
                if c[i][1] == '#'
                    c[i] = c[i][2:end]
                    @info "Enabled `Pkg.activate()` on line $i in $(split(fname, "/")[end])."
                else
                    @info "No `#Pkg.activate()` found in file."
                end
            end
        end

        if contains(c[i], "╔═╡ 00000000-0000-0000-0000-000000000001")
            blocked = true
            display_actions && println("Blocked at line $i")
            done = true
        end

        if contains(c[i], "╔═╡ Cell order")
            blocked = false
            display_actions && println("Unblocked at line $i")
        end

        if !blocked
            if i < 3
                display_actions && println(c[i])
            end
            if !contains(c[i], "╟─00000000-0000-0000-0000-000000000001") &&
                !contains(c[i], "╟─00000000-0000-0000-0000-000000000002")

                push!(d, c[i])
            end
        end
    end
    open(fname, "w") do io
        for i in 1:length(d)
            println(io, d[i])
        end
    end
    done
end

"""

This function provides:

1. Reset selected Pluto notebooks by removing Project and Manifest sections. This will
ensure the latest version of packages will be used.
2. During development work on projects and packages I often use `Pkg.activate()` and work
in a project environment to have updates installed. This function comments out such a line,
typically before I merge the project back to Github.

$(SIGNATURES)

See the Maintenance Pluto notebooks in the `Regression And Other Stories` and `Statistical Rethinking` projects.

"""
function reset_selected_notebooks_in_notebooks_df!(df::DataFrame;
    display_actions=false, reset_activate=true, set_activate=false)
    for row in eachrow(df)
        if row.reset == true
            row.done = reset_notebook!(expanduser(row.file);
                display_actions, reset_activate, set_activate)
            row.reset = false
        end
    end
end
