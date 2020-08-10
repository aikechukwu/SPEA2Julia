let
    include("ZDT.jl")
    include("Dominates.jl")
    include("plotCosts.jl")
    include("BinaryTournamentSelection.jl")
    include("rand_uniform.jl")
    include("pdist.jl")
    include("FeasibleRegion.jl")
    include("SearchSpace.jl")

    using LinearAlgebra
    using Statistics
    using Random


    function CostFunction(x)
         return ZDT(x)
    end

    nVar=10;             # Number of Decision Variables

    VarSize=[nVar 1];    # Decision Variables Matrix Size

    VarMin=ones(Int64,1,10);        # Decision Variables Lower Bound
    VarMax= [7	6	3	4	2	3	5	6	8	4];           # Decision Variables Upper Bound

    ## SPEA2 Settings

    MaxIt = 50;          # Maximum Number of Iterations


    nPop=500;            # Population Size

    nArchive=500;        # Archive Size

    K=round(sqrt(nPop+nArchive));  # KNN Parameter

    pCrossover=0.7;
    nCrossover=round(pCrossover*nPop/2)*2;

    pMutation=1-pCrossover;
    nMutation=nPop-nCrossover;

    struct crossover_params_
        gamma
        VarMin
        VarMax
    end
    struct mutation_params_
        h
        VarMin
        VarMax
    end

    crossover_params = crossover_params_(0.1,VarMin,VarMax)
    mutation_params = mutation_params_(0.2,VarMin,VarMax)

    mutable struct empty_individual_
        Position
        Cost
        S
        R
        sigma
        sigmaK
        D
        F
        G
    end


    function Popvalue(i,T)
        empty_individual = T(zeros(Int64,1,nVar),[],[],0,[],[],[],[],[])
        PoPulation = empty_individual;
        for j in 1:nVar

            ndex = VarMax[j];
            hold = rand(1:ndex);
            PoPulation.Position[j]= hold;
        end
        PoPulation.Cost=CostFunction(PoPulation.Position);
        return PoPulation;
    end

    PoP = [Popvalue(i,empty_individual_) for i in 1:nPop];
    archive = [];

    #Main Loop
    for it in 1:MaxIt

        Q = [PoP;archive];



        nQ = length(Q);

        dom = falses(nQ,nQ);

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
        if nND <= nArchive
            for i in 1:nQ
                F[i] = Q[i].F;
            end
            SO = sortperm(F);
            F = F[SO];
            for i in 1:nQ
                Q[i]=Q[SO[i]];
            end

            archive = Q[1:min(nArchive,nQ)];
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

            while length(archive)>nArchive
                while minimum(SIGMA[k,:]) == maximum(SIGMA[k,:]) && k<size(SIGMA)[1]
                    k+=1;
                end

                MinFind = minimum(SIGMA[k,:]);
                j = findfirst(SIGMA[k,:] .== MinFind);

                archive=archive[1:end .!=j];
                SIGMA = SIGMA[:,1:end .!=j];
            end
        end



        for uu in 1:nArchive
            aa = isempty(archive[uu].G);
            if aa
                archive[uu].G = it;
            end
        end

        sizee = length(archive);
        index = falses(sizee);
        for count in 1:sizee
            if archive[count].R == 0
                index[count] = true;
            end
        end

        using Plots

        global PF = archive[index];


        plotCosts(PF);
        sleep(0.01);

        println("SearchSpace ", SearchSpace(10,T,1000))
        println("FeasibleRegion ", FeasibleRegion(10,MTTF,1000))


        println("Iteration " ,it ," : Number of PF members = ",length(PF));

       if it >= MaxIt
           break;
       end

       #Crossover
       Num = Int64(nCrossover/2);
       popc =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[]) for i in 1:nCrossover];
       gamma = crossover_params.gamma;



       popc1 =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[]) for i in 1:Num];
       #popc1 = [popc1 popc1];

       popc2 =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[]) for i in 1:Num];
       #popc2 = [popc2 popc2];

       F = zeros(length(archive));
       for i in 1:length(archive)
           F[i] = archive[i].F;
       end



       for c in 1:Int64(nCrossover/2)
           p1 = BinaryTournamentSelection(archive,F);
           p2 = BinaryTournamentSelection(archive,F);


           alpha1 = rand_uniform(-gamma,1+gamma,1,nVar);
           x1=p1.Position;
           x2 =p2.Position;

           params = crossover_params;

           VarMin1 = params.VarMin;
           VarMax1 = params.VarMax;

           y1 = round.(alpha1 .*x1 .+(1 .-alpha1) .*x2);
           y1 =Int64.(min.(max.(y1,VarMin1),VarMax1));

           y2 = round.(alpha1 .*x2 .+(1 .-alpha1).*x1);
           y2 = Int64.(min.(max.(y2,VarMin1),VarMax1));

           popc1[c].Position = y1;
           popc2[c].Position = y2;

           popc1[c].Cost = CostFunction(popc1[c].Position);
           popc2[c].Cost = CostFunction(popc2[c].Position);

       end
       pp = [popc1;popc2];

       for tt in 1:length(popc)
           popc[tt].Position=pp[tt].Position;
           popc[tt].Cost = pp[tt].Cost;
       end

       #Mutation
       popm=[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[]) for i in 1:nMutation];

       for m in 1:Int64(nMutation)
           p = BinaryTournamentSelection(archive,F);
           xxx = p.Position;
           params = mutation_params;
           h = params.h;
           VarMin2 = params.VarMin;
           VarMax2 = params.VarMax;

           sigma =h .*(VarMax.-VarMin);
           xx = randn(1,nVar);
           yy = round.(xxx .+sigma .*xx);

           popm[m].Position = min.(max.(yy,VarMin),VarMax);
           popm[m].Cost = CostFunction(popm[m].Position);
       end
       PoP = [popc
       popm];
    end

    #Results
    len = length(PF);
    PFC = zeros(2,len);
    for i in 1:len
        PFC[:,i] = PF[i].Cost;
    end

    using DataFrames
    using CSV

    finalResult = DataFrame(objective=String[],Minimum=Float64[],Maximum=Float64[],Range=Float64[],Std=Float64[],Mean=Float64[]);

    obj =("Unavailability","Cost");

    for j in 1:2
        println("  ");
        println("Objective","  ",obj[j],":");
        println("       Min   = ",round(minimum(PFC[j,:]),digits=6));
        println("       Max   = ",round(maximum(PFC[j,:]),digits=6));
        println("       Range = ",round(maximum(PFC[j,:])-minimum(PFC[j,:]),digits=6));
        println("       St.D. = ",round(std(PFC[j,:]),digits=6));
        println("       Mean  = ",round(mean(PFC[j,:]),digits=6));
        println("  ");
        push!(finalResult,(obj[j],round(minimum(PFC[j,:]),digits=6),round(maximum(PFC[j,:]),digits=6),round(maximum(PFC[j,:])-minimum(PFC[j,:]),digits=6),round(std(PFC[j,:]),digits=6),round(mean(PFC[j,:]),digits=6)));
    end

    println(finalResult);
    println();
    CSV.write("FinalMaxMinResult.csv", finalResult);
    include("STable.jl");
end
