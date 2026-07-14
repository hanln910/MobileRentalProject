/**
 * MotoRent - Client-side Validation
 */

// =============================================
// LOGIN FORM VALIDATION
// =============================================
function validateLoginForm() {
    let isValid = true;
    const email = document.getElementById('loginEmail');
    const password = document.getElementById('loginPassword');

    clearValidation(email);
    clearValidation(password);

    if (!email.value.trim()) {
        showError(email, 'Email is required.');
        isValid = false;
    } else if (!isValidEmail(email.value.trim())) {
        showError(email, 'Please enter a valid email address.');
        isValid = false;
    }

    if (!password.value.trim()) {
        showError(password, 'Password is required.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// REGISTER FORM VALIDATION
// =============================================
function validateRegisterForm() {
    let isValid = true;
    const fullName = document.getElementById('regFullName');
    const email = document.getElementById('regEmail');
    const phone = document.getElementById('regPhone');
    const address = document.getElementById('regAddress');
    const password = document.getElementById('regPassword');
    const confirmPassword = document.getElementById('regConfirmPassword');

    const fields = [fullName, email, phone, address, password, confirmPassword];
    fields.forEach(f => clearValidation(f));

    if (!fullName.value.trim()) {
        showError(fullName, 'Full name is required.');
        isValid = false;
    } else if (fullName.value.trim().length < 2) {
        showError(fullName, 'Full name must be at least 2 characters.');
        isValid = false;
    }

    if (!email.value.trim()) {
        showError(email, 'Email is required.');
        isValid = false;
    } else if (!isValidEmail(email.value.trim())) {
        showError(email, 'Please enter a valid email address.');
        isValid = false;
    }

    if (!phone.value.trim()) {
        showError(phone, 'Phone number is required.');
        isValid = false;
    } else if (!isValidPhone(phone.value.trim())) {
        showError(phone, 'Please enter a valid phone number.');
        isValid = false;
    }

    if (!address.value.trim()) {
        showError(address, 'Address is required.');
        isValid = false;
    }

    if (!password.value) {
        showError(password, 'Password is required.');
        isValid = false;
    } else if (password.value.length < 6) {
        showError(password, 'Password must be at least 6 characters.');
        isValid = false;
    }

    if (!confirmPassword.value) {
        showError(confirmPassword, 'Please confirm your password.');
        isValid = false;
    } else if (confirmPassword.value !== password.value) {
        showError(confirmPassword, 'Passwords do not match.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// BOOKING FORM VALIDATION
// =============================================
function validateBookingForm() {
    let isValid = true;
    const pickupDate = document.getElementById('pickupDate');
    const returnDate = document.getElementById('returnDate');

    clearValidation(pickupDate);
    clearValidation(returnDate);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (!pickupDate.value) {
        showError(pickupDate, 'Pickup date is required.');
        isValid = false;
    } else if (new Date(pickupDate.value) < today) {
        showError(pickupDate, 'Pickup date cannot be in the past.');
        isValid = false;
    }

    if (!returnDate.value) {
        showError(returnDate, 'Return date is required.');
        isValid = false;
    } else if (pickupDate.value && new Date(returnDate.value) <= new Date(pickupDate.value)) {
        showError(returnDate, 'Return date must be after pickup date.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// MOTORBIKE FORM VALIDATION (Admin)
// =============================================
function validateMotorbikeForm() {
    let isValid = true;
    const name = document.getElementById('motorbikeName');
    const brandId = document.getElementById('brandId');
    const categoryId = document.getElementById('categoryId');
    const price = document.getElementById('pricePerDay');

    const fields = [name, brandId, categoryId, price];
    fields.forEach(f => { if (f) clearValidation(f); });

    if (name && !name.value.trim()) {
        showError(name, 'Motorbike name is required.');
        isValid = false;
    }
    if (brandId && !brandId.value) {
        showError(brandId, 'Please select a brand.');
        isValid = false;
    }
    if (categoryId && !categoryId.value) {
        showError(categoryId, 'Please select a category.');
        isValid = false;
    }
    if (price && (!price.value || parseFloat(price.value) <= 0)) {
        showError(price, 'Price must be greater than 0.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// STAFF CREATE FORM VALIDATION (Admin)
// =============================================
function validateStaffForm() {
    let isValid = true;
    const fullName = document.getElementById('staffFullName');
    const email = document.getElementById('staffEmail');
    const password = document.getElementById('staffPassword');

    const fields = [fullName, email, password];
    fields.forEach(f => { if (f) clearValidation(f); });

    if (fullName && !fullName.value.trim()) {
        showError(fullName, 'Full name is required.');
        isValid = false;
    }
    if (email && !email.value.trim()) {
        showError(email, 'Email is required.');
        isValid = false;
    } else if (email && !isValidEmail(email.value.trim())) {
        showError(email, 'Please enter a valid email address.');
        isValid = false;
    }
    if (password && !password.value) {
        showError(password, 'Password is required.');
        isValid = false;
    } else if (password && password.value.length < 6) {
        showError(password, 'Password must be at least 6 characters.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// REVIEW FORM VALIDATION
// =============================================
function validateReviewForm() {
    let isValid = true;
    const rating = document.querySelector('input[name="rating"]:checked');
    const comment = document.getElementById('reviewComment');

    if (!rating) {
        alert('Please select a rating.');
        isValid = false;
    }

    return isValid;
}

// =============================================
// UTILITY FUNCTIONS
// =============================================
function isValidEmail(email) {
    return /^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$/.test(email);
}

function isValidPhone(phone) {
    return /^[0-9+\-\s()]{8,20}$/.test(phone);
}

function showError(input, message) {
    const inputGroup = input.closest('.input-group') || input.parentElement;
    input.classList.add('is-invalid');
    let feedback = inputGroup.parentElement.querySelector('.invalid-feedback');
    if (!feedback) {
        feedback = document.createElement('div');
        feedback.className = 'invalid-feedback';
        inputGroup.parentElement.appendChild(feedback);
    }
    feedback.textContent = message;
    feedback.style.display = 'block';
}

function clearValidation(input) {
    if (!input) return;
    input.classList.remove('is-invalid');
    input.classList.remove('is-valid');
    const inputGroup = input.closest('.input-group') || input.parentElement;
    const feedback = inputGroup.parentElement.querySelector('.invalid-feedback');
    if (feedback) {
        feedback.style.display = 'none';
    }
}

// =============================================
// BOOKING PRICE CALCULATOR
// =============================================
function calculateTotal() {
    const pickupDate = document.getElementById('pickupDate');
    const returnDate = document.getElementById('returnDate');
    const pricePerDay = document.getElementById('pricePerDay');
    const totalPrice = document.getElementById('totalPrice');

    if (pickupDate && returnDate && pricePerDay && totalPrice && pickupDate.value && returnDate.value) {
        const start = new Date(pickupDate.value);
        const end = new Date(returnDate.value);
        const diffTime = end - start;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        if (diffDays > 0) {
            const price = parseFloat(pricePerDay.dataset.price || pricePerDay.value);
            const total = diffDays * price;
            totalPrice.textContent = '$' + total.toFixed(2);
            const totalDaysEl = document.getElementById('totalDays');
            if (totalDaysEl) totalDaysEl.textContent = diffDays + ' day(s)';
        } else {
            totalPrice.textContent = '$0.00';
        }
    }
}

// =============================================
// IMAGE GALLERY
// =============================================
function changeMainImage(src) {
    const mainImage = document.getElementById('mainImage');
    if (mainImage) {
        mainImage.src = src;
        document.querySelectorAll('.gallery-thumbs img').forEach(img => {
            img.classList.remove('active');
            if (img.src === src) img.classList.add('active');
        });
    }
}

// =============================================
// AUTO-DISMISS ALERTS
// =============================================
document.addEventListener('DOMContentLoaded', function () {
    // Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            if (bsAlert) bsAlert.close();
        }, 5000);
    });

    // Set min date for date inputs to today
    const dateInputs = document.querySelectorAll('input[type="date"]');
    const today = new Date().toISOString().split('T')[0];
    dateInputs.forEach(input => {
        if (!input.min) input.min = today;
    });

    // Price calculator listeners
    const pickupDate = document.getElementById('pickupDate');
    const returnDate = document.getElementById('returnDate');
    if (pickupDate) pickupDate.addEventListener('change', calculateTotal);
    if (returnDate) returnDate.addEventListener('change', calculateTotal);

    // Gallery thumbnails click
    document.querySelectorAll('.gallery-thumbs img').forEach(img => {
        img.addEventListener('click', function () {
            changeMainImage(this.src.replace('w=400', 'w=1200'));
        });
    });
});
