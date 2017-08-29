open! Core_kernel

module Entry = struct
  type t =
    { filename : string
    ; crc32    : Crc.t }
  [@@deriving fields, sexp]

  let invariant t =
    assert String.(t.filename <> "");
    assert (not (String.is_prefix t.filename ~prefix:";"));
    assert (not (String.is_suffix t.filename ~suffix:" "));
  ;;

  let to_string t = sprintf !"%-39s %{Crc}" t.filename t.crc32

  let of_string s =
    if String.length s < 8
    then (
      raise_s [%message "SFV line too short" ~length:(String.length s : int)]);
    let filename, crc_string = String.drop_suffix s 8, String.suffix s 8 in
    if not (String.is_suffix filename ~suffix:" ")
    then (raise_s [%message "missing space between filename and CRC"]);
    let filename = String.strip filename in
    { filename
    ; crc32 = Crc.of_string crc_string }
  ;;

  let check { filename; crc32 = expected } =
    match Crc.file filename with
    | Error _ as e -> e
    | Ok actual ->
      if Crc.equal expected actual
      then Ok ()
      else (
        Or_error.error_s [%message "mismatched CRC"
                                     (filename : string)
                                     (expected : Crc.t)
                                     (actual : Crc.t)])
  ;;
end

let is_comment line = String.is_prefix line ~prefix:";"

let iter_entries chan ~f =
  In_channel.iter_lines chan ~f:(fun line ->
    if not (is_comment line)
    then (f @@ Entry.of_string line))
;;
