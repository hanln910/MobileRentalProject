<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <!-- Dark Navbar for Staff -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark-custom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/staff?action=dashboard"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent <span class="badge bg-primary ms-2">Staff</span></a>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/home" class="nav-link"><i class="fa-solid fa-home me-1"></i> Home</a>
                <div class="dropdown">
                    <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-white" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" width="36" height="36" class="rounded-circle me-2" alt="User">
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
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 d-md-block sidebar collapse bg-white p-3">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column gap-2">
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=dashboard"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=overdueOrders"><i class="fa-solid fa-clock text-danger"></i> Overdue</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <h1 class="h2 fw-bold pt-3 pb-2 mb-4 border-bottom">Staff Dashboard</h1>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.staffSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.staffSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="staffSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.staffError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.staffError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="staffError" scope="session"/>
        </c:if>

        <!-- Statistics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon primary"><i class="fa-solid fa-list-check"></i></div>
                    <div><h3 class="fw-bold mb-0">${totalOrders}</h3><p class="text-muted mb-0 fw-semibold">Total</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon warning"><i class="fa-solid fa-clock"></i></div>
                    <div><h3 class="fw-bold mb-0">${pendingOrders}</h3><p class="text-muted mb-0 fw-semibold">Pending</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon primary"><i class="fa-solid fa-file-contract"></i></div>
                    <div><h3 class="fw-bold mb-0">${confirmedOrders}</h3><p class="text-muted mb-0 fw-semibold">Confirmed</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon danger"><i class="fa-solid fa-key"></i></div>
                    <div><h3 class="fw-bold mb-0">${activeRentals}</h3><p class="text-muted mb-0 fw-semibold">Renting</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon info"><i class="fa-solid fa-hand-holding"></i></div>
                    <div><h3 class="fw-bold mb-0">${receivedOrders}</h3><p class="text-muted mb-0 fw-semibold">Received</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon success"><i class="fa-solid fa-check-double"></i></div>
                    <div><h3 class="fw-bold mb-0">${returnedOrders}</h3><p class="text-muted mb-0 fw-semibold">Returned</p></div>
                </div>
            </div>
            <div class="col-6 col-md">
                <div class="stat-card shadow-sm border-0">
                    <div class="stat-icon danger"><i class="fa-solid fa-gavel"></i></div>
                    <div><h3 class="fw-bold mb-0">${finedOrders}</h3><p class="text-muted mb-0 fw-semibold">Fined</p></div>
                </div>
            </div>
        </div>

        <!-- Status Filter Tabs -->
        <div class="mb-4">
            <div class="d-flex flex-wrap gap-2">
                <a href="${pageContext.request.contextPath}/staff?action=dashboard" class="btn ${empty statusFilter ? 'btn-dark' : 'btn-outline-dark'} btn-sm rounded-pill px-3">All</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Pending" class="btn ${statusFilter == 'Pending' ? 'btn-warning' : 'btn-outline-warning'} btn-sm rounded-pill px-3">Pending</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Confirmed" class="btn ${statusFilter == 'Confirmed' ? 'btn-primary' : 'btn-outline-primary'} btn-sm rounded-pill px-3">Confirmed</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Renting" class="btn ${statusFilter == 'Renting' ? 'btn-info' : 'btn-outline-info'} btn-sm rounded-pill px-3">Renting</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Received" class="btn ${statusFilter == 'Received' ? 'btn-info' : 'btn-outline-info'} btn-sm rounded-pill px-3">Received</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Returned" class="btn ${statusFilter == 'Returned' ? 'btn-success' : 'btn-outline-success'} btn-sm rounded-pill px-3">Returned</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Fined" class="btn ${statusFilter == 'Fined' ? 'btn-danger' : 'btn-outline-danger'} btn-sm rounded-pill px-3">Fined</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Completed" class="btn ${statusFilter == 'Completed' ? 'btn-success' : 'btn-outline-success'} btn-sm rounded-pill px-3">Completed</a>
                <a href="${pageContext.request.contextPath}/staff?action=dashboard&status=Cancelled" class="btn ${statusFilter == 'Cancelled' ? 'btn-danger' : 'btn-outline-danger'} btn-sm rounded-pill px-3">Cancelled</a>
            </div>
        </div>

        <!-- Order Management Table -->
        <div class="card border-0 shadow-sm p-4">
            <h4 class="fw-bold mb-4">Order Management</h4>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <th>Motorbike</th>
                            <th>Dates</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="order" items="${orders}">
                            <tr>
                                <td class="fw-semibold">#ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                <td>
                                    <h6 class="mb-0 fw-bold">${order.customerName}</h6>
                                    <small class="text-muted">${order.customerEmail}</small>
                                </td>
                                <td>
                                    <c:if test="${not empty order.orderDetails}">
                                        ${order.orderDetails[0].brandName} ${order.orderDetails[0].motorbikeName}
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${not empty order.orderDetails}">
                                        <small><fmt:formatDate value="${order.orderDetails[0].rentalDate}" pattern="MM/dd"/> - <fmt:formatDate value="${order.orderDetails[0].returnDate}" pattern="MM/dd/yy"/></small>
                                    </c:if>
                                </td>
                                <td class="fw-bold">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.status == 'Pending'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                                        <c:when test="${order.status == 'Confirmed'}"><span class="badge bg-primary">Confirmed</span></c:when>
                                        <c:when test="${order.status == 'Renting'}"><span class="badge bg-info text-dark">Renting</span></c:when>
                                        <c:when test="${order.status == 'Received'}"><span class="badge" style="background-color: #0dcaf0;">Received</span></c:when>
                                        <c:when test="${order.status == 'Returned'}"><span class="badge bg-success">Returned</span></c:when>
                                        <c:when test="${order.status == 'Fined'}"><span class="badge bg-danger"><i class="fa-solid fa-gavel me-1"></i>Fined</span></c:when>
                                        <c:when test="${order.status == 'Completed'}"><span class="badge bg-success">Completed</span></c:when>
                                        <c:when test="${order.status == 'Cancelled'}"><span class="badge bg-danger">Cancelled</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex flex-wrap gap-1">
                                    <c:if test="${order.status == 'Pending'}">
                                        <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="confirm">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3" title="Confirm Order">
                                                <i class="fa-solid fa-check me-1"></i>Confirm
                                            </button>
                                        </form>
                                        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Reject Order" data-bs-toggle="modal" data-bs-target="#rejectModal${order.orderId}">
                                            <i class="fa-solid fa-ban me-1"></i>Reject
                                        </button>
                                        <!-- Reject Modal -->
                                        <div class="modal fade" id="rejectModal${order.orderId}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="${pageContext.request.contextPath}/staff" method="POST">
                                                        <input type="hidden" name="action" value="rejectOrder">
                                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                                        <div class="modal-header"><h5 class="modal-title">Reject Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                                        <div class="modal-body">
                                                            <label class="form-label fw-semibold">Reason for rejection *</label>
                                                            <textarea name="rejectReason" class="form-control" rows="3" required placeholder="Please provide a reason..."></textarea>
                                                            <small class="text-muted">The customer will be notified by email and the payment will be refunded.</small>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn btn-danger"><i class="fa-solid fa-ban me-1"></i>Reject & Refund</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                    <c:if test="${order.status == 'Confirmed'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View/Sign Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="startRental">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-sm btn-info rounded-pill px-3 text-white" title="Start Rental">
                                                <i class="fa-solid fa-motorcycle me-1"></i>Start
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;" onsubmit="return confirm('Cancel this order? Amount will be refunded.')">
                                            <input type="hidden" name="action" value="cancelOrder">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Cancel">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${order.status == 'Renting'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <span class="badge bg-info text-dark">Awaiting receipt</span>
                                    </c:if>
                                    <c:if test="${order.status == 'Received'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-warning rounded-pill px-3" title="Inspect Return">
                                            <i class="fa-solid fa-magnifying-glass me-1"></i>Inspect
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status == 'Returned'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-outline-info rounded-pill px-2" title="View Inspection">
                                            <i class="fa-solid fa-clipboard-check me-1"></i>Inspection
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status == 'Fined'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-outline-danger rounded-pill px-2" title="View Fine">
                                            <i class="fa-solid fa-gavel me-1"></i>Fine
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status == 'Completed'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="View Contract">
                                            <i class="fa-solid fa-file-contract me-1"></i>Contract
                                        </a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-outline-success rounded-pill px-2" title="View Inspection">
                                            <i class="fa-solid fa-clipboard-check me-1"></i>Inspection
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status == 'Cancelled'}">
                                        <span class="text-muted small">No action</span>
                                    </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty orders}">
                            <tr><td colspan="7" class="text-center text-muted py-4">No orders found.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-3">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/staff?action=dashboard${not empty statusFilter ? '&status='.concat(statusFilter) : ''}&page=${currentPage - 1}">&laquo;</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/staff?action=dashboard${not empty statusFilter ? '&status='.concat(statusFilter) : ''}&page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/staff?action=dashboard${not empty statusFilter ? '&status='.concat(statusFilter) : ''}&page=${currentPage + 1}">&raquo;</a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
