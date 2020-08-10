dd = PF;
sw = Vector{Char}("af(0) bp(0) cp(0) fm(0) ht(0) if(0) me(0) mt(0) st(0) vm(0)");


df = DataFrame(Combination=String[],Unavailability=Float64[],Cost=Float64[],Generation=Int[])



mutable struct M_
    Combination
    Unavailability
    Cost
    Generation
end

Mt = M_([],[],[],[]);
M = [Mt for i in 1:length(dd)];

for jj = 1:length(dd)
    M[jj].Combination = sw;
    M[jj].Unavailability = dd[jj].Cost[1];
    M[jj].Cost = dd[jj].Cost[2];
    M[jj].Generation = dd[jj].G
    bb = 0;
    for kk = 4:6:58
        bb+=1;
        M[jj].Combination[kk] = Char('0'+Int64(dd[jj].Position[bb]));
    end

   if !isempty(M[jj].Generation)
       push!(df,(String(M[jj].Combination),M[jj].Unavailability,M[jj].Cost,M[jj].Generation));
   end
end



CSV.write("Result.csv", df)
println(df);
