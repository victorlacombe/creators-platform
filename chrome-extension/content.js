console.log("Ready to go");


// chrome.runtime.onMessage.addListener(gotMessage);

// function gotMessage(message, sender, sendResponse) {
//   console.log(message)
//   if (message === "hello") {
//     const videoTitles = document.querySelectorAll("#video-title")
//     videoTitles.forEach (function(videoTitle) {
//       videoTitle.innerText = "COIN COIN !"
//     })
//   }
// }

const dashboardCommentAuthors = document.querySelectorAll(".comment-header");

dashboardCommentAuthors.forEach(function(dashboardCommentAuthor) {
  dashboardCommentAuthor.insertAdjacentHTML("beforeend", '<a href="https://www.youtube.com/comments">CLICK ME</a>' )
})

// document.addEventListener("DOMNodeInserted", function() {
//   const videoCommentAuthors = document.querySelectorAll("#header-author");
//   videoCommentAuthors.forEach(function(videoCommentAuthor) {
//     videoCommentAuthor.insertAdjacentHTML("beforeend", '<a href="https://www.youtube.com/comments">CLICK ME</a>' )
//   })
// })


