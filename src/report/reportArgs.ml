(*
 * This file is part of Bisect.
 * Copyright (C) 2008-2012 Xavier Clerc.
 *
 * Bisect is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Bisect is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

type output_kind =
  | Html_output of string
  | Xml_output of string
  | Xml_emma_output of string
  | Csv_output of string
  | Text_output of string
  | Dump_output of string
  | Bisect_output of string

let outputs = ref []

let add_output o =
  outputs := o :: !outputs

let verbose = ref false

let tab_size = ref 8

let title = ref "Coverage report"

let separator = ref ";"

let search_path = ref [""]

let add_search_path sp =
  search_path := sp :: !search_path

let files = ref []

let combine_expr = ref None

let summary_only = ref false

let add_file f =
  files := f :: !files

let options = [
  ("-I",
   Arg.String add_search_path,
   "<dir>  Look for .cmp and/or .ml files in the given directory") ;
  ("-html",
   Arg.String (fun s -> add_output (Html_output s)),
   "<dir>  Output html to the given directory") ;
  ("-title",
   Arg.Set_string title,
   "<string>  Set the title for generated output (HTML only)") ;
  ("-tab-size",
   Arg.Int
     (fun x ->
       if x < 0 then
         (print_endline " *** error: tab size should be positive"; exit 1)
       else
         tab_size := x),
   "<int>  Set tabulation size in output (HTML only)") ;
  ("-text",
   Arg.String (fun s -> add_output (Text_output s)),
   "<file>  Output plain text to the given file") ;
    ("-summary-only",
   Arg.Set summary_only,
   " Output only a summary (text only)") ;
  ("-bisect",
   Arg.String (fun s -> add_output (Bisect_output s)),
   "<file>  Output bisect data to the given file") ;
  ("-combine-expr",
   Arg.String (fun s -> combine_expr := Some s),
   "<expr>  Combine files according to given expression to produce counts") ;
  ("-csv",
   Arg.String (fun s -> add_output (Csv_output s)),
   "<file>  Output CSV to the given file") ;
  ("-separator",
   Arg.Set_string separator,
   "<string>  Set the separator for generated output (CSV only)") ;
  ("-dump",
   Arg.String (fun s -> add_output (Dump_output s)),
   "<file>  Output bare dump to the given file") ;
  ("-xml",
   Arg.String (fun s -> add_output (Xml_output s)),
   "<file>  Output XML to the given file") ;
  ("-dump-dtd",
   Arg.String
     (function
       | "-" ->
           ReportUtils.output_strings ReportXML.dtd [] stdout;
           exit 0
       | s ->
           Common.try_out_channel
             false
             s
             (ReportUtils.output_strings ReportXML.dtd []);
           exit 0),
   "<file>  Output XML DTD to the given file") ;
  ("-xml-emma",
   Arg.String (fun s -> add_output (Xml_emma_output s)),
   "<file>  Output EMMA XML to the given file") ;
  ("-verbose",
   Arg.Set verbose,
   " Set verbose mode") ;
  ("-version",
   Arg.Unit (fun () -> print_endline Version.value; exit 0),
   " Print version and exit") ;
  ("-no-folding",
   Arg.Unit ignore,
   " Deprecated") ;
  ("-no-navbar",
   Arg.Unit ignore,
   " Deprecated")
]

let parse () =
  Arg.parse
    (Arg.align options)
    add_file
    ("Usage:\n\n  bisect-ppx-report <options> <.out files>\n\n" ^
     "Where a file is required, '-' may be used to specify STDOUT\n\n" ^
     "Examples:\n\n" ^
     "  bisect-ppx-report -I build/ -I src/ -html coverage/ bisect*.out\n" ^
     "  bisect-ppx-report -I _build/ -summary-only -text - bisect*.out\n\n" ^
     "Options are:")
