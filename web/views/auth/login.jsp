<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="container-fluid p-0 auth-split">
        <div class="row g-0 h-100">
            <!-- Left Side Background Image -->
            <div class="col-lg-6 d-none d-lg-block auth-bg">
                <div class="h-100 w-100 d-flex flex-column justify-content-center p-5 text-white" style="background: linear-gradient(to bottom, rgba(30, 41, 59, 0.2), rgba(30, 41, 59, 0.7));">
                    <a href="${pageContext.request.contextPath}/home" class="text-white text-decoration-none mb-auto">
                        <h2 class="fw-bold"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</h2>
                    </a>
                    <div>
                        <h1 class="display-4 fw-bold mb-4">Welcome Back!</h1>
                        <p class="lead mb-0">Log in to manage your rentals, explore new motorbikes, and hit the road.</p>
                    </div>
                    <div class="mt-auto">
                        <p class="mb-0">&copy; 2026 MotoRent. All rights reserved.</p>
                    </div>
                </div>
            </div>

            <!-- Right Side Login Form -->
            <div class="col-lg-6 d-flex align-items-center justify-content-center bg-white min-vh-100">
                <div class="w-100 p-4 p-md-5" style="max-width: 500px;">
                    <div class="text-center mb-5 d-lg-none">
                        <a href="${pageContext.request.contextPath}/home" class="text-primary text-decoration-none">
                            <h2 class="fw-bold"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</h2>
                        </a>
                    </div>

                    <h2 class="fw-bold mb-2">Sign In</h2>
                    <p class="text-muted mb-5">Please enter your details to access your account.</p>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <!-- Success Message -->
                    <c:if test="${not empty success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i>${success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth" method="POST" onsubmit="return validateLoginForm()">
                        <input type="hidden" name="action" value="login">

                        <div class="mb-4">
                            <label class="form-label fw-semibold text-muted">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-regular fa-envelope text-muted"></i></span>
                                <input type="email" id="loginEmail" name="email" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                       placeholder="Enter your email" value="${email}" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <label class="form-label fw-semibold text-muted mb-0">Password</label>
                            </div>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                                <input type="password" id="loginPassword" name="password" class="form-control form-control-lg bg-light border-start-0 ps-0"
                                       placeholder="Enter your password" required>
                            </div>
                        </div>

                        <div class="mb-5 form-check">
                            <input type="checkbox" class="form-check-input" id="rememberMe">
                            <label class="form-check-label text-muted" for="rememberMe">Remember me for 30 days</label>
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill fw-semibold mb-4">Log In</button>

                        <div class="text-center">
                            <p class="text-muted">Don't have an account?
                                <a href="${pageContext.request.contextPath}/auth?action=register" class="text-primary fw-semibold text-decoration-none">Register here</a>
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
