open! Core_kernel

type t = int32                  (* TODO consider changing type *)

let to_string t = sprintf "%08lX" t

let of_string s = Int32.of_string ("0x" ^ s)

let t_of_sexp (sexp : Sexp.t) =
  match sexp with
  | Atom s -> of_string s
  | List _ -> raise_s [%message "expected an atom"]
;;

let sexp_of_t t : Sexp.t = Atom (to_string t)
