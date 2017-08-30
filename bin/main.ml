open! Core_kernel
open! Ofv_lib

open Cmdliner

let sfv_file =
  let docv = "SFV-FILE" in
  Arg.(required & pos 0 (some string) None & info [] ~docv)
;;

let quiet =
  let doc = "Don't print OK for each successfully verified file." in
  Arg.(value & flag & info ["q"; "quiet"] ~doc)
;;

let main sfv_file quiet =
  let count_ok       = ref 0 in
  let count_mismatch = ref 0 in
  let count_error    = ref 0 in
  In_channel.with_file sfv_file ~f:(fun file ->
    Sfv.iter_entries file ~f:(fun entry ->
      match Sfv.Entry.check entry with
      | `Ok ->
        incr count_ok;
        if not quiet then (printf "%s: OK\n%!" entry.filename)
      | `Mismatch actual ->
        incr count_mismatch;
        printf !"%s: NOT OK, expected %{Crc} but got %{Crc}\n%!"
          entry.filename entry.crc32 actual
      | `Read_error e ->
        incr count_error;
        printf !"%s: %{Error#mach}\n%!" entry.filename e));
  printf "%d OK, %d mismatches, %d errors\n%!"
    !count_ok !count_mismatch !count_error;
  match !count_mismatch + !count_error with
  | 0 -> `Ok ()
  | bad -> `Error (false, sprintf "%d files were not successfully verified" bad)
;;

let () = Term.(exit @@ eval (ret (pure main $ sfv_file $ quiet), info "ofv"))
