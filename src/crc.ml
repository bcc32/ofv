open! Core_kernel

type t = int32                  (* TODO consider changing type *)

let to_string t = sprintf "%08lX" t

let of_string s = Int32.of_string ("0x" ^ s)

let t_of_sexp (sexp : Sexp.t) =
  match sexp with
  | Atom s -> of_string s
  | List _ -> invalid_arg "Crc.t_of_sexp"
;;

let sexp_of_t t : Sexp.t = Atom (to_string t)

external string : string -> int -> int -> t = "caml_crc32_string"

let string s ~pos ~len =
  if pos < 0
  then (raise_s [%message "invalid pos" (pos : int)]);
  if pos + len > String.length s
  then (
    raise_s [%message "invalid substring" (pos : int) (len : int)
                        ~string_length:(String.length s : int)]);
  string s pos len
;;
