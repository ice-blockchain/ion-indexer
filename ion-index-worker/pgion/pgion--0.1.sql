CREATE TYPE ionhash;

CREATE OR REPLACE FUNCTION ionhash_in(cstring)
   RETURNS ionhash
   AS 'MODULE_PATHNAME', 'ionhash_in'
   LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ionhash_out(ionhash)
   RETURNS cstring
   AS 'MODULE_PATHNAME', 'ionhash_out'
   LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ionhash_recv(internal)
   RETURNS ionhash
   AS 'MODULE_PATHNAME', 'ionhash_recv'
   LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ionhash_send(ionhash)
   RETURNS bytea
   AS 'MODULE_PATHNAME', 'ionhash_send'
   LANGUAGE C IMMUTABLE STRICT;


CREATE TYPE ionhash (
   input = ionhash_in,
   output = ionhash_out,
   send = ionhash_send,
   receive = ionhash_recv,
   internallength = 32,
   alignment = int4
);

CREATE FUNCTION ionhash_lt(ionhash, ionhash) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionhash_lt' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionhash_le(ionhash, ionhash) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionhash_le' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionhash_eq(ionhash, ionhash) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionhash_eq' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionhash_gt(ionhash, ionhash) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionhash_gt' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionhash_ge(ionhash, ionhash) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionhash_ge' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionhash_cmp(ionhash, ionhash) RETURNS int4
   AS 'MODULE_PATHNAME', 'ionhash_cmp' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
   leftarg = ionhash, rightarg = ionhash, procedure = ionhash_lt,
   commutator = > , negator = >= ,
   restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR <= (
   leftarg = ionhash, rightarg = ionhash, procedure = ionhash_le,
   commutator = >= , negator = > ,
   restrict = scalarlesel, join = scalarlejoinsel
);
CREATE OPERATOR = (
   leftarg = ionhash, rightarg = ionhash, procedure = ionhash_eq,
   commutator = = ,
   restrict = eqsel, join = eqjoinsel
);
CREATE OPERATOR >= (
   leftarg = ionhash, rightarg = ionhash, procedure = ionhash_ge,
   commutator = <= , negator = < ,
   restrict = scalargesel, join = scalargejoinsel
);
CREATE OPERATOR > (
   leftarg = ionhash, rightarg = ionhash, procedure = ionhash_gt,
   commutator = < , negator = <= ,
   restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR CLASS ionhash_ops
    DEFAULT FOR TYPE ionhash USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       ionhash_cmp(ionhash, ionhash);

-- TonAddr type
CREATE TYPE ionaddr;

CREATE OR REPLACE FUNCTION ionaddr_in(cstring)
   RETURNS ionaddr
   AS 'MODULE_PATHNAME', 'ionaddr_in'
   LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ionaddr_out(ionaddr)
   RETURNS cstring
   AS 'MODULE_PATHNAME', 'ionaddr_out'
   LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ionaddr_recv(internal)
   RETURNS ionaddr
   AS 'MODULE_PATHNAME', 'ionaddr_recv'
   LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ionaddr_send(ionaddr)
   RETURNS bytea
   AS 'MODULE_PATHNAME', 'ionaddr_send'
   LANGUAGE C IMMUTABLE STRICT;


CREATE TYPE ionaddr (
   input = ionaddr_in,
   output = ionaddr_out,
   send = ionaddr_send,
   receive = ionaddr_recv,
   internallength = 36,
   alignment = int4
);

CREATE FUNCTION ionaddr_lt(ionaddr, ionaddr) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionaddr_lt' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionaddr_le(ionaddr, ionaddr) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionaddr_le' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionaddr_eq(ionaddr, ionaddr) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionaddr_eq' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionaddr_gt(ionaddr, ionaddr) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionaddr_gt' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionaddr_ge(ionaddr, ionaddr) RETURNS bool
   AS 'MODULE_PATHNAME', 'ionaddr_ge' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION ionaddr_cmp(ionaddr, ionaddr) RETURNS int4
   AS 'MODULE_PATHNAME', 'ionaddr_cmp' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
   leftarg = ionaddr, rightarg = ionaddr, procedure = ionaddr_lt,
   commutator = > , negator = >= ,
   restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR <= (
   leftarg = ionaddr, rightarg = ionaddr, procedure = ionaddr_le,
   commutator = >= , negator = > ,
   restrict = scalarlesel, join = scalarlejoinsel
);
CREATE OPERATOR = (
   leftarg = ionaddr, rightarg = ionaddr, procedure = ionaddr_eq,
   commutator = = ,
   restrict = eqsel, join = eqjoinsel
);
CREATE OPERATOR >= (
   leftarg = ionaddr, rightarg = ionaddr, procedure = ionaddr_ge,
   commutator = <= , negator = < ,
   restrict = scalargesel, join = scalargejoinsel
);
CREATE OPERATOR > (
   leftarg = ionaddr, rightarg = ionaddr, procedure = ionaddr_gt,
   commutator = < , negator = <= ,
   restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR CLASS ionaddr_ops
    DEFAULT FOR TYPE ionaddr USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       ionaddr_cmp(ionaddr, ionaddr);
