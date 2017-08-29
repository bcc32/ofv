open! Core_kernel
open! Ofv_lib

open Cmdliner

let sfv_file =
  let docv = "sfv-file" in
  Arg.(required & pos 0 (some string) None & info [] ~docv)
;;

let main sfv_file =
  In_channel.with_file sfv_file ~f:(fun file ->
    Sfv.iter_entries file ~f:(fun entry ->
      match Sfv.Entry.check entry with
      | Ok () -> printf "%s: OK\n" entry.filename
      | Error e -> printf !"%s: %{Error#mach}\n" entry.filename e))
;;

let () = Term.(exit @@ eval (pure main $ sfv_file, info "ofv"))
