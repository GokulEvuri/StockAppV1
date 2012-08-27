-module(user_tcp_manager).

-include("../include/stockapp.hrl").

-compile(export_all).


start(ListenSocket)->
   init(ListenSocket).

init(ListenSocket)->
    io:format("Got here init~n"),
    loop(ListenSocket).

loop(ListenSocket)->
     io:format("Got here loop~n"),
    accept_loop(ListenSocket).

accept_loop(ListenSocket) ->
     io:format("Got here accept_loop~n"),
    case gen_tcp:accept(ListenSocket) of
        {ok,Socket} ->
          io:format("Got here accept_socket~n"),
	    receive_loop(Socket),
            accept_loop(ListenSocket);
        Other ->
            io:format("accept returned ~w - goodbye!~n",[Other]),
            ok
    end.

receive_loop(S) ->
    inet:setopts(S,[{active,once}]),
    io:format("Got here receive_loop~n"),
    receive
	{tcp,S,Data} ->
	    PData = binary_to_list(Data),
	    io:format("~w~n",[PData]),
            receive_loop(S);
        {tcp_closed,S} ->
            io:format("Socket ~w closed [~w]~n",[S,self()]),
            ok
    end.
