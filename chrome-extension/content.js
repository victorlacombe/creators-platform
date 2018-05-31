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

  // select the main div that contains the comment block and the profil picture

  const commentMainDivs = document.querySelectorAll("#body")
  commentMainDivs.forEach(function(commentMainDiv) {

    // select the div that contains the username, to add the "See fan details" button

    const videoCommentAuthor = commentMainDiv.querySelector("#header-author");
    if (videoCommentAuthor.querySelector('.btn-see-details')) {

      // do nothing, the "see fan details" button is already present
    } else {

      videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="btn-see-details">See fan details</a>');
      let insertedLink = videoCommentAuthor.querySelector('.btn-see-details')

      // Then implement the next block to reconciliate data between YouTube and our App

      if (insertedLink) {
        insertedLink.addEventListener('click', function() {

//-------------------- 1.  retrieve the fan's fanPictureUrl --------------------

          const fanPicture = commentMainDiv.querySelector("#author-thumbnail #img")
          const fanPictureUrl = fanPicture.getAttribute("src").replace(/\/s48-/, "/s28-")

//---------------- 2. Request the DB to get the fan information ----------------
          console.log(fanPictureUrl)


          fetch(`http://localhost:3000/api/v1/fans?query=${fanPictureUrl}`)
          .then(response => response.json())
          .then((data) => {
            console.log(data[0].comments.length);
            // console.log(data[0].comments.length);
          });

          // // Getting the fan's ID

          // fetch(`http://localhost:3000/api/v1/fans?query=${fanPictureUrl}`)
          // .then(response => response.json())
          // .then((data) => {
          //   console.log(data)
          //   data.forEach(function(fan) {

          // // Getting the fan's comments and related information

          //     fetch(`http://localhost:3000/api/v1/comments?query=${fan.id}`)
          //     .then(response => response.json())
          //     .then((data) => {
          //       // console.log(data)
          //       data.forEach(function(comment) {
          //         comment = comment.content
          //         pulishedAt = comment.published_at
          //       })
          //     })

          // // Getting the fan's memo and related information

          //     fetch(`http://localhost:3000/api/v1/memos?query=${fan.memo_id}`)
          //     .then(response => response.json())
          //     .then((data) => {
          //       console.log(data)
          //     })
          //   })
          // });
//------------------- 3. Inject the retrived data in the DOM -------------------
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







