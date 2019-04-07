%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. mar 2019 21:29
%%%-------------------------------------------------------------------
-module(qsort).
-author("kacper").

%% API
-export([lessThan/2, grtEqThan/2, qs/1, randomElems/3, compareSpeeds/3
  , map/2, filter/2, sumDigitsInNumber/1]).

lessThan(List, Arg) -> [X || X <- List, X < Arg].

grtEqThan(List, Arg) -> [X || X <- List, X >= Arg].

qs([]) -> [];
qs([Pivot|Tail]) ->
  qs(lessThan(Tail,Pivot)) ++ [Pivot] ++ qs(grtEqThan(Tail,Pivot)).

randomElems(N,Min,Max)-> [rand:uniform(Max - Min) + Min || _ <- lists:seq(1, N)].

compareSpeeds(List, Fun1, Fun2) ->
  {timer:tc(Fun1, List), timer:tc(Fun2, List)}.

map(_, []) -> [];
map(F, [H | T]) -> [F(H) | map(F, T)].

filter(_, []) -> [];
filter(F, [H | T]) -> case F(H) of
                        true -> [H | filter(F, T)];
                        _ -> filter(F, T)
                      end.

sumDigitsInNumber(N) ->
  lists:foldl(fun(A, B) -> list_to_integer([A]) + B end, 0, integer_to_list(N)).
