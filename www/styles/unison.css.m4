/* $Id: unison.css,v 1.39 2006/11/04 03:48:25 rkh Exp $     emacs: -*-c-*-  */

/*
  The color palette should be decomposed into the simplest set of colors,
  such as:
  FG, BG
  HIGHLIGHT_FG, BG
  HIGHLIGHT2_FG, BG

  or consider:
  HUE{1,2,3,4}{A,B,C,D}_{FG,BG} where HUE1 is a color group, A-D are
  specifc colors, and FG,BG provide contrast for highlighting

 */


body {
 background: U_BG;
 font-family: sans-serif;
}

img {
 border: 0;
}

a:hover {
 background: U_HOVER_HIGHLIGHT_BG;
 color: U_HOVER_HIGHLIGHT_FG;
}



/* page elements */
table.page {
 width: 100%;
}
table.page td {
 margin: 0;
 padding: 2px;
 vertical-align: middle;
}
table.page td.left {
  text-align: center;
  width: 120px;
  border-right: medium double U_FRAME;
}
table.page td.body {
  padding: 10px 0px 10px 0px;
  border-top: medium double U_FRAME;
  border-bottom: medium double U_FRAME;
}
table.page td.right {
  text-align: left;
}


/* navbar */
div.nav table {
  border-spacing: 0;
  margin: 0;
  width: 100%;
}
div.nav table.navp {
 border: none;
  border-bottom: 2px solid U_BG;
}
div.nav table.navc {
  border: medium solid U_FRAME;
  padding: 1px;
}

span.note {
  font-size: 0.8em;
  font-style: italic;
}

div.nav ul {
  display: inline;
  padding: 0;
  margin: 0;
  list-style-type: none;
  text-align: left;
}
div.nav td.right {
  text-align: right;
}
div.nav table.navp ul {
}

div.nav li { 
  display: inline;
  backgrond: white;
  border: thin solid U_FRAME;
  color: U_FRAME;
 -moz-border-radius: 3px;
  border-radius: 3px;
}
div.nav li.selected { 
  background: U_FRAME;
  color: white;
  font-weight: bold;
}
div.nav table.navp li.selected {
  border-top: thin solid U_FRAME;  
  border-bottom: 5px solid U_FRAME;  
}

div.nav li a, div.nav li span {
  padding: 0px 4px 0px 4px;
}

div.nav a {
  text-decoration: none;
  color: U_FRAME;
}

div.nav a:hover {
  color: black;
  background-color: U_HOVER_HIGHLIGHT;
}



/* grouped data */
table.group {
 width: 100%;
 margin: 0;
  margin-top: 10px;
 padding: 0;
 border: 0;
 border-spacing: 0;
}

table.group th.grouptag {
 border: thin solid U_FRAME;
 -moz-border-radius: 4px;
  border-radius: 4px;
 background: U_FRAME;
 width: 20%;
 font-size: largest;
 color: U_BG;
}

table.group td {
 border: medium solid U_FRAME;
 -moz-border-radius: 4px;
  border-radius: 4px;
}


table.summary {
 width: 100%;
 background: U_BG;
 border: none;
 margin: 0px;
 padding: 0px;
}
table.summary th {
 border: none;
 margin: 0px;
 padding: 0px;
 text-align: right;
 vertical-align: top;
 white-space: nowrap;
}
table.summary th div {
 background: U_UWTABLE_FG;
 color: U_UWTABLE_BG;
 white-space: nowrap;
 border: thin solid U_UWTABLE_FG;
 padding: 0px;
 margin: 0px;
}
table.summary td {
 vertical-align: top;
 border: none;
 margin: 0px;
 padding: 0px;
}


/* Quick Links */
table.quicklinks {
  /* border:  U_FRAME thin solid; */
}
td.quicklinks_title {
 background: U_NAV_FG;
 color: U_NAV_BG;
 padding-left: 2px;
 padding-right: 2px;
 white-space: nowrap;
 font-style: italic; 
}
td.quicklinks {
 border:  thin solid U_NAV_FG;
 color: U_NAV_FG;
 padding-left: 2px;
 padding-right: 2px;
 white-space: nowrap;
}


