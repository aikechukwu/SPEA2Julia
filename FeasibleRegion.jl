function FeasibleRegion(m,ATF,T)
    alpha =div.(ATF,T)
    return prod(alpha)
end
