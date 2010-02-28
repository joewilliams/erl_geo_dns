{application, libgeoip,
 [{description, "libgeoip port"},
  {vsn, "1.0.1"},
  {modules, [libgeoip_app, libgeoip_sup, libgeoip]},
  {registered, [libgeoip]},
  {applications, [kernel, stdlib]},
  {mod, {libgeoip_app,[]}}
 ]}.