/* credits */
table.credits {
 border: U_FRAME thin solid;
}
table.credits th {
 border: U_FRAME thin solid;
 background: U_FRAME;
  /* color: white; */
}
table.credits td {
 border: U_FRAME thin solid;
}



table.uwtable {
 background: U_UWTABLE_BG;
 border: none;
 margin: 0px;
  border-collapse: collapse;
 -moz-border-radius: 0px;
  border-radius: 0px;
  white-space: wrap;
}
table.uwtable th, table.uwtable td {
 -moz-border-radius: 0px;
  border-radius: 0px;
}
table.uwtable th {
 border: thin solid U_UWTABLE_BG;
 background: U_UWTABLE_FG;
 color: U_UWTABLE_BG;
}
table.uwtable td {
 border: thin solid U_UWTABLE_FG;
}
table.uwtable th.highlighted {
 background: U_TABLE_HIGHLIGHT_FG;
}
table.uwtable td.highlighted {
 background: U_TABLE_HIGHLIGHT_BG;
}


/* software stack table (in about_unison) */
table.sw_stack {
 border: medium U_FRAME solid;
}
table.sw_stack tr {
 border: thin U_FRAME solid;
}
table.sw_stack th {
 background: U_FRAME;
 color: U_BG;
 vertical-align: top;
 padding: 5px;
}
table.sw_stack td.sw_stack_sep {
 border-top: thin solid U_FRAME;
 border-bottom: thin solid U_FRAME;
}



span.page_break {
  border-bottom: medium double U_FRAME;
}

/* 
TR.tablesep {
  background: orange;
}
*/

span.page_title {
  font-weight: bold;
}


/* cheap text buttons */
span.button {
 background: U_UNHIGHLIGHTED;
 border: black thin solid;
}
span.button:hover {
 background: U_HOVER_HIGHLIGHT;
}
/* SPAN.button A {
   color: white;
   font-weight: bold;
   text-decoration: none;
   } */



div.important {
 border: red medium solid;
 padding: 4px;
 margin: 20px 20px 20px 20px;
 color: U_IMPORTANT_FG;
 background-color: U_IMPORTANT_BG;
}



/* tooltip */
span.tooltip {
 border: none;
 background-color: U_TOOLTIP_BG;
 color: U_TOOLTIP_FG;
 font-weight: bold;
 font-size: smaller;
 padding: none;
 margin: none;
}

span.tooltip:hover {
 cursor:pointer;cursor:help;
}


/* domTT Classic Style, from domTT examples.css */
div.domTTUnison {
 border: 2px solid U_POPUP_FRAME;
 background: U_POPUP_BG;
}
div.domTTUnison .caption {
  font-family: serif;
  font-size: 12px;
  font-weight: bold;
  font-style: italic;
 padding: 1px 2px;
 background: U_POPUP_BG;
}
div.domTTUnison .contents {
 color: U_POPUP_FG;
 font-size: 12px;
 font-family: Arial, sans-serif;
 padding: 1px 2px;
}



pre.code {
 border: black thin dashed;
 background: U_CODE_BG;
 margin: 20px;
 padding: 5px;
 overflow: auto;
}


dl {
 margin-right: 50px;
}
dt {
 font-style: italic;
}
dd {
 margin-right: 50px;
 font-size: smaller;
}

/* miscellany */
span.error {
 color: U_ERROR_FG;
}
span.debug {
  background-color: U_DEBUG_BG;
}
div.warning {
 border: U_ERROR_FG medium solid;
 padding: 2px;
 margin: 5px;
 color: U_ERROR_FG;
}
div.sql {
 border: U_SQL_FG thin solid;
 padding: 2px;
 margin: 5px;
 color: U_SQL_FG;
 background-color: U_SQL_BG;
 font-family: monospace;
 font-size: xx-small;
}
