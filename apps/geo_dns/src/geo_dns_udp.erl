-module(geo_dns_udp).

-behaviour(gen_server).

-include("../include/geo_dns.hrl").

-type socket() :: any().

-record( state, 
  {socket :: socket(),
   host   :: hostname(),
   port   :: pos_integer()}).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
   terminate/2, code_change/3]).

start_link() ->
  {ok, Port} = application:get_env(geo_dns, port),
  {ok, Host} = application:get_env(geo_dns, host),
  gen_server:start_link(?MODULE, [Host, Port], []).

init([Host, Post]) ->
  case gen_udp:open(Port, [{active, once}, binary]) of
    {ok, Socket} ->
      {ok, #state{socket=Socket,host=Host,port=Port}};
    _ -> udp_error
  end.

handle_call(_Msg, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({udp, Socket, Host, Port, Bin}, State)->
  Reply = geo_dns_query:query_handler(Host, Bin),
  gen_udp:send(Socket, Host, Port, Reply),
  inet:setopts(Socket, [{active,once}]),
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
