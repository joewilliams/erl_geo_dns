-module(geo_dns).

-export([start/0, stop/0]).

start() ->
  start_geo_dns(),
  start_couchbeam(),
  start_libgeoip().

stop() ->
  application:stop(geo_dns).

start_couchbeam() ->
  ok = couchbeam:start(),
  couchbeam_server:start_connection_link(),
  {ok, DnsDb} = application:get_env(geo_dns, dnsdb),
  couchbeam_server:open_db(default, {dnsdb, DnsDb}).

start_libgeoip() ->
  {ok, GeoDb} = application:get_env(geo_dns, geodb),
  application:start(libgeoip),
  db_set = libgeoip:set_db(GeoDb).
  
start_geo_dns() ->
  application:start(geo_dns).

