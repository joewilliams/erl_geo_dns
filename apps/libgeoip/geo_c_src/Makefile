all:
	mkdir ../priv
	gcc -Wall -Os -L/usr/lib \
  -I/usr/include \
  -I/usr/local/include \
	-L/opt/erlang/current/lib/erlang/lib/erl_interface-3.6.5/lib/ \
  -I/opt/erlang/current/lib/erlang/lib/erl_interface-3.6.5/include/ \
	-I/usr/local/lib/erlang/lib/erl_interface-3.6.5/include/ \
  -lGeoIP -lpthread -lei -lerl_interface \
	-o ../priv/geoipport erl_comm.c geoipport.c geohash.c 
