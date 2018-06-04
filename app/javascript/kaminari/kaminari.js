function infinitescrolling() {
  window.addEventListener('scroll', function(e) {
  derniere_position_de_scroll_connue = window.scrollY;
  if (!ticking) {
    window.requestAnimationFrame(function() {
      faitQuelquechose(derniere_position_de_scroll_connue);
      ticking = false;
    });
  }
  ticking = true;
  });
}
// sélectionner la div fans_cards
// si je récupère une div
  // écouter le scroll sur window
  // calculer la height de fans-cards
  // calculer le niveau de scroll
  // si le niveau de scroll atteint la height
    // on déclenche le click sur le lien next
