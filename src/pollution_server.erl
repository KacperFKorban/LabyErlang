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
-export([start/0, stop/0, addStation/2, addValue/4,
  removeValue/3, getOneValue/3, getStationMean/2,
  getDailyMean/2, getCorrelation/2]).

start() ->
  register(monitor, spawn(fun() -> init() end)).

stop() ->
  monitor ! stop.

init() ->
  loop(pollution:createMonitor()).

loop(M) ->
  receive
    {request, Pid, {addStation, N, C}} ->
      NewM = pollution:addStation(N, C, M),
      Pid ! {reply, ok},
      loop(NewM);
    {request, Pid, {addValue, K, D, T, V}} ->
      NewM = pollution:addValue(K, D, T, V, M),
      Pid ! {reply, ok},
      loop(NewM);
    {request, Pid, {removeValue, K, D, T}} ->
      NewM = pollution:removeValue(K, D, T, M),
      Pid ! {reply, ok},
      loop(NewM);
    {request, Pid, {getOneValue, K, D, T}} ->
      Pid ! {reply, pollution:getOneValue(K, D, T, M)},
      loop(M);
    {request, Pid, {getStationMean, K, T}} ->
      Pid ! {reply, pollution:getStationMean(K, T, M)},
      loop(M);
    {request, Pid, {getDailyMean, D, T}} ->
      Pid ! {reply, pollution:getDailyMean(D, T, M)},
      loop(M);
    {request, Pid, {getCorrelation, T1, T2}} ->
      Pid ! {reply, pollution:getCorrelation(T1, T2, M)},
      loop(M);
    stop ->
      terminate()
  end.

call(Message) ->
  monitor ! {request, self(), Message},
  receive
    {reply, Reply} -> Reply
  end.

addStation(N, C) ->
  call({addStation, N, C}).

addValue(K, D, T, V) ->
  call({addValue, K, D, T, V}).

removeValue(K, D, T) ->
  call({removeValue, K, D, T}).

getOneValue(K, D, T) ->
  call({getOneValue, K, D, T}).

getStationMean(K, T) ->
  call({getStationMean, K, T}).

getDailyMean(D, T) ->
  call({getDailyMean, D, T}).

getCorrelation(T1, T2) ->
  call({getCorrelation, T1, T2}).

terminate() ->
  ok.
