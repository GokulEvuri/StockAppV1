-module(gen_tcp_test).
-compile(export_all).

client() ->
    SomeHostInNet = {127,0,0,1},
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 8091, 
                                 [binary,{active,true}]),
    ok = gen_tcp:send(Sock, "Some Data").
