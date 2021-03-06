open! Core_kernel

module Entry : sig
  type t =
    { filename : string
    ; crc32    : Crc.t }
  [@@deriving fields, sexp]

  include Invariant.S  with type t := t
  include Stringable.S with type t := t

  val check : t -> [ `Ok | `Mismatch of Crc.t | `Read_error of Error.t ]
end

val iter_entries : In_channel.t -> f:(Entry.t -> unit) -> unit
