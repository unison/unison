/* $Id: unison.css,v 1.39 2006/11/04 03:48:25 rkh Exp $     emacs: -*-c-*-  */

/* PALETTE */

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
 border: 0px;
}

hr {
 clear: both;
}

dt {
  font-weight: bold;
}
dd {
  margin-left: 20px;
  margin-bottom: 10px;
}

a:hover {
 background: U_HIGHLIGHT_BG;
 color: U_HIGHLIGHT_FG;
}
a.ext_link {
  /* consider css2 :after pseudo-element instead */
 background: url(../av/extlink.gif) right center no-repeat;
 padding-right: 14px;
}

a.nofeedback:hover {
 background: U_BG;
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
  /*border-right: thin dotted U_FRAME;*/
}
table.page td.body {
  padding: 10px 0px 10px 0px;
  border-top: thin solid U_FRAME;
  border-bottom: thin solid U_FRAME;
}
table.page td.right {
  text-align: left;
}


/* navbar */
div.nav table {
 border-spacing: 0px;
 border: none;
 margin: 0px;
 padding: 0px;
 width: 100%;
  /* font-size: 0.9em; */
  font-variant: small-caps;
}
div.nav table.navp {
 border: none;
 border-bottom: 2px solid U_NAV_BG;
}
div.nav table.navc {
 border: medium solid U_NAV_FRAME;
 padding: 1px;
}
div.nav ul {
 display: inline;
 padding: 0px;
 margin: 0px;
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
 background: U_NAV_BG;
 border: thin solid U_NAV_FRAME;
 -moz-border-radius: 3px;
 color: U_NAV_FG;
}
div.nav li.selected { 
 background: U_NAV_SELECTED_BG;
 border-color: U_NAV_SELECTED_FRAME;
 color: U_NAV_SELECTED_FG;
 font-weight: bold;
}
div.nav table.navp li.selected {
 border-top: thin solid U_NAV_FRAME;  
 border-bottom: 5px solid U_NAV_FRAME;  
}
div.nav li a, div.nav li span {
 padding: 0px 4px 0px 4px;
}
div.nav a {
 text-decoration: none;
 color: U_NAV_FG;
}
div.nav a:hover {
 color: U_NAV_HOVER_FG;
 background-color: U_NAV_HOVER_BG;
 border-color: U_NAV_HOVER_FRAME;
}







/* grouped data */
fieldset.group {
 border: medium solid U_FRAME;
 margin: 5px 0px 15px 0px;
 padding: 3px;
}

fieldset.group legend {
 border-color: U_LEGEND_FRAME;
  border-style: solid;
  border-width: 0px medium 0px medium;
 background: U_LEGEND_BG;
 color: U_LEGEND_FG;
 font-weight: bold;
 padding: 2px 5px 2px 5px;
}

fieldset.group hr {
 color: U_LEGEND_FRAME;
 background: U_LEGEND_FRAME;
 margin: 2px 50px 2px 50px;
}

span.group_ctl {
 background: U_BG;
 color: U_FRAME;
}


/* Summary table */
table.summary {
 width: 100%;
 background: U_BG;
 border: none;
 margin: 0px;
 padding: 0px;
}
table.summary th {
 border: none;
 border-right: medium solid U_UWTABLE_TH_FRAME;
 margin: 0px;
 padding: 0px;
 text-align: right;
 vertical-align: top;
 white-space: nowrap;
 width: 10%;					/* to prevent short BA's from causing odd splits */
}
table.summary th div {
 border: none;
 border-left: thin solid U_UWTABLE_TH_FRAME;
 border-top: thin solid U_UWTABLE_TH_FRAME;
 border-bottom: thin solid U_UWTABLE_TH_FRAME;
 color: U_UWTABLE_TH_FG;
 background: U_UWTABLE_TH_BG;
 white-space: nowrap;
 padding: 1px 4px 1px 4px;
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
  border-collapse: collapse;
}
table.quicklinks th, table.quicklinks td {
  border: U_NAV_FG thin solid;
 padding-left: 2px;
 padding-right: 2px;
 white-space: nowrap;
}
table.quicklinks th {
 background: U_NAV_FG;
 color: U_NAV_BG;
 font-style: italic; 
}


/* (screen)shots */
table.shots {
 width: 60%;
  /* center table with margin-left == margin-right */
  margin-left: auto;
  margin-right: auto;
}
table.shots th {
 width: 20%;
  vertical-align: middle;
 border: thin solid U_FRAME;
}
table.shots td {
  vertical-align: middle;
 border: thin solid U_FRAME;
}
table.shots th img {
 width: 100%;
}


