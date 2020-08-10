using Distributed
hold=pmap(x->iseven(x) ? error("foo") : x, 1:25; on_error=ex->0,batch_size=10,distributed=true);
print(hold)
