console.log("Content Script is working")
// -------   FUNCTION TO ADD A LINK IN A COMMUNITY'S YouTube Page     ----------

const dashboardCommentAuthors = document.querySelectorAll(".comment-header");
dashboardCommentAuthors.forEach(function(dashboardCommentAuthor) {
  dashboardCommentAuthor.insertAdjacentHTML("beforeend", '<a class=".btn-see-details">See fan details</a>' )
})


// ----------- FUNCTION TO ADD A LINK IN A VIDEO'S COMMENT FLOW  ---------------
//                           (update every 900ms)
// Do not use 'scroll' event, since it would overload the page each time the is a scroll on a pixel
// Do not use the 'NodeInserted' event, since Youtube seems to load a lot of new Nodes even after page DOM is Loaded

setInterval(function() {
  // sélectionner les header-authors (les entêtes des div de commentaire)
  const videoCommentAuthors = document.querySelectorAll("#header-author");
  // itérer sur les résultats
  videoCommentAuthors.forEach(function(videoCommentAuthor) {
    // pour chaque header si le lien existe
    if (videoCommentAuthor.querySelector(".btn-see-details")) {
      // do nothing, the button is already present
    } else {
      videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="btn-see-details">See fan details</a>');
      let link = videoCommentAuthor.querySelector('.btn-see-details')
      if (link) {
        link.addEventListener('click', function(event) {
          // retrieve the fan's youtube_username or channel_id_youtube
          // youtube_username exemple: /user/MarcGamesons
          // channel_id_youtube exemple  : /channel/UC5QXpT_ALp-b_OUcv4WtRvw
          const fan = videoCommentAuthor.querySelector('#author-text')
          const fanIdentificator = fan.getAttribute("href")
          fanIdentificator.replace(/.*\//, '');
          console.log(fanIdentificator);

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


