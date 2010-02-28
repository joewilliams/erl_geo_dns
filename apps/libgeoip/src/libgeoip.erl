-module(libgeoip).
-include("libgeoip.hrl").

-behaviour(gen_server).

-export([start_link/0, start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-export([lookup/1, set_db/1]).

-export([test/0]).


start_link() ->
  start_link([]).

start_link(DBName) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, DBName, []).

init(DBName) -> 
  Path = case code:priv_dir(libgeoip) of
           {error, bad_name} -> "";
           Found -> Found ++ "/"
         end,
  GeoIP = open_port({spawn, Path ++ "geoipport"}, [{packet, 2}, binary]),
  process_flag(trap_exit, true),
  case DBName of
    [] -> ok;
     _ -> port_command(GeoIP, term_to_binary(DBName))
  end,
  {ok, [GeoIP]}.


%%%----------------------------------------------------------------------
%%% Call handling for local modules
%%%----------------------------------------------------------------------

handle_call({lookup, IP}, _From, [GeoIP1] = State) ->
  port_command(GeoIP1, term_to_binary(IP)),
  receive 
    {GeoIP1, {data, Term}} -> {reply, binary_to_term(Term), State}
  after
    200 -> {reply, timeout, State}
  end;
handle_call({set_db, DBPath}, _From, [GeoIP1] = State) ->
  port_command(GeoIP1, term_to_binary(DBPath)),
  {reply, db_set, State}.

%%%----------------------------------------------------------------------
%%% unimplemented gen_server callbacks
%%%----------------------------------------------------------------------

handle_cast(_Msg, _State) ->  {noreply, undefined}.
terminate(_Reason, _State) -> ok.
handle_info(_Info, State) -> {noreply, State}.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%%----------------------------------------------------------------------
%%% External API
%%%----------------------------------------------------------------------

lookup(<<_A,_B,_C,_D>> = IP) ->
  <<I:32/unsigned-integer>> = IP,
  lookup(I);
lookup(IP) when is_integer(IP) ->
  gen_server:call(?MODULE, {lookup, IP}).

set_db(DBPath) ->
  gen_server:call(?MODULE, {set_db, DBPath}).
  
%%%----------------------------------------------------------------------
%%% quick and dirty testing
%%%----------------------------------------------------------------------

test() ->
  crypto:start(),
  [lookup(crypto:rand_bytes(4)) || _ <- lists:seq(1,5000)]. 
