%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. kwi 2019 21:46
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("kacper").

%% API
-export([start/0, stop/0]).

start() ->
  Pid = spawn(fun() -> init() end),
  register(monitor, Pid),
  Pid.

stop() ->
  monitor ! stop.

init() ->
  M = pollution:createMonitor(),
  loop(M).

loop(M) ->
  receive
    {addStation, N, C} ->
      NewM = pollution:addStation(N, C, M),
      loop(NewM);
    {addValue, K, D, T, V} ->
      NewM = pollution:addValue(K, D, T, V, M),
      loop(NewM);
    {removeValue, K, D, T} ->
      NewM = pollution:removeValue(K, D, T, M),
      loop(NewM);
    {getOneValue, K, D, T} ->
      NewM = pollution:getOneValue(K, D, T, M),
      loop(NewM);
    {getStationMean, K, T} ->
      NewM = pollution:getStationMean(K, T, M),
      loop(NewM);
    {getDailyMean, D, T} ->
      NewM = pollution:getDailyMean(D, T, M),
      loop(NewM);
    {getDailyMean, T1, T2} ->
      NewM = pollution:getCorrelation(T1, T2, M),
      loop(NewM);
    stop ->
      terminate()
  end.

terminate() ->
  ok.
