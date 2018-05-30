console.log("Content Script is working")
// -------   FUNCTION TO ADD A LINK IN A COMMUNITY'S YouTube Page     ----------

const dashboardCommentAuthors = document.querySelectorAll(".comment-header");
dashboardCommentAuthors.forEach(function(dashboardCommentAuthor) {
  dashboardCommentAuthor.insertAdjacentHTML("beforeend", '<a class=".btn-see-details">See fan details</a>' )
})


// ----------- FUNCTION TO ADD A LINK IN A VIDEO'S COMMENT FLOW  ---------------
//                           (update every 900ms)
// Do not use 'scroll' event, since it would overload the page each time there is
// a scroll on each window pixel
// Do not use the 'NodeInserted' event, since Youtube seems to load a lot of new
// nodes even after page DOM is Loaded

setInterval(function() {
  // slect the main div that contains the comment block and the profil picture
  const commentMainDivs = document.querySelectorAll("#body")
  commentMainDivs.forEach(function(commentMainDiv) {
    // select the header-author (the header of the comment div)
    const videoCommentAuthor = commentMainDiv.querySelector("#header-author");
    if (videoCommentAuthor.querySelector('.btn-see-details')) {
      // do nothing, the "see fan details" button is already present
    } else {
      videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="btn-see-details">See fan details</a>');
      let insertedLink = videoCommentAuthor.querySelector('.btn-see-details')
      // Then implement the next block to reconciliate data between YouTube and our App
      if (insertedLink) {
        insertedLink.addEventListener('click', function() {
          // retrieve the fan's fanPictureUrl: it's unique identificator with our API
          const fanPicture = commentMainDiv.querySelector("#author-thumbnail #img")
          const fanPictureUrl = fanPicture.getAttribute("src").match(/(.+)\/s48/)[1]
          // faire une requête à ta DB
          // injecter des infos dans le DOM
        })
      }
    }
  })
}, 900);





// -----------------------------------------------------------------------------
//   ***********   THIS PART IS FORM FORMER IRRELEVANT ATTEMPTS   ***********
// -----------------------------------------------------------------------------



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







