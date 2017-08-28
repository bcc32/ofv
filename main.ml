open! Core_kernel

open Cmdliner

let sfv_file =
  let docv = "sfv-file" in
  Arg.(required & pos 0 (some string) None & info [] ~docv)
;;

let main sfv_file =
  In_channel.with_file sfv_file ~f:(fun file ->
    Sfv.iter_entries file ~f:(fun entry ->
      Debug.eprint_s [%sexp (entry : Sfv.Entry.t)]))
;;

let () = Term.(exit @@ eval (pure main $ sfv_file, info "ofv"))
