
"""
Container for the first-order decay rate constants (k values) for the 
DPM, RPM and HYM pools used by RothC and it's derivatives.
"""
struct ECOSSEOrganicParams
    k_dpm::Float64
    k_rpm::Float64
    k_bio::Float64
    k_hum::Float64
    alpha::Float64
    beta::Float64
    delta::Float64
    gamma::Float64

    function ECOSSEOrganicParams(;
        k_dpm = )
end

