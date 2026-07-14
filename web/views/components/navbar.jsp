<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- Sticky Navigation Bar -->
<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
            <i class="fa-solid fa-motorcycle me-2"></i>MotoRent
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mx-auto">
                <li class="nav-item">
                    <a class="nav-link ${param.active == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/home">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.active == 'motorbikes' ? 'active' : ''}" href="${pageContext.request.contextPath}/motorbikes?action=list">Motorbikes</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#">Pricing</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#">About</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.active == 'chatbot' ? 'active' : ''}" href="${pageContext.request.contextPath}/chatbot">
                        <i class="fa-solid fa-robot me-1"></i>AI Consultant
                    </a>
                </li>
            </ul>
            <div class="d-flex gap-2">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="dropdown">
                            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" alt="User" width="36" height="36" class="rounded-circle me-2">
                                <span class="fw-semibold d-none d-md-inline">${sessionScope.user.fullName}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" aria-labelledby="userDropdown">
                                <c:if test="${sessionScope.user.roleId == 1}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin?action=dashboard"><i class="fa-solid fa-chart-line me-2"></i>Admin Dashboard</a></li>
                                </c:if>
                                <c:if test="${sessionScope.user.roleId == 3}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/staff?action=dashboard"><i class="fa-solid fa-clipboard-list me-2"></i>Staff Dashboard</a></li>
                                </c:if>
                                <c:if test="${sessionScope.user.roleId == 2}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/orders?action=dashboard"><i class="fa-solid fa-chart-pie me-2"></i>My Dashboard</a></li>
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/wallet"><i class="fa-solid fa-wallet me-2"></i>My Wallet</a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Logout</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline-primary px-4 rounded-pill">Login</a>
                        <a href="${pageContext.request.contextPath}/auth?action=register" class="btn btn-primary px-4 rounded-pill">Register</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
