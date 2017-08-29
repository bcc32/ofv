open! Core_kernel

type t [@@deriving sexp]

include Stringable.S with type t := t
(** [of_string] is case-insensitive. [to_string] uses uppercase hex digits. *)

val string : string -> pos:int -> len:int -> t
