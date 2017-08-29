open! Core_kernel

type t [@@deriving sexp]

include Equal.S      with type t := t
include Stringable.S with type t := t
(** [of_string] is case-insensitive. [to_string] uses uppercase hex digits. *)

val add_string    : t -> string      -> pos:int -> len:int -> t
val add_bigstring : t -> Bigstring.t -> pos:int -> len:int -> t

val string    : ?pos:int -> ?len:int -> string      -> t
val bigstring : ?pos:int -> ?len:int -> Bigstring.t -> t

val file : string -> t Or_error.t
