DEV = true;

BASE_URL = DEV ? "http://localhost:3000" : "https://www.recll.xyz";

// // ----------------   Defining remove duplicates function     ------------------

// function onlyUnique(value, index, self) {
//     return self.indexOf(value) === index;
// }


console.log("Content Script is working")
// -------   FUNCTION TO ADD A LINK IN A COMMUNITY'S YouTube Page     ----------

const allScript = function() {

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


  let interval;

  const userChannelId = window.location.search.match(/\?v=(.*)/)[1]
  console.log(userChannelId)

  fetch(`${BASE_URL}/api/v1/videos/find_video_owner?query=${userChannelId}`)
  .then(response => {
    console.log(response)
    if (response.status == 500) {
      console.log("MOFO", userChannelId)
      // Remove "See fan details" button from the former page

      html.addEventListener("data-changed", function() {
        console.log("FJEIOZJFIOZEJFIOJEZOIFJIZEOJFIOZEJFOI")
      })

      const visibleSeeFanDetailsButtons = document.querySelectorAll(".btn-see-details-recll")
      console.log(visibleSeeFanDetailsButtons)
      console.log(visibleSeeFanDetailsButtons.length)
      if (visibleSeeFanDetailsButtons.length > 0) {
        for (i = 0; i < visibleSeeFanDetailsButtons.length; i++ ) {
          visibleSeeFanDetailsButtons[i].remove()
        }
      }

    } else {
      // OK// fetch(`${BASE_URL}/api/v1/fans?query=${fanPictureUrl}`)
      const currentUserYoutubeId = userChannelId;
      interval = setInterval(function() {
        // select the main div that contains the comment block and the profil picture
        const commentMainDivs = document.querySelectorAll("#body")
        commentMainDivs.forEach(function(commentMainDiv) {
          // select the header-author (the header of the comment div)
          const videoCommentAuthor = commentMainDiv.querySelector("#header-author");
          if (videoCommentAuthor.querySelector('.btn-see-details-recll')) {
            // do nothing, the "see fan details" button is already present
            // récupérer l'id youtube la page actuelle (après potentielle navigation)
            const newUserChannelId = document.querySelector('#owner-name a').getAttribute("href").match(/\/channel\/(.*)/)[1];
            if (newUserChannelId !== currentUserYoutubeId) {
              // videoCommentAuthor.querySelector('.btn-see-details-recll').remove();
            }
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
                  return new Promise((resolve) => {
                    // console.log(data)
                    // Retrieving the fan id
                    const fanId = data[0].id
                    // Retrieving the fan username
                    const userName = data[0].youtube_username
                    // Retrieving the fan comment number
                    const commentsNumber = data[0]["comments"].length
                    // Retrieving the memo
                    if (data[0]["memo"]["memo_details"]["content"].length === 0) {
                      memoContent = `
                      <div class="button-memo">
                        <a href="https://www.recll.xyz/fans/${fanId}" target="_blank" class="button-centered-memo">Add a memo</a>
                      </div>`

                    } else {
                      memoContent = `<p id="memo">${data[0]["memo"]["memo_details"]["content"]}</p>`
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
                      lastcommentDate = new Date(commentsDates.sort()[commentsDates.length - 1]).toLocaleDateString('fr-FR')
                      console.log(lastcommentDate)
                      }
                    // Retrieving the fan's first activity date

        //------------------- 4. Inject the retrived data in the DOM -------------------
                    const commentImage = chrome.extension.getURL('chat-46.png');
                    const videoImage = chrome.extension.getURL('video-viewed.png');
                    const lastCommentDate = chrome.extension.getURL('last-comment-date.png');
                    commentMainDiv.insertAdjacentHTML("beforebegin",
                        ` <div class="fan-info-recll">
                            <div class="extension-header">
                              <div class="header-left-section">
                                <img src="${profilPictureUrl}" alt="" id="fan-picture"/>
                                <h3>${userName}</h3>
                              </div>
                              <a id="more-details" target=”_blank” href=https://www.recll.xyz/fans/${fanId}> See more details</a>
                            </div>


                            <div class="stats-section">
                              <div class="comments-section">
                                <p id="commentNumber">${commentsNumber}</p>
                                <img src="${commentImage}" alt="" id="comments-image"/>
                              </div>
                              <div class="videos-section">
                                <p id="nb-of-video-commented">${numberOfCommentedVideos.length}</p>
                                <img src="${videoImage}" alt="" id="comments-image"/>
                              </div>
                              <div class="latest-comment-section">
                                <p id="last-comment-date">${lastcommentDate}</p>
                                <img src="${lastCommentDate}" alt="" id="comments-image"/>
                              </div>
                            </div>
                            <div class="separation-line"></div>
                            <div class="memo-section">
                                ${memoContent}
                            </div>
                          </div>`)
                    resolve("ok to launch transition");
                  });
                }).then((data) => {
                  console.log(data);
                  setTimeout(() => {
                    commentMainDiv.parentElement.querySelector(".fan-info-recll").style.opacity = "1";
                    commentMainDiv.parentElement.querySelector(".fan-info-recll").style.height = "185px";
                  }, 50)
                })
              })
            }
          }
        })
      }, 50);
      document.addEventListener('yt-navigate-finish', function() {
        //
        clearInterval(interval);
        allScript();
      });
    }
  })
}

allScript();




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

