<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - Staff - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
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
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=dashboard"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=overdueOrders"><i class="fa-solid fa-clock text-danger"></i> Overdue</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <h2 class="fw-bold pt-3 pb-2 mb-4 border-bottom">All Orders</h2>
        <div class="card border-0 shadow-sm p-4">
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
                                <td>${order.customerName}<br><small class="text-muted">${order.customerPhone}</small></td>
                                <td>
                                    <c:if test="${not empty order.orderDetails}">
                                        ${order.orderDetails[0].brandName} ${order.orderDetails[0].motorbikeName}
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${not empty order.orderDetails}">
                                        <small><fmt:formatDate value="${order.orderDetails[0].rentalDate}" pattern="MM/dd/yy"/> - <fmt:formatDate value="${order.orderDetails[0].returnDate}" pattern="MM/dd/yy"/></small>
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
                                            <input type="hidden" name="action" value="confirm"><input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-sm btn-primary rounded-pill">Confirm</button>
                                        </form>
                                        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill" data-bs-toggle="modal" data-bs-target="#rejectModalO${order.orderId}"><i class="fa-solid fa-ban me-1"></i>Reject</button>
                                        <div class="modal fade" id="rejectModalO${order.orderId}" tabindex="-1">
                                            <div class="modal-dialog"><div class="modal-content">
                                                <form action="${pageContext.request.contextPath}/staff" method="POST">
                                                    <input type="hidden" name="action" value="rejectOrder"><input type="hidden" name="orderId" value="${order.orderId}">
                                                    <div class="modal-header"><h5 class="modal-title">Reject Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                                    <div class="modal-body"><label class="form-label fw-semibold">Reason *</label><textarea name="rejectReason" class="form-control" rows="3" required placeholder="Reason for rejection..."></textarea></div>
                                                    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-danger">Reject & Refund</button></div>
                                                </form>
                                            </div></div>
                                        </div>
                                    </c:if>
                                    <c:if test="${order.status == 'Confirmed'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                        <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="startRental"><input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-sm btn-info rounded-pill text-white">Start</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${order.status == 'Renting'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                    </c:if>
                                    <c:if test="${order.status == 'Received'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-warning rounded-pill"><i class="fa-solid fa-magnifying-glass me-1"></i>Inspect</a>
                                    </c:if>
                                    <c:if test="${order.status == 'Returned'}">
                                        <a href="${pageContext.request.contextPath}/staff?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                        <a href="${pageContext.request.contextPath}/staff?action=inspectReturn&orderId=${order.orderId}" class="btn btn-sm btn-outline-info rounded-pill"><i class="fa-solid fa-clipboard-check me-1"></i>Inspection</a>
                                    </c:if>
                                    <c:if test="${order.status == 'Cancelled'}">
                                        <span class="text-muted small">-</span>
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
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav class="mt-4">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/staff?action=orders&page=${currentPage - 1}">&laquo;</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/staff?action=orders&page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/staff?action=orders&page=${currentPage + 1}">&raquo;</a>
                    </li>
                </ul>
            </nav>
        </c:if>
            </main>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
