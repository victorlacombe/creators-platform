console.log("Ready to go");

const dashboardCommentAuthors = document.querySelectorAll(".comment-header");

dashboardCommentAuthors.forEach(function(dashboardCommentAuthor) {
  dashboardCommentAuthor.insertAdjacentHTML("beforeend", '<a href="https://www.youtube.com/comments">See fan details</a>' )
})


// ----------------------- FUNCTION TO ADD A LINK IN A VIDEO'S COMMENT FLOW (update every 900ms)  -----------------
// Do not use 'scroll' event, since it would overload the page each time the is a scroll on a pixel
// Do not use the 'NodeInserted' event, since Youtube seems to load a lot of new Nodes even after page DOM is Loaded



setInterval(function() {
  // sélectionner les header-authors (les entêtes des div de commentaire)
  const videoCommentAuthors = document.querySelectorAll("#header-author");
  // itérer sur les résultats
  videoCommentAuthors.forEach(function(videoCommentAuthor) {
    // pour chaque header si le lien existe
    if (videoCommentAuthor.querySelector(".btn-see-details")) {
      console.log('already there')
    } else {
      videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="btn-see-details" href="https://www.youtube.com/comments">See fan details</a>' )
    }
  })
}, 900);


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



// ----------------------- ALTERNATIVES QUI NE MARCHENT PAS (BIEN)  -----------------


// setTimeout(function() {
//   console.log('Waited 5000ms');
//   document.addEventListener("DOMNodeInserted", function(event) {
//     const relatedNode = event.relatedNode;
//     if (relatedNode.querySelector('#header-author')) {
//       console.log(event.relatedNode.querySelector('#header-author').innerText);
//     }
//   });
// }, 5000);


// const contentsSection = document.querySelector("#contents")
// console.log('passed the #contents div selection')

// contentsSection.addEventListener("DOMNodeInserted", function(event) {
//   console.log('inside the DOMNodeInserted event listener')
//   console.log(event)
//   const videoCommentAuthors = contentsSection.querySelectorAll("#header-author");
//   videoCommentAuthors.forEach(function(videoCommentAuthor) {
//     if (videoCommentAuthor.querySelector('.details')) {
//       console.log('already there')
//     } else {

//       videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="details" href="https://www.youtube.com/comments">See fan details</a>' )
//     }
//   })
// })


