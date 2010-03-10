-module(geo_dns_query).

-include("../include/geo_dns.hrl").

-export([query_handler/2]).

query_handler(IP, Packet)->
  {ok, Request} = inet_dns:decode(Packet),
  [Query] = Request#dns_rec.qdlist,
  OldHeader = Request#dns_rec.header,
  case get_addr(Query#dns_query.domain, IP) of
    nonexistant_domain ->
      nonexistant_domain;
    Addr ->
      Reply =
        {dns_rec,
        {dns_header,OldHeader#dns_header.id,true,'query',false,false,true,true,false,0},
        [Query],
        [{dns_rr,Query#dns_query.domain,a,in,0,5,
          Addr,
          undefined,[],false}],
        [],[]},
      io:format("reply: ~p~n", [Reply]),
      ReplyBin=inet_dns:encode(Reply),
      ReplyBin
  end.

get_addr(Domain, Origin) ->
  {ok, DnsDb} = application:get_env(geo_dns, dnsdb),
  Db = couchbeam_server:open_db(default, DnsDb),
  case couchbeam_db:open_doc(Db, Domain) of
    {[_,_,{<<"iplist">>,IpList}]} ->
      io:format("doc: ~p~n",[couchbeam_db:open_doc(Db, Domain)]),
      IpListBin = [list_to_binary(X) || X <- IpList],
      geo_dns_distance:closest(ip_to_binary({64,81,165,209}), IpListBin);
    _ ->
      nonexistant_domain
  end.

ip_to_binary({A,B,C,D}) ->
  <<A,B,C,D>>.
