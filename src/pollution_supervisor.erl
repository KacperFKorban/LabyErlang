%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. maj 2019 01:24
%%%-------------------------------------------------------------------
-module(pollution_supervisor).
-behaviour(supervisor).
-author("kacper").

%% API
-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link(
    {local, pollution_supervisor},
    pollution_supervisor, []).

init(_) ->
  {ok, {
    {one_for_one, 2, 3},
    [{pollution_gen_server,
      {pollution_gen_server, start_link, []},
      permanent, brutal_kill, worker, [pollution_gen_server, pollution]}
    ]}
  }.
