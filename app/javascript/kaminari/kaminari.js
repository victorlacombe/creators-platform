function infinite_loader() {
  var fans_cards = document.querySelector(".fan-cards")
  if (fans_cards) {
    window.addEventListener('scroll', function(event) {
      var d = document.documentElement;
      var offset = d.scrollTop + window.innerHeight;
      var height = d.offsetHeight;
      if (height - offset - 200 < 0 ) {
        document.querySelector("[rel=next]").click();
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
