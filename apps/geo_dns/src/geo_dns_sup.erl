-module(geo_dns_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  GeoDNSSpec = {geodns,
                 {geo_dns, start_link, []},
                   permanent, brutal_kill, worker, [geo_dns]},

  {ok, {{one_for_one, 5, 1}, [GeoDNSSpec]}}.
