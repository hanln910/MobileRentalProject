<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Overdue Orders - Staff - MotoRent</title>
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
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/staff?action=overdueOrders"><i class="fa-solid fa-clock text-danger"></i> Overdue</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <h2 class="fw-bold pt-3 pb-2 mb-4 border-bottom">
                    <i class="fa-solid fa-clock text-danger me-2"></i>Overdue Rentals
                </h2>

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

                <c:choose>
                    <c:when test="${empty overdueOrders}">
                        <div class="card border-0 shadow-sm p-5 text-center">
                            <i class="fa-solid fa-circle-check text-success" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">No Overdue Rentals</h4>
                            <p class="text-muted">All current rentals are within their return dates.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-0 shadow-sm p-4">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Customer</th>
                                            <th>Motorbike</th>
                                            <th>Overdue Days</th>
                                            <th>Penalty ($10/day)</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${overdueOrders}">
                                            <tr>
                                                <td class="fw-semibold">#ORD-<fmt:formatNumber value="${item.orderId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                                <td>${item.customerName}</td>
                                                <td>${item.motorbikeName}</td>
                                                <td><span class="badge bg-danger fs-6">${item.overdueDays} days</span></td>
                                                <td class="fw-bold text-danger">$<fmt:formatNumber value="${item.totalPenalty}" maxFractionDigits="2"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status == 'Pending'}"><span class="badge bg-warning text-dark">Penalty Pending</span></c:when>
                                                        <c:when test="${item.status == 'Paid'}"><span class="badge bg-success">Paid</span></c:when>
                                                        <c:when test="${item.status == 'Waived'}"><span class="badge bg-secondary">Waived</span></c:when>
                                                        <c:otherwise><span class="badge bg-outline-secondary text-dark">Not Issued</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="d-flex gap-1 flex-wrap">
                                                        <c:if test="${empty item.status || item.status == 'Pending'}">
                                                            <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="issueOverdueWarning">
                                                                <input type="hidden" name="orderId" value="${item.orderId}">
                                                                <button type="submit" class="btn btn-sm btn-danger rounded-pill px-3"
                                                                        onclick="return confirm('Issue/update overdue warning and email customer?')">
                                                                    <i class="fa-solid fa-triangle-exclamation me-1"></i>Warn
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${item.status == 'Pending'}">
                                                            <form action="${pageContext.request.contextPath}/staff" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="waiveOverduePenalty">
                                                                <input type="hidden" name="orderId" value="${item.orderId}">
                                                                <button type="submit" class="btn btn-sm btn-outline-info rounded-pill px-3"
                                                                        onclick="return confirm('Waive this overdue penalty?')">
                                                                    <i class="fa-solid fa-hand-holding-dollar me-1"></i>Waive
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
