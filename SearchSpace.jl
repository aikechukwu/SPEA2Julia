function SearchSpace(m,T,RT)
    alpha = div.(RT,T)
    return prod(alpha)
end
