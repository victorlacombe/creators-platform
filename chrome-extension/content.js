console.log("Ready to go");

chrome.runtime.onMessage.addListener(gotMessage);

function gotMessage(message, sender, sendResponse) {
  console.log(message)
  if (message === "hello") {
    const videoTitle = document.querySelectorAll("#video-title")
    videoTitle.forEach(function() {
      videoTitle.innerText = "COIN COIN !"
    })
  }
}
