-module(libgeoip_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  LibGeoIPSpec = {libgeoip,
                   {libgeoip, start_link, []},
                   permanent, brutal_kill, worker, [libgeoip]},

  {ok, {{one_for_one, 5, 1}, [LibGeoIPSpec]}}.
