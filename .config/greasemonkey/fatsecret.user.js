// ==UserScript==
// @name        FatSecret redirect to absolute date
// @namespace   ipwnponies
// @description Resolves food diary to absolute url. Because they try to do clever, stateful shit using with cookies.
// @version     1.0
// @match       https:*.fatsecret.com/Diary.aspx?pa=fj
// @grant       none
// ==/UserScript==

(() => {
  const currentDate = new Date();

  // Why the shit is in this in minutes. I get it, there's places in the world with 30 minute offset.
  // But this doesn't work for Local Mean Time, where offsets are continuous instead of discrete.
  const timezone_offset = currentDate.getTimezoneOffset() * 60 * 1000;
  const local_time = currentDate.getTime() - timezone_offset;
  const days_epoch = Math.floor(local_time / (1000*60*60*24));

  window.location.replace('?pa=fj&dt=' + days_epoch);
})()
