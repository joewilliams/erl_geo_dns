-module(geo_dns_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  {ok, Db} = application:get_env(geo_dns, db),
  {ok, Port} = application:get_env(geo_dns, port),
  {ok, Host} = application:get_env(geo_dns, host),
  GeoDNSSpec =
  [
    {libgeoip, {libgeoip, start_link, [Db]}, permanent, brutal_kill, worker, [libgeoip]},
    {geo_dns_udp, {geo_dns_udp, start_link, [Host, Port]}, permanent, brutal_kill, worker, [geo_dns_udp]}
  ],
  io:format("starting: ~p~n", [GeoDNSSpec]),
  {ok, {{one_for_one, 1, 1}, GeoDNSSpec}}.
