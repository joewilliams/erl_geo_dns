-module(geo_dns).

-export([start/0, stop/0]).

start() ->
  start_couchbeam(),
  start_libgeoip(),
  start_geo_dns().

stop() ->
  application:stop(geo_dns).

%% internal functions

start_couchbeam() ->
  couchbeam:start(),
  couchbeam_server:start_connection_link(),
  {ok, DnsDb} = application:get_env(geo_dns, dnsdb),
  Db = couchbeam_server:open_db(default, DnsDb),
  ets:new(geo_dns, [named_table, bag]),
  ets:insert(geo_dns, {couchdb, Db}).

start_libgeoip() ->
  {ok, GeoDb} = application:get_env(geo_dns, geodb),
  application:start(libgeoip_app),
  libgeoip:set_db(GeoDb).
  
start_geo_dns() ->
  application:start(geo_dns).

