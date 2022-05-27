using RegressionAndOtherStories

"""

Update the ros_notebooks DataFrame contents.

$(SIGNATURES)

## Positional arguments
```julia
* `df=ros_notebooks # DataFrame to be updated according to `./notebooks`
```

Not exported.

"""
function update_ros_notebooks!(df; display_actions=false)

    files = readdir(pwd(); join=true)
    for f in files
        if !(contains(f, ".DS_Store") || contains(f, "intros"))
            if isdir(f) && !contains(f, "intros") 
                display_actions && println("Found dir $f")
                add_to_ros_notebooks!(df, f)
            elseif isfile(f)
                display_actions && println("Found notebook $f")
                split_dir_path = split(f, "/")
                parts = split_dir_path[end-1:end]

                append!(df, 
                    DataFrame(
                        :chapter => parts[1],
                        :section => parts[2],
                        :reset => false
                    )
                )
            end
        end
    end
end

"""

Add entries to DataFrame `df` based on notebooks found in `dir_path`.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame to be updated according to `./notebooks`
* `dir_path::AbstractString` # Directory holding the notebooks
```

## Optional keyword arguments
```julia
* `display_actions=false # Display action steps taken
```

Not exported.

"""
function add_to_ros_notebooks!(df, dir_path;
    display_actions=false)

    files = readdir(dir_path; join=true)
    for f in files
        if !(contains(f, ".DS_Store") || contains(f, "intros"))
            if isdir(f)
                display_actions && println("Found dir $f")
                add_to_ros_notebooks!(df, f)
            elseif isfile(f)
                display_actions && println("Found notebook $f")
                split_dir_path = split(f, "/")
                parts = split_dir_path[end-1:end]

                append!(df, 
                    DataFrame(
                        :chapter => parts[1],
                        :section => parts[2],
                        :reset => false
                    )
                )
            end
        end
    end
end

"""

Reset a single notebook.

$(SIGNATURES)

## Positional arguments
```julia
* `fname::AbstractString` # Path to the notebook to be reset
```

## Optional keyword arguments
```julia
* `display_actions=false # Display action steps taken
* `create_pkg_files=false # Not implemented yet!
```

Not exported.

"""
function reset_notebook!(fname;
    display_actions=false, 
    create_pkg_files=false) # Not implemented yet

    f = open(fname)
    c = readlines(f)
    display_actions && length(c) |> display

    d = Vector{String}()
    blocked = false

    for i in 1:length(c) 
        if contains(c[i], "╔═╡ 00000000-0000-0000-0000-000000000001")
            blocked = true
            display_actions && println("Blocked at line $i")
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
    d
end

"""

Update notebook files from DataFrame `df` with `df.reset` set to `true`.

$(SIGNATURES)

## Optional positional arguments
```julia
* `df=ros_notebooks` # DataFrame with info on all notebooks
```

## Optional keyword arguments
```julia
* `display_actions=false # Display action steps taken
```

Exported.

"""
function update_notebooks!(df=ros_notebooks; display_actions=false)

    if !isdir("./notebooks")
        @error "You are not in a directory that holds a `notebooks` \
            subdirectory."
        return
    end

    if nrow(df) == 0
        @info "DataFrame ros_notebooks is empty!\n \
            It will be recreated from directory `./notebooks`."

        oldwd = pwd()
        cd("./notebooks")
        update_ros_notebooks!(df)
        display_actions && println()
        display_actions && df |> display
        display_actions && println()
        cd(oldwd)
    end

    if !all(df.reset)
        @info "All ros_notebooks.reset values are false. No actions taken. \
            \nUse `reset_notebooks!()`to reset all notebooks \
            \nor set some entries in ros_notebooks.reset to `true` \
            \nand run `update_notebooks!() again."
    end
    
    oldwd = pwd()
    isdir(joinpath(oldwd, "notebooks")) && cd("notebooks")
    if !contains(split(pwd(), "/")[end], "notebooks")
        @info "Notebooks directory not found."
        return
    end

    for f in eachrow(df)
        display_actions && println(f)
        if f.reset
            nb = joinpath(".", f.chapter, f.section)
            d = reset_notebook!(nb)

            fname = split(nb, "/")[end]
            new_path = joinpath(".", f.chapter, f.section)
            println("Updating file:$(new_path)")
            
            open(new_path, "w") do io
                for i in 1:length(d)
                    println(io, d[i])
                end
            end
            f.reset = false
            
        end
    end
    cd(oldwd)
end

"""

Reset all notebook files from df.

$(SIGNATURES)

## Optional positional arguments
```julia
* `df=ros_notebooks` # DataFrame with info on all notebooks
```

## Optional keyword arguments
```julia
* `display_actions=false # Display action steps taken
* `create_pkg_files=false # Not implemented yet!
```

Please see [this file](https://github.com/RegressionAndOtherStoriesJulia/RegressionAndOtherStories.jl/blob/main/src/Maintenance/README.md) for how to use these maintenance functions.

Exported.

"""
function reset_notebooks!(df=ros_notebooks; display_actions=false)

    if !isdir("./notebooks")
        @error "You are not in a directory that holds a `notebooks` \
            subdirectory."
        return
    end

    if nrow(ros_notebooks) > 0
        ros_notebooks.reset .= true
        update_notebooks!()
    else
        @info "DataFrame `ros_notebooks` is empty, \nupdate ros_notebooks first by running \
            `update_notebooks!()`"
        return
    end
end

export
    reset_notebooks!,
    update_notebooks!

