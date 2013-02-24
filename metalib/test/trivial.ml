(* Trivial tests of MetaOCaml, which are also regression tests *)

3+2;;
(* - : int = 5 *)
let rec fact = function | 0 -> 1 | n -> n * fact (n-1);;
(* val fact : int -> int = <fun> *)
let 120 = fact 5;;

.<1>.;;
(* - : ('cl, int) code = .<1>. *)
.<"aaa">.;;
(* - : ('cl, string) code = .<"aaa">. *)
let 1 = .! .<1>.;;
(* - : int = 1 *)


.<fun x -> .~(let y = x in y)>.;;
(*
Characters 22-23:
  .<fun x -> .~(let y = x in y)>.;;
                        ^
Error: Wrong level: variable bound at level 1 and used at level 0
*)
print_endline "Error was expected";;

.<fun x -> 1 + .~(.<true>.)>.;;
(*
Characters 20-24:
  .<fun x -> 1 + .~(.<true>.)>.;;
                      ^^^^
Error: This expression has type bool but an expression was expected of type
         int
*)
print_endline "Error was expected";;

.<fun x -> .~(.! .<x>.; .<1>.)>.;;
(*
Characters 14-22:
  .<fun x -> .~(.! .<x>.; .<1>.)>.;;
                ^^^^^^^^
Error: .! error: 'cl not generalizable in ('cl, 'a) code
*)
print_endline "Error was expected";;

(* CSP *)

let x = 1 in .<x>.;;
(*
- : ('cl, int) code = .<1>.
*)
let x = 1.0 in .<x>.;;
(*
- : ('cl, float) code = .<1.>.
*)
let x = true in .<x>.;;
(*
- : ('cl, bool) code = .<true>.
*)
let x = "aaa" in .<x>.;;
(*
- : ('cl, string) code = .<"aaa">.
*)
let x = 'a' in .<x>.;;
(*
- : ('cl, char) code = .<'a'>.
*)
let x = ['a'] in .<x>.;;
(*
- : ('cl, char list) code = .<(* cross-stage persistent value (as id: x) *)>.
*)

let l x = .<x>.;;                       (* polymorphic *)
(* val l : 'a -> ('cl, 'a) code = <fun> *)
l 1;;
(*
- : ('a, int) code = .<(* cross-stage persistent value (as id: x) *)>.
*)
let 1 = .! (l 1);;
l 1.0;;                  (* better printing in N100 *)
(*
- : ('a, float) code = .<1.>.
*)
let 1.0 = .! (l 1.0);;

.<List.rev>.;;
(*
- : ('cl, 'a list -> 'a list) code = .<List.rev>.
*)

.<Array.get>.;;
(*
- : ('cl, 'a array -> int -> 'a) code = .<Array.get>.
*)
.<(+)>.;;
(*
- : ('cl, int -> int -> int) code = .<(+)>.
*)


let x = true in .<assert x>.;;
(*
- : ('cl, unit) code = .<assert (true)>.
*)

(* Applications and labels *)
.<succ 1>.;;
(*
- : ('cl, int) code = .<succ 1>.
*)

let 2 = .! .<succ 1>.;;

.<1 + 2>.;;
(*
- : ('cl, int) code = .<(1 + 2)>.
*)
let 3 = .! .<(1 + 2)>.;;

.<String.length "abc">.;;
(*
- : ('cl, int) code = .<String.length "abc">.
*)
let 3 = 
  .! .<String.length "abc">.;;

.<StringLabels.sub ?pos:1 ?len:2 "abc">.;;
(*
- : ('cl, string) code = .<(StringLabels.sub "abc" ~pos:1 ~len:2>.
*)
let "bc" =
  .! .<StringLabels.sub ?pos:1 ?len:2 "abc">.;;

.<StringLabels.sub ~len:2 ~pos:1 "abc">.;;
(*
- : ('cl, string) code = .<(StringLabels.sub "abc" ~pos:1 ~len:2>.
*)
let "bc" =
  .! .<StringLabels.sub ~len:2 ~pos:1 "abc">.;;

(* Nested brackets and escapes and run *)
.<.<1>.>.;;
(*
- : ('cl, ('cl0, int) code) code = .<.<1>.>.
*)
.! .<.<1>.>.;;
(* - : ('cl, int) code = .<1>. *)
let 1 = .! (.! .<.<1>.>.);;)
(* - : int = 1 *)
.<.!.<1>.>.;;
(*
- : ('cl, int) code = .<.!.<1>.>.
*)
let 1 = .! .<.!.<1>.>.;;
.<1 + .~(let x = 2 in .<x>.)>.;;
(*
- : ('cl, int) code = .<(1 + 2)>.
*)
let x = .< 2 + 4 >. in .< .~ x + .~ x >. ;;
(*
- : ('cl, int) code = .<((2 + 4) + (2 + 4))>.
*)
let 12 = .! (let x = .< 2 + 4 >. in .< .~ x + .~ x >. );;

.<1 + .~(let x = 2 in .<.<x>.>.)>.;;
(*
Characters 24-29:
  .<1 + .~(let x = 2 in .<.<x>.>.)>.;;
                          ^^^^^
Error: This expression has type ('cl, 'a) code
       but an expression was expected of type int
*)
print_endline "Error was expected";;
.<1 + .! .~(let x = 2 in .<.<x>.>.)>.;;
(*
- : ('cl, int) code = .<(1 + .!.<2>.)>.
*)
let 3 = .! .<1 + .! .~(let x = 2 in .<.<x>.>.)>.;;
.! .<1 + .~ (.~(let x = 2 in .<.<x>.>.))>.;;
(*
Characters 12-40:
  .! .<1 + .~ (.~(let x = 2 in .<.<x>.>.))>.;;
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Error: Wrong level: escape at level 0
*)
print_endline "Error was expected";;

.<.<.~(.<1>.)>.>.;;
(*
- : ('cl, ('cl0, int) code) code = .<.<.~(.<1>.)>.>.
*)
.!.<.<.~(.<1>.)>.>.;;
(*
- : ('cl, int) code = .<1>.
*)
.<.<.~.~(.<.<1>.>.)>.>.;;
(*
- : ('cl, ('cl0, int) code) code = .<.<.~(.<1>.)>.>.
*)

(* Lazy *)
.<lazy 1>.;;
(*
- : ('cl, int lazy_t) code = .<lazy 1>.
*)
let 1 = Lazy.force (.! .<lazy 1>.);;

(* Tuples *)
.<(1,"abc")>.;;
(*
- : ('cl, int * string) code = .<((1), ("abc"))>.
*)
.<(1,"abc",'d')>.;;
(*
- : ('cl, int * string * char) code = .<((1), ("abc"), ('d'))>.
*)
let "abc" =
  match .! .<(1,"abc",'d')>. with (_,x,_) -> x;;

(* Arrays *)
.<[||]>.;;
(*
- : ('cl, 'a array) code = .<[||]>.
*)
let x = .<1+2>. in .<[|.~x;.~x|]>.;;
(*
- : ('cl, int array) code = .<[|(1 + 2); (1 + 2)|]>.
*)

(* Constructors and enforcing externality *)
.<raise Not_found>.;;
(*
- : ('cl, 'a) code = .<(raise (Not_found)>.
*)
.<raise (Scan_failure "")>.;;
(*
Characters 8-25:
  .<raise (Scan_failure "")>.;;
          ^^^^^^^^^^^^^^^^^
Error: Unbound constructor Scan_failure
*)
print_endline "Error was expected";;
.<raise (Scanf.Scan_failure "")>.;;
(*
- : ('cl, 'a) code = .<(raise (Scanf.Scan_failure (""))>.
*)
open Scanf;;
.<raise (Scan_failure "")>.;;
(*
- : ('cl, 'a) code = .<(raise (Scanf.Scan_failure (""))>.
*)
.! .<raise (Scan_failure "")>.;;
(*
Exception: Scanf.Scan_failure "".
*)
print_endline "Exception was expected";;


.<true>.;;
(*
- : ('cl, bool) code = .<(true)>.
*)
.<Some 1>.;;
(*
- : ('cl, int option) code = .<(Some (1))>.
*)
.<Some [1]>.;;
(*
- : ('cl, int list option) code = .<(Some ([1]))>.
*)
.! .<Some [1]>.;;
(*
- : int list option = Some [1]
*)
.<None>.;;
(*
- : ('cl, 'a option) code = .<(None)>.
*)
.! .<None>.;;
(*
- : 'a option = None
*)

.<Genlex.Int 1>.;;
(*
- : ('cl, Genlex.token) code = .<(Genlex.Int (1))>.
*)
open Genlex;;
.<Int 1>.;;
(*
- : ('cl, Genlex.token) code = .<(Genlex.Int (1))>.
*)
let Int 1 = .! .<Int 1>.;;

module Foo = struct exception E end;;
.<raise Foo.E>.;;
(*
Fatal error: exception Trx.TrxError("Exception Foo.E cannot be used within brackets. Put into a separate file.")
*)
print_endline "Error was expected";;

type foo = Bar;;
.<Bar>.;;
(*
Fatal error: exception Trx.TrxError("Constructor Bar cannot be used within brackets. Put into a separate file.")
*)
print_endline "Error was expected";;

module Foo = struct type foo = Bar end;;
.<Foo.Bar>.;;
(*
Fatal error: exception Trx.TrxError("Constructor Foo.Bar cannot be used within brackets. Put into a separate file.")
*)
print_endline "Error was expected";;

(* Records *)

.<{Complex.re = 1.0; im = 2.0}>.;;
(*
- : ('cl, Complex.t) code = .<{Complex.re = 1.0; Complex.im = 2.0}>.
*)
Complex.conj (.! .<{Complex.re = 1.0; im = 2.0}>.);;
(*
- : Complex.t = {Complex.re = 1.; Complex.im = -2.}
*)
let x = {Complex.re = 1.0; im = 2.0} in .<x.re>.;;
(*
Characters 42-46:
  let x = {Complex.re = 1.0; im = 2.0} in .<x.re>.;;
                                            ^^^^
Error: Unbound record field label re
*)
print_endline "Error was expected";;

let x = {Complex.re = 1.0; im = 2.0} in .<x.Complex.re>.;;
(*
- : ('cl, float) code =
.<((* cross-stage persistent value (as id: x) *)).Complex.re>.
*)
let 1.0 = .!(let x = {Complex.re = 1.0; im = 2.0} in .<x.Complex.re>.);;
let x = ref 1 in .<x.contents>.;;       (* Pervasive record *)
(*
- : ('cl, int) code =
.<((* cross-stage persistent value (as id: x) *)).contents>.
*)
let 1 = .!(let x = ref 1 in .<x.contents>.);;
let x = ref 1 in .<x.contents <- 2>.;;
(*
- : ('cl, unit) code =
.<((* cross-stage persistent value (as id: x) *)).contents <- 2>.
*)
let x = ref 1 in (.! .<x.contents <- 2>.); x;;
(* - : int ref = {contents = 2} *)

open Complex;;
.<{re = 1.0; im = 2.0}>.;;
(*
- : ('cl, Complex.t) code = .<{Complex.re = 1.0; Complex.im = 2.0}>.
*)
let 5.0 = norm (.! .<{re = 3.0; im = 4.0}>.);;
let x = {re = 1.0; im = 2.0} in .<x.re>.;;
(*
- : ('cl, float) code =
.<((* cross-stage persistent value (as id: x) *)).Complex.re>.
*)
let 1.0 = .!(let x = {re = 1.0; im = 2.0} in .<x.re>.);;

type foo = {fool : int};;
.<{fool = 1}>.;;
(*
Fatal error: exception Trx.TrxError("Label fool cannot be used within brackets. Put into a separate file.")
*)
print_endline "Error was expected";;

(* Conditional *)

.<if true then 1 else 2>.;;
(* - : ('cl, int) code = .<if (true) then 1 else 2>. *)
.<if Some 1 = None then print_string "weird">.;;
(*
- : ('cl, unit) code =
.<if ((Some (1)) = (None)) then (print_string "weird">.
*)
let () = .! .<if Some 1 = None then print_string "weird">.;;

(* Polymorphic variants *)
.<`Foo>.;;
(*
- : ('cl, [> `Foo ]) code = .<`Foo>.
*)
.<`Bar 1>.;;
(*
- : ('cl, [> `Bar of int ]) code = .<`Bar 1>.
*)
let 1 = match .! .<`Bar 1>. with `Bar x -> x ;;

(* Some support for modules *)
let f = fun x -> .<x # foo>.;;
(*
val f : < foo : 'a; .. > -> ('cl, 'a) code = <fun>
*)
let x = object method foo = 1 end;;
(*
val x : < foo : int > = <obj>
*)
f x;;
(*
- : ('a, int) code =
.<(((* cross-stage persistent value (as id: x) *))#foo)>.
*)
let 1 = .! (f x);;

(* Local open *)
let 5.0 = .! .<Complex.(norm {re=3.0; im = 4.0})>.;;

let 5.0 = .! .<let open Complex in norm {re=4.0; im = 3.0}>.;;

(* For-loop *)

.<for i=1 to 5 do Printf.printf "ok %d %d\n" i (i+1) done>.;;
(*
- : ('cl, unit) code =
.<for i_10 = 1 to 5 do Printf.printf "ok %d %d\n" i_10 (i_10 + 1) done>.
*)
.! .<for i=1 to 5 do Printf.printf "ok %d %d\n" i (i+1) done>.;;
(*
ok 1 2
ok 2 3
ok 3 4
ok 4 5
ok 5 6
*)

.<for i=5 downto 1 do Printf.printf "ok %d %d\n" i (i+1) done>.;;
(*
- : ('cl, unit) code =
.<for i_8 = 5 downto 1 do Printf.printf "ok %d %d\n" i_8 (i_8 + 1) done>.
*)
.! .<for i=5 downto 1 do Printf.printf "ok %d %d\n" i (i+1) done>.;;
(*
ok 5 6
ok 4 5
ok 3 4
ok 2 3
ok 1 2
*)

.<for i=1 to 2 do for j=1 to 3 do Printf.printf "ok %d %d\n" i j done done>.;;
(*
- : ('cl, unit) code =
.<for i_14 = 1 to 2 do
   for j_15 = 1 to 3 do (Printf.printf "ok %d %d\n" i_14 j_15 done done>.
*)
.! .<for i=1 to 2 do 
     for j=1 to 3 do Printf.printf "ok %d %d\n" i j done done>.;;
(*
ok 1 1
ok 1 2
ok 1 3
ok 2 1
ok 2 2
ok 2 3
*)

let c = .<for i=1 to 2 do .~(let x = .<i>. in 
             .<for i=1 to 3 do Printf.printf "ok %d %d\n" i .~x done>.) done>.;;
(*
val c : ('cl, unit) code =
  .<for i_20 = 1 to 2 do
     for i_21 = 1 to 3 do (Printf.printf "ok %d %d\n" i_21 i_20 done done>.
*)
.! c;;
(*
ok 1 1
ok 2 1
ok 3 1
ok 1 2
ok 2 2
ok 3 2
*)

(* Scope extrusion test *)

let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<0>.; .<()>.) done>.; 
                     .<for i=1 to 5 do ignore (.~(!r)) done>.;;
(*
- : ('cl, unit) code = .<for i_2 = 1 to 5 do (ignore 0 done>.
*)

let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; 
                     .<for i=1 to 5 do ignore (.~(!r)) done>.;;
(*
Exception:
Failure
 "Scope extrusion at Characters 49-50:\n  let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;\n                                                   ^\n for the identifier i_3 bound at Characters 27-28:\n  let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;\n                             ^\n".
*)
print_endline "Error was expected";;

(* Simple functions *)
.<fun x -> x>.;;
(*
- : ('cl, 'a -> 'a) code = .<fun x_3 -> x_3>.
*)
let 42 = (.! .<fun x -> x>.) 42;;

.<fun x y -> x + y>.;;
(*
- : ('cl, int -> int -> int) code = .<fun x_5 -> fun y_6 -> (x_5 + y_6)>.
*)
let 5 = (.! .<fun x y -> x + y>.) 2 3;;

.<fun x -> fun x -> x + x >.;;
(*
- : ('cl, 'a -> int -> int) code = .<fun x_9 -> fun x_10 -> (x_10 + x_10)>.
*)

(* Testing hygiene  *)
let eta f = .<fun x -> .~(f .<x>.)>.;;
(*
val eta : (('cl, 'a) code -> ('cl, 'b) code) -> ('cl, 'a -> 'b) code = <fun>
*)
eta (fun x -> .<1 + .~x>.);;
(*
- : ('cl, int -> int) code = .<fun x_11 -> (1 + x_11)>.
*)
eta (fun y -> .<fun x -> x + .~y>.);;
(*
- : ('cl, int -> int -> int) code = .<fun x_12 -> fun x_13 -> (x_13 + x_12)>.
*)
let 5 = (.! (eta (fun y -> .<fun x -> x + .~y>.))) 2 3;;

(* new identifiers must be generated at run-time *)
let rec fhyg = function
  | 0 -> .<1>.
  | n -> .<(fun x -> .~(fhyg (n-1)) + x) n>.;;
(*
val fhyg : int -> ('cl, int) code = <fun>
*)
fhyg 3;;
(*
- : ('a, int) code = .<
((fun x_5 -> (((fun x_6 -> (((fun x_7 -> (1 + x_7)) 1) + x_6)) 2) + x_5)) 3)>.
*)
let 7 = .! (fhyg 3);;

(* pattern-matching, general functions *)

.<fun () -> 1>.;;
(* - : ('cl, unit -> int) code = .<fun () -> 1>. *)
.! .<fun () -> 1>.;;
(* - : unit -> int = <fun> *)
let 1 = (.! .<fun () -> 1>.) ();;

.<function true -> 1 | false -> 0>.;;
(*
- : ('cl, bool -> int) code = .<function | true -> 1 | false -> 0>. 
*)
let 1 = (.! .<function true -> 1 | false -> 0>.) true;;

.<fun (true,[]) -> 1>.;;
(*
- : ('cl, bool * 'a list -> int) code = .<fun (true, []) -> 1>. 
*)
(.! .<fun (true,[]) -> 1>.) (true,[1]);;
(*
Exception: Match_failure ("//toplevel//", 1, 6).
*)
print_endline "Error was expected";;
let 1 = (.! .<fun (true,[]) -> 1>.) (true,[]);;

.<fun [|true;false;false|] -> 1>.;;
(*
- : ('cl, bool array -> int) code = .<fun [|true; false; false|] -> 1>. 
*)
let 1 = (.! .<fun [|true;false;false|] -> 1>.) [|true;false;false|];;

.<function `F 1 -> true | _ -> false>.;;
(*
- : ('cl, [> `F of int ] -> bool) code = .<
function | (`F 1) -> true | _ -> false>. 
*)
let true = (.! .<function `F 1 -> true | _ -> false>.) (`F 1);;
.<function `F 1 | `G 2 -> true | _ -> false>.;;
(*
- : ('cl, [> `F of int | `G of int ] -> bool) code = .<
function | ((`F 1) | (`G 2)) -> true | _ -> false>. 
*)

.<function (1,"str") -> 1 | (2,_) -> 2>.;;
(*
- : ('cl, int * string -> int) code = .<
function | (1, "str") -> 1 | (2, _) -> 2>. 
*)
let 1 = (.! .<function (1,"str") -> 1 | (2,_) -> 2>.) (1,"str");;
let 2 = (.! .<function (1,"str") -> 1 | (2,_) -> 2>.) (2,"str");;
let 1 = (.! .<fun [1;2] -> 1>.) [1;2];;

let 2 = (.! .<function None -> 1 | Some [1] -> 2>.) (Some [1]);;

let 2 = (.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some None);;
let 1 = (.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some (Some true));;
let 2 = (.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some (Some false));;
let 2 = (.! .<function (Some (Some true)) -> 1 | _ -> 2>.) None;;

open Complex;;
.<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.;;
(*
- : ('cl, Complex.t -> int) code = .<
function
| {Complex.re = 1.0} -> 1
| {Complex.re = 2.0; Complex.im = 2.0} -> 2
| {Complex.im = _} -> 3>. 
*)

let 1 = (.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.)
        {re=1.0; im=2.0};;
let 2 = (.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.)
        {re=2.0; im=2.0};;
(* - : int = 2 *)
let 3 = (.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.)
        {re=2.0; im=3.0};;

(* General functions *)

.<fun (x,y) -> x + y>.;;
(*
- : ('cl, int * int -> int) code = .<fun (x_2, y_3) -> (x_2 + y_3)>. 
*)
let 5 = (.! .<fun (x,y) -> x + y>.) (2,3);;
.<function (Some x) as y -> x | _ ->  2>.;;
(*
- : ('cl, int option -> int) code = .<
function | (Some (x_6) as y_7) -> x_6 | _ -> 2>.
*)
let 1 = (.! .<function (Some x) as y -> x | _ ->  2>.) (Some 1);;
let 2 = (.! .<function (Some x) as y -> x | _ ->  2>.) None;;
.<function [x;y;z] -> x - y + z | [x;y] -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
function
| (x_12 :: y_13 :: z_14 :: []) -> ((x_12 - y_13) + z_14)
| (x_15 :: y_16 :: []) -> (x_15 - y_16)>. 
*)
let 2 = (.! .<function [x;y;z] -> x - y + z | [x;y] -> x - y>.) [1;2;3];;

 (* OR patterns *)
.<function ([x;y] | [x;y;_]) -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
fun ((x_1 :: y_2 :: []) | (x_1 :: y_2 :: _ :: [])) -> (x_1 - y_2)>. 
*)
let -1 = (.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2];;
let -1 = (.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2;3];;
(.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2;3;4];;
(* Exception: Match_failure ("//toplevel//", 1, 6). *)
print_endline "Error was expected";;

.<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
fun (((x_9 :: y_10 :: []) | (x_9 :: y_10 :: _ :: []))
     | (y_10 :: x_9 :: _ :: _ :: [])) ->
 (x_9 - y_10)>.
*)
let -1 = (.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2];;
let -1 = (.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2;3];;
let  1 = (.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2;3;4];;

.<function (`F x | `G x) -> x | `E x -> x>.;;
(*
- : ('cl, [< `E of 'a | `F of 'a | `G of 'a ] -> 'a) code = .<
function | ((`F x_17) | (`G x_17)) -> x_17 | (`E x_18) -> x_18>. 
*)
let 2 = (.! .<function (`F x | `G x) -> x | `E x -> x>.) (`F 2);;
open Complex;;
.<function {re=x} -> x | {im=x; re=y} -> x -. y>.;;
(*
Characters 25-37:
  .<function {re=x} -> x | {im=x; re=y} -> x -. y>.;;
                           ^^^^^^^^^^^^
Warning 11: this match case is unused.
- : ('cl, Complex.t -> float) code = .<
function
| {Complex.re = x_21} -> x_21
| {Complex.re = y_22; Complex.im = x_23} -> (x_23 -. y_22)>. 
*)
.<function {re=x; im=2.0} -> x | {im=x; re=y} -> x -. y>.;;
(*
- : ('cl, Complex.t -> float) code = .<
function
| {Complex.re = x_24; Complex.im = 2.0} -> x_24
| {Complex.re = y_25; Complex.im = x_26} -> (x_26 -. y_25)>. 
*)
let 0. = (.! .<function {re=x; im=2.0} -> x | {im=x; re=y} -> x -. y>.) 
         {re=1.0; im=1.0};;
(* - : float = 0. *)
.<function (Some x) as y when x  > 0 -> y | _ -> None>.;;
(*
- : ('cl, int option -> int option) code = .<
function | (Some (x_30) as y_31) when (x_30 > 0) -> y_31 | _ -> None>. 
*)
let Some 1 = (.! .<function (Some x) as y when x  > 0 -> y | _ -> None>.)
             (Some 1);;
let None = (.! .<function (Some x) as y when x  > 0 -> y | _ -> None>.)
           (Some 0);;

(* pattern-matching *)
.<match 1 with 1 -> true>.;;
(*
- : ('cl, bool) code = .<(match 1 with 1 -> true)>. 
*)
let true = .! .<match 1 with 1 -> true>.;;

.<match (1,2) with (1,x) -> true | x -> false>.;;
(*
- : ('cl, bool) code = .<
(match ((1), (2)) with | (1, x_3) -> true | x_4 -> false)>. 
*)
.<match [1;2] with [x] -> x | [x;y] -> x + y>.;;
(*
- : ('cl, int) code = .<
(match [1; 2] with | (x_5 :: []) -> x_5 | (x_6 :: y_7 :: []) -> (x_6 + y_7))>.
*)
let 3 = 
  .! .<match [1;2] with [x] -> x | [x;y] -> x + y>.;;

(* OR patterns *)
.<match [1;2] with [x] -> x | [x;y] | [x;y;_] -> x + y>.;;
(*
- : ('cl, int) code = .<
(match [1; 2] with
 | (x_11 :: []) -> x_11
 | ((x_12 :: y_13 :: []) | (x_12 :: y_13 :: _ :: [])) -> (x_12 + y_13))>.
*)
let 3 = .! .<match [1;2] with [x] -> x | [x;y] | [x;y;_] -> x + y>.;;

.<match [1;2;3;4] with [x] -> x | [x;y] | [x;y;_] | [y;x;_;_] -> x - y>.;;
(*
- : ('cl, int) code = .<
(match [1; 2; 3; 4] with
 | (x_17 :: []) -> x_17
 | (((x_18 :: y_19 :: []) | (x_18 :: y_19 :: _ :: []))
    | (y_19 :: x_18 :: _ :: _ :: [])) ->
    (x_18 - y_19))>.
*)
let 1 =
  .! .<match [1;2;3;4] with [x] -> x | [x;y] | [x;y;_] | [y;x;_;_] -> x - y>.;;

.<fun x -> match x with (`F x | `G x) -> x | `E x -> x>.;;
(*
- : ('cl, [< `E of 'a | `F of 'a | `G of 'a ] -> 'a) code = .<
fun x_23 ->
 (match x_23 with | ((`F x_24) | (`G x_24)) -> x_24 | (`E x_25) -> x_25)>.
*)

let 1 = (.! .<fun x -> match x with (`F x | `G x) -> x | `E x -> x>.) (`G 1);;

open Complex;;
.<fun x -> match x with {re=x; im=2.0} -> x | {im=x; re=y} -> x -. y>.;;
(*
- : ('cl, Complex.t -> float) code = .<
fun x_29 ->
 (match x_29 with
  | {Complex.re = x_30; Complex.im = 2.0} -> x_30
  | {Complex.re = y_31; Complex.im = x_32} -> (x_32 -. y_31))>.
*)

let 1.0 =
  (.! .<fun x -> match x with {re=x; im=2.0} -> x | {im=x; re=y} -> x -. y>.)
    {im=2.0; re=1.0};;


(* try *)
.<fun x -> try Some (List.assoc x [(1,true); (2,false)]) with Not_found -> None>.;;
(*
- : ('cl, int -> bool option) code = .<
fun x_1 ->
 (try Some(List.assoc x_1 [((1), (true)); ((2), (false))])) with
  Not_found -> None)>.
*)
let Some true =
  (.! .<fun x -> try Some (List.assoc x [(1,true); (2,false)]) with Not_found -> None>.) 1;;
let Some false =
(.! .<fun x -> try Some (List.assoc x [(1,true); (2,false)]) with Not_found -> None>.) 2;;
let None =
(.! .<fun x -> try Some (List.assoc x [(1,true); (2,false)]) with Not_found -> None>.) 3;;

.<fun x -> let open Scanf in try sscanf x "%d" (fun x -> string_of_int x) with Scan_failure x -> "fail " ^ x>.;;
(*
- : ('cl, string -> string) code = .<
fun x_5 ->
 let open Scanf in
 (try (Scanf.sscanf x_5 "%d" (fun x_7 -> (string_of_int x_7))) with
  Scanf.Scan_failure (x_6) -> ("fail " ^ x_6))>.
*)

let "1" = 
  (.! .<fun x -> let open Scanf in try sscanf x "%d" (fun x -> string_of_int x) with Scan_failure x -> "fail " ^ x>.) "1";;
let "fail scanf: bad input at char number 0: ``character 'x' is not a decimal digit''" =
(.! .<fun x -> let open Scanf in try sscanf x "%d" (fun x -> string_of_int x) with Scan_failure x -> "fail " ^ x>.) "xxx";;

(* Simple let *)

.<let x = 1 in x>.;;
(*
- : ('cl, int) code = .<let x_1 = 1 in x_1>. 
*)
let 1 = 
  .! .<let x = 1 in x>.;;
.<let x = 1 in let x = x + 1 in x>.;;
(*
- : ('cl, int) code = .<let x_7 = 1 in let x_8 = (x_7 + 1) in x_8>. 
*)
let 2 = 
  .! .<let x = 1 in let x = x + 1 in x>.;;
.<let rec f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;
(*
- : ('cl, int) code = .<
let rec f_11 =
 fun n_12 -> if (n_12 = 0) then 1 else (n_12 * (f_11 (n_12 - 1))) in
(f_11 5)>. 
*)
let 120 =
  .! .<let rec f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;

(* Recursive vs. non-recursive bindings *)
.<let f = fun x -> x in 
  let rec f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;
(*
Characters 6-7:
  .<let f = fun x -> x in let rec f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;
        ^
Warning 26: unused variable f.
- : ('cl, int) code = .<
let f_19 = fun x_22 -> x_22 in
let rec f_20 =
 fun n_21 -> if (n_21 = 0) then 1 else (n_21 * (f_20 (n_21 - 1))) in
(f_20 5)>. 
*)

let 120 = .! .<let f = fun x -> x in 
               let rec f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;

.<let f = fun x -> x in 
  let f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;
(*
- : ('cl, int) code = .<
let f_31 = fun x_34 -> x_34 in
let f_32 = fun n_33 -> if (n_33 = 0) then 1 else (n_33 * (f_31 (n_33 - 1))) in
(f_32 5)>. 
*)
let 20 = .! .<let f = fun x -> x in 
              let f = fun n -> if n = 0 then 1 else n * f (n-1) in f 5>.;;


(* General let *)
.<let x = 1 and y = 2 in x + y>.;;
(*
- : ('cl, int) code = .<let x_1 = 1 and y_2 = 2 in (x_1 + y_2)>. 
*)
let 3 = .! .<let x = 1 and y = 2 in x + y>.;;

.<let x = 1 in let x = x+1 and y = x+1 in x + y>.;;
(*
- : ('cl, int) code = .<
let x_3 = 1 in let x_4 = (x_3 + 1) and y_5 = (x_3 + 1) in (x_4 + y_5)>. 
*)
let 4 = .! .<let x = 1 in let x = x+1 and y = x+1 in x + y>.;;
(*
.<fun x -> let (Some x) = x in x + 1>.;;
Characters 15-23:
  .<fun x -> let (Some x) = x in x + 1>.;;
                 ^^^^^^^^
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
None
- : ('cl, int option -> int) code = .<
fun x_11 -> let Some (x_12) = x_11 in (x_12 + 1)>. 
*)
let 3 = (.! .<fun x -> let (Some x) = x in x + 1>.) (Some 2);;
(.! .<fun x -> let (Some x) = x in x + 1>.) None;;
(*
Characters 19-27:
  (.! .<fun x -> let (Some x) = x in x + 1>.) None;;
                     ^^^^^^^^
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
None
Exception: Match_failure ("//toplevel//", 1, 19).
*)
print_endline "Error was expected";;

.<fun x -> let rec even = function 0 -> true | x -> odd (x-1) and 
                   odd  = function 0 -> false | x -> even (x-1) in even x>.;;
(*
- : ('cl, int -> bool) code = .<
fun x_17 ->
 let rec even_18 = function | 0 -> true | x_21 -> (odd_19 (x_21 - 1))
 and odd_19 = function | 0 -> false | x_20 -> (even_18 (x_20 - 1)) in
 (even_18 x_17)>.
*)
let true = (.! .<fun x -> let rec even = function 0 -> true | x -> odd (x-1) and odd = function 0 -> false | x -> even (x-1) in even x>.) 42;;
let false = (.! .<fun x -> let rec even = function 0 -> true | x -> odd (x-1) and odd = function 0 -> false | x -> even (x-1) in even x>.) 43;;


(* testing scope extrusion *)
let r = ref .<0>. in let _ = .<fun x -> .~(r := .<1>.; .<0>.)>. in !r ;;
(* - : ('cl, int) code = .<1>.  *)
let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;
(* shown code is a bit funny -- but instructive! *)
(*
- : ('cl, int) code = .<x_10 <- x_10>.

Failure("Scope extrusion at Characters 50-51:\n  let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;\n                                                    ^\n for the identifier x_10 bound at Characters 35-36:\n  let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;\n                                     ^\n")
*)
print_endline "Error was expected";;

let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;
(*
Exception:
Failure
 "Scope extrusion at Characters 58-59:\n  let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;\n                                                            ^\n for the identifier x_11 bound at Characters 43-44:\n  let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;\n                                             ^\n".
*)
print_endline "Error was expected";;

let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;
(*
- : ('cl, '_a -> '_a) code = .<x_13 <- fun y_14 -> x_13>.

Failure("Scope extrusion at Characters 57-67:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;\n                                                           ^^^^^^^^^^\n for the identifier x_13 bound at Characters 42-43:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;\n                                            ^\n")
*)
print_endline "Error was expected";;

(* Error message is reported on splice *)
let r = ref .<fun y->y>. in 
let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in .<fun x -> .~(!r) 1>. ;;
(*
Failure
 "Scope extrusion at Characters 58-68:\n  let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in .<fun x -> .~(!r) 1>. ;;\n                               ^^^^^^^^^^\n for the identifier x_34 bound at Characters 43-44:\n  let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in .<fun x -> .~(!r) 1>. ;;\n                ^\n".
*)
print_endline "Error was expected";;

(* The test is approximate: it is sound but overflagging *)
let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;
(*
- : ('cl, '_a -> '_a) code = .<x_16 <- fun y_17 -> y_17>.

Failure("Scope extrusion at Characters 57-67:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;\n                                                           ^^^^^^^^^^\n for the identifier x_16 bound at Characters 42-43:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;\n                                            ^\n")
*)
print_endline "Error was expected";;

(* The following are OK though *)
let r = ref .<fun y->y>. in .<fun x -> .~(r := .<fun y -> y>.; !r)>.;;
(*
- : ('cl, '_a -> '_b -> '_b) code = .<fun x_22 -> fun y_23 -> y_23>. 
*)
let r = ref .<fun y->y>. in .<fun x -> .~(r := .<fun y -> x>.; !r)>.;;
(*
- : ('cl, '_a -> '_a -> '_a) code = .<fun x_25 -> fun y_26 -> x_25>. 
*)

print_endline "\nAll done\n";;
