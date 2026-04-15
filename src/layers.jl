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

"""
Remap intensive values from one layer scheme to another.

Use this function to remap intensive layer quantities such as pH, bulk density,
water holding capacites and percentages to a different layer scheme. intensive
quantities are those whose magnitude does not depend on the size of the layer.

Note that source_layers and destination_layers should be in the same units.

Arguments:
- source_values: array of intensive values to be remapped. The array should be the same length as the
    arrays contained in source_layers.
- source_layers - Layers struct describing the source layer scheme
- destination_layers - Layers struct describing the desitnation layer scheme
"""
function remap_intensive_values(source_values, source_layers::Layers, destination_layers::Layers)
    _array_matches_layers(source_values, source_layers) || error("source_values and source_layers arrays should be the same length")
    remapped = zeros(Float64, length(destination_layers.z1))
    for i = 1:length(destination_layers.z1)
        overlaps = overlap.(source_layers.z1, source_layers.z2, destination_layers.z1[i], destination_layers.z2[i])
        total_overlap = sum(overlaps)
        if total_overlap > 0
            remapped[i] = sum([sv * ol / total_overlap for (sv, ol) in zip(source_values, overlaps)])
        else
            remapped[i] = 0
        end
    end
    return remapped
end

"""
Remap extensive values from one layer scheme to another layer scheme.

Use this function to remap extensive layer quantities (e.g. soil carbon
content), to a different layer scheme. Extensive qunatities are additive over
multiple layers (i.e. their magnitude depends on the size of the layer
of which they are a property). 

Note that source_layers and destination_layers should be in the same units.

Arguments:
- source_values: array of extensive values to be remapped. The array should be the same length as the
    arrays contained in source_layers.
- source_layers - Layers struct describing the source layer scheme
- destination_layers - Layers struct describing the desitnation layer scheme
"""
function remap_extensive_values(source_values, source_layers::Layers, destination_layers::Layers)
    _array_matches_layers(source_values, source_layers) || error("source_values and source_layers arrays should be the same length")   
    remapped = zeros(Float64, length(destination_layers.z1))
    for i = 1:length(destination_layers.z1)
        overlaps = overlap.(source_layers.z1, source_layers.z2, destination_layers.z1[i], destination_layers.z2[i])
        remapped[i] = sum([sv * ol / sldz for (sv, ol, sldz) in zip(source_values, overlaps, source_layers.dz)])
    end
    return remapped
end


function _array_matches_layers(a, layers::Layers)
    return length(a) == length(layers.z1)
end

println("Remapping...")
#lyrs = Layers([5, 5, 10, 10])
water_layers = Layers([30])
om_layers = Layers([5, 5, 10, 10])
#overlap.(wlyrs.z1, wlyrs.z1, destination_layers.z1[i], destination_layers.z2[i])
println(remap_intensive_values([100], water_layers, om_layers))
println(remap_extensive_values([100], water_layers, om_layers))
println("Done.")
