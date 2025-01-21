//
//  stack.js
//  Jandy
//
//  Created by Jack Anderson on 1/21/25.
//

// Function to initialize a stack
function initializeStack(stackSelector, intervalTime = 4000) {
  const stack = document.querySelector(stackSelector);
  if (!stack) return; // Ensure the stack exists
  const cards = Array.from(stack.children)
    .reverse()
    .filter((child) => child.classList.contains("card"));

  // Reorder cards initially
  cards.forEach((card) => stack.appendChild(card));

  // Move card function scoped to this stack
  function moveCard() {
    const lastCard = stack.lastElementChild;
    if (lastCard.classList.contains("card")) {
      lastCard.classList.add("swap");

      setTimeout(() => {
        lastCard.classList.remove("swap");
        stack.insertBefore(lastCard, stack.firstElementChild);
      }, 1200);
    }
  }

  // Set up autoplay for this stack
  let autoplayInterval = setInterval(moveCard, intervalTime);

  // Click event listener scoped to this stack
  stack.addEventListener("click", function (e) {
    const card = e.target.closest(".card");
    if (card && card === stack.lastElementChild) {
      card.classList.add("swap");

      setTimeout(() => {
        card.classList.remove("swap");
        stack.insertBefore(card, stack.firstElementChild);
      }, 1200);
    }
  });

  // Return a reference to manage the stack if needed
  return {
    startAutoplay: () => (autoplayInterval = setInterval(moveCard, intervalTime)),
    stopAutoplay: () => clearInterval(autoplayInterval),
  };
}

// Initialize multiple stacks
initializeStack(".stack");
initializeStack(".stack-secondary");
