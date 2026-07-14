<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - Admin - MotoRent</title>
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
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageUsers"><i class="fa-solid fa-users"></i> Users</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageMotorbikes"><i class="fa-solid fa-motorcycle"></i> Motorbikes</a></li>
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageCategories"><i class="fa-solid fa-tags"></i> Categories</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageBrands"><i class="fa-solid fa-copyright"></i> Brands</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageComplaints"><i class="fa-solid fa-flag"></i> Complaints</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <h1 class="h2 fw-bold pt-3 pb-2 mb-4 border-bottom">Manage Orders</h1>

                <div class="card border-0 shadow-sm p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Order ID</th>
                                    <th>Customer</th>
                                    <th>Motorbike</th>
                                    <th>Rental Period</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Order Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${orders}">
                                    <tr>
                                        <td class="fw-semibold">#ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                        <td>
                                            <h6 class="mb-0 fw-bold">${order.customerName}</h6>
                                            <small class="text-muted">${order.customerEmail}</small><br>
                                            <small class="text-muted">${order.customerPhone}</small>
                                        </td>
                                        <td>
                                            <c:if test="${not empty order.orderDetails}">
                                                <div class="d-flex align-items-center">
                                                    <img src="${order.orderDetails[0].motorbikeImage}" class="rounded me-2" width="50" height="38" style="object-fit: cover;" alt="Bike">
                                                    <div>
                                                        <span class="fw-semibold">${order.orderDetails[0].motorbikeName}</span><br>
                                                        <small class="text-muted">${order.orderDetails[0].brandName} - ${order.orderDetails[0].categoryName}</small>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty order.orderDetails}">
                                                <fmt:formatDate value="${order.orderDetails[0].rentalDate}" pattern="MM/dd/yyyy"/> -
                                                <fmt:formatDate value="${order.orderDetails[0].returnDate}" pattern="MM/dd/yyyy"/>
                                                <br><small class="text-muted">${order.orderDetails[0].totalDays} day(s)</small>
                                            </c:if>
                                        </td>
                                        <td class="fw-bold text-primary">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></td>
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
                                        <td><small><fmt:formatDate value="${order.orderDate}" pattern="MM/dd/yyyy HH:mm"/></small></td>
                                        <td>
                                            <c:if test="${order.status != 'Pending' && order.status != 'Cancelled'}">
                                                <a href="${pageContext.request.contextPath}/admin?action=viewContract&orderId=${order.orderId}" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="fa-solid fa-file-contract me-1"></i>Contract</a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty orders}">
                                    <tr><td colspan="8" class="text-center text-muted py-4">No orders found.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
