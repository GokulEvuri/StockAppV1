-module(stock_tcp_handler).
-include("../include/stockapp.hrl").
-compile(export_all).

start(_,_)->
    register(tcp_shandler, AppPid = spawn(test,init,[[]])),
    ets:new(stock_table,[set,public,named_table,{keypos,#stocktrend.fla}]),
    {ok, AppPid}.

init(State)->
    loop(State).

loop(State)->
    receive
	{add_stock,Stock} ->
	    self() ! {spawn_stock,Stock},
	    StockTrend = #stocktrend{fla = Stock#stock.fla, stock_Name = Stock#stock.stock_Name}
	    ets:insert(stock_table,StockTrend)
	    loop(State);
	{spawn_stock,Stock}->
	    stock_process:start(Stock),
	    loop(State);
	{list_all_Stocks} ->
	    io:format("~n~w~n",[ets:select(stock_table,[{#stocktrend{fla='$1',stock_Name='$2'}}],[],['$2'])]),
	    loop(State);
	{get_lowest_trade,Stock} ->
	    Stock#stock.fla ! {get_lowest_trade},
	    loop(State);
	{get_higest_trade,Stock} ->
	    Stock#stock.fla ! {get_higest_trade},
	    loop(State)
    end.

stop(_)->
    ok.
