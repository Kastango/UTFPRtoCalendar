// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.getElementById('html-input').addEventListener('keyup', function() {
	document.getElementById('html-output').innerHTML = "";
	document.getElementById('html-output').insertAdjacentHTML('afterbegin', this.value);
  });