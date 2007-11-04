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


BODY {
 background: U_BACKGROUND;
 font-family: sans-serif;
}

IMG {
 border: 0;
}


/*
A {
 border: 1px solid U_BACKGROUND;
}
*/
A:hover {
 background: U_HOVER_HIGHLIGHT_BG;
 color: U_HOVER_HIGHLIGHT_FG;
}



/* page elements */
TABLE.page TD.logo {
  text-align: center;
  vertical-align: middle;
  border-right: medium double U_FRAME;
  padding: 0px 5px 0px 0px;
}
TABLE.page TD.logo IMG {
 border: 0;
}
TABLE.page TD.body {
  padding-top: 2px;
  padding-bottom: 10px;
  border-top: medium double U_FRAME;
  border-bottom: medium double U_FRAME;
  vertical-align: top;
}
TABLE.page TD.footer {
  vertical-align: middle;
 padding: 0px 0px 0px 5px;
}
TABLE.page TD.navbar {
  font-size: small;
 padding: 0px 0px 0px 0px;
 margin: 0px;
}


/* nav and subnav bars */
TABLE.nav {
 border: none;
 color: U_NAV_FG;
 background: U_BACKGROUND;
}
TABLE.nav TD.unselected {
 background: U_NAV_BG;
 border: thin solid U_FRAME;
 color: U_NAV_FG;
 padding-left: 5px;
 padding-right: 5px;
 width: 50px;
}
TABLE.nav TD.selected {
 background: U_NAV_FG;
 border: thin solid U_FRAME;
 color: U_NAV_BG;
 font-weight: bold;
 padding-left: 5px;
 padding-right: 5px;
 white-space: nowrap;
 width: 50px;
}
TABLE.nav TD.unselected:hover {
 background: U_HOVER_HIGHLIGHT;
 border: U_FRAME thin solid;
 color: U_NAV_FG;
 cursor:pointer;cursor:hand;
}
TABLE.nav TD.selected A {
 color: U_NAV_FG;
 font-weight: bold;
 text-decoration: none;
}
TABLE.nav TD.unselected A {
 text-decoration: none;
 color: U_NAV_FG;
}


TABLE.subnav {
 border: U_FRAME medium solid;
 color: U_NAV_FG;
}
TABLE.subnav TD.unselected {
 width: 50px;
 border: U_NAV_BG thin solid;
 padding-left: 5px;
 padding-right: 5px;
 background: U_NAV_BG;
 color: U_NAV_FG;
}
TABLE.subnav TD.selected {
 width: 50px;
 border: U_FRAME thin solid;
 padding-left: 5px;
 padding-right: 5px;
 background: U_FRAME;
 font-weight: bold;
 color: U_NAV_FG;
}
TABLE.subnav TD.unselected:hover {
 background: U_HOVER_HIGHLIGHT;
 border: U_FRAME thin solid;
 cursor:pointer;cursor:hand;
 color: U_NAV_FG;
}
TABLE.subnav TD.selected A {
 color: U_NAV_FG;
 font-weight: bold;
 text-decoration: none;
}
TABLE.subnav TD.unselected A {
 color: U_NAV_FG;
 text-decoration: none;
}



/* grouped data */
TABLE.group {
 width: 100%;
 margin: 0px;
 padding: 0px;
 border: 0px;
}

TABLE.group TH.grouptag {
 border: thin solid U_FRAME;
 background-color: U_FRAME;
 width: 20%;
 font-size: largest;
 color: U_BACKGROUND;
}

TABLE.group TD {
 border: thin solid U_FRAME;
}


TABLE.summary {
 width: 100%;
 border: none;
 background: U_BACKGROUND;
 margin: none;
 border: none;
}
TABLE.summary TH {
 background-color: U_BACKGROUND;
 border: 0px;
 padding: 0px;
 color: U_NAV_FG;
 text-align: right;
 vertical-align: top;
 white-space: nowrap;
}
TABLE.summary TH DIV {
 border: thin solid U_FRAME;
 background-color: U_FRAME;
 color: U_BACKGROUND;
 white-space: nowrap;
}
TABLE.summary TD {
 vertical-align: top;
 border: none;
 margin: none;
}


