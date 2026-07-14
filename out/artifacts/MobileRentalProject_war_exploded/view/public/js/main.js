// Calculate total price dynamically on detail page
document.addEventListener('DOMContentLoaded', function() {
  const pickupDate = document.getElementById('pickupDate');
  const returnDate = document.getElementById('returnDate');
  const totalPriceEl = document.getElementById('totalPrice');
  const pricePerDayEl = document.getElementById('pricePerDay');

  if (pickupDate && returnDate && totalPriceEl && pricePerDayEl) {
    const pricePerDay = parseFloat(pricePerDayEl.dataset.price);

    function calculateTotal() {
      if (pickupDate.value && returnDate.value) {
        const start = new Date(pickupDate.value);
        const end = new Date(returnDate.value);
        
        if (end > start) {
          const diffTime = Math.abs(end - start);
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
          const total = diffDays * pricePerDay;
          totalPriceEl.textContent = '$' + total.toFixed(2);
        } else {
          totalPriceEl.textContent = '$0.00';
        }
      }
    }

    pickupDate.addEventListener('change', calculateTotal);
    returnDate.addEventListener('change', calculateTotal);
  }

  // Image Gallery on Detail Page
  const mainImage = document.getElementById('mainImage');
  const thumbs = document.querySelectorAll('.gallery-thumbs img');

  if (mainImage && thumbs.length > 0) {
    thumbs.forEach(thumb => {
      thumb.addEventListener('click', function() {
        mainImage.src = this.src;
        thumbs.forEach(t => t.classList.remove('active'));
        this.classList.add('active');
      });
    });
  }
});
