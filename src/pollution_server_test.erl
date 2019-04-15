%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. kwi 2019 00:37
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("kacper").

-include_lib("eunit/include/eunit.hrl").

pollution_server_test() ->
  pollution_server:start(),
  pollution_server:addStation("Robakowo", {10.0,10.0}),
  pollution_server:addValue("Robakowo", {{2019,4,15},{23,3,51}}, "PM10", 80),
  pollution_server:addValue("Robakowo", {{2019,4,15},{23,3,51}}, "PM2.5", 100),
  pollution_server:addValue("Robakowo", {{2019,4,15},{23,5,1}}, "PM2.5", 200),
  pollution_server:addStation("Gorzów Wielkopolski", {45.0,67.0}),
  pollution_server:addValue("Gorzów Wielkopolski", {{2019,4,15},{23,5,37}}, "CO", 110),
  pollution_server:addValue("Gorzów Wielkopolski", {{2019,4,15},{23,5,37}}, "PM10", 110),
  pollution_server:addValue("Gorzów Wielkopolski", {{2019,4,15},{23,5,37}}, "PM2.5", 120),
  pollution_server:addValue("Gorzów Wielkopolski", {{2019,4,15},{23,7,57}}, "CO", 160),
  pollution_server:addValue("Gorzów Wielkopolski", {{2019,4,15},{23,8,23}}, "SO2", 200),
  pollution_server:addValue("Robakowo", {{2019,4,15},{23,5,40}}, "PM10", 300),
  pollution_server:removeValue("Robakowo", {{2019,4,15},{23,5,40}}, "PM10"),
  ?assert(pollution_server:getOneValue("Robakowo", {{2019,4,15},{23,3,51}}, "PM10") == 80),
  ?assert(pollution_server:getStationMean("Robakowo", "PM10") == 80.0),
  ?assert(pollution_server:getStationMean("Gorzów Wielkopolski", "CO") == 135.0),
  ?assert(pollution_server:getDailyMean({2019,4,15}, "PM10") == 95.0),
  ?assert(pollution_server:getCorrelation("PM10", "PM2.5") == 15.811388300841896).
