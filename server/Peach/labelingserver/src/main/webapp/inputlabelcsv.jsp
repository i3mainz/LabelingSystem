<script src="http://code.jquery.com/jquery-latest.js"></script>
<script>
	var Config = {};
	Config.InputLabelCSV = 'http://localhost:8084/labelingserver/InputLabelCSV';
	var user = "maxmustermann";
	var validator = "true";
	var mode = "start";
</script>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
		<link rel="stylesheet" href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
		<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
		<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
		<style>
			.ui-progressbar {
				position: relative;
				width: 50%;
			}
			.progress-label {
				position: absolute;
				left: 50%;
				top: 4px;
				font-weight: bold;
				text-shadow: 1px 1px 0 #fff;
			}
		</style>
    </head>
    <body>
	<center>
		<form id="data">
			Select File to Upload:<input type="file" name="fileName">
			<input type="submit" value="Upload">
			<input type="checkbox" id="validate" checked>&nbsp;just validate
		</form>
	</center>
	<div id="statusbar" hidden><center><div id="progressbar"><div class="progress-label">Loading...</div></div></center></div>
	<br>
	<div id="result"></div>
</body>
</html>

<script>
	var UPDATE_ADDRESS = Config.InputLabelCSV + "?mode=update";
	var FINISH_ADDRESS = Config.InputLabelCSV + "?mode=finish";
	var updateTime = 2000;
	var status = -1;

	var progressbar = $("#progressbar");
	var progressLabel = $(".progress-label");
	progressbar.progressbar({
		value: false,
		change: function () {
			progressLabel.text(progressbar.progressbar("value") + "%");
		},
		complete: function () {
			progressLabel.text("Complete!");
		}
	});

	$("form#data").submit(function (event) {
		status = -1;
		progressbar.progressbar("value", 0);
		$('#statusbar').hide();
		document.getElementById("result").innerHTML = "";
		event.preventDefault();
		var formData = new FormData($(this)[0]);
		if (document.getElementById("validate").checked) {
			validator = true;
		} else {
			validator = false;
		}
		$.ajax({
			url: Config.InputLabelCSV + '?creator=' + user + '&validator=' + validator + '&mode=' + mode,
			type: 'POST',
			data: formData,
			async: false,
			cache: false,
			contentType: false,
			processData: false,
			error: function (jqXHR, textStatus, errorThrown) {
				var html = "<center><img src='nok.png' height='200'><br><br><b>Please choose a File!</b></center>";
				document.getElementById("result").innerHTML = html;
				alert(errorThrown);
			},
			success: function (output) {
				$('#statusbar').show();
				status = parseInt(output.status);
				progressbar.progressbar("value", parseInt(status));
				action = output.action;
				console.log(status + " | " + action); // GIVE FEEDBACK TO USER
				uploadAction(UPDATE_ADDRESS, update);
			}
		});
		return false;
	});

	function update(output) {
		status = parseInt(output.status);
		action = output.action;
		console.log(status + " | " + action); // GIVE FEEDBACK TO USER
		progressbar.progressbar("value", parseInt(status));
		if (status < 100)
			window.setTimeout(function () {
				uploadAction(UPDATE_ADDRESS, update)
			}, updateTime); // alle X Milli-Sekunden fragen
		else
			uploadAction(FINISH_ADDRESS, finishAction);
	}

	function uploadAction(address, callback) {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", address);
		xmlhttp.onreadystatechange = function () {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status >= 200 && xmlhttp.status < 300) {
					callback(JSON.parse(xmlhttp.responseText));
				}
			}
		}
		xmlhttp.send();
	}

	function finishAction(output) {
		progressbar.progressbar("value", 100);
		status = 0;
		var html = "";
		if (validator) {
			if (output.success == "true") {
				html += "<center><img src='ok.png' height='200'></center><br>";
				document.getElementById("result").innerHTML = html;
			} else {
				html += "<center><img src='nok.png' height='200'></center><br>";
				var errors;
				var relationerrors;
				var error = "";
				for (var key in output) {
					if (key == "errors") {
						errors = output[key];
					} else if (key == "relationerrors") {
						relationerrors = output[key];
					} else if (key == "importedlabels") {
					} else if (key == "importedrelations") {
					} else if (key == "success") {
					} else if (key == "warnings") {
					} else {
						error += output[key] + "<br>";
					}
				}
				html += "<center><b>errors: " + errors + "</b></center>";
				html += "<center><b>relationerrors: " + relationerrors + "</b></center>";
				html += "<center><br><b>error list</b> <br>" + error + "</center>";
				document.getElementById("result").innerHTML = html;
			}
		} else {
			if (output.success == "true") {
				html += "<center><img src='ok.png' height='200'></center><br>";
				html += "<center><b>IDs:<br> " + output.ids + "</b><br>";
				document.getElementById("result").innerHTML = html;
			} else {
				html += "<center><img src='nok.png' height='200'></center><br>";
				var errors;
				var relationerrors;
				var error = "";
				for (var key in output) {
					if (key == "errors") {
						errors = output[key];
					} else if (key == "relationerrors") {
						relationerrors = output[key];
					} else if (key == "importedlabels") {
					} else if (key == "importedrelations") {
					} else if (key == "success") {
					} else if (key == "warnings") {
					} else {
						error += output[key] + "<br>";
					}
				}
				html += "<center><b>errors: " + errors + "</b></center>";
				html += "<center><b>relationerrors: " + relationerrors + "</b></center>";
				html += "<center><br><b>error list</b> <br>" + error + "</center>";
				document.getElementById("result").innerHTML = html;
			}
		}
		console.info(output);
		console.info(output.ids);
		console.info(output.success);
	}

</script>