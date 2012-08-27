%%% @author lengor <admin@lengors-macbook.local.lan>
%%% @copyright (C) 2012, lengor
%%% @doc
%%%
%%% @end
%%% Created : 20 Aug 2012 by lengor <admin@lengors-macbook.local.lan>

-module(stock_process).

-include("../include/stockapp.hrl").

-compile(export_all).

start(Stock)->
    register(Stock#stock.fla,spawn(?MODULE,init,[Stock])).

%% each stock process should have a unique db updater, any updates on the database should be performed by this process "only".

init(Stock)->
    DB_Pid = spawn(stockdb,stockdb, [ets:new(Stock#stock.fla,[ordered_set,public,{keypos,#stockObj.time},named_table])]),
    loop(Stock,DB_Pid).


loop(Stock,DB_Pid) ->
    receive
	Request when is_record(Request, request) ->
	    {MGS,SEC,MIS} = now(), 
	    Time =  ((MGS * 1000000) + SEC) * 1000000 + MIS,
	    StockObj =  #stockObj{price=Request#request.price,order=Request#request.order,time=Time,user=Request#request.user},
	    process_loop(DB_Pid,StockObj),
	    loop(Stock,DB_Pid)
    end.


process_loop(DB_Pid,StockObj)->
    DB_Pid ! {StockObj#stockObj.order,StockObj}.
	





































% case ets:select(DbName,[{#stockObj{order='_',price='$1',list='_'}}],[{'=:=','$1',Request#request.price}],['$1']) of
%	[] ->                         %% when no price matches it, ets:select returns a empty list.    ------ TEST TEST TEST
%	    handle_emptyList(DbName,Request);
	%% You Dumb fuck check for the lower best match and shit too,, that should go here
	%% send to pid that the order is been listed in our databeses; when your order matches any clients we will inform you
	%% and update the data base with this order
%	[RecStkObj] -> % RecStkDb - Record of Stock Database "stockdb"
%	    Pid_db_owner !{s_d_update,RecStkObj,Request},
%	    [_H|_T] =  lists:reverse(RecStkObj#stockObj.list),
						% select the last stock of the opposite request
						% Process the request
						% Check with the list, case empty list, delete the entry of stockdb from the ets table.
%	    ok