/* credits */
table.credits {
 border: none; /* U_FRAME thin solid; */
}
table.credits th {
 border: U_FRAME thin solid;
 background: U_FRAME;
  /* color: white; */
}
table.credits td {
 border: U_FRAME thin solid;
}


/* Gene Ontology table (used for nice spacing) */
/* (a ul or dl might be more natural) */
table.go {
  border-collapse: collapse;
}
tr.go_function, tr.go_process, tr.go_component {
  /*
	border: 1px black dashed;
	background: #eee;
  */
 padding: 1px;
}
table.go th {
 padding: 1px 4px 1px 1px;
 font-weight: bold;
  font-style: italic;
 text-align: left;
  vertical-align: top;
}
table.go td {
 padding: 1px;
}


/* uwtable (e.g., commonly inside the group fieldset) */
table.uwtable {
 width: 100%;
 background: U_UWTABLE_BG;
 border: none;
  border-collapse: collapse;
}
table.uwtable tr {
  /*background: U_UWTABLE_TD_BG;*/
}
table.uwtable tr:hover {
 background: U_HOVER_BG;
}
table.uwtable th, table.uwtable td {
  vertical-align: top;
  border: thin solid;
}
table.uwtable th {
  border-color: U_UWTABLE_TH_FRAME;
  border-bottom-width: medium;
  color:  U_UWTABLE_TH_FG;
  background: U_UWTABLE_TH_BG;
 text-align: center;
 font-weight: bold;
}
table.uwtable td {
  border-color: U_UWTABLE_TD_FRAME;
  color:  U_UWTABLE_TD_FG;
  white-space: normal;
}
table.uwtable .highlighted, table.uwtable .highlighted td {
 border-color: U_UWTABLE_HIGHLIGHT_FRAME;
 background: U_UWTABLE_HIGHLIGHT_BG;
 color: U_UWTABLE_HIGHLIGHT_FG;
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
 background: U_BG;
 color: U_FRAME;
 margin: 0px 2px 0px 2px;
}
span.button:hover {
 background: U_HIGHLIGHT_BG;
}



/* tooltip */
span.has_tooltip {
 color: U_TOOLTIP_FG;
 cursor:help;
}

span.tooltip {
 border: none;
 background-color: U_TOOLTIP_BG;
 color: U_TOOLTIP_FG;
 font-weight: bold;
 font-size: smaller;
 padding: 0px;
 margin: 0px;
}

span.tooltip:hover {
 cursor:pointer;cursor:help;
}


/* domTT Classic Style, from domTT examples.css */
div.domTTUnison {
 border: medium double U_POPUP_FRAME;
 background: U_POPUP_BG;
}
div.domTTUnison .caption {
  font-family: serif;
  font-size: 12px;
  font-weight: bold;
  font-style: italic;
 padding: 2px 2px;
 background: U_POPUP_BG;
}
div.domTTUnison .contents {
 color: U_POPUP_FG;
 font-size: 12px;
 font-family: Arial, sans-serif;
 padding: 2px 2px;
}



pre.code {
 border: black thin dashed;
 background: U_CODE_BG;
 margin: 20px;
 padding: 5px;
 overflow: auto;
}



/* "top" pages */
div.top {
  margin-left: 10%;
  margin-right: 10%;
}

div.top dl {
}
div.top dt {
 margin: 0px;
 border-bottom: thin dotted U_FRAME_BG;
 font-weight: bold;
}
div.top dd {
 margin: 0px 0px 10px 0px;
}


/* USED?
div.top fieldset {
 border: thin dotted U_FRAME;
 margin: 5px;
 padding: 3px;
 width: 40%;
}
div.top legend {
 border-color: U_LEGEND_FRAME;
  border-style: solid;
  border-width: 0px thin 0px thin;
 background: U_LEGEND_BG;
 color: U_LEGEND_FG;
 font-weight: bold;
 padding: 2px 5px 2px 5px;
}
*/




/* miscellany */
span.debug {
  background-color: U_DEBUG_BG;
}
span.note {
  font-style: italic;
  color: U_ERROR_FG;
}
span.error {
 color: U_NOTICE_FG;
 background: U_NOTICE_BG;
}

div.sql {
 border: U_CODE_FRAME thin solid;
 padding: 2px;
 margin: 5px;
 color: U_CODE_FG;
 background-color: U_CODE_BG;
 font-family: monospace;
 font-size: 0.8em;
}
div.notice, div.warning, div.important {
 border: medium solid U_ERROR_FG;
 padding: 4px;
 font-style: italic;
}
div.notice {
 margin: 5px 25px 5px 25px;
}
div.warning, div.important {
 margin: 25px;
}
