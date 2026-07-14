<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="container-fluid p-0 auth-split">
        <div class="row g-0 h-100">
            <div class="col-lg-5 d-none d-lg-block auth-bg" style="background-image: url('https://images.unsplash.com/photo-1558981806-ec527fa84c39?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80');">
                <div class="h-100 w-100 d-flex flex-column justify-content-center p-5 text-white" style="background: rgba(30, 41, 59, 0.7);">
                    <a href="${pageContext.request.contextPath}/home" class="text-white text-decoration-none mb-auto">
                        <h2 class="fw-bold"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</h2>
                    </a>
                    <div>
                        <h1 class="display-4 fw-bold mb-4">Join the Ride!</h1>
                        <p class="lead mb-0">Create an account to book your dream motorbike and start your adventure today.</p>
                    </div>
                    <div class="mt-auto">
                        <p class="mb-0">&copy; 2026 MotoRent. All rights reserved.</p>
                    </div>
                </div>
            </div>

            <div class="col-lg-7 d-flex align-items-center justify-content-center bg-white min-vh-100 py-5">
                <div class="w-100 p-4 p-md-5" style="max-width: 650px;">
                    <div class="text-center mb-5 d-lg-none">
                        <a href="${pageContext.request.contextPath}/home" class="text-primary text-decoration-none">
                            <h2 class="fw-bold"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</h2>
                        </a>
                    </div>

                    <h2 class="fw-bold mb-2">Create an Account</h2>
                    <p class="text-muted mb-5">Fill in the details below to register.</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth" method="POST" onsubmit="return validateRegisterForm()">
                        <input type="hidden" name="action" value="register">

                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold text-muted">Full Name</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="fa-regular fa-user text-muted"></i></span>
                                    <input type="text" id="regFullName" name="fullName" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                           placeholder="John Doe" value="${fullName}" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold text-muted">Phone Number</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-phone text-muted"></i></span>
                                    <input type="tel" id="regPhone" name="phone" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                           placeholder="+1 (555) 000-0000" value="${phone}" required>
                                </div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold text-muted">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-regular fa-envelope text-muted"></i></span>
                                <input type="email" id="regEmail" name="email" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                       placeholder="john@example.com" value="${email}" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold text-muted">Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-location-dot text-muted"></i></span>
                                <input type="text" id="regAddress" name="address" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                       placeholder="123 Main St, City, Country" value="${address}" required>
                            </div>
                        </div>

                        <div class="row g-4 mb-5">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold text-muted">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                                    <input type="password" id="regPassword" name="password" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                           placeholder="Create password" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold text-muted">Confirm Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                                    <input type="password" id="regConfirmPassword" name="confirmPassword" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                           placeholder="Confirm password" required>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill fw-semibold mb-4">Register Account</button>

                        <div class="text-center">
                            <p class="text-muted">Already have an account?
                                <a href="${pageContext.request.contextPath}/auth?action=login" class="text-primary fw-semibold text-decoration-none">Log in here</a>
                            </p>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
