//
//  swiper.js
//  Jandy
//
//  Created by Jack Anderson on 1/22/25.
//
const swiper = new Swiper('.swiper', {
  loop: true,
  pagination: {
    el: '.swiper-pagination',
  },
  navigation: {
    nextEl: '.swiper-button-next',
    prevEl: '.swiper-button-prev',
  },
});
