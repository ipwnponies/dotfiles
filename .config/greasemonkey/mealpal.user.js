// ==UserScript==
// @name        Mealpal with Yelp Reviews
// @namespace   ipwnponies
// @description Add link to yelp reviews, for mealpal
// @version     1.0
// @match       https://secure.mealpal.com/lunch
// @grant       GM_xmlhttpRequest
// @grant       GM_getValue
// @grant       GM_openInTab
// ==/UserScript==

const getApiKey = () => {
  let apiKey = GM_getValue('apiKey');
  if (!apiKey) {
    alert('You need to set the yelp api token before using this script. Set "apiKey"');
    throw 'apiToken not set';
  }

  return apiKey;
};

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function addYelpButton(node) {
  // Noop if already has button, as marked by prescence special class
  if (node.nextElementSibling.classList.contains('ipwnponies')) {
    return;
  }

  const link = document.createElement('input');
  link.type='button';
  link.value='See Yelp reviews';
  link.classList.add('btn', 'btn-primary', 'ipwnponies');
  link.onclick = () => {
    const key = getApiKey();

    const name = node.parentNode.parentNode.querySelector('.restaurant .name').textContent;
    const address = node.parentNode.parentNode.querySelector('.restaurant .address').textContent.replace(/^\s+|\s+$/g, '');
    const graphqlQuery = `
      {
        search(
          term: "${name}",
          location:"${address} SF",
          radius: 200,
          categories: "restaurants",limit:1, sort_by:"distance"
        ) {
          business {
            name
            url
          }
        }
      }
    `;

    GM_xmlhttpRequest({
      method: 'POST',
      url: 'https://api.yelp.com/v3/graphql',
      data: graphqlQuery,
      headers: {
        'Content-Type': 'application/graphql',
        'Accept-Language': 'en-US',
        Authorization: `Bearer ${getApiKey()}`
      },
      onload: function(gmResponse) {
        response = JSON.parse(gmResponse.response);
        if (gmResponse.status == 200 && response.data.search.business) {
          url = response.data.search.business[0].url;
          // Open yelp page in new tab, query for mealpal
          GM_openInTab(`${url}&q=mealpal`);
        }
      }
    });
  };

  node.after(link);
}

async function addYelpButtonsForRestaurants() {
  let nodes = [];
  while (nodes.length == 0) {
    await sleep(1000);
    nodes = document.querySelectorAll('.description[bo-text="schedule.meal.shortDescription"]');
  }

  nodes.forEach(addYelpButton);
}

function addBootstrapCss(){
  const link = document.createElement('link');
  document.head.appendChild(link);

  link.href = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css";
  link.rel = 'stylesheet';
  link.type = 'text/css';
  link.integrity = "sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u";
  link.crossorigin = "anonymous";
}

async function addManuallyReloadButton() {
  const link = document.createElement('input');
  link.type='button';
  link.value='Reload yelp buttons, please';
  link.classList.add('btn', 'btn-primary', 'ipwnponies');
  link.onclick = addYelpButtonsForRestaurants;

  let filterRow;
  while (!filterRow){
    await sleep(1000);
    filterRow = document.querySelector('.filters-wrapper');
  }
  filterRow.appendChild(link);
}

addBootstrapCss();
addManuallyReloadButton();
addYelpButtonsForRestaurants();
