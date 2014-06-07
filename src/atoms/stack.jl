import Base.vcat, Base.hcat, Base.hvcat
export vcat, hcat, hvcat

# TODO: don't allow all constants

function vcat(args::AffineOrConstant...)
  println("VCAT")

end

function vcat(args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  vcat(args_converted...)
end



function hcat(args::AffineOrConstant...)
  println("HCAT")

end


function hcat(args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  hcat(args_converted...)
end

function hvcat(rows::(Int64...), args::AffineOrConstant...)
   println("HVCAT")

end

function hvcat(rows::(Int64...), args::AffineOrValue...)
  args_converted = AffineOrConstant[]
  for arg in args
    if typeof(arg) <: Value
      push!(args_converted, Constant(arg))
    else
      push!(args_converted, arg)
    end
  end
  hvcat(rows, args_converted...)
end


