<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Complaints - Admin - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark-custom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/admin?action=dashboard"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent <span class="badge bg-danger ms-2">Admin</span></a>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="nav-link"><i class="fa-solid fa-chart-pie me-1"></i> Dashboard</a>
                <a href="${pageContext.request.contextPath}/home" class="nav-link"><i class="fa-solid fa-home me-1"></i> Home</a>
                <div class="dropdown">
                    <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-white" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=dc3545&color=fff" width="36" height="36" class="rounded-circle me-2" alt="User">
                        <span class="fw-semibold">${sessionScope.user.fullName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                        <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <div class="col-md-3 col-lg-2 d-md-block sidebar collapse bg-white p-3">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column gap-2">
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=dashboard"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageUsers"><i class="fa-solid fa-users"></i> Users</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageMotorbikes"><i class="fa-solid fa-motorcycle"></i> Motorbikes</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageCategories"><i class="fa-solid fa-tags"></i> Categories</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageBrands"><i class="fa-solid fa-copyright"></i> Brands</a></li>
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageComplaints"><i class="fa-solid fa-flag"></i> Complaints</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <!-- Alerts -->
        <c:if test="${not empty sessionScope.adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.adminSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="adminSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.adminError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="adminError" scope="session"/>
        </c:if>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1"><i class="fa-solid fa-flag text-warning me-2"></i>Manage Complaints</h2>
                <p class="text-muted mb-0">
                    <span class="badge bg-warning text-dark me-2">${openCount} Open</span>
                    Total: ${complaints.size()} complaints
                </p>
            </div>
        </div>

        <c:if test="${empty complaints}">
            <div class="text-center py-5">
                <i class="fa-solid fa-face-smile text-success" style="font-size: 64px;"></i>
                <h3 class="mt-4 text-muted">No complaints yet!</h3>
                <p class="text-muted">All customers are happy.</p>
            </div>
        </c:if>

        <c:forEach var="c" items="${complaints}">
            <div class="card border-0 shadow-sm mb-3">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div>
                            <h5 class="fw-bold mb-1">${c.subject}</h5>
                            <small class="text-muted">
                                Complaint #${c.complaintId} •
                                Order #ORD-<fmt:formatNumber value="${c.orderId}" minIntegerDigits="4" groupingUsed="false"/> •
                                By <strong>${c.customerName}</strong> •
                                <fmt:formatDate value="${c.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                            </small>
                        </div>
                        <c:choose>
                            <c:when test="${c.status == 'Open'}"><span class="badge bg-warning text-dark px-3 py-2">${c.status}</span></c:when>
                            <c:when test="${c.status == 'InProgress'}"><span class="badge bg-info text-dark px-3 py-2">In Progress</span></c:when>
                            <c:when test="${c.status == 'Resolved'}"><span class="badge bg-success px-3 py-2">${c.status}</span></c:when>
                            <c:when test="${c.status == 'Rejected'}"><span class="badge bg-danger px-3 py-2">${c.status}</span></c:when>
                        </c:choose>
                    </div>

                    <div class="bg-light p-3 rounded mb-3">
                        <p class="mb-0">${c.description}</p>
                    </div>

                    <!-- Admin Response (if exists) -->
                    <c:if test="${not empty c.adminResponse}">
                        <div class="border-start border-3 border-primary ps-3 mb-3">
                            <small class="fw-bold text-primary"><i class="fa-solid fa-reply me-1"></i>Admin Response:</small>
                            <p class="mb-1 mt-1">${c.adminResponse}</p>
                            <small class="text-muted">
                                <c:if test="${not empty c.resolvedByName}">By ${c.resolvedByName} • </c:if>
                                <fmt:formatDate value="${c.resolvedAt}" pattern="MMM dd, yyyy HH:mm"/>
                            </small>
                        </div>
                    </c:if>

                    <!-- Respond Form (for Open or InProgress) -->
                    <c:if test="${c.status == 'Open' || c.status == 'InProgress'}">
                        <div class="border-top pt-3">
                            <form action="${pageContext.request.contextPath}/admin" method="POST">
                                <input type="hidden" name="action" value="respondComplaint">
                                <input type="hidden" name="complaintId" value="${c.complaintId}">
                                <div class="row g-2">
                                    <div class="col-md-8">
                                        <textarea name="adminResponse" class="form-control" rows="2" required placeholder="Type your response to the customer..."></textarea>
                                    </div>
                                    <div class="col-md-2">
                                        <select name="newStatus" class="form-select">
                                            <option value="InProgress">In Progress</option>
                                            <option value="Resolved">Resolved</option>
                                            <option value="Rejected">Rejected</option>
                                        </select>
                                    </div>
                                    <div class="col-md-2 d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa-solid fa-paper-plane me-1"></i>Respond
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </c:if>
                </div>
            </div>
        </c:forEach>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
