console.log("background running");
chrome.browserAction.onClicked.addListener(buttonClicked);

function buttonClicked(tab) {
  chrome.tabs.sendMessage(tab.id, "hello")
}




// const seeFanDetails = document.querySelectorAll(".btn-see-details");
// console.log(seeFanDetails)
// console.log("I'm here 1 :)")
// seeFanDetails.forEach(function(seeFanDetail) {
//   console.log("I'm here 2 :)")
//   console.log(seeFanDetail)
//   seeFanDetail.addEventListener("click",function() {
//     console.log("The user Clicked the link")
//   });
