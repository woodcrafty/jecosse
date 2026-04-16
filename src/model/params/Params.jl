module Params

include("CarbonParams.jl")
include("NitrogenParams.jl")
include("SoilParams.jl")
include("WaterParams.jl")
include("PlantParams.jl")
include("FertiliserParams.jl")

export CarbonParams, NitrogenParams, SoilParams, WaterParams, PlantParams, FertiliserParams

end