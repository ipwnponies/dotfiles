// ==UserScript==
// @name        Fix search bar behaviour
// @namespace   ipwnponies
// @description Searching only works when input is clicked, which is not the only way a textbox can be used.
// @version     1.0.0
// @match       https://www.fatsecret.com/Diary.aspx
// @grant       none

const fatsecret = () => {
  for (var i of ['searchBfastExp', 'searchLunchExp', 'searchDinnerExp', 'searchOtherExp']) {
    const input = document.getElementById(i);
    input.addEventListener('focus', input.onclick);
  };
};

fatsecret();
