<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>SPARQL LabelingSystem Query - Labels</title>
		<link type="text/css" rel="stylesheet" href="../ProjectTree/style.css"/>
        <style type="text/css">
            a:link    {color: blue;text-decoration:underline}
            a:visited {color: blue;text-decoration:underline}
            a:hover   {color: blue;text-decoration:none}
            a.hover   {color: blue;text-decoration:none}
            a:active  {color: blue;text-decoration:underline}
			
			.login-dialog .modal-dialog {
				width: 1000px;
			}
			
        </style>
		
		<script src="http://code.jquery.com/jquery-latest.js"></script>
		<link href="bootstrap/assets/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
		<script src="bootstrap/assets/bootstrap/js/bootstrap.min.js"></script>
		<script src="bootstrap/assets/prettify/run_prettify.js"></script>
		<link href="bootstrap/assets/bootstrap-dialog/css/bootstrap-dialog.min.css" rel="stylesheet" type="text/css" />
		<script src="bootstrap/assets/bootstrap-dialog/js/bootstrap-dialog.min.js"></script>
		
    </head>
    <body>
        
        <center>
		<br><br>
		<img src='../client/models/site-templates/images/ls_color.png'>
        <br><br>
		<h1>SPARQL query Label Repository</h1>
		<br>
        <span id="example">
            <b>Example SPARQL-Querys: </b>
            <a href="javaScript:ex1();projectsinfo()">SELECT all projects</a> | 
			<a href="javaScript:ex4();schemesinfo()">SELECT all ConceptScheme</a> | 
			<a href="javaScript:ex5();conceptsinfo()">SELECT all Concepts with prefLabel</a>
        </span>
        <br><br>
        <textarea id="sparql_eingabe" cols="150" rows="20" value="" style="background-color:#dddddd;">SELECT * WHERE { ?concept <http://www.w3.org/2004/02/skos/core#prefLabel> ?prefLabel. ?concept a <http://www.w3.org/2004/02/skos/core#Concept>. }</textarea>
        <br>
        <span id="sendlink">
            <input type="button" value="Send SPARQL" id="sendsparqltextarea" onclick="IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json')">
            <span id="xmllink"></span>
            <span id="jsonlink"></span>
            <span id="csvlink"></span>
            <span id="csvfile"></span>
        </span>
        <br><br>
        <span id="sparql_result"></span>
        <br>
        
    </body>
</html>

<script src="http://code.jquery.com/jquery-latest.js"></script>
<script src="../client/config.js"></script>
<script>

var TS = {};
TS.vars = [];
TS.result = [];
TS.output = [];
TS.output2 = [];

var html_str = "";

var IO = {};

IO.sendSPARQLShowTable = function(url, query, format, callback, info) {
    
    $('#sparql_result').html('<b>Loading...</b> <img src="loading.gif" height="40">');
    
    query = encodeURIComponent(query);
        
    $.ajax({
        type: 'GET',
        url: url,
        dataType: "json",
        data: {query: query, format: format},
        error: function(jqXHR, textStatus, errorThrown) {
            alert(errorThrown);
        },
        success: function(output) {
            
            // set help array to null
            TS.vars.length = 0;
            TS.result.length = 0;
            TS.output.length = 0;
            TS.output2.length = 0;
            
            // html output
            html_str = "";
            html_str += "<table border='1'>";
            html_str += "<tr>";
            
            // read JSON head-->vars objects to array (e.g. spo)
            var varsj = output.head.vars;
            for (var i=0; i<varsj.length; i++) {
                TS.vars.push(varsj[i]);
            }
            // html output
            for (var i=0; i<TS.vars.length; i++){
                html_str += "<th>"+TS.vars[i]+"</th>";
            }
            
            // html output
            html_str += "</tr>";
            html_str += "</tr>";
            
            // read JSON rasults-->bindings[i] objects to array with key (e.g. pppsssooo)
            var bindings = output.results.bindings; 
            for (var i=0; i<bindings.length; i++) {       
                var t = bindings[i];     
                for(var key in t) {
                    TS.result.push(key + "__" + t[key].value);
                }
            }
            
            // sort sparql output like the vars e.g. ssspppooo
            var k = 0;
            for (var i=0; i<TS.vars.length; i++) {
                for (var j=0; j<TS.result.length; j++) {
                    if (TS.result[j].indexOf(TS.vars[i]+"__") != -1){
                        var split = TS.result[j].split("__");
                        TS.output[k] = k + "__" + split[1];
                        k++;
                    }
                }
            }
        
            // sort output like the vars triples e.g. spospospo
            var k = -1;
            var l = (TS.output.length)/TS.vars.length;
            for (var i=0; i<l; i++) {
                if (TS.vars.length==1){
                    TS.output2[k+1] = TS.output[i];
                    k++;
                } else {
                    for (var j=0; j<TS.vars.length; j++) {
                        var tmp1 = k+1;
                        var tmp2 = i+(j*l);
                        TS.output2[tmp1] = TS.output[tmp2];
                        k++;
                    }
                }
            }
        
            // html output
            html_str += "<tr>";
            for (var i=0; i<TS.output2.length; i++) {
                var split = TS.output2[i].split("__");
                html_str += "<td>"+split[1]+"</td>";
                if ((i+1)%TS.vars.length==0) {
                    html_str += "</tr>";
                    html_str += "<tr>";
                }
            }
            
            // html output
            html_str += "</tr>";
            html_str += "</table>";
            
            // set div/span with sparql table content
            $('#sparql_result').html("");
            $('#sparql_result').html(html_str);
            
            // set links to XML and JSON
            setXMLJSONlink();
        
        }
    });
}

function ex0() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?s ?p ?o }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}
function ex1() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?project a <http://143.93.114.137/vocab#Project> }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}
function ex2() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?vocabulary a <http://143.93.114.137/vocab#Vocabulary> }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}
function ex3() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?label a <http://143.93.114.137/vocab#Label> }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}
function ex4() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?conceptscheme a <http://www.w3.org/2004/02/skos/core#ConceptScheme> }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}
function ex5() {
    $('#sparql_eingabe').val("SELECT * WHERE { ?concept <http://www.w3.org/2004/02/skos/core#prefLabel> ?prefLabel. ?concept a <http://www.w3.org/2004/02/skos/core#Concept>. }");
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
    $('#csvfile').html("");
    IO.sendSPARQLShowTable(Config.SPARQL,document.getElementById('sparql_eingabe').value,'json');
}

