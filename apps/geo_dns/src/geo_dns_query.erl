-module(geo_dns_query).

-include("../include/geo_dns.hrl").

-export([query_handler/2]).

query_handler(IP, Packet)->
  {ok, Request} = inet_dns:decode(Packet),
  io:format("request: ~p~n", [Request]),
  [Query] = Request#dns_rec.qdlist,
  OldHeader = Request#dns_rec.header,
  case get_addr(Query#dns_query.domain, IP) of
    nonexistant_domain ->
      nonexistant_domain;
    Addr ->
      Reply = response(Addr, OldHeader, Query),
      io:format("reply: ~p~n", [Reply]),
      ReplyBin=inet_dns:encode(Reply),
      ReplyBin
  end.

get_addr(Domain, Origin) ->
  case couchbeam_db:open_doc(dnsdb, Domain) of
    {[_,_,{<<"iplist">>,IpList}]} ->
      IpListBin = [list_to_binary(X) || X <- IpList],
      geo_dns_distance:closest(ip_to_binary({64,81,165,209}), IpListBin);
    _ ->
      nonexistant_domain
  end.

response(Addr, OldHeader, Query=#dns_query{type=a,class=in}) ->
  {dns_rec,
    OldHeader,
    [Query],
    [{dns_rr,
      Query#dns_query.domain,
      Query#dns_query.type,
      Query#dns_query.class,
      0,
      get_ttl(Query#dns_query.domain),
      Addr,
      undefined,
      [],
      false}],
    [],[]}.

ip_to_binary({A,B,C,D}) ->
  <<A,B,C,D>>.

get_ttl(_) ->
  300.
