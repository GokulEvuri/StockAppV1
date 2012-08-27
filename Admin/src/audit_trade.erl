%%%-------------------------------------------------------------------
%%% @author lengor <admin@lengors-MacBook.local>
%%% @copyright (C) 2012, lengor
%%% @doc
%%%
%%% @end
%%% Created : 27 Aug 2012 by lengor <admin@lengors-MacBook.local>
%%%-------------------------------------------------------------------
-module(audit_trade).

-include("../include/stockapp.hrl").

-export([start/0, init/1]).


start() ->
    spawn(trade_process, init, [self()]).

init(From) ->
    ets:new(trade_db,[bag,public,{keypos,#trade.stock},named_table]),
    loop(From).

loop(From) ->
    receive
	{record_trade,User,Price,Stock,Order} ->
	    Recobj = #trade{user=User,stock=Stock,price=Price,order=Order},
	    ets:insert(trade_db,Recobj),
	    loop(From);
	 {audit,Stock,Pid}->
	    MatchPattern = #trade{user='_',stock=Stock,price='_',order='_'},
	    Pid ! ets:match(trade_db,MatchPattern)
    end.
