// ==UserScript==
// @name        Fix add item and search bar behaviour
// @namespace   ipwnponies
// @description Searching only works when input is clicked, which is not the only way a textbox can be used.
//              This script will correct "Add Item" button behaviour: upon click, immediately focus the search bar and
//              also trigger any bespoke magicks. So that we end up with a normal-ass website.
// @version     1.1.0
// @match       https://www.fatsecret.com/Diary.aspx
// @grant       none

for (var i of ['addBfast', 'addLunch', 'addDinner', 'addOther']) {
    const addItemButton = document.getElementById(i);
    addItemButton.addEventListener('click', event=> {
        // Search bar is not nested under "Add item", it's an invisible div at the same level. It doesn't make sense
        const input = addItemButton.nextElementSibling.querySelector('input');

        // Trigger click events, which is where auto suggestion logic is invoked
        input.click();

        // Focus the search bar so searching can begin immediately
        input.focus();
    });
};

fatsecret();
