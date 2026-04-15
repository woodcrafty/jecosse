# This file contains types and functions for handling layers

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
    - dz_layers: Array of numbers specifying the depth (thickness) of each layer from [cm]
        Layers are specified beginning with the layer closest to the surace and ending with the deepest layer
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

"""
Return the index of the layer corresponding to a depth.

If the depth does not correspond to any of the layers, the function returns nothing.
"""
function index_from_depth(lyrs::Layers, depth)
    for i = 1:length(lyrs.z1)
        if depth >= lyrs.z1[i] && depth < lyrs.z2[i]
            return i
        end
        if depth == lyrs.z2[i]
            return i
        end
    end
    return nothing
end

"""
Return the extent of overlap between two layers, a and b.

Both layers should be in the same units. If there is no overlap between
the layers, 0 is returned.

Arguments:
- az1: Distance from the surface to the top of layer a
- az2: Distance from the surface to the top of layer a
- bz1: Distance from the surface to the top of layer b
- bz2: Distance from the surface to the top of layer b
"""
function overlap(az1, az2, bz1, bz2)
    adz = az2 - az1         # Depth (thickness) of layer a
    bdz = bz2 - bz1         # Depth (thickness) of layer b

    # No overlap between layers
    if az1 >= bz2 || az2 <= bz1
        return 0
    # Top of a lies within b and...
    elseif bz1 <= az1 && az1 < bz2
        #...bottom of a is within b, so a lies completely within b
        if az2 <= bz2
            return adz
        #...bottom of a lies below bottom of b
        else
            return bz2 - az1
        end
    # Top of a lies above b and...
    else
        #...bottom of a lies inside of b
        if bz1 < az2 && az2 <= bz2
            return az2 - bz1
        #...bottom of a lies below bottom of b so b is completely
        # contained by within above
        elseif az2 > bz2
            return bdz
        end
    end
    error("invalid logic in overlap()")  # Should never reach this line
end

function transcribe_intensive_values(source_values, source_layers::Layers, destination_layers::Layers)
    length(source_values) == length(source_layers.z1) || error("source_values and source_layers arrays should be the same length")
    new_values = zeros(Float64, length(destination_layers.z1))
    for i = 1:length(destination_layers.z1)
        overlaps = overlap.(source_layers.z1, source_layers.z1, destination_layers.z1[i], destination_layers.z2[i])
        total_overlap = sum(overlaps)
        if total_overlap > 0
            new_values[i] = sum([sv * ol / total_overlap for (sv, ol) in zip(source_value, overlaps)])
        else
            new_values[i] = 0
        end
    end
    return new_values
end

#lyrs = Layers([5.0, 5.0, 10.0, 10.0])
water_layers = Layers([10, 20])
om_layers = Layers([5, 5, 10, 10])
transcribe_intensive_values([5, 10], water_layers, om_layers)
