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
    on: {
        slideChange: function () {
            // Get the actual active slide (which will be the "next" slide during transition)
            let activeSlideIndex = this.activeIndex;
            let activeSlide = this.slides[activeSlideIndex].querySelector('img');
            
            if (activeSlide) {
                let imageName = activeSlide.src.split('/').pop();
                fetch(`/feature-text/${imageName}`)
                    .then(response => response.text())
                    .then(featureText => {
                        document.querySelector('#feature-text').textContent = featureText;
                    })
                    .catch(error => {
                        console.error('Error fetching feature text:', error);
                        document.querySelector('#feature-text').textContent = 'Feature information not available';
                    });
            }
        }
    }
});
