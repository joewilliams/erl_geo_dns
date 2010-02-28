all:
	mkdir ../priv
	gcc -Wall -Os -L/usr/lib -I/usr/include \
	-L/opt/erlang/current/lib/erlang/lib/erl_interface-3.6.5/lib/ \
        -I/opt/erlang/current/lib/erlang/lib/erl_interface-3.6.5/include/ \
	-o ../priv/geoipport erl_comm.c geoipport.c geohash.c -lerl_interface -lei -lGeoIP \
	-lpthread
