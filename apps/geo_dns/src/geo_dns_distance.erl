-module(geo_dns_distance).

%% math functions
-export([haversine/4, pythagoras/4, sphericalcos/4]).

%% distance sorting functions
-export([timedrun/2, start/1, lookup_ip/1]).

%% util functions
-export([distance/3, closest/2, closest/3]).

-define(RADDEG, 0.017453292519943295769236907684886).


%% math functions

haversine(Lat0, Lon0, Lat1, Lon1) ->
  DLonRad = (Lon1 - Lon0) * ?RADDEG,
  DLatRad = (Lat1 - Lat0) * ?RADDEG,
  Lat0Rad = Lat0 * ?RADDEG,
  Lat1Rad = Lat1 * ?RADDEG,
  A = math:pow((math:sin(DLatRad/2)),2) + math:cos(Lat0Rad) * math:cos(Lat1Rad) * math:pow((math:sin(DLonRad/2)), 2),
  C = 2 * math:atan2( math:sqrt(A), math:sqrt(1-A)),
  C.

pythagoras(Lat0, Lon0, Lat1, Lon1) ->
  C = math:sqrt(math:pow(Lon0 - Lon1, 2) + math:pow(Lat0 - Lat1, 2)),
  C.

sphericalcos(Lat0, Lon0, Lat1, Lon1) ->
  C = math:acos(math:sin(Lat0) * math:sin(Lat1) + math:cos(Lat0) * math:cos(Lat1) * math:cos(Lon1 - Lon0)),
  C.


%% distance sorting functions

closest(Origin, List) ->
  closest(haversine, Origin, List).

closest(Fun, Origin, List) ->
  L = [ {X, distance:distance(Fun, Origin, X)} || X <- List ],
  [{IP, _} | _] = lists:sort(fun({_, Dist0}, {_, Dist1}) -> Dist0 =< Dist1 end, L),
  IP.

distance(Fun, Origin, IP) ->
  {geoip, _, _, _, _, _, Lat, Lon, _} = distance:lookup_ip(IP),
  {geoip, _, _, _, _, _, OriginLat, OriginLon, _} = distance:lookup_ip(Origin),
  Dist = distance:Fun(OriginLat, OriginLon, Lat, Lon),
  Dist.


%% util functions

lookup_ip(IP) ->
  libgeoip:lookup(IP).

timedrun(Fun, Count) ->
  Time0 = erlang:now(),
  for(1, Count, fun() -> Fun end),
  Time1 = timer:now_diff(erlang:now(), Time0),
  Time1.


%% internal functions

for(N,N,F) -> [F()];
for(I,N,F) -> [F()|for(I+1,N,F)].

set_geo_db(File) ->
  case libgeoip:set_db(File) of
    db_set ->
      ok;
    _ ->
      error
  end.
