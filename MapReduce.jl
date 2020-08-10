let
    include("plotCosts.jl")
    @everywhere include("MapperFunction.jl")
    include("ReducerFunction.jl")


    using DataFrames
    using CSV
    using Plots
    @everywhere using LinearAlgebra
    @everywhere using Statistics
    @everywhere using Random

    @everywhere function CostFunction(x)
         return ZDT(x)
    end

    function Reducer(archive)
        return ReducerFunction(archive)
    end
    ## SPEA2 Settings
    @everywhere include("mapreduceVariablesSettings.jl")


    function Popvalue(i,T)
        empty_individual = T(zeros(Int64,1,nVar),[],[],0,[],[],[],[],[],1)
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

    #[PoP[i:j] for i in 1:initialDataChunk:nPop for j in i+intialDataChunk-1:i+intialDataChunk-1]

    #Main Loop
    for it in 1:MaxIt
        Q = [PoP;archive];

        Q[1].iteration = it
        partition = mod(length(Q),initialDataChunk)!=0 ? error("Check initialDataChunk") : Int64(length(Q)/initialDataChunk)

        Collection = Iterators.partition(Q,partition)|>collect


        #Calling the mapper
        result = pmap((x)->Mapper(x),Collection; batch_size = batch_Size,distributed=true)
        archive = Iterators.flatten(result)|>collect

        println("Iteration ",it)
        if it >= MaxIt
           break;
        end
        #Calling the reducer
        PoP = Reducer(archive)
        #println(length(PoP));
    end


    sizee = length(archive);
    index = falses(sizee);
    for count in 1:sizee
        if archive[count].R == 0
            index[count] = true;
        end
    end

    global PF = archive[index];

    println([archive[i].G for i in 1:length(archive)])
    plotCosts(PF);
    sleep(0.01);
    #Results
    len = length(PF);
    PFC = zeros(2,len);
    for i in 1:len
        PFC[:,i] = PF[i].Cost;
    end

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
