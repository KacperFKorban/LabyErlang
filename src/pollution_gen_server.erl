%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. maj 2019 20:54
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behaviour(gen_server).
-author("kacper").

%% API
-export([start/0, stop/0, init/1, handle_call/3, handle_cast/2]).
-export([addStation/2, addValue/4, removeValue/3, getOneValue/3,
  getStationMean/2, getDailyMean/2, getCorrelation/2, crash/0,
  handle_info/2, start_link/0, terminate/2]).

start_link() ->
  gen_server:start_link(
    {local, pollution_gen_server},
    pollution_gen_server
    , [], []).

start() ->
  gen_server:start(
    {local, pollution_gen_server},
    pollution_gen_server,
    [], []).

stop() ->
  gen_server:stop(pollution_gen_server).

init(_) ->
  {ok, pollution:createMonitor()}.

handle_cast({addStation, N, C}, M) ->
  {noreply, pollution:addStation(N, C, M)};

handle_cast({addValue, K, D, T, V}, M) ->
  {noreply, pollution:addValue(K, D, T, V, M)};

handle_cast({removeValue, K, D, T}, M) ->
  {noreply, pollution:removeValue(K, D, T, M)};

handle_cast(crash, _) ->
  1/0,
  {noreply, ok}.

handle_call({getOneValue, K, D, T}, _From, M) ->
  {reply, pollution:getOneValue(K, D, T, M), M};

handle_call({getStationMean, K, T}, _From, M) ->
  {reply, pollution:getStationMean(K, T, M), M};

handle_call({getDailyMean, D, T}, _From, M) ->
  {reply, pollution:getDailyMean(D, T, M), M};

handle_call({getCorrelation, T1, T2}, _From, M) ->
  {reply, pollution:getCorrelation(T1, T2, M)}.

addStation(N, C) ->
  gen_server:cast(pollution_gen_server, {addStation, N, C}).

addValue(K, D, T, V) ->
  gen_server:cast(pollution_gen_server, {addValue, K, D, T, V}).

removeValue(K, D, T) ->
  gen_server:cast(pollution_gen_server, {removeValue, K, D, T}).

getOneValue(K, D, T) ->
  gen_server:call(pollution_gen_server, {getOneValue, K, D, T}).

getStationMean(K, T) ->
  gen_server:call(pollution_gen_server, {getStationMean, K, T}).

getDailyMean(D, T) ->
  gen_server:call(pollution_gen_server, {getDailyMean, D, T}).

getCorrelation(T1, T2) ->
  gen_server:call(pollution_gen_server, {getCorrelation, T1, T2}).

crash() ->
  gen_server:cast(pollution_gen_server, crash).

handle_info(_, LoopData) ->
  {noreply, LoopData}.

terminate(_Reason, _State) ->
  ok.