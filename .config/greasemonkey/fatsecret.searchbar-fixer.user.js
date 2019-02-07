// ==UserScript==
// @name        Fix add item and search bar behaviour
// @namespace   ipwnponies
// @description Searching only works when input is clicked, which is not the only way a textbox can be used.
//              This script will correct "Add Item" button behaviour by triggering any bespoke magicks.
//              So that we end up with a normal-ass website.
// @version     1.2.0
// @match       https://www.fatsecret.com/Diary.aspx
// @grant       none

for (var i of ['addBfast', 'addLunch', 'addDinner', 'addOther']) {
  const search_input = document.querySelector(`#${i} + * input`);
  search_input.addEventListener('focus', event => {
    search_input.click();
  });
};
