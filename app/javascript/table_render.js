import "controllers"

document.getElementById('html-input').addEventListener('keyup', function() {
	var input = this.value.replaceAll("#000000", "#ffffff")
	document.getElementById('html-output').innerHTML = "";
	document.getElementById('html-output').insertAdjacentHTML('afterbegin', input);
  });


document.getElementById('process-button').addEventListener('click', () => {
	document.getElementById('process-button').style.display = 'none';
	document.getElementById('download-csv-link').style.visibility = 'visible';

});

