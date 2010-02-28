all:
	make -C apps/libgeoip/geo_c_src
	./rebar compile

clean:
	./rebar clean
	rm -rf apps/libgeoip/priv
