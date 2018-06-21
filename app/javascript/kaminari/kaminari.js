import $ from 'jquery';

function infinite_loader() {
  // console.log('hello')
  // $('.next').on('show', () => {
  //   console.log('inside')
  //   $(this).closest('a').click();
  // });
  var fans_cards = document.querySelector(".fan-cards");
  if (fans_cards) {
    var date = new Date();
    window.addEventListener('scroll', function(event) {
      var d = document.documentElement;
      var offset = d.scrollTop + window.innerHeight;
      var height = d.offsetHeight;

      if (height - offset - 600 < 0 && (new Date() - date) > 200) {
        console.log("request");
        document.querySelector("[rel=next]").click();
        date = new Date();
      }
    });
  }
}

// sélectionner la div fans_cards
// si je récupère une div
  // écouter le scroll sur window
  // calculer la height de fans-cards
  // calculer le niveau de scroll
  // si le niveau de scroll atteint la height
    // on déclenche le click sur le lien next

export { infinite_loader };
