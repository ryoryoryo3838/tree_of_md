(** JSON-only public forest façade. The legacy Tree_of_md_legacy API remains separate. *)
module Public_forest : module type of Tree_of_md_legacy.Public_forest
