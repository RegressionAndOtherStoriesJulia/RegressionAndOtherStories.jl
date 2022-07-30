import PlutoPDF

function create_pdfs(path::Union{AbstractString, Nothing}=nothing)
    if path == nothing
        @info "create_pdfs() expect a path to the notebook files."
        return
    end
    if isdir(path)
        cd(path)
    end
    files = readdir(path; join=true)
    @info "Creating PDF file for:"
    for file in files
        if !(file[end-8:end] == ".DS_Store")
            fin = split(file, '/')[end]
            print(fin)
            print(" => ")
            fout = "../../pdfs/" * fin[1:end-3] * ".pdf"
            println(fout)
            PlutoPDF.pluto_to_pdf(fin, fout)
        end
    end
end

export
    create_pdfs