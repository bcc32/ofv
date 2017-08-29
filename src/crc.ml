open! Core_kernel

type t = int32

let equal = Int32.equal

let to_string t = sprintf "%08lX" t

let of_string s = Int32.of_string ("0x" ^ s)

let t_of_sexp (sexp : Sexp.t) =
  match sexp with
  | Atom s -> of_string s
  | List _ -> invalid_arg "Crc.t_of_sexp"
;;

let sexp_of_t t : Sexp.t = Atom (to_string t)

external add_string : t -> string -> int -> int -> t
  = "caml_crc32_add_string"

let add_string t s ~pos ~len =
  if pos < 0
  then (raise_s [%message "invalid pos" (pos : int)]);
  if pos + len > String.length s
  then (
    raise_s [%message "invalid substring" (pos : int) (len : int)
                        ~string_length:(String.length s : int)]);
  add_string t s pos len
;;

external add_bigstring : t -> Bigstring.t -> int -> int -> t
  = "caml_crc32_add_bigstring"

let add_bigstring t s ~pos ~len =
  if pos < 0
  then (raise_s [%message "invalid pos" (pos : int)]);
  if pos + len > Bigstring.length s
  then (
    raise_s [%message "invalid substring" (pos : int) (len : int)
                        ~string_length:(Bigstring.length s : int)]);
  add_bigstring t s pos len
;;

let opt_pos =
  function
  | None -> 0
  | Some p -> p
;;

let opt_len pos length =
  function
  | None -> length - pos
  | Some l -> l
;;

let string ?pos ?len s =
  let pos = opt_pos pos in
  let len = opt_len pos (String.length s) len in
  add_string 0l s ~pos ~len
;;

let bigstring ?pos ?len s =
  let pos = opt_pos pos in
  let len = opt_len pos (Bigstring.length s) len in
  add_bigstring 0l s ~pos ~len
;;

let block_size = 4096

let file filename =
  let buf = String.create block_size in
  Or_error.try_with (fun () ->
    In_channel.with_file filename ~f:(fun chan ->
      let rec loop crc =
        let len = In_channel.input chan ~buf ~pos:0 ~len:block_size in
        let crc = add_string crc buf ~pos:0 ~len in
        loop crc
      in
      loop 0l))
;;
