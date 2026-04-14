module Layers2

"""
- z1: Distance from the surface to the top of each layer [cm]
- z2: Distance from the surface to the bottom of each layer [cm]
- zmid: Distance from the surface to the middle of the layer [cm]
- dz: Depth (thickness) of the layer [cm]
"""
struct Layers
    z1::Vector{Float64}
    z2::Vector{Float64}
    zmid::Vector{Float64}
    dz::Vector{Float64}

    """
    - dz_layers: Array specifying the depth (thickness) of each layer, starting from the surface [cm]
        e.g. [5, 5, 10] will produce the layers that look like this:

                ---- 0 cm (surface)
        layer 1
                ---- 5 cm
        layer 2
                ---- 10 cm
        
        layer 3
                ---- 20 cm
    """
    function Layers(dz_layers)
        any(dz_layers .<= 0) && error("dz_layer must contain only positive numbers")
        z1 = [i == 1 ? 0 : sum(dz_layers[1:i-1]) for i=1:length(dz_layers)]
        z2 = [z + dz for (z, dz) in zip(z1, dz_layers)]
        zmid = (z1 + z2) / 2
        dz = z2 - z1
        return new(z1, z2, zmid, dz)
    end
end

#lyrs = Layers([5.0, 5.0, 10.0, 10.0])
lyrs = Layers([5, 5, 10, 10])
println(lyrs)
println(lyrs.z1)

end