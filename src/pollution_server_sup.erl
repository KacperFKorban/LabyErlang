%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. kwi 2019 11:42
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("kacper").

%% API
-export([start/0, stop/0]).

start() ->
  Pid = spawn(fun() -> init() end),
  register(pollution_sup, Pid),
  Pid.

init() ->
  process_flag(trap_exit, true),
  ServerPid = pollution_server:start(),
  link(ServerPid),
  loop().

loop() ->
  receive
    {'EXIT', _, _} ->
      ServerPid = pollution_server:start(),
      link(ServerPid),
      loop();
    stop ->
      ok
  end.

stop() ->
  pollution_sup ! stop.