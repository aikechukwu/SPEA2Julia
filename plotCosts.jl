function plotCosts(PFF)


   len = length(PFF);
   PFC =  zeros(2,len);

   for i in 1:len
      PFC[:,i] = PFF[i].Cost[:];
   end

    fig = plot(PFC[1,:], PFC[2,:], seriestype = :scatter,xlabel="Unavailability",ylabel="Cost");
    savefig(fig,string("Result Plot.png"));
end
