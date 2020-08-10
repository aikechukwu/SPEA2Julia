function ReducerFunction(archive)

#include("mapreduceVariablesSettings.jl")
#include("data.jl")

#Crossover
Num = Int64(nCrossover/2);
popc =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[],[]) for i in 1:nCrossover];
gamma = crossover_params.gamma;



popc1 =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[],[]) for i in 1:Num];
#popc1 = [popc1 popc1];

popc2 =[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[],[]) for i in 1:Num];
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
   popc[tt].G = pp[tt].G
end

#Mutation
popm=[empty_individual_(zeros(Int64,1,nVar),[],[],[],[],[],[],[],[],[]) for i in 1:nMutation];

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
return PoP = [popc
popm];
end
