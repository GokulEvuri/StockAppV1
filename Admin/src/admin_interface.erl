-module(admin_interface).

-include("../include/stockapp.hrl").

-compile(export_all).

add_stock(Stock) when is_record(Stock,stock) ->
    case catch   tcp_shandler ! {add_stock,Stock} of
	{'EXIT',{badarg,_}}-> "please wait untill tcp_shandler starts";
	_ -> "Request sent"
    end;

add_stock(_) ->
    {error, {"Request sent failed, Stock record is not valid"}}.

list_all_stocks()->
    case catch   tcp_shandler ! {list_all_Stocks} of
	{'EXIT',{badarg,_}}-> "please wait untill tcp_shandler starts";
	_ -> "Request sent"
    end.

get_lowest_trade(Stock) ->
    case catch   tcp_shandler ! {get_lowest_trade,Stock} of
	{'EXIT',{badarg,_}}-> "please wait untill tcp_shandler starts";
	_ -> "Request sent"
    end.

get_higest_trade(Stock) ->
    case catch   tcp_shandler ! {gethigest_trade,Stock} of
	{'EXIT',{badarg,_}}-> "please wait untill tcp_shandler starts";
	_ -> "Request sent"
    end.

audit_trade(Stock)->
        case catch   trade_process ! {audit,Stock,spawn(?MODULE,auditreceive,[])} of
	{'EXIT',{badarg,_}} -> "please wait untill tcp_shandler starts";
	_ -> "Request sent"
	end.

auditreceive()->
    receive
	Audit ->	
	    io:format("Audit of stock is ~w",[Audit])
    end.
