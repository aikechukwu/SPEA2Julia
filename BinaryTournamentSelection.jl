function BinaryTournamentSelection(pop,f)
    n = length(pop);
    I = rand(1:n,2);

    il = I[1];
    i2 = I[2];

    if f[il]<f[i2]
        p = pop[il];
    else
        p = pop[i2];
    end
    return p;
end
