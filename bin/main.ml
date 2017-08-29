open! Core_kernel
open! Ofv_lib

open Cmdliner

let sfv_file =
  let docv = "sfv-file" in
  Arg.(required & pos 0 (some string) None & info [] ~docv)
;;

let main sfv_file =
  let count_ok       = ref 0 in
  let count_mismatch = ref 0 in
  let count_error    = ref 0 in
  In_channel.with_file sfv_file ~f:(fun file ->
    Sfv.iter_entries file ~f:(fun entry ->
      match Sfv.Entry.check entry with
      | `Ok ->
        incr count_ok;
        printf "%s: OK\n" entry.filename
      | `Mismatch actual ->
        incr count_mismatch;
        printf !"%s: NOT OK, expected %{Crc} but got %{Crc}\n"
          entry.filename entry.crc32 actual
      | `Read_error e ->
        incr count_error;
        printf !"%s: %{Error#mach}\n" entry.filename e));
  printf "%d OK, %d mismatches, %d errors\n"
    !count_ok !count_mismatch !count_error
;;

let () = Term.(exit @@ eval (pure main $ sfv_file, info "ofv"))
