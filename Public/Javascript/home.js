//
//  home.js
//  Jandy
//
//  Created by Jack Anderson on 1/7/25.
//

document.addEventListener("DOMContentLoaded", function () {
    let hamburgerButton = document.querySelector(".hamburger-button");
    let mobileMenu = document.querySelector(".mobile-menu");

    hamburgerButton.addEventListener("click", function () {
        mobileMenu.classList.toggle("active");
    });
});

