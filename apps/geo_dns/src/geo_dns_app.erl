-module(geo_dns_app).
-behaviour(application).

-export([start/0, stop/0]).
-export([start/2, stop/1]).

start() ->
  application:start(geo_dns_app).

stop() ->
  application:stop(geo_dns_app).


start(_Type, _Args) ->
  geo_dns_sup:start_link().

stop(_State) ->
  ok.