// Bugs to correct

// 1. initializePage does not work every time. (find the right eventlistener to get
// use : getEventListener(window) to display all events. Best attemps = yt-navigate-finish )


// 2. Warning with setInterval, et intervalTimeout (not used here). Try to identify an eventListner
// responsible for loading new comments / replies


// 3. The extension first load is triggered only when hard refresh on a video owned by the logged in user
// Find a way to run the script at any page change or page start.
// If start page is youtube video dashboard and if user clicks on one of his videos, the script won't load.
// If start page is a video owned by the user, script will load.

// 4. Are the promises the good solution ?




// --------------------------------------------------------------------------------------------
// -------------------------------- Setting up the environment --------------------------------
// --------------------------------------------------------------------------------------------

DEV = true;
BASE_URL = DEV ? "http://localhost:3000" : "https://www.recll.xyz";



// --------------------------------------------------------------------------------------------
// ------- Initializing the page to remove former inserted elements from the previous page ----
// ------- when changing page and elements zlready inserted in another page                ----
// --------------------------------------------------------------------------------------------

const initializingPage = function() {
  // 1. Remove the 'See fan details' buttons when loading a new page
  const visibleSeeFanDetailsButtons = document.querySelectorAll(".btn-see-details-recll")
  if (visibleSeeFanDetailsButtons.length > 0) {
    for (i = 0; i < visibleSeeFanDetailsButtons.length; i++ ) {
      visibleSeeFanDetailsButtons[i].remove();
    }
  }
  // 2. Remove the Fan Info Card when loading a new page
  const visibleFanInfoCards = document.querySelectorAll(".fan-info-recll")
  if (visibleFanInfoCards.length > 0) {
    for (i = 0; i < visibleFanInfoCards.length; i++ ) {
      visibleFanInfoCards[i].remove();
    }
  }
}

// --------------------------------------------------------------------------------------------
// ------------------------ Recover the vidio Id from the current page ------------------------
// --------------------------------------------------------------------------------------------

let videoId = window.location.search.split('v=')[1];
let ampersandPosition = videoId.indexOf('&');
if(ampersandPosition != -1) {
  videoId = videoId.substring(0, ampersandPosition);
}

// --------------------------------------------------------------------------------------------
// ----------------------------------- Main script runs here ----------------------------------
// --------------------------------------------------------------------------------------------

const allScript = function() {

console.log(' ------------- all script starts ------------- ')
console.log(' --------------------------------------------- ')

  initializingPage();

  let interval;

  // Get the information related to the video displayed on Youtube
  fetch(`${BASE_URL}/api/v1/videos/find_video_owner?query=${videoId}`, {
    credentials: 'include' // works with videos_controller (the api controller)
  })
  .then(response => response.json())
  .then((data) => {
    // the api call will display an error if the user is not authorized to get the API info
    // i.e : if the user connected Recll dashboard is not the one seeing the video, api request aborted

      interval = setInterval(function() {
        // select the main div that contains the comment block and the profil picture
        const commentMainDivs = document.querySelectorAll("#body")
        commentMainDivs.forEach(function(commentMainDiv) {
          // select the header-author (the header of the comment div)
          addButton(commentMainDiv)
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
                  visibleInfoWindow.remove();
                }

                //-------------------- 2.  retrieve the fan's fanPictureUrl --------------------

                const fanPicture = commentMainDiv.querySelector("#author-thumbnail #img")
                const fanPictureUrl = fanPicture.getAttribute("src").match(/(.*)\/s\d+/)[1]

                //---------------- 3. Request the DB to get the fan information ----------------

                fetch(`${BASE_URL}/api/v1/fans?query=${fanPictureUrl}`)
                .then(response => response.json())
                .then((data) => {
                  return new Promise((resolve) => {
                    // Retrieving the fan id
                    const fanId = data[0].id
                    // Retrieving the fan username
                    const userName = data[0].youtube_username
                    // Retrieving the fan comment number
                    const commentsNumber = data[0]["comments"].length
                    // Retrieving the memo, if there is no memo, add a button "add memo", if there is a memo, display the memo
                    const fanMemo = data[0]["memo"]["memo_details"]["content"]
                    if (fanMemo.length === 0) {
                      memoContent = `
                      <div class="button-memo">
                        <a href="${BASE_URL}/fans/${fanId}" target="_blank" class="button-centered-memo">Add a memo</a>
                      </div>`

                    } else {
                      memoContent = `<p id="memo">${fanMemo}</p>
                      <p id="resize-memo">show more</p>`
                    }
                    // Retrieving the fan's profil picture
                    const profilPictureUrl = data[0].profile_picture_url
                    // Retrieving the fan's number of video commented
                    let videoIds = []
                    for (i = 0; i < data[0]["comments"].length; i++) {
                      videoIds.push(data[0]["comments"][i].video_id)
                      // filter unique values from array
                      numberOfCommentedVideos = videoIds.filter(function(item, pos, self) {
                        return self.indexOf(item) == pos;
                      })
                    }
                    // Retrieving the fan's last comment date
                    let commentsDates = []
                    for (i = 0; i < data[0]["comments"].length; i++) {
                      commentsDates.push(data[0]["comments"][i].published_at)
                      var options = { year: 'numeric', month: 'short', day: 'numeric' };
                      lastcommentDate = new Date(commentsDates.sort()[commentsDates.length - 1]).toLocaleDateString('en-GB', options)

                      }

                    //------------------- 4. Inject the retrieved data in the DOM -------------------
                    // See manifest.json
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
                              <a id="more-details" target=”_blank” href=${BASE_URL}/fans/${fanId}> See more details</a>
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
                    resolve();
                  });
                }).then((data) => {
                  setTimeout(() => {
                    commentMainDiv.parentElement.querySelector(".fan-info-recll").style.opacity = "1";
                    commentMainDiv.parentElement.querySelector(".fan-info-recll").style.height = "220px";

                    const showMore = document.querySelector("#resize-memo")
                    if (commentMainDiv.parentElement.querySelector(".memo-section").offsetHeight < 90) {
                      showMore.remove()
                    }
                    else {
                      showMore.addEventListener("click", function () {
                        if (showMore.innerText === "show more") {
                          commentMainDiv.parentElement.querySelector(".fan-info-recll").style.height = "initial";
                          showMore.innerText = "show less"
                        }
                        else {
                          showMore.innerText = "show more"
                          commentMainDiv.parentElement.querySelector(".fan-info-recll").style.height = "220px";
                        }
                      });
                    }
                  }, 50);
                });
              });
            }
          }
        });
      }, 50);

    // Reload allScript when the user clicks back or forward (page history)
    // window.addEventListener('popstate', function() {
    //   console.log("popstate event triggered")
    //   clearInterval(interval);
    //   allScript();
    // });

    // // Reload allScript when the user navigates on Youtube
    document.addEventListener('yt-navigate-finish', function() {
      console.log("yt-navigate-finish event triggered")
      clearInterval(interval);
      allScript();
    });
  });


console.log(' --------------------------------------------- ')
console.log(' ------------- all script ends ------------- ')
};

console.log(' ///////////// First load starts ///////////// ')

allScript();

console.log(' ///////////// First load ends ///////////// ')


function addButton(div) {

}



