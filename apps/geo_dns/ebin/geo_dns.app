{application, geo_dns,
 [{description, "dns server with geoip support"},
  {vsn, "0.1"},
  {modules, 
    [geo_dns_distance, 
     geo_dns_sup, 
     geo_dns_app, 
     geo_dns_udp, 
     geo_dns_query]},
  {registered, []},
  {applications, []},
  {env, 
    [{port, 5353}, 
     {host, {0,0,0,0}},
     {geodb, "/home/joe/GeoLiteCity.dat"},
     {dnsdb, "test"}]
  },
  {mod, {geo_dns_app, []}}
 ]}.
