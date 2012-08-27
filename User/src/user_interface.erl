%%%-------------------------------------------------------------------
%%% @author lengor <admin@lengors-MacBook.local>
%%% @copyright (C) 2012, lengor
%%% @doc
%%%
%%% @end
%%% Created : 26 Aug 2012 by lengor <admin@lengors-MacBook.local>
%%%-------------------------------------------------------------------
-module(user_interface).

-include("../include/stockapp.hrl").

-export([sell_stock/2,buy_stock/2,cancel_order/1]).

sell_stock(Stock,Price) when is_record(Stock,stock)->
case catch   user_server ! {sell,Stock,Price} of
    {'EXIT',{badarg,_}}-> "please wait untill user_server starts";
    N -> N
end;

sell_stock(_,_)->
    {info,"please enter argument 1 a record of type 'stock'"}.

buy_stock(Stock,Price) when is_record(Stock,stock)->
case catch   user_server ! {buy,Stock,Price} of
    {'EXIT',{badarg,_}}-> "please wait untill user_server starts";
    N -> N
end;

buy_stock(_,_)->
    {info,"please enter argument 1 a record of type 'stock'"}.


cancel_order(OrderId)->
case catch   user_server ! {cancel,OrderId} of
    {'EXIT',{badarg,_}}-> "please wait untill user_server starts";
    N -> N
end.
