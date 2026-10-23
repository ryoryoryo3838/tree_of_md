(** Public-v2 JSON-only conversion. No source discovery or publication policy.
    The closed unavailable content node accepts only kind and an optional
    literal label, with the same string validation/escaping as metadata. It
    emits a native HTML anchor to the fixed /_unavailable/ href, defaulting to
    [非公開], without creating or authorizing a graph target. Title disclosure
    authorization belongs to the producer; arbitrary Markdown/raw link guards
    are unchanged. The closed image content node accepts only kind, sha256,
    alt and optional integer display width/height. Its sorted unique JPEG
    registry must equal the exact used digest set; both roots and registry are
    retained internally. Images are not graph targets. Emission is limited to
    the native html:img primitive at /media/<lowercase-sha256>.jpg, with literal
    alt escaping once. No JPEG/source path access, copy or normalization occurs;
    byte verification and publication authorization belong to the caller.
    Errors never contain input snippets or filenames. *)
type error = Invalid_json | Schema | Invalid_id | Duplicate_id | Invalid_date
           | Unsafe_markdown | Missing_target | Cycle | Limit | Io | Unsafe_output
type t
val error_code : error -> string
val of_string : string -> (t, error) result
val compile_forest : t -> ((string * string) list, error) result
val max_json_bytes : int
val max_json_depth : int
val max_tree_depth : int
val max_chunk_bytes : int
val load_file : string -> (t, error) result
(** Validate and compile everything before writing. Require a new or empty,
    nonsymlink output directory; never reuse stale output or overwrite files. *)
val write_forest : out_dir:string -> t -> (int, error) result
val convert_file : input:string -> out_dir:string -> (int, error) result
