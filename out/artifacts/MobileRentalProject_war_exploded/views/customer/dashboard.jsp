<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <!-- Top Navbar -->
    <nav class="navbar navbar-expand-lg sticky-top bg-white border-bottom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</a>
            <div class="d-flex align-items-center gap-3">
                <div class="dropdown">
                    <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" id="userDropdown" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" alt="User" width="40" height="40" class="rounded-circle me-2">
                        <span class="fw-semibold d-none d-md-inline">${sessionScope.user.fullName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#profileModal"><i class="fa-regular fa-user me-2"></i>Profile</a></li>
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#changePasswordModal"><i class="fa-solid fa-gear me-2"></i>Change Password</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 d-md-block sidebar collapse bg-white p-3">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column gap-2">
                        <li class="nav-item">
                            <a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/orders?action=dashboard">
                                <i class="fa-solid fa-chart-pie"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/orders?action=history">
                                <i class="fa-solid fa-motorcycle"></i> My Rentals
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/wallet">
                                <i class="fa-solid fa-wallet"></i> My Wallet
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/motorbikes?action=list">
                                <i class="fa-solid fa-magnifying-glass"></i> Browse Bikes
                            </a>
                        </li>
                        <li class="nav-item mt-auto">
                            <a class="nav-link text-danger d-flex align-items-center gap-3 mt-5" href="${pageContext.request.contextPath}/auth?action=logout">
                                <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-4 border-bottom">
                    <h1 class="h2 fw-bold">Dashboard</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-primary rounded-pill px-4">
                            <i class="fa-solid fa-plus me-2"></i>New Rental
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.orderSuccess}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.orderSuccess}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="orderSuccess" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.orderError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.orderError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="orderError" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.profileSuccess}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.profileSuccess}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="profileSuccess" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.profileError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.profileError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="profileError" scope="session"/>
                </c:if>

                <!-- Unpaid Overdue Penalty Warning -->
                <c:if test="${hasUnpaidPenalties}">
                    <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center mb-4" role="alert">
                        <i class="fa-solid fa-triangle-exclamation fs-4 me-3"></i>
                        <div>
                            <strong>Account Restricted:</strong> You have unpaid overdue penalties. New rentals and returns are blocked until all penalties are paid.
                            Check your order history for overdue orders.
                        </div>
                    </div>
                </c:if>

                <!-- Wallet Balance Banner -->
                <div class="card border-0 shadow-sm p-3 mb-4" style="background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); border-radius: 12px;">
                    <div class="d-flex justify-content-between align-items-center text-white">
                        <div>
                            <p class="mb-0 fw-semibold" style="opacity: 0.8;"><i class="fa-solid fa-wallet me-2"></i>Wallet Balance</p>
                            <h2 class="fw-bold mb-0">$<fmt:formatNumber value="${wallet.balance}" maxFractionDigits="2"/></h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/wallet" class="btn btn-light rounded-pill px-4 fw-semibold">
                            <i class="fa-solid fa-plus me-1"></i>Top Up
                        </a>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row g-4 mb-5">
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon primary"><i class="fa-solid fa-motorcycle"></i></div>
                            <div>
                                <h3 class="fw-bold mb-0">${totalOrders}</h3>
                                <p class="text-muted mb-0 fw-semibold">Total Rentals</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon warning"><i class="fa-solid fa-key"></i></div>
                            <div>
                                <h3 class="fw-bold mb-0">${activeOrders}</h3>
                                <p class="text-muted mb-0 fw-semibold">Active Rentals</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon success"><i class="fa-solid fa-check-double"></i></div>
                            <div>
                                <h3 class="fw-bold mb-0">${completedOrders}</h3>
                                <p class="text-muted mb-0 fw-semibold">Completed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon ${remainingSlots > 0 ? 'info' : 'danger'}">
                                <i class="fa-solid fa-${remainingSlots > 0 ? 'circle-check' : 'ban'}"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${remainingSlots}/${maxRentals}</h3>
                                <p class="text-muted mb-0 fw-semibold">Slots Left</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Rental History Table -->
                <div class="card border-0 shadow-sm p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="fw-bold mb-0">Rental History</h4>
                        <a href="${pageContext.request.contextPath}/orders?action=history" class="btn btn-sm btn-outline-primary rounded-pill px-3">View All</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Order ID</th>
                                    <th>Motorbike</th>
                                    <th>Rental Date</th>
                                    <th>Return Date</th>
                                    <th>Total Price</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${orders}">
                                    <tr>
                                        <td class="fw-semibold">#ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                        <td>
                                            <c:if test="${not empty order.orderDetails}">
                                                <div class="d-flex align-items-center">
                                                    <img src="${order.orderDetails[0].motorbikeImage}" class="rounded me-3" width="50" height="40" style="object-fit: cover;" alt="Bike">
                                                    <div>
                                                        <h6 class="mb-0 fw-bold">${order.orderDetails[0].brandName} ${order.orderDetails[0].motorbikeName}</h6>
                                                        <small class="text-muted">${order.orderDetails[0].categoryName}</small>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty order.orderDetails}">
                                                <fmt:formatDate value="${order.orderDetails[0].rentalDate}" pattern="MMM dd, yyyy"/>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty order.orderDetails}">
                                                <fmt:formatDate value="${order.orderDetails[0].returnDate}" pattern="MMM dd, yyyy"/>
                                            </c:if>
                                        </td>
                                        <td class="fw-bold">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status == 'Pending'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                                                <c:when test="${order.status == 'Confirmed'}"><span class="badge bg-primary">Confirmed</span></c:when>
                                                <c:when test="${order.status == 'Renting'}"><span class="badge bg-info text-dark">Renting</span></c:when>
                                                <c:when test="${order.status == 'Received'}"><span class="badge bg-cyan text-dark" style="background-color: #0dcaf0 !important;">Received</span></c:when>
                                                <c:when test="${order.status == 'Returned'}"><span class="badge bg-success">Returned</span></c:when>
                                                <c:when test="${order.status == 'Fined'}"><span class="badge bg-danger"><i class="fa-solid fa-gavel me-1"></i>Fined</span></c:when>
                                                <c:when test="${order.status == 'Completed'}"><span class="badge bg-success">Completed</span></c:when>
                                                <c:when test="${order.status == 'Cancelled'}"><span class="badge bg-danger">Cancelled</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${order.status == 'Pending'}">
                                                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to cancel this order?')">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill">Cancel</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${order.status == 'Confirmed'}">
                                                <a href="${pageContext.request.contextPath}/orders?action=contract&orderId=${order.orderId}" class="btn btn-sm btn-outline-primary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                            </c:if>
                                            <c:if test="${order.status == 'Renting'}">
                                                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Confirm you have received the motorbike?')">
                                                    <input type="hidden" name="action" value="received">
                                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                                    <button type="submit" class="btn btn-sm btn-info rounded-pill text-white"><i class="fa-solid fa-hand-holding me-1"></i>Received</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${order.status == 'Received'}">
                                                <span class="badge bg-info text-dark">In Use</span>
                                            </c:if>
                                            <c:if test="${order.status == 'Returned' || order.status == 'Completed'}">
                                                <span class="text-success"><i class="fa-solid fa-check"></i> Done</span>
                                            </c:if>
                                            <c:if test="${order.status == 'Fined'}">
                                                <a href="${pageContext.request.contextPath}/orders?action=returnInspection&orderId=${order.orderId}" class="btn btn-sm btn-outline-danger rounded-pill"><i class="fa-solid fa-gavel me-1"></i>View Fine</a>
                                            </c:if>
                                            <c:if test="${order.status == 'Cancelled'}">
                                                <span class="text-muted">Cancelled</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty orders}">
                                    <tr><td colspan="7" class="text-center text-muted py-4">No rental history found. <a href="${pageContext.request.contextPath}/motorbikes?action=list">Browse motorbikes</a> to get started!</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav class="mt-3">
                            <ul class="pagination justify-content-center mb-0">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/orders?action=dashboard&page=${currentPage - 1}">&laquo;</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/orders?action=dashboard&page=${i}">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/orders?action=dashboard&page=${currentPage + 1}">&raquo;</a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                </div>
            </main>
        </div>
    </div>

    <!-- Profile Modal -->
    <div class="modal fade" id="profileModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold">Edit Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/profile" method="POST">
                    <input type="hidden" name="action" value="update">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Full Name</label>
                            <input type="text" name="fullName" class="form-control" value="${sessionScope.user.fullName}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" class="form-control" value="${sessionScope.user.email}" disabled>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Phone</label>
                            <input type="text" name="phone" class="form-control" value="${sessionScope.user.phone}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Address</label>
                            <input type="text" name="address" class="form-control" value="${sessionScope.user.address}">
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold">Change Password</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/profile" method="POST">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Current Password</label>
                            <input type="password" name="currentPassword" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">New Password</label>
                            <input type="password" name="newPassword" class="form-control" minlength="6" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Change Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="/views/includes/chatbot-widget.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
