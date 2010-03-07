-module(geo_dns_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  GeoDNSSpec = {geo_dns_udp, {geo_dns_udp, start_link, []}, permanent, brutal_kill, worker, [geo_dns_udp]},
  io:format("starting: ~p~n", [GeoDNSSpec]),
  {ok, {{one_for_one, 1, 1}, [GeoDNSSpec]}}.
