-record(stock, {fla,stock_Name}).
-record(request, {order,price,user}).
-record(stockObj,{price,order,time,user}).
-record(user,{socket,pid}).
-record(state,{lowest,higest}).
-record(stocktrend,{fla,stock_Name,lowest,higest}).
% kpo key with price and order -> {price,order,time}
% should contain pid of user and time he made the order -> {UserPid,Time}
% time should be {MGS,SEC,MIS} = now(), Time =  (MGS * 10^6 + SEC) * 10^6 + MIS.

%% List should be containing "User",
%% user should contain {user,pid}


%database in stock process

%Rec{Order,Price,}

%Order = buy/sell
