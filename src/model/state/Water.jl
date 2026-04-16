module SoilWaterState

import Params


"""
Holds soil water state variables.

# Fields
- `aw`: available water content [mm/layer]
- `w`:  water content (equal to wiltpoint + available water) [mm/layer]
- `wd_below_fc`: water deficit below field capacity [mm/layer]
- `drain`: water drained through each layer [mm/layer]
- `wfps`: water-filled pore space [proportion]
- `wt`: depth from soil surface to the water table. Negative values denote a WT above the soil surface [cm]
"""
struct WaterState
    # Public state variables
    available_water::Vector{Float64}
    water::Vector{Float64}
    drain::Vector{Float64}
    wd_below_fc::Vector{Float64}
    wfps::Vector{Float64}
    water_table::Float64

    function WaterState(layers::Layers.LayerScheme, waterparams::Params.WaterParams)
        available_water = fill(waterparams.aw_fc, layers.nlayers)   # Initialise to field capacity
        water = available_water .+ waterparams.wc_wp                # Add wiltpoint water to get water content at field capacity
        drain = zeros(layers.nlayers)
        wd_below_fc = zeros(layers.nlayers)
        wfps = water ./ waterparams.wc_sat
        water_table = layers.z2[layers.nlayers]   # Initialise it to the bottom of the soil column
        return new(available_water, water, drain, wd_below_fc, wfps, water_table)
    end
end

end  # of module