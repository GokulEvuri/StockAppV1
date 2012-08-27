%%%-------------------------------------------------------------------
%%% @author lengor <admin@lengors-MacBook.local>
%%% @copyright (C) 2012, lengor
%%% @doc
%%%
%%% @end
%%% Created : 26 Aug 2012 by lengor <admin@lengors-MacBook.local>
%%%-------------------------------------------------------------------

-module(user_server).

-include("../include/stockapp.hrl").

-define(LocalPort,8091).

-export([start/1,init/2,loop/1]).
%-compile(export_all).


start({IPAdress,Port})->
   init(IPAdress,Port).

init(IP,Port)->
    case  gen_tcp:connect(IP,Port,[binary,{packet,2},{active,false},{port,?LocalPort}]) of
	{ok,AppSocket} ->
	    register(user_server,spawn_link(?MODULE,loop,[AppSocket])),
	    spawn_link(user_tcp_manager,start,[AppSocket]);
	_ ->
	    io:format("The server side port is not opened for listening, please contact application admin")
    end.

loop(AppSocket)->
    receive	
	{sell,Stock,Price}->
	    Fla = list_to_binary(Stock#stock.fla), 
	    SName = list_to_binary(Stock#stock.stock_Name),
	    Order = list_to_binary("sell"),
	    BinData = <<Fla/binary,SName/binary,Order/binary,Price>>,
	    gen_tcp:send(AppSocket,BinData),
	    loop(AppSocket);
	
	{buy,Stock,Price}->
	    Fla = list_to_binary(Stock#stock.fla), 
	    SName = list_to_binary(Stock#stock.stock_Name),
	    Order = list_to_binary("buy"),
	    BinData = <<Fla/binary,SName/binary,Order/binary,Price>>,
	    gen_tcp:send(AppSocket,BinData),
	    loop(AppSocket);
	{cancel,OrderID} ->
	    Order = list_to_binary("cancel"),
	    Data = <<Order/binary,OrderID>>,
	    gen_tcp:send(AppSocket,Data)
    end.
