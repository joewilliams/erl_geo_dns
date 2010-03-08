-module(geo_dns_query).

-include("../include/geo_dns.hrl").

-export([query_handler/2]).

query_handler(IP, Packet)->
  {ok, Request} = inet_dns:decode(Packet),
  [Query] = Request#dns_rec.qdlist,
  OldHeader = Request#dns_rec.header,
  Reply = 
    {dns_rec,
      {dns_header,OldHeader#dns_header.id,true,'query',false,false,true,true,false,0},
        [Query],
        [{dns_rr,Query#dns_query.domain,a,in,0,5,
          get_addr(Query#dns_query.domain, IP),
          undefined,[],false}],
        [],[]},
  io:format("reply: ~p~n", [Reply]),
  ReplyBin=inet_dns:encode(Reply),
  ReplyBin.

get_addr(Domain, Origin) ->
  Db = couchbeam_server:open_db(default, "test"),
  {[_,_,{<<"iplist">>,IpList}]} = couchbeam_db:open_doc(Db, Domain),
  io:format("doc: ~p~n",[couchbeam_db:open_doc(Db, Domain)]),
  IpListBin = [list_to_binary(X) || X <- IpList],
  geo_dns_distance:closest(ip_to_binary({64,81,165,209}), IpListBin).

ip_to_binary({A,B,C,D}) ->
  <<A,B,C,D>>.
