/*********************************
 * Module: DOM_Fixes.js Version 1.1
 *********************************
 * Various functions fixing the inconsistencies of DOM implementation by
 * different browsers.
 *********************************
 * Copyright (c) 2002, Vlad Krylov, All Rights Reserved.
 *********************************/

var browser = '';
var version = 0.0;
var str = ''
// Perform browser identification on load
switch(navigator.appName)
  { case 'Microsoft Internet Explorer':
        browser='ie';
        str = navigator.appVersion;
        str = str.substring(str.indexOf('MSIE')+4,str.length);
        version = parseFloat(str);
	    break;
    case 'Netscape':
	    if(navigator.vendorSub!='')
          { browser='ns';
            version=parseFloat(navigator.vendorSub);
          }
        else
          { browser='mz'
	        version=parseFloat(navigator.appVersion);
          }
        break;
	default:
	    browser='unknown';
	    break;
  }

/* Function:  setRowBG
 * Arguments: row  - Row object	
 *            bgc  - background color
 *     Works around the Internet Explorer flaw of not updating cell
 *     backgroungs when row background is changed
 */
function setRowBG(row,bgc)
{   if(browser == 'ns')
      { row.style.backgroundColor=bgc;
      }
    else
      { for(var i=0; i<row.childNodes.length; i++)
	    row.childNodes[i].style.backgroundColor=bgc;
      }
    return;
}


function IEWidthFix()
{   if(browser == 'ie')
      { setTimeout('IEResize();',20);
      }
    return;
}

function IEResize()
{  window.resizeBy(-1,-1);
   setTimeout('window.resizeBy(-1,-1);',2);
}


