{application, geo_dns,
 [{description, "dns server with geoip support"},
  {vsn, "0.1"},
  {modules, [geo_dns_distance, geo_dns_sup, geo_dns_app, geo_dns]},
  {registered, []},
  {applications, []}
 ]}.
