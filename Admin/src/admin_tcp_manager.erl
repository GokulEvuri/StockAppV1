-module(admin_tcp_manager).
-include("../include/stockapp.hrl").
-define(ListenPort,8091).
-compile(export_all).


start()->
    case  gen_tcp:listen(?ListenPort,[binary,{packet,2},{active,false}]) of
	{ok,ListenSock} ->
	    start_server(ListenSock);
	{error,Reason} ->
	    {error,Reason}
    end.

start_server(ListenSock)->
    server(ListenSock).

server(ListenSock) ->
    case gen_tcp:accept(ListenSock) of
	{ok,Socket}->
	   spawn_link(?MODULE,loop,[Socket]),
	    server(ListenSock);
	Other ->
	    io:format("problem with gen_tcp:accept, returned ~w ~n",[Other]),
	    ok
    end.

loop(Socket) ->
    inet:setopts(Socket,[{active,once}]),
    receive
	{tcp,Socket,Data}->
	    spawn(?MODULE,handle_tcp_data,[Data,Socket]);
	{tcp_closed,Socket} ->
	    io:format("Socket ~w closed [~w]~n",[Socket,self()]),
	    ok
    end.


handle_tcp_data(<<Fla,_SName,Order,Price>>,Socket)->
    FLa = binary_to_list(Fla),
    ORder = binary_to_list(Order),
    User = #user{socket=Socket,pid='undefined'},
    Request = #request{order=ORder,price=Price,user=User},
    case is_FLa_started(FLa) of
	{ok,started}->
	    FLa ! Request;
	{info,_Info} ->
	    handle_send_data(Socket,"The Stock you are trying to buy doesnot trade with us, for now. Please Checkin Later for this. Thank You")
    end.

is_FLa_started(FLa) ->
   case lists:member(FLa,registered()) of
       true->
	   {ok,started};
       false ->
	   {info,not_started_or_crashed}
   end.

handle_send_data(Socket,Message)->
    gen_tcp:send(Socket,list_to_binary(Message)).
