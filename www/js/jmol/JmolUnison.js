/* 
 * This are modifications to jmol functions to accomodate
 * features implemented in Unison::Structure
 */
$ID : $Id$;
// see Jmol.js
// modification to jmolLink to remember 
// the link name (loaded molecule) when clicked
// set the pdbid global variable to one clicked
function jmolChangeStructureLink(script, text, id) {
  
    _jmolInitCheck();
  if (id == undefined || id == null)
    id = "jmolLink" + _jmol.linkCount;
  ++_jmol.linkCount;
		
  var scriptIndex = _jmolAddScript(script);
  var t = "<a name='" + id + "' id='" + id + 
          "' href='javascript:_jmolClick(" + scriptIndex +
          _jmol.targetText +
          ");'onClick='pdbid=text; ' onMouseover='_jmolMouseOver(" + scriptIndex +
          ");return true;' onMouseout='_jmolMouseOut()' " +
        _jmol.linkCssText + 
          ">" + text + "</a>";
  if (_jmol.debugAlert)
    alert(t);
  document.write(t);
}

//gets pdb position from seq_str.pdbid.seq_pos global object
// and then calls jmolScript
function jmolSelectPosition(pos, labe, targetSuffix) {

    var chain = pdbid.substr(4,1);

    chain = (chain == '' ? '' : ":"+chain);

    var script = "spacefill off;select "+seq_str[pdbid][pos]+chain+"; wireframe 0.5;color cpk;select "+seq_str[pdbid][pos]+chain+" and *.CA; label "+labe+":"+seq_str[pdbid][pos]+"; color label green; center "+seq_str[pdbid][pos]+chain+";zoom 400; select all;hbonds 0.1; ssbonds on";

    //alert("spacefill off;select "+seq_str[pdbid][pos]+chain+"; wireframe 0.5;color cpk;select "+seq_str[pdbid][pos]+chain+" and *.CA; label "+labe+":"+seq_str[pdbid][pos]+"; color label green; center "+seq_str[pdbid][pos]+chain+";zoom 400; select all;hbonds 0.1; ssbonds on");
    jmolScript(script);
}

//gets pdb positions from seq_str.pdbid.seq_pos global object
// and then calls jmolScript
function jmolSelectRegion(posone, postwo, labe, targetSuffix) {

    var start = Number(seq_str[pdbid][posone]);
    var end = Number(seq_str[pdbid][postwo]);
    var chain = pdbid.substr(4,1);

    chain = (chain == '' ? '' : ":"+chain);

    var label_pos = start + parseInt((end-start)/2);
    var script = "select "+seq_str[pdbid][posone]+"-"+seq_str[pdbid][postwo]+chain+"; color cartoon red; select "+label_pos+" and *.CA; label "+labe+"; color label green";

    //alert("select "+seq_str[pdbid][posone]+"-"+seq_str[pdbid][postwo]+chain+"-"+pdbid+"; color cartoon red; select "+ label_pos +" and *.CA; label "+labe+"; color label green");
    jmolScript(script);
}

//didn't work
function jmolSelectPositionLink(pos, labe, text, id) {

    var chain = pdbid.substr(4,1);

    chain = (chain == '' ? '' : ":"+chain);

    var script = "spacefill off;select "+seq_str[pdbid][pos]+chain+"; wireframe 0.5;color cpk;select "+seq_str[pdbid][pos]+chain+" and *.CA; label "+labe+":"+seq_str[pdbid][pos]+"; color label green; center "+seq_str[pdbid][pos]+chain+";zoom 400; select all;hbonds 0.5; ssbonds on";

    //alert("spacefill off;select "+seq_str[pdbid][pos]+chain+"; wireframe 0.5;color cpk;select "+seq_str[pdbid][pos]+chain+" and *.CA; label "+labe+":"+seq_str[pdbid][pos]+"; color label green; center "+seq_str[pdbid][pos]+chain+";zoom 400; select all;hbonds on; color hbonds green; ssbonds on");
    
    jmolLink(script, text, id);
}