function setXMLJSONlink() {
    
    var m = encodeURIComponent(document.getElementById('sparql_eingabe').value);
    
    var l = Config.SPARQL + "?query=" + m + "&format=xml";
    var h = "<a href='"+l+"' target='_blank'>XML-Dokument</a> | ";
    $('#xmllink').html("<b>Downloads: </b>"+h);
    
    var l = Config.SPARQL + "?query=" + m + "&format=json";
    var h = "<a href='"+l+"' target='_blank'>JSON-Dokument</a> | ";
    $('#jsonlink').html(h);
    
    var l = Config.SPARQL + "?query=" + m + "&format=csv";
    var h = "<a href='"+l+"' target='_blank'>CSV-Dokument</a> | ";
    $('#csvlink').html(h);
    
    var l = Config.SPARQL + "?query=" + m + "&format=csv&file=true";
    var h = "<a href='"+l+"' target='_blank'>CSV-File</a>";
    $('#csvfile').html(h);
}

$('#sparql_eingabe').keyup(function(){
    $('#xmllink').html("");
    $('#jsonlink').html("");
    $('#csvlink').html("");
	$('#csvfile').html("");
});

function projectsinfo() {

	var raute = "#";
	BootstrapDialog.show({
		size: BootstrapDialog.SIZE_NORMAL,
		title: 'SELECT all projects',
		message: "<h1>Here you can query all the projects in the label repository. You will see the link to in internal ontology (it will not work for the outside).<br><br><b>SELECT * WHERE {<br>?project a &lt;http://143.93.114.137/vocab#Project&gt;<br>}</b></h1>",
		draggable: true,
		cssClass: 'login-dialog',
		buttons: [{
			label: 'close',
			action: function(dialogItself){
				dialogItself.close();
			}
		}]
	});

}

function schemesinfo() {

	var raute = "#";
	BootstrapDialog.show({
		size: BootstrapDialog.SIZE_NORMAL,
		title: 'SELECT all ConceptScheme',
		message: "<h1>Here you can query all the skos ConceptScheme in the label repository. You will see the link to in internal ontology as vocabulary (for the outside you can browse it in the REST interface as conceptscheme).<br><br><b>SELECT * WHERE {<br>?conceptscheme a &lt;http://www.w3.org/2004/02/skos/core#ConceptScheme&gt;<br>}</b></h1>",
		draggable: true,
		cssClass: 'login-dialog',
		buttons: [{
			label: 'close',
			action: function(dialogItself){
				dialogItself.close();
			}
		}]
	});

}

function conceptsinfo() {

	var raute = "#";
	BootstrapDialog.show({
		size: BootstrapDialog.SIZE_NORMAL,
		title: 'SELECT all Concepts with prefLabel',
		message: "<h1>Here you can query all the skos Concepts and it's prefLabel in the label repository. You will see the link to in internal ontology as labels (for the outside you can browse it in the REST interface as concepts).<br><br><b>SELECT * WHERE {<br>?concept &lt;http://www.w3.org/2004/02/skos/core#prefLabel&gt; ?prefLabel.<br>?concept a &lt;http://www.w3.org/2004/02/skos/core#Concept&gt;.<br>}</b></h1>",
		draggable: true,
		cssClass: 'login-dialog',
		buttons: [{
			label: 'close',
			action: function(dialogItself){
				dialogItself.close();
			}
		}]
	});

}

</script>