%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. kwi 2019 22:55
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("kacper").

-record(monitor, {names, stations}).

-include_lib("eunit/include/eunit.hrl").

getRobakowo() -> {monitor,#{"Gorzów Wielkopolski" => {45.0,67.0},
  "Robakowo" => {10.0,10.0}},
  #{{10.0,10.0} =>
  #{{{{2019,4,15},{23,3,51}},"PM10"} => 80,
  {{{2019,4,15},{23,3,51}},"PM2.5"} => 100,
  {{{2019,4,15},{23,5,1}},"PM2.5"} => 200},
  {45.0,67.0} =>
  #{{{{2019,4,15},{23,5,37}},"CO"} => 110,
  {{{2019,4,15},{23,5,37}},"PM10"} => 110,
  {{{2019,4,15},{23,5,37}},"PM2.5"} => 120,
  {{{2019,4,15},{23,7,57}},"CO"} => 160,
  {{{2019,4,15},{23,8,23}},"SO2"} => 200}}}.

createMonitor_test() ->
  ?assert(pollution:createMonitor() == #monitor{names = #{}, stations = #{}}).

addStation_test() ->
  ?assert(pollution:addStation("Robakowo", {10.0, 20.0}, pollution:createMonitor())
    == #monitor{names = #{"Robakowo" => {10.0, 20.0}}, stations = #{{10.0, 20.0} => #{}}}).

addValue_test() ->
  ?assert(pollution:addValue("Robakowo", {{2019,4,15},{23,5,37}}, "PM10", 110, #monitor{names = #{"Robakowo" => {10.0, 20.0}}, stations = #{{10.0, 20.0} => #{}}})
    == #monitor{names = #{"Robakowo" => {10.0, 20.0}}, stations = #{{10.0, 20.0} => #{{{{2019,4,15},{23,5,37}},"PM10"} => 110}}}).

removeValue_test() ->
  ?assert(pollution:removeValue("Robakowo", {{2019,4,15},{23,5,37}}, "PM10", #monitor{names = #{"Robakowo" => {10.0, 20.0}}, stations = #{{10.0, 20.0} => #{{{{2019,4,15},{23,5,37}},"PM10"} => 110}}})
    == #monitor{names = #{"Robakowo" => {10.0, 20.0}}, stations = #{{10.0, 20.0} => #{}}}).

getOneValue_test() ->
  ?assert(pollution:getOneValue("Robakowo", {{2019,4,15},{23,3,51}}, "PM10", getRobakowo()) == 80).

getStationMean_test() ->
  ?assert(pollution:getStationMean("Robakowo", "PM10", getRobakowo()) == 80.0),
  ?assert(pollution:getStationMean("Robakowo", "PM2.5", getRobakowo()) == 150.0).

getDailyMean_test() ->
  ?assert(pollution:getDailyMean({2019,4,15}, "PM10", getRobakowo()) == 95.0).

getCorrelation_test() ->
  ?assert(pollution:getCorrelation("PM10", "PM2.5", getRobakowo()) == 15.811388300841896).
