function pdist2(Z)
    S = std(Z,dims = 1);

    
    S=S[1,:];
    (LEN,) = size(Z);

    d = zeros(LEN,LEN);

    Vinv = Diagonal(1 ./S .^2);

    v = zeros(1,2);
    for m in 1:LEN
        for n in 1:LEN
            v[:] = Z[m,:] - Z[n,:];
            d[m,n] = sqrt(v*Vinv*v')[1];
        end
    end
    return d;
end
