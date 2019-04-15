%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. mar 2019 22:30
%%%-------------------------------------------------------------------
-module(pollution).
-author("kacper").

-record(monitor, {names, stations}).

%% API
-export([createMonitor/0, addStation/3, addValue/5,
  removeValue/4, getOneValue/4, getStationMean/3,
  getDailyMean/3, getCorrelation/3]).

createMonitor() -> #monitor{names = #{}, stations = #{}}.

addStation(N, {X, Y}, M) when is_float(X) and is_float(Y) and is_record(M, monitor) and is_list(N)
  and (X > -90) and (X < 90) and (Y > -180) and (Y < 180) ->
  isTaken(N, {X, Y}, M),
  #monitor{names = (M#monitor.names)#{N => {X, Y}}, stations = (M#monitor.stations)#{{X, Y} => #{}}}.

isTaken(N, C, M) ->
  NC = maps:get(N, M#monitor.names, dunno),
  CS = maps:get(C, M#monitor.stations, dunno),
  if
    (NC =/= dunno) or (CS =/= dunno)-> error("Already taken!");
    true -> ok
  end.

checkKey({X, Y}, _) when is_float(X) and is_float(Y) ->
  {X, Y};
checkKey(K, M) when is_record(M, monitor) and is_list(K) ->
  getSafe(K, M#monitor.names).

getReadings(K, M) when is_record(M, monitor) ->
  getSafe(K, M#monitor.stations).

getSafe(K, M) ->
  V = maps:get(K, M, dunno),
  if
    V =:= dunno -> error("Wrong Key!");
    true -> V
  end.

getReading(Readings, D, T, M) when is_record(M, monitor) ->
  ReadingValue = maps:get({D, T}, Readings, dunno),
  if
    ReadingValue =:= dunno -> error("No such Reading!");
    true -> ReadingValue
  end.

addValue(K, D, T, V, M) when is_record(M, monitor) and is_list(T) and (is_float(V) or is_integer(V)) ->
  Key = checkKey(K, M),
  Readings = getReadings(Key, M),
  ReadingValue = maps:get({D, T}, Readings, dunno),
  if
    ReadingValue =/= dunno -> error("Wrong Key!");
    true -> ok
  end,
  {{_, _, _}, {_, _, _}} = D,
  M#monitor{stations = (M#monitor.stations)#{Key => Readings#{{D, T} => V}}}.

removeValue(K, D, T, M) when is_record(M, monitor) ->
  Key = checkKey(K, M),
  Readings = getReadings(Key, M),
  M#monitor{stations = (M#monitor.stations)#{Key => maps:remove({D, T}, Readings)}}.

getOneValue(K, D, T, M) when is_record(M, monitor) ->
  Key = checkKey(K, M),
  Readings = getReadings(Key, M),
  getReading(Readings, D, T, M).

getStationMean(K, T, M) when is_record(M, monitor) ->
  Key = checkKey(K, M),
  Readings = getReadings(Key, M),
  {Sum, Length} = maps:fold(fun(_, V, {S, L}) ->
    {S + V, L + 1} end, {0, 0},
    maps:filter(fun({_, TI}, _) ->
      TI =:= T end, Readings)),
  Sum / Length.

getDailyMean(D, T, M) when is_record(M, monitor) ->
  Stations = maps:values(M#monitor.stations),
  FilteredStationsValues = lists:map(fun(Readings) ->
    maps:values(maps:filter(fun({{DI, _}, TI}, _) ->
      (D =:= DI) and (TI =:= T) end, Readings)) end, Stations),
  FlattenedValues = lists:flatten(FilteredStationsValues),
  {Sum, Length} = lists:foldl(fun(V, {S, L}) ->
    {S + V, L + 1} end, {0, 0}, FlattenedValues),
  Sum / Length.

getCorrelation(T1, T2, M) when is_record(M, monitor) and is_list(T1) and is_list(T2) ->
  Set = maps:from_list(lists:flatmap(fun(Vals) ->
     maps:to_list(
       maps:filter(fun({D, T}, _) ->
        ((T =:= T1) and (maps:get({D, T2}, Vals, dunno) =/= dunno))
          or ((T =:= T2) and (maps:get({D, T1}, Vals, dunno) =/= dunno))
                   end, Vals))
                      end, maps:values(M#monitor.stations))),
  Keys = lists:map(fun({{D, _}, _}) -> D end, maps:to_list(Set)),
  Tuples = lists:map(fun(D) -> {maps:get({D, T1}, Set), maps:get({D, T2}, Set)} end, Keys),
  SquaresSum = lists:foldl(fun({V1, V2}, Acc) -> (V1 - V2)*(V1 - V2) + Acc end, 0, Tuples),
  Res = math:sqrt(SquaresSum / lists:flatlength(Tuples)),
  Res.