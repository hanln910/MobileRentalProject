<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin - MotoRent</title>
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
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageUsers"><i class="fa-solid fa-users"></i> Users</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageMotorbikes"><i class="fa-solid fa-motorcycle"></i> Motorbikes</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageCategories"><i class="fa-solid fa-tags"></i> Categories</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageBrands"><i class="fa-solid fa-copyright"></i> Brands</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageComplaints"><i class="fa-solid fa-flag"></i> Complaints</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-4 border-bottom">
                    <h1 class="h2 fw-bold">Manage Users</h1>
                    <button class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#createStaffModal">
                        <i class="fa-solid fa-user-plus me-2"></i>Create Staff Account
                    </button>
                </div>

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

                <div class="card border-0 shadow-sm p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>User</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Joined</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${users}">
                                    <tr>
                                        <td>${u.userId}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="https://ui-avatars.com/api/?name=${u.fullName}&background=random" class="rounded-circle me-2" width="36" height="36" alt="User">
                                                <span class="fw-bold">${u.fullName}</span>
                                            </div>
                                        </td>
                                        <td>${u.email}</td>
                                        <td>${u.phone}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.roleId == 1}"><span class="badge bg-danger">Admin</span></c:when>
                                                <c:when test="${u.roleId == 2}"><span class="badge bg-primary">Customer</span></c:when>
                                                <c:when test="${u.roleId == 3}"><span class="badge bg-info text-dark">Staff</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.isActive}"><span class="badge bg-success">Active</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary">Locked</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><small><fmt:formatDate value="${u.createdAt}" pattern="MM/dd/yyyy"/></small></td>
                                        <td>
                                            <c:if test="${u.userId != sessionScope.user.userId}">
                                                <div class="d-flex gap-1">
                                                    <form action="${pageContext.request.contextPath}/admin" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggleUser">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <button type="submit" class="btn btn-sm ${u.isActive ? 'btn-outline-warning' : 'btn-outline-success'} rounded-pill" title="${u.isActive ? 'Lock User' : 'Unlock User'}">
                                                            <i class="fa-solid ${u.isActive ? 'fa-lock' : 'fa-unlock'}"></i>
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/admin" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user?')">
                                                        <input type="hidden" name="action" value="deleteUser">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill" title="Delete User">
                                                            <i class="fa-solid fa-trash"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                            <c:if test="${u.userId == sessionScope.user.userId}">
                                                <span class="text-muted small">Current User</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Create Staff Modal -->
    <div class="modal fade" id="createStaffModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold">Create Staff Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/admin" method="POST" onsubmit="return validateStaffForm()">
                    <input type="hidden" name="action" value="createStaff">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Full Name</label>
                            <input type="text" id="staffFullName" name="fullName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" id="staffEmail" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Phone</label>
                            <input type="text" name="phone" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Password</label>
                            <input type="password" id="staffPassword" name="password" class="form-control" minlength="6" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Address</label>
                            <input type="text" name="address" class="form-control">
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Create Staff</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
