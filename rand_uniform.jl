#Draw a uniform random sample in the interval (a,b)
function rand_uniform(a,b,M=1,N=1)

    A = zeros(M,N);

    for i in 1:M
        for j = 1:N
            A[i,j] = a .+ rand().*(b - a);
        end
    end
    return A;
end
