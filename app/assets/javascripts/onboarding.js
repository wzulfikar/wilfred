const organizationSelect = document.querySelector('.js-organization');

if (organizationSelect) {
  organizationSelect.addEventListener('change', (event) => {
    if (organizationSelect.value.length == 0)
      return;

    getRepos(); 
  });
  getRepos();
}

document.addEventListener('click', function (event) {
  if (!event.target.matches('.js-pick-repo-action')) return;
  event.preventDefault();
  event.target.innerHTML = "Fetching repository data...";

  var organization = document.getElementsByClassName("js-organization")[0].value;
  var name = document.getElementsByClassName("js-repo")[0].value;

  fetch(event.target.href, {
    headers: { "Content-Type": "application/json; charset=utf-8" },
    method: "POST",
    body: JSON.stringify({ organization: organization, name: name })
  })
  .then(function(response) {
    return response.json();
  })
  .then(response => {
    window.location = "/";
  });
}, false);

function getRepos() {
  fetch('/repos?organization=' + organizationSelect.value, {
    headers: { "Content-Type": "application/json; charset=utf-8" }
  })
  .then(function(response) {
    return response.json();
  })
  .then(response => {
    const repositorySelect = document.querySelector('.js-repo');
    repositorySelect.length = 0;

    let defaultOption = document.createElement('option');
    defaultOption.text = 'Repository';
    defaultOption.disabled = true;

    repositorySelect.add(defaultOption);
    repositorySelect.selectedIndex = 0;

    let option;
    for (let i = 0; i < response.repositories.length; i++) {
      option = document.createElement('option');
      option.text = response.repositories[i];
      option.value = response.repositories[i];
      repositorySelect.add(option);
    }    

    repositorySelect.classList.remove('disabled');
  });
}
