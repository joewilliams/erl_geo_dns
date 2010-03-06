%% http://erlang.org/examples/klacke_examples/ftpd.erl
-define(is_ip(X), size(X)==4, (element(1,X) bor element(2,X) bor element(3,X) bor element(4,X)) band (bnot 255) == 0).

%% thanks to kernel/src/inet_dns.hrl

-type dns_class() ::'a' | 'ptr' | 'mr'. 
-type dns_type() ::'in'| 'ch' .
-type ip_address() :: tuple().
-type hostname() :: string().

-record(dns_header, 
	{ 
	  id :: pos_integer(),
	  qr = 0 :: 0 | 1,
	  opcode = 0 :: pos_integer() , % :4
	  aa = 0 :: 0 | 1,
	  tc = 0 :: 0 | 1,
	  rd = 0 :: 0 | 1,
	  ra = 1 :: 0 | 1,
	  pr = 0,
	  rcode = 0 
	}).

-record(dns_rr,
	{ domain  :: hostname(),
	  class   :: dns_class(),
	  type    :: dns_type(),
	  cnt = 0 :: integer(), 
	  tm      :: integer(), 
	  ttl     :: integer(),
	  bm = [] :: list(), 
	  data = [] :: ip_address() | hostname(),
	  func = false :: true | false
	 }).

-record(dns_rec,
	{ header :: #dns_header{},
	  qdlist = [] :: [ #dns_rr{} ],
	  anlist = [] :: [ #dns_rr{} ],
	  nslist = [] :: [ #dns_rr{} ],
	  arlist = [] :: [ #dns_rr{} ]
	 }).

-record(dns_query, { domain :: hostname(), type :: dns_type(), class :: dns_class()}).
