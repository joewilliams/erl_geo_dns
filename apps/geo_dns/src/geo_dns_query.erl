-module(geo_dns_query).

-include("../include/geo_dns.hrl").

-export([query_handler/2]).

query_handler(Ip, Packet)->
  {ok, Request} = inet_dns:decode(Packet),
  io:format("request: ~p~n", [Request]),
  [Query] = Request#dns_rec.qdlist,
  OldHeader = Request#dns_rec.header,
  case Query#dns_query.type of
    a ->
      case get_addr(Query#dns_query.domain, Ip) of
        nonexistant_domain ->
          nonexistant_domain;
        {Ttl, Addr} ->
          Reply = response(Addr, Ttl, OldHeader, Query),
          io:format("reply: ~p~n", [Reply]),
          ReplyBin=inet_dns:encode(Reply),
          ReplyBin
      end;
    _ ->
      wrong_record_type
  end.

get_addr(Domain, Origin) ->
  io:format("~p~n", [couchbeam_db:open_doc(dnsdb, Domain)]),
  case couchbeam_db:open_doc(dnsdb, Domain) of
    {[_,_,{<<"iplist">>,IpList}, {<<"ttl">>, Ttl}]} ->
      IpListBin = [list_to_binary(X) || X <- IpList],
      Ip = geo_dns_distance:closest(ip_to_binary({64,81,165,209}), IpListBin),
      {Ttl, Ip};
    _ ->
      nonexistant_domain
  end.

response(Addr, Ttl, OldHeader, Query=#dns_query{class=in}) ->
  {dns_rec,
    OldHeader,
    [Query],
    [{dns_rr,
      Query#dns_query.domain,
      Query#dns_query.type,
      Query#dns_query.class,
      0,
      Ttl,
      Addr,
      undefined,
      [],
      false}],
    [],[]}.

ip_to_binary({A,B,C,D}) ->
  <<A,B,C,D>>.

get_ttl(_) ->
  300.
