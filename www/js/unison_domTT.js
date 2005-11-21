/* unison_activateTooltips
	Attaches onmouseover function to all span objects with "tooltip" attributes.
	This enables simple tooltips like <span tooltip="hi there">something</a>.
 */

function unison_activateTooltips() {
	var elements = document.getElementsByTagName('span');
	for (var i = 0; i < elements.length; i++) {
		if (elements[i].getAttribute("tooltip")) {
			var content = elements[i].getAttribute("tooltip");
			content = content.replace(new RegExp('\'', 'g'), '\\\'');
			elements[i].onmouseover = new Function('in_event', "domTT_activate(this, in_event, 'content', '" + content + "')");
			elements[i].tooltip = 'been here';
		}
	}
}
