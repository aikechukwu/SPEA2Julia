function Dominates(x,y)

    if isstructtype(typeof(x)) && fieldname(typeof(x),2) == :Cost
        x=x.Cost;
    end

    if  isstructtype(typeof(y)) && fieldname(typeof(y),2) == :Cost
        y=y.Cost;
    end

    return (x[1]<=y[1] && x[2]<=y[2]) && (x[1]<=y[1] || x[2]<=y[2]);

end
