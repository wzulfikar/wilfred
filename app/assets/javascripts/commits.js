document.addEventListener('click', function (event) {
  if (!event.target.matches('.js-commit-action')) return;

  event.preventDefault();

  var successText = event.target.dataset.successText;

  fetch(event.target.href, { headers: { "Content-Type": "application/json; charset=utf-8" }, method: "POST" })
  .then(function(response) {
    return response.json();
  })
  .then(response => {
    if (successText !== undefined && successText.length > 0) {
      event.target.innerHTML = successText;
    } else {
      document.getElementsByClassName("yield")[0].innerHTML = response.html;
    }
  });
}, false);
