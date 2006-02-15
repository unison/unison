/* unison_activateTooltips
	Attaches onmouseover function to ALL elements with "tooltip" attributes.
	This enables simple tooltips like <span tooltip="hi there">something</a>.
 */

function unison_activateTooltips() {
	/* WARNING: domLib_isIE5 must have already been set; see domLib.js */
    var elements = domLib_isIE5 ? document.all : document.getElementsByTagName('*');
	for (var i = 0; i < elements.length; i++) {
		if (elements[i].getAttribute("tooltip")) {
			var content = elements[i].getAttribute("tooltip");
			content = content.replace(new RegExp('\'', 'g'), '\\\'');
			elements[i].onmouseover = new Function('in_event', "domTT_activate(this, in_event, 'content', '" + content + "')");
			elements[i].onmouseout = function(in_event) { domTT_mouseout(this, inevent); };
		}
	}
}
