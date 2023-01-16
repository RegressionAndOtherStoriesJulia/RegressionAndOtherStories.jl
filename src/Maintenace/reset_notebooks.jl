function reset_notebook!(fname::AbstractString; display_actions=false) 

    if !isfile(fname)
        @warn "Notebook $fname does not exist!"
    end

    f = open(fname)
    c = readlines(f)
    display_actions && length(c) |> display

    d = Vector{String}()
    blocked = false
    done = false

    for i in 1:length(c) 
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

function reset_selected_notebooks_in_notebooks_df!(df::DataFrame; display_actions=false)
    for row in eachrow(df)
        if row.reset == true
            row.done = reset_notebook!(expanduser(row.file); display_actions=display_actions)
            row.reset = false
        end
    end
end
