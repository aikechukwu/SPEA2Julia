include("BinaryTournamentSelection.jl")
include("Dominates.jl")
include("ZDT.jl")
include("rand_uniform.jl")
include("pdist.jl")
include("data.jl")

initialDataChunk =10 #Number of data chunk

MaxIt = 500;          # Maximum Number of Iterations
nPop=500;            # Population Size
nArchive=500;        # Archive Size
batch_Size = 4;      # batch size for the mapreduce
K=round(sqrt(nPop+nArchive));  # KNN Parameter


divValue =  Int64(nArchive/initialDataChunk);
innerArch = (mod(nArchive,initialDataChunk) != 0) || (divValue < K) ? error("Check initialDataChunk") : divValue;



VarMin=ones(Int64,1,10);        # Decision Variables Lower Bound
VarMax= [7	6	3	4	2	3	5	6	8	4];           # Decision Variables Upper Bound

pCrossover=0.7;
nCrossover=round(pCrossover*nPop/2)*2;

pMutation=1-pCrossover;
nMutation=nPop-nCrossover;
nVar=10;             # Number of Decision Variables
VarSize=[nVar 1];    # Decision Variables Matrix Size


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
        iteration
    end

    function CostFunction(x)
         return ZDT(x)
    end


    function Mapper(Q)
        return MapperFunction(Q)
    end

println("Loaded")
