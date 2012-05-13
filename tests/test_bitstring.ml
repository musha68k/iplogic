(* Copyright (C) 2012  Petter Urkedal <paurkedal@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

open Printf

let maxdim = 256

let bool_array_get8 i data =
    let rec loop j x =
	if j < 0 then x else
	let bit = if Array.get data (i * 8 + j) then 1 else 0 in
	loop (j - 1) (2 * x + bit) in
    loop 7 0

let bool_array_get16 i data =
    let rec loop j x =
	if j < 0 then x else
	let bit = if Array.get data (i * 16 + j) then 1 else 0 in
	loop (j - 1) (2 * x + bit) in
    loop 15 0

let test () =
    let data = Array.init maxdim (fun i -> Random.bool ()) in
    let n = Random.int 256 in
    let bs = Bitstring.init n (fun i -> Array.get data i) in
    let bs8 = Bitstring.init8 (n / 8) (fun i -> bool_array_get8 i data) in
    let bs16 = Bitstring.init16 (n / 16) (fun i -> bool_array_get16 i data) in

    assert (Bitstring.length bs8 = n / 8 * 8);
    assert (Bitstring.length bs16 = n / 16 * 16);

    for i = 0 to n - 1 do
	assert (Bitstring.get i bs = Array.get data i)
    done;
    for i = 0 to n / 8 - 1 do
	assert (Bitstring.get8 i bs = bool_array_get8 i data)
    done;
    for i = 0 to n / 16 - 1 do
	assert (Bitstring.get16 i bs = bool_array_get16 i data)
    done;

    let i_r = ref 0 in
    let n' = Bitstring.foldi
	(fun i x ->
	    assert (i = !i_r);
	    assert (x = Array.get data i);
	    i_r := !i_r + 1;
	    fun x -> x + 1)
	bs 0 in
    assert (!i_r = n);
    assert (n' = n);

    let i_r = ref 0 in
    let n' = Bitstring.foldi8
	(fun i x ->
	    assert (i = !i_r);
	    assert (x = bool_array_get8 i data);
	    i_r := !i_r + 1;
	    fun x -> x + 1)
	bs8 0 in
    assert (!i_r = n / 8);
    assert (n' = n / 8);

    let i_r = ref 0 in
    let n' = Bitstring.foldi16
	(fun i x ->
	    assert (i = !i_r);
	    assert (x = bool_array_get16 i data);
	    i_r := !i_r + 1;
	    fun x -> x + 1)
	bs16 0 in
    assert (!i_r = n / 16);
    assert (n' = n / 16);

    assert (n = Bitstring.common_prefix_length bs bs);
    assert (n / 8 * 8 = Bitstring.common_prefix_length bs bs8);
    assert (n / 16 * 16 = Bitstring.common_prefix_length bs bs16)

let () =
    for i = 0 to 1000 do test () done
