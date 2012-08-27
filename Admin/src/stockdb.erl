% This module has been designed to not to have different processes modify/acess the data bases to make a mess
% Have tried with different designes, which have been making job more complicated, so decided to go with this model.
-module(stockdb).
-include("../include/stockapp.hrl").
-compile(export_all).

stockdb(ETNW,Stock) ->
    receive
	{buy,StockObj}->
	    handle_buy(ETNW,#request{order=StockObj#stockObj.order,price=StockObj#stockObj.price,
				     user=StockObj#stockObj.user},Stock),
	    stockdb(ETNW,Stock);
	{sell,StockObj} ->
	    handle_sell(ETNW,#request{order=StockObj#stockObj.order,price=StockObj#stockObj.price,
				      user=StockObj#stockObj.user},Stock),
	    stockdb(ETNW,Stock);
	{withdraw,StockObj} ->
	    handle_withdraw(ETNW,StockObj)
end.

handle_sell(ETNW,Request,Stock)->
    case  ets:select(ETNW,[{#stockObj{price='$1',order="buy",time='_',user='_'},
			    [{'==','$1',Request#request.price}],['$_']}],1) of
	'$end_of_table' -> 
	    handle_empty_list(ETNW,Request, ets:select(ETNW,[{#stockObj{price='$1',order="sell",time='_',user='_'},
							      [{'<','$1',Request#request.price}],['$_']}],1),Stock); 
	%% "Best match" with "first come first" 
	
	[{_,Price,Order,Time,User}] ->
	    MatchPattern = #stockObj{price=Price,order=Order,time=Time,user=User},
	    ets:match_delete(ETNW,MatchPattern),
	    Message = list_to_binary("Congratulations, Your order has been processed with price"),
	    gen_tcp:send(User#user.socket,<<Message/binary,Price>>),
	    Price1 = Request#request.price,
	    gen_tcp:send(Request#request.user#user.socket,<<Message/binary,Price1>>),
	    inform_trade(tcp_shandler,{set_trade_price,Stock,Price}),
	    inform_trade(trade_process,{record_trade,User,Price}),
	    inform_trade(trade_process,{record_trade,Request#stockObj.user,Price})
    end.


handle_buy(ETNW,Request,Stock)->
    case  ets:select(ETNW,[{#stockObj{price='$1',order="sell",time='_',user='_'},
			    [{'==','$1',Request#request.price}],['$_']}],1) of
	'$end_of_table' -> 
	    handle_empty_list(ETNW,Request, ets:select(ETNW,[{#stockObj{price='$1',order="sell",time='_',user='_'},
							      [{'>','$1',Request#request.price}],['$_']}],1),Stock);
	
	[{_,Price,Order,Time,User}] ->
	    MatchPattern = #stockObj{price=Price,order=Order,time=Time,user=User},
	    ets:match_delete(ETNW,MatchPattern),
	    Message = list_to_binary("Congratulations, Your order has been processed with price"),
	    Data = <<Message/binary,Price>>,
	    gen_tcp:send(User#user.socket,Data),
	    gen_tcp:send(Request#request.user#user.socket,Data),
	    inform_trade(tcp_shandler,{set_trade_price,Stock,Price}),
	    inform_trade(trade_process,{record_trade,User,Price}),
	    inform_trade(trade_process,{record_trade,Request#stockObj.user,Price})

    end.

handle_withdraw(ETNW,StockObj)->
    case ets:delete(ETNW,StockObj#stockObj.time) of 
	%% It is taken care that no two orders can have same time stamp, so relaying on time stamp
	true ->
	    gen_tcp:send(StockObj#stockObj.user#user.socket,list_to_binary("Your cancelation request has been processed")),					
						% and inform uset that the request has been processed
	    ok;
	_->
	    gen_tcp:send(StockObj#stockObj.user#user.socket,
			 list_to_binary("Your cancelation request cannot be processed at this time")),						
						% inform user that the operation has been failed
	    {not_deleted}
    end.

handle_empty_list(ETNW,StockObj,{[{_,Price,Order,Time,User}],_Con},Stock)->
    MatchPattern = #stockObj{price=Price,order=Order,time=Time,user=User},
    ets:match_delete(ETNW,MatchPattern),
    Message = list_to_binary("Congratualions your order has been processed at price "),
    Data = <<Message/binary,Price>>,
    inform_trade(tcp_shandler,{set_trade_price,Stock,Price}),
    inform_trade(trade_process,{record_trade,User,Price}),
    inform_trade(trade_process,{record_trade,StockObj#stockObj.user,Price}),
    gen_tcp:send(User#user.socket,Data),	%and inform user that he had his stock
    gen_tcp:send(StockObj#stockObj.user#user.socket,Data);

handle_empty_list(ETNW,StockObj,'$end_of_table',_Stock) ->
    ets:insert(ETNW,StockObj),
    Message = list_to_binary("Congratulations your order has been placed in our database, 
will inform you when it processes, to cancel your request please use this ID "),
    Id = StockObj#stockObj.time,
    Data = <<Message/binary,Id>>,
    gen_tcp:send(StockObj#stockObj.user#user.socket,Data)
						% and inform user that his stock order has been placed in database
    .
inform_trade(Process,Data)->
    Process ! Data.
