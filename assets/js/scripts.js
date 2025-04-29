function showVersion(version) {
  var contents = document.querySelectorAll('.links-wrapper[id]');
  contents.forEach(function(content) {
    content.style.display = 'none';
  });
  document.getElementById(version).style.display = 'block';
  var buttons = document.querySelectorAll('.switcher button');
  buttons.forEach(function(button) {
    button.classList.remove('active');
  });
  var activeButton = Array.from(buttons).find(button => button.textContent === version);
  if (activeButton) {
    activeButton.classList.add('active');
  }
}

function initializePlatforms(platforms, platform) {
  if (platforms.length > 0) {
      showVersion(platform);
  }
}
