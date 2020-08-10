function MapperFunction(Q)


    nQ = length(Q);
    dom = falses(nQ,nQ);
    nArchiveMap = innerArch;
    it = Q[1].iteration;



    for i in 1:nQ
        Q[i].S = 0;
    end

    for i in 1:nQ
        for j in (i+1):nQ
            if Dominates(Q[i],Q[j])
                Q[i].S = Q[i].S+1;
                dom[i,j] =true;
            elseif Dominates(Q[j],Q[i])
                Q[j].S = Q[j].S+1;
                dom[j,i]= true;
            end
        end
    end


    #[println(Q[i].S) for i in 1:nQ];

    S=zeros(nQ,1);
    for sCount in 1:nQ
        S[sCount] = Q[sCount].S
    end

    for sCount in 1:nQ
        IND = dom[:,sCount]
        Q[sCount].R = sum(S[IND]);
    end

    Z=zeros(nQ,2);
    for k in 1:nQ
        Z[k,:] = Q[k].Cost';
    end

    #Place Holder
    #SIGMA = rand(nQ,nQ);
    SIGMA = pdist2(Z);

    for k in 1:nQ
        SIGMA[:,k] = sort(SIGMA[:,k]);
    end
    
    for i in 1:nQ
        Q[i].sigma = SIGMA[:,i];
        Q[i].sigmaK = Q[i].sigma[Int64(K)];
        Q[i].D = 1 ./(Q[i].sigmaK .+2);
        Q[i].F = Q[i].R + Q[i].D;
    end

    nND = 0;
    for i in 1:nQ
        if Q[i].R == 0
            nND+=1
        end
    end
    F = zeros(nQ);


    if nND <= nArchiveMap
        for i in 1:nQ
            F[i] = Q[i].F;
        end
        SO = sortperm(F);
        F = F[SO];
        for i in 1:nQ
            Q[i]=Q[SO[i]];
        end

        archive = Q[1:min(nArchiveMap,nQ)];
    else
        index = falses(nQ);
        for i in 1:nQ
            if Q[i].R == 0
                index[i] = true;
            end
        end
        SIGMA = SIGMA[:,index];
        archive=Q[index];
        k=2

        while length(archive)>nArchiveMap
            while minimum(SIGMA[k,:]) == maximum(SIGMA[k,:]) && k<size(SIGMA)[1]
                k+=1;
            end

            MinFind = minimum(SIGMA[k,:]);
            j = findfirst(SIGMA[k,:] .== MinFind);

            archive=archive[1:end .!=j];
            SIGMA = SIGMA[:,1:end .!=j];
        end
    end

    for uu in 1:nArchiveMap
        aa = isempty(archive[uu].G);
        if aa
            archive[uu].G = it;
        end
    end

    return archive
end
