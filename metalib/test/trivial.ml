(* Trivial tests of MetaOCaml, which are also regression tests *)

3+2;;
(* - : int = 5 *)
let rec fact = function | 0 -> 1 | n -> n * fact (n-1);;
(* val fact : int -> int = <fun> *)
fact 5;;
(* - : int = 120 *)

.<1>.;;
(* - : ('cl, int) code = .<1>. *)
.<"aaa">.;;
(* - : ('cl, string) code = .<"aaa">. *)
.! .<1>.;;
(* - : int = 1 *)


.<fun x -> .~(let y = x in y)>.;;
(*
Characters 22-23:
  .<fun x -> .~(let y = x in y)>.;;
                        ^
Error: Wrong level: variable bound at level 1 and used at level 0
*)

.<fun x -> 1 + .~(.<true>.)>.;;
(*
Characters 20-24:
  .<fun x -> 1 + .~(.<true>.)>.;;
                      ^^^^
Error: This expression has type bool but an expression was expected of type
         int
*)

.<fun x -> .~(.! .<x>.; .<1>.)>.;;
(*
Characters 14-22:
  .<fun x -> .~(.! .<x>.; .<1>.)>.;;
                ^^^^^^^^
Error: .! error: 'cl not generalizable in ('cl, 'a) code
*)

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
l 1.0;;                  (* better printing in N100 *)
(*
- : ('a, float) code = .<1.>.
*)

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

.! .<succ 1>.;;
(* - : int = 2 *)

.<1 + 2>.;;
(*
- : ('cl, int) code = .<(1 + 2)>.
*)
.! .<(1 + 2)>.;;
(* - : int = 3 *)

.<String.length "abc">.;;
(*
- : ('cl, int) code = .<String.length "abc">.
*)
.! .<String.length "abc">.;;
(* - : int = 3 *)

.<StringLabels.sub ?pos:1 ?len:2 "abc">.;;
(*
- : ('cl, string) code = .<(StringLabels.sub "abc" ~pos:1 ~len:2>.
*)
.! .<StringLabels.sub ?pos:1 ?len:2 "abc">.;;
(* - : string = "bc" *)

.<StringLabels.sub ~len:2 ~pos:1 "abc">.;;
(*
- : ('cl, string) code = .<(StringLabels.sub "abc" ~pos:1 ~len:2>.
*)
.! .<StringLabels.sub ~len:2 ~pos:1 "abc">.;;
(* - : string = "bc" *)

(* Nested brackets and escapes and run *)
.<.<1>.>.;;
(*
- : ('cl, ('cl0, int) code) code = .<.<1>.>.
*)
.! .<.<1>.>.;;
(* - : ('cl, int) code = .<1>. *)
.! (.! .<.<1>.>.);;)
(* - : int = 1 *)
.<.!.<1>.>.;;
(*
- : ('cl, int) code = .<.!.<1>.>.
*)
.! .<.!.<1>.>.;;
(* - : int = 1 *)
.<1 + .~(let x = 2 in .<x>.)>.;;
(*
- : ('cl, int) code = .<(1 + 2)>.
*)
let x = .< 2 + 4 >. in .< .~ x + .~ x >. ;;
(*
- : ('cl, int) code = .<((2 + 4) + (2 + 4))>.
*)

.<1 + .~(let x = 2 in .<.<x>.>.)>.;;
(*
Characters 24-29:
  .<1 + .~(let x = 2 in .<.<x>.>.)>.;;
                          ^^^^^
Error: This expression has type ('cl, 'a) code
       but an expression was expected of type int
*)
.<1 + .! .~(let x = 2 in .<.<x>.>.)>.;;
(*
- : ('cl, int) code = .<(1 + .!.<2>.)>.
*)
.! .<1 + .! .~(let x = 2 in .<.<x>.>.)>.;;
(* - : int = 3 *)
.! .<1 + .~ (.~(let x = 2 in .<.<x>.>.))>.;;
(*
Characters 12-40:
  .! .<1 + .~ (.~(let x = 2 in .<.<x>.>.))>.;;
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Error: Wrong level: escape at level 0
*)

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
Lazy.force (.! .<lazy 1>.);;
(* - : int = 1 *)

(* Tuples *)
.<(1,"abc")>.;;
(*
- : ('cl, int * string) code = .<((1), ("abc"))>.
*)
.<(1,"abc",'d')>.;;
(*
- : ('cl, int * string * char) code = .<((1), ("abc"), ('d'))>.
*)
match .! .<(1,"abc",'d')>. with (_,x,_) -> x;;
(* - : string = "abc" *)

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
.! .<Int 1>.;;
(*
- : Genlex.token = Int 1
*)

module Foo = struct exception E end;;
.<raise Foo.E>.;;
(*
Fatal error: exception Trx.TrxError("Exception Foo.E cannot be used within brackets. Put into a separate file.")
*)
type foo = Bar;;
.<Bar>.;;
(*
Fatal error: exception Trx.TrxError("Constructor Bar cannot be used within brackets. Put into a separate file.")
*)
module Foo = struct type foo = Bar end;;
.<Foo.Bar>.;;
(*
Fatal error: exception Trx.TrxError("Constructor Foo.Bar cannot be used within brackets. Put into a separate file.")
*)

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
let x = {Complex.re = 1.0; im = 2.0} in .<x.Complex.re>.;;
(*
- : ('cl, float) code =
.<((* cross-stage persistent value (as id: x) *)).Complex.re>.
*)
.!(let x = {Complex.re = 1.0; im = 2.0} in .<x.Complex.re>.);;
(* - : float = 1. *)
let x = ref 1 in .<x.contents>.;;       (* Pervasive record *)
(*
- : ('cl, int) code =
.<((* cross-stage persistent value (as id: x) *)).contents>.
*)
.!(let x = ref 1 in .<x.contents>.);;
(* - : int = 1 *)
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
norm (.! .<{re = 1.0; im = 2.0}>.);;
(* - : float = 2.23606797749979 *)
let x = {re = 1.0; im = 2.0} in .<x.re>.;;
(*
- : ('cl, float) code =
.<((* cross-stage persistent value (as id: x) *)).Complex.re>.
*)
.!(let x = {re = 1.0; im = 2.0} in .<x.re>.);;
(* - : float = 1. *)

type foo = {fool : int};;
.<{fool = 1}>.;;
(*
Fatal error: exception Trx.TrxError("Label fool cannot be used within brackets. Put into a separate file.")
*)

(* Conditional *)

.<if true then 1 else 2>.;;
(* - : ('cl, int) code = .<if (true) then 1 else 2>. *)
<if Some 1 = None then print_string "weird">.;;
(*
- : ('cl, unit) code =
.<if ((Some (1)) = (None)) then (print_string "weird">.
*)
.! .<if Some 1 = None then print_string "weird">.;;
(* - : unit = () *)

(* Polymorphic variants *)
.<`Foo>.;;
(*
- : ('cl, [> `Foo ]) code = .<`Foo>.
*)
.<`Bar 1>.;;
(*
- : ('cl, [> `Bar of int ]) code = .<`Bar 1>.
*)
match .! .<`Bar 1>. with `Bar x -> x ;;
(* - : int = 1 *)

(* Some support for modules *)
et f = fun x -> .<x # foo>.;;
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
.! (f x);;
(* - : int = 1 *)

(* Local open *)
.! .<Complex.(norm {re=1.0; im = 3.0})>.;;
(*
- : float = 3.16227766016837952
*)

.! .<let open Complex in norm {re=1.0; im = 3.0}>.;;

(* - : float = 3.16227766016837952 *)

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
.! .<for i=1 to 2 do for j=1 to 3 do Printf.printf "ok %d %d\n" i j done done>.;;
(*
ok 1 1
ok 1 2
ok 1 3
ok 2 1
ok 2 2
ok 2 3
*)

let c = .<for i=1 to 2 do .~(let x = .<i>. in .<for i=1 to 3 do Printf.printf "ok %d %d\n" i .~x done>.) done>.;;
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

let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<0>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;
(*
- : ('cl, unit) code = .<for i_2 = 1 to 5 do (ignore 0 done>.
*)

let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;
(*
Exception:
Failure
 "Scope extrusion at Characters 49-50:\n  let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;\n                                                   ^\n for the identifier i_3 bound at Characters 27-28:\n  let r = ref .<0>. in .<for i=1 to 5 do .~(r := .<i>.; .<()>.) done>.; .<for i=1 to 5 do ignore (.~(!r)) done>.;;\n                             ^\n".
*)

(* Simple functions *)
.<fun x -> x>.;;
(*
- : ('cl, 'a -> 'a) code = .<fun x_3 -> x_3>.
*)
(.! .<fun x -> x>.) 42;;
(* - : int = 42 *)

.<fun x y -> x + y>.;;
(*
- : ('cl, int -> int -> int) code = .<fun x_5 -> fun y_6 -> (x_5 + y_6)>.
*)
(.! .<fun x y -> x + y>.) 2 3;;
(* - : int = 5 *)

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
(.! (eta (fun y -> .<fun x -> x + .~y>.))) 2 3;;
(* - : int = 5 *)

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
(.! .<fun () -> 1>.) ();;
(* - : int = 1  *)

.<function true -> 1 | false -> 0>.;;
(*
- : ('cl, bool -> int) code = .<function | true -> 1 | false -> 0>. 
*)
(.! .<function true -> 1 | false -> 0>.) true;;
(* - : int = 1 *)

.<fun (true,[]) -> 1>.;;
(*
- : ('cl, bool * 'a list -> int) code = .<fun (true, []) -> 1>. 
*)
(.! .<fun (true,[]) -> 1>.) (true,[1]);;
(*
Exception: Match_failure ("//toplevel//", 1, 6).
*)
(.! .<fun (true,[]) -> 1>.) (true,[]);;
(* - : int = 1 *)

.<fun [|true;false;false|] -> 1>.;;
(*
- : ('cl, bool array -> int) code = .<fun [|true; false; false|] -> 1>. 
*)
(.! .<fun [|true;false;false|] -> 1>.) [|true;false;false|];;
(* - : int = 1 *)

.<function `F 1 -> true | _ -> false>.;;
(*
- : ('cl, [> `F of int ] -> bool) code = .<
function | (`F 1) -> true | _ -> false>. 
*)
(.! .<function `F 1 -> true | _ -> false>.) (`F 1);;
(* - : bool = true *)
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
(.! .<function (1,"str") -> 1 | (2,_) -> 2>.) (1,"str");;
(* - : int = 1 *)
(.! .<function (1,"str") -> 1 | (2,_) -> 2>.) (2,"str");;
(* - : int = 2 *)
(.! .<fun [1;2] -> 1>.) [1;2];;
(* - : int = 1 *)

(.! .<function None -> 1 | Some [1] -> 2>.) (Some [1]);;
(* - : int = 2 *)


(.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some None);;
(* - : int = 2 *)
(.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some (Some true));;
(* - : int = 1 *)
(.! .<function (Some (Some true)) -> 1 | _ -> 2>.) (Some (Some false));;
(* - : int = 2 *)
(.! .<function (Some (Some true)) -> 1 | _ -> 2>.) None;;
(* - : int = 2 *)

open Complex;;
.<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.;;
(*
- : ('cl, Complex.t -> int) code = .<
function
| {Complex.re = 1.0} -> 1
| {Complex.re = 2.0; Complex.im = 2.0} -> 2
| {Complex.im = _} -> 3>. 
*)

(.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.) {re=1.0; im=2.0};;
(* - : int = 1 *)
(.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.) {re=2.0; im=2.0};;
(* - : int = 2 *)
(.! .<function {re=1.0} -> 1 | {im=2.0; re = 2.0} -> 2 | {im=_} -> 3>.) {re=2.0; im=3.0};;
(* - : int = 3 *)

(* General functions *)

.<fun (x,y) -> x + y>.;;
(*
- : ('cl, int * int -> int) code = .<fun (x_2, y_3) -> (x_2 + y_3)>. 
*)
(.! .<fun (x,y) -> x + y>.) (2,3);;
(* - : int = 5 *)
.<function (Some x) as y -> x | _ ->  2>.;;
(*
- : ('cl, int option -> int) code = .<
function | (Some (x_6) as y_7) -> x_6 | _ -> 2>.
*)
(.! .<function (Some x) as y -> x | _ ->  2>.) (Some 1);;
(* - : int = 1 *)
(.! .<function (Some x) as y -> x | _ ->  2>.) None;;
(* - : int = 2 *)
.<function [x;y;z] -> x - y + z | [x;y] -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
function
| (x_12 :: y_13 :: z_14 :: []) -> ((x_12 - y_13) + z_14)
| (x_15 :: y_16 :: []) -> (x_15 - y_16)>. 
*)
(.! .<function [x;y;z] -> x - y + z | [x;y] -> x - y>.) [1;2;3];;
(* - : int = 2 *)

 (* OR patterns *)
.<function ([x;y] | [x;y;_]) -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
fun ((x_1 :: y_2 :: []) | (x_1 :: y_2 :: _ :: [])) -> (x_1 - y_2)>. 
*)
(.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2];;
(* - : int = -1 *)
(.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2;3];;
(* - : int = -1 *)
(.! .<function ([x;y] | [x;y;_]) -> x - y>.) [1;2;3;4];;
(* Exception: Match_failure ("//toplevel//", 1, 6). *)

.<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.;;
(*
- : ('cl, int list -> int) code = .<
fun (((x_9 :: y_10 :: []) | (x_9 :: y_10 :: _ :: []))
     | (y_10 :: x_9 :: _ :: _ :: [])) ->
 (x_9 - y_10)>.
*)
(.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2];;
(* - : int = -1 *)
(.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2;3];;
(* - : int = -1 *)
(.! .<function ([x;y] | [x;y;_]| [y;x;_;_]) -> x - y>.) [1;2;3;4];;
(* - : int = 1 *)

.<function (`F x | `G x) -> x | `E x -> x>.;;
(*
- : ('cl, [< `E of 'a | `F of 'a | `G of 'a ] -> 'a) code = .<
function | ((`F x_17) | (`G x_17)) -> x_17 | (`E x_18) -> x_18>. 
*)
(.! .<function (`F x | `G x) -> x | `E x -> x>.) (`F 2);;
(* - : int = 2 *)
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
(.! .<function {re=x; im=2.0} -> x | {im=x; re=y} -> x -. y>.) {re=1.0; im=1.0};;
(* - : float = 0. *)
.<function (Some x) as y when x  > 0 -> y | _ -> None>.;;
(*
- : ('cl, int option -> int option) code = .<
function | (Some (x_30) as y_31) when (x_30 > 0) -> y_31 | _ -> None>. 
*)
(.! .<function (Some x) as y when x  > 0 -> y | _ -> None>.) (Some 1);;
(* - : int option = Some 1 *)
(.! .<function (Some x) as y when x  > 0 -> y | _ -> None>.) (Some 0);;
(* - : int option = None *)

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

(* testing scope extrusion *)
let r = ref .<0>. in let _ = .<fun x -> .~(r := .<1>.; .<0>.)>. in !r ;;
(* - : ('cl, int) code = .<1>.  *)
let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;
(* shown code is a bit funny -- but instructive! *)
(*
- : ('cl, int) code = .<x_10 <- x_10>.

Failure("Scope extrusion at Characters 50-51:\n  let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;\n                                                    ^\n for the identifier x_10 bound at Characters 35-36:\n  let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in !r ;;\n                                     ^\n")
*)
let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;
(*
Exception:
Failure
 "Scope extrusion at Characters 58-59:\n  let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;\n                                                            ^\n for the identifier x_11 bound at Characters 43-44:\n  let c = let r = ref .<0>. in let _ = .<fun x -> .~(r := .<x>.; .<0>.)>. in (!r) in .! c;;\n                                             ^\n".
*)

let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;
(*
- : ('cl, '_a -> '_a) code = .<x_13 <- fun y_14 -> x_13>.

Failure("Scope extrusion at Characters 57-67:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;\n                                                           ^^^^^^^^^^\n for the identifier x_13 bound at Characters 42-43:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> x>.; .<0>.)>. in !r ;;\n                                            ^\n")
*)

(* The test is approximate: it is sound but overflagging *)
let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;
(*
- : ('cl, '_a -> '_a) code = .<x_16 <- fun y_17 -> y_17>.

Failure("Scope extrusion at Characters 57-67:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;\n                                                           ^^^^^^^^^^\n for the identifier x_16 bound at Characters 42-43:\n  let r = ref .<fun y->y>. in let _ = .<fun x -> .~(r := .<fun y -> y>.; .<0>.)>. in !r ;;\n                                            ^\n")
*)

(* The fopllowing are OK though *)
let r = ref .<fun y->y>. in .<fun x -> .~(r := .<fun y -> y>.; !r)>.;;
(*
- : ('cl, '_a -> '_b -> '_b) code = .<fun x_22 -> fun y_23 -> y_23>. 
*)
let r = ref .<fun y->y>. in .<fun x -> .~(r := .<fun y -> x>.; !r)>.;;
(*
- : ('cl, '_a -> '_a -> '_a) code = .<fun x_25 -> fun y_26 -> x_25>. 
*)
