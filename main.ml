open! Core_kernel

open Cmdliner

let sfv_file =
  let docv = "sfv-file" in
  Arg.(required & pos 0 (some string) None & info [] ~docv)
;;

let main sfv_file =
  In_channel.with_file sfv_file ~f:(fun file ->
    In_channel.iter_lines file ~f:(fun line ->
      if not (String.is_prefix line ~prefix:";")
      then (
        let sfv = Sfv.Entry.of_string line in
        Debug.eprint_s [%sexp (sfv : Sfv.Entry.t)])))
;;

let () = Term.(exit @@ eval (pure main $ sfv_file, info "ofv"))
