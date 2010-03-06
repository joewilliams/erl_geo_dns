-module(geo_dns).

-behaviour(gen_server).

-include("../include/bine_dns.hrl").

-define(SERVER, ?MODULE).

-type socket() :: any().

-record( state,
	 {socket :: socket(),
	  host   :: hostname(),
	  port   :: pos_integer()
	 }).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
   terminate/2, code_change/3]).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  Port = 5353,
  Host = "0.0.0.0",
  case gen_udp:open(Port, [{active, once}, binary]) of
    {ok, Socket} ->
      {ok, #state{socket=Socket,host=Host,port=Port}};
    _ -> error
  end.

handle_call(_Msg, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({udp, Socket, Host, Port, Bin}, State)->
  Reply = query_handler(Bin),
  gen_udp:send(Socket, Host, Port, Reply),
  inet:setopts(Socket, [{active,once}]),
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


query_handler(Packet)->
  {ok, Request} = inet_dns:decode(Packet),
  io:format("qdlist ~p~n", [Request#dns_rec.qdlist]),
  [Query] = Request#dns_rec.qdlist,
  OldHeader = Request#dns_rec.header,
  io:format("old header ~p~nid: ~p~n", [OldHeader,OldHeader#dns_header.id]),
  Reply = {dns_rec,{dns_header,OldHeader#dns_header.id,true,'query',false,false,true,true,false,0},
    [Query],
    [{dns_rr,Query#dns_query.domain,a,in,0,5,
      get_addr(Query#dns_query.domain),
      undefined,[],false},{dns_rr,Query#dns_query.domain,a,in,0,5,
      get_addr(Query#dns_query.domain),
      undefined,[],false}],
      [],[]},
  io:format("reply: ~p~n", [Reply]),
  ReplyBin=inet_dns:encode(Reply),
  io:format("raw reply: ~p~n",[ReplyBin]),
  ReplyBin.

get_addr(Domain) ->
  case Domain of
    "cloudant.com" ->
      {75,101,130,106};
    _ ->
      {127,0,0,1}
  end.

