function plot_models(models::Vector{SampleModel}, type::Symbol;
  fig="", title = uppercase(String(type)))

  mnames = [models[i].name for i in 1:length(models)]
  for i in 1:length(mnames)
    if length(mnames[i]) > 9
      mnames[i] = mnames[i][1:9]
    end
  end

  df_waic = compare(models, type)
  plot_models(df_waic, type; fig, title)
end

export
  plot_models