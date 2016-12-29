(* Simple Tests of genlet (from MetaFX/metaocaml) *)

let t1 = .<1 + .~(genlet .<2>.)>.
(* val t1 : int code = .<1 + 2>.  *)

let t2 = .<fun x -> 1 + .~(genlet .<2>.)>.
(* val t2 : ('a -> int) code = .<fun x_1  -> 1 + 2>.  *)

let t3 = let_locus (fun () -> .<fun x -> 1 + .~(genlet .<2>.)>.)
(* val t3 : ('_a -> int) code = .<let t_3 = 2 in fun x_2  -> 1 + t_3>. 
*)

let t4 = let_locus (fun () -> .<fun x -> 1 + .~(genlet .<x>.)>.)
(* val t4 : (int -> int) code = .<fun x_9  -> 1 + x_9>. 
*)

let t5 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<2+3>.)>.))
  >.))
  >.)
(*
val t5 : ('_a -> '_b -> int) code = .<
  let t_12 = 2 + 3 in fun x_10  y_11  -> 1 + t_12>. 
*)

let t51 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<2+x>.)>.))
  >.))
  >.)
(*
val t51 : (int -> '_a -> int) code = .<
  fun x_13  -> let t_15 = 2 + x_13 in fun y_14  -> 1 + t_15>. 
*)
let t52 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<y+x>.)>.))
  >.))
  >.)
(*
val t52 : (int -> int -> int) code = .<
  fun x_16  y_17  -> let t_18 = y_17 + x_16 in 1 + t_18>. 
*)

(* XXX *)

Needss nested genlet!

(* A simple DSL. See loop_motion_gen.ml for a realistic example *)
module type DSL = sig
  val sqr           : int code -> int code
  val make_incr_fun : (int code -> int code) -> (int -> int) code
end

(* Sample DSL expressions *)
module DSLExp(S: DSL) = struct
  open S
  let exp1 = sqr .<2+3>.
  let exp2 = make_incr_fun (fun x -> sqr .<2+3>.)
  let exp3 = make_incr_fun (fun x -> sqr .<.~x + 3>.)
end

(* The naive implementation of the DSL *)
module DSL1 = struct
  let sqr e = .<.~e * .~e>.
  let make_incr_fun body = .<fun x -> x + .~(body .<x>.)>.
end

let module M = DSLExp(DSL1) in
  (M.exp1, M.exp2, M.exp3)
(*
- : int code * (int -> int) code * (int -> int) code =
(.<(2 + 3) * (2 + 3)>. , 
 .<fun x_14  -> x_14 + ((2 + 3) * (2 + 3))>. , 
 .<fun x_15  -> x_15 + ((x_15 + 3) * (x_15 + 3))>. )
*)

(* Adding let-insertion, trasparently *)
module DSL2 = struct
  let sqr e = DSL1.sqr (genlet e)
  let make_incr_fun body = 
    let_locus @@ fun () ->
      DSL1.make_incr_fun @@ fun x ->
        let_locus @@ fun () -> 
          body x
end

let module M = DSLExp(DSL2) in
  (M.exp1, M.exp2, M.exp3)
(*
(.<(2 + 3) * (2 + 3)>. , 
 .<let t_17 = 2 + 3 in fun x_16  -> x_16 + (t_17 * t_17)>. , 
 .<fun x_18  -> x_18 + (let t_19 = x_18 + 3 in t_19 * t_19)>. )
*)