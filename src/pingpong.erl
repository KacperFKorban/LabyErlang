%%%-------------------------------------------------------------------
%%% @author kacper
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. kwi 2019 11:30
%%%-------------------------------------------------------------------
-module(pingpong).
-author("kacper").

%% API
-export([start/0, stop/0, play/1]).

start() ->
  Loop = fun() -> loop() end,
  Ping = spawn(Loop),
  Pong = spawn(Loop),
  register(ping, Ping),
  register(pong, Pong).

stop() ->
  ping ! stop,
  pong ! stop.

play(N) when is_integer(N) ->
  ping ! {start, N}.

loop() ->
  receive
    {start, N} ->
      pong ! {msg, self(), N, pong},
      loop();
    {msg, Pid, N, ping} ->
      if
        (N > 0) ->
          io:format("Ping ~B~n", [N]),
          Pid ! {msg, self(), N-1, pong},
          loop();
        true -> loop()
      end;
    {msg, Pid, N, pong} ->
      if
        (N > 0) ->
          io:format("Pong ~B~n", [N]),
          Pid ! {msg, self(), N-1, ping},
          loop();
        true -> loop()
      end;
    stop -> ok
  after
    20000 -> pingpong:stop()
  end.