/* Quick Links */
table.quicklinks {
  /* border:  U_FRAME thin solid; */
}
TD.quicklinks_title {
 background:  U_NAV_BG;
 color: U_NAV_FG;
 padding-left: 2px;
 padding-right: 2px;
 white-space: nowrap;
 font-style: italic; 
}
TD.quicklinks {
 border:  thin solid U_NAV_BG;
 color: U_NAV_FG;
 padding-left: 2px;
 padding-right: 2px;
 white-space: nowrap;
}


/* credits */
TABLE.credits {
 border: U_FRAME thin solid;
}
TABLE.credits TH {
 border: U_FRAME thin solid;
 background: U_FRAME;
  /* color: white; */
}
TABLE.credits TD {
 border: U_FRAME thin solid;
}



TABLE.uwtable {
 background-color: U_TABLE_BG;
 margin: 0px;
}
TABLE.uwtable TBODY {
 background-color: U_TABLE_BG;
 overflow: auto;
}
TABLE.uwtable TH {
 border: thin solid U_FRAME;
 background-color: U_TABLE_TH_BG;
 color: U_TABLE_TH_FG;
}
TABLE.uwtable TH.highlighted {
 border: thin solid U_FRAME;
 background-color: U_TABLE_HIGHLIGHT_BG;
}
TABLE.uwtable TD {
  background-color: U_TABLE_BG;
}
TABLE.uwtable TD.highlighted {
  background-color: U_TABLE_HIGHLIGHT_BG;
}


/* software stack table (in about_unison) */
TABLE.sw_stack {
 border: medium U_FRAME solid;
}
TABLE.sw_stack TR {
 border: thin U_FRAME solid;
}
TABLE.sw_stack TH {
 background: U_FRAME;
 color: U_BACKGROUND;
 vertical-align: top;
 padding: 5px;
}
TABLE.sw_stack TD.sw_stack_sep {
 border-top: thin solid U_FRAME;
 border-bottom: thin solid U_FRAME;
}



SPAN.page_break {
  border-bottom: medium double U_FRAME;
}

/* 
TR.tablesep {
  background-color: orange;
}
*/

SPAN.page_title {
  font-weight: bold;
}


/* cheap text buttons */
SPAN.button {
 background: U_UNHIGHLIGHTED;
 border: black thin solid;
}
SPAN.button:hover {
 background: U_HOVER_HIGHLIGHT;
}
/* SPAN.button A {
   color: white;
   font-weight: bold;
   text-decoration: none;
   } */



DIV.important {
 border: red medium solid;
 padding: 4px;
 margin: 20px 20px 20px 20px;
 color: U_IMPORTANT_FG;
 background-color: U_IMPORTANT_BG;
}



/* tooltip */
SPAN.tooltip_old {
 border: 1px solid U_POPUP_FRAME;
 background-color: U_POPUP_BG;
 color: U_POPUP_FG;
 font-weight: bold;
 font-size: smaller;
 padding: 0px 1px 0px 1px;
 margin: 0px;
}
SPAN.tooltip {
 border: none;
 background-color: U_TOOLTIP_BG;
 color: U_TOOLTIP_FG;
 font-weight: bold;
 font-size: smaller;
 padding: none;
 margin: none;
}

SPAN.tooltip:hover {
 cursor:pointer;cursor:help;
}


/* domTT Classic Style, from domTT examples.css */
div.domTTUnison {
 border: 2px solid U_POPUP_FRAME;
 background-color: U_POPUP_BG;
}
div.domTTUnison .caption {
  font-family: serif;
  font-size: 13px;
  /* _font-size: 12px; */
  font-weight: bold;
  font-style: italic;
 padding: 1px 2px;
 background: U_POPUP_BG;
}
div.domTTUnison .contents {
 color: black;
 font-size: 13px;
  /* font-size: 12px; */
 font-family: Arial, sans-serif;
 padding: 1px 2px;
  /* padding-bottom: 0; */
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
SPAN.error {
 color: U_ERROR_FG;
}
SPAN.debug {
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

/*
  I haven't a clue why I disabled this
  2007-10-19 Reece Hart <reece@harts.net>

div.tip {
 border: black thin solid;
 padding: 2px;
 margin: 20px;
 background: lightgrey;
}
*/



