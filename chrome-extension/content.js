DEV = true;

BASE_URL = DEV ? "http://localhost:3000" : "https://www.recll.xyz";

// // ----------------   Defining remove duplicates function     ------------------

// function onlyUnique(value, index, self) {
//     return self.indexOf(value) === index;
// }


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

//-------------   Identify if the user is on a video of his own --------------

//-----------> WE NEED AN ALTERNATIVE <-------------
  setTimeout(function() {
    const userChannelId = document.querySelector('#owner-name a').getAttribute("href").match(/\/channel\/(.*)/)[1]
    console.log(userChannelId)

    fetch(`${BASE_URL}/api/v1/users/verif?query=${userChannelId}`)
    .then(response => {
      if (response.status == 500) {
        // PAS OK
      } else {
        // OK// fetch(`${BASE_URL}/api/v1/fans?query=${fanPictureUrl}`)
        setInterval(function() {
          // select the main div that contains the comment block and the profil picture
          const commentMainDivs = document.querySelectorAll("#body")
          commentMainDivs.forEach(function(commentMainDiv) {
            // select the header-author (the header of the comment div)
            const videoCommentAuthor = commentMainDiv.querySelector("#header-author");
            if (videoCommentAuthor.querySelector('.btn-see-details-recll')) {
              // do nothing, the "see fan details" button is already present
            } else {
              videoCommentAuthor.insertAdjacentHTML("beforeend", '<a class="btn-see-details-recll">See fan details</a>');

              let insertedLink = videoCommentAuthor.querySelector('.btn-see-details-recll')
              // Then implement the next block to reconciliate data between YouTube and our App
              if (insertedLink) {
                insertedLink.addEventListener('click', function(event) {

        //---------- 1.  Remove former opened popup when openning a new one ------------


                  const visibleInfoWindow = document.querySelector(".fan-info-recll")
                  if (visibleInfoWindow) {
                    visibleInfoWindow.remove()
                  }

        //-------------------- 2.  retrieve the fan's fanPictureUrl --------------------

                  const fanPicture = commentMainDiv.querySelector("#author-thumbnail #img")
                  const fanPictureUrl = fanPicture.getAttribute("src").match(/(.*)\/s\d+/)[1]
                  console.log(fanPictureUrl)

        //---------------- 3. Request the DB to get the fan information ----------------

                  fetch(`${BASE_URL}/api/v1/fans?query=${fanPictureUrl}`)
                  .then(response => response.json())
                  .then((data) => {
                    // console.log(data)
                    // Retrieving the fan id
                    const fanId = data[0].id
                    // Retrieving the fan username
                    const userName = data[0].youtube_username
                    // Retrieving the fan comment number
                    const commentsNumber = data[0]["comments"].length
                    // Retrieving the memo
                    if (data[0]["memo"]["memo_details"]["content"].length === 0) {
                      memoContent = `<a href="https://www.recll.xyz/fans/${fanId}" target="_blank" class="href">Add a memo</a>`
                    } else {
                      memoContent = `Memo: ${data[0]["memo"]["memo_details"]["content"]}`
                    }

                    // Retrieving the fan's profil picture
                    const profilPictureUrl = data[0].profile_picture_url
                    // Retrieving the fan's number of video commented
                    let videoIds = []
                    for (i = 0; i < data[0]["comments"].length; i++) {
                      videoIds.push(data[0]["comments"][i].video_id)
                      numberOfCommentedVideos = videoIds.filter(function(item, pos, self) {
                        return self.indexOf(item) == pos;
                      })
                    }
                    // Retrieving the fan's last comment date
                    let commentsDates = []
                    for (i = 0; i < data[0]["comments"].length; i++) {
                      console.log(commentsDates)
                      commentsDates.push(data[0]["comments"][i].published_at)
                      lastcommentDate = new Date(commentsDates.sort()[commentsDates.length - 1]).toLocaleDateString('en-GB')
                      console.log(lastcommentDate)
                      }

                    // Retrieving the fan's first activity date



        //------------------- 4. Inject the retrived data in the DOM -------------------

                    commentMainDiv.insertAdjacentHTML("beforebegin",
                      `<div class="fan-info-recll">
                        <img src="${profilPictureUrl}" alt="" />
                        <h3>${userName}</h3>
                        <a id="more-details" target=”_blank” href=https://www.recll.xyz/fans/${fanId}> See more details</a>
                        <p id="commentNumber">Commented ${commentsNumber} time(s) on your videos</p>
                        <p id="nb-of-video-commented">Total video commented: ${numberOfCommentedVideos.length}</p>
                        <p id="last-comment-date">Latest comment: ${lastcommentDate}</p>
                        <div id="memo">
                          ${memoContent}
                        </div>
                      </div>`)
                  })
                })
              }
            }
          })
        }, 100);
      }
    })
  }, 5000)





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






