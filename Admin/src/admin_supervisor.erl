%%%-------------------------------------------------------------------
%%% @author lengor <admin@lengors-MacBook.local>
%%% @copyright (C) 2012, lengor
%%% @doc
%%%
%%% @end
%%% Created : 27 Aug 2012 by lengor <admin@lengors-MacBook.local>
%%%-------------------------------------------------------------------
-module(admin_supervisor).
-include("../include/stockapp.hrl").
-compile(export_all).

startApplication()->
    audit_trade:start(),
    stock_tcp_handler:start(start,[]),
    admin_tcp_manager:start().
