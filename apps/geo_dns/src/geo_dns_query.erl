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
  case Domain of
    "cloudant.com" ->
      geo_dns_distance:closest(ip_to_binary({75,101,130,106}), [ip_to_binary({75,101,130,106}), ip_to_binary({63,246,20,70})]);
    _ ->
      {127,0,0,1}
  end.

ip_to_binary({A,B,C,D}) ->
  <<A,B,C,D>>.
