<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Rentals - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg sticky-top bg-white border-bottom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</a>
            <div class="d-flex align-items-center">
                <div class="dropdown">
                    <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" width="36" height="36" class="rounded-circle me-2" alt="User">
                        <span class="fw-semibold">${sessionScope.user.fullName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                        <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/orders?action=dashboard"><i class="fa-solid fa-chart-pie me-2"></i>Dashboard</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <form action="${pageContext.request.contextPath}/auth?action=logout" method="post" style="display: inline">
                                <input type="hidden" name="action" value="logout">
                                <button type="submit" class="dropdown-item py-2 text-danger boder-0 bg- transparent">
                                    <i class="fa-solid fa-arrow-right-from-bracket me-2">Logout</i>
                                </button>
                            </form>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1">My Rental History</h2>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/orders?action=dashboard" class="text-decoration-none">Dashboard</a></li>
                        <li class="breadcrumb-item active">My Rentals</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-primary rounded-pill px-4"><i class="fa-solid fa-plus me-2"></i>New Rental</a>
        </div>

        <c:forEach var="order" items="${orders}">
            <div class="card border-0 shadow-sm mb-4 p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0">#ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></h5>
                    <c:choose>
                        <c:when test="${order.status == 'Pending'}"><span class="badge bg-warning text-dark px-3 py-2">Pending</span></c:when>
                        <c:when test="${order.status == 'Confirmed'}"><span class="badge bg-primary px-3 py-2">Confirmed</span></c:when>
                        <c:when test="${order.status == 'Renting'}"><span class="badge bg-info text-dark px-3 py-2">Renting</span></c:when>
                        <c:when test="${order.status == 'Received'}"><span class="badge px-3 py-2" style="background-color: #0dcaf0;">Received</span></c:when>
                        <c:when test="${order.status == 'Returned'}"><span class="badge bg-success px-3 py-2">Returned</span></c:when>
                        <c:when test="${order.status == 'Fined'}"><span class="badge bg-danger px-3 py-2"><i class="fa-solid fa-gavel me-1"></i>Fined</span></c:when>
                        <c:when test="${order.status == 'Completed'}"><span class="badge bg-success px-3 py-2">Completed</span></c:when>
                        <c:when test="${order.status == 'Cancelled'}"><span class="badge bg-danger px-3 py-2">Cancelled</span></c:when>
                    </c:choose>
                </div>
                <c:forEach var="detail" items="${order.orderDetails}">
                    <div class="d-flex align-items-center">
                        <img src="${detail.motorbikeImage}" class="rounded me-4" width="120" height="90" style="object-fit: cover;" alt="Bike">
                        <div class="flex-grow-1">
                            <h5 class="fw-bold mb-1">${detail.brandName} ${detail.motorbikeName}</h5>
                            <p class="text-muted mb-1"><i class="fa-regular fa-calendar me-2"></i><fmt:formatDate value="${detail.rentalDate}" pattern="MMM dd, yyyy"/> - <fmt:formatDate value="${detail.returnDate}" pattern="MMM dd, yyyy"/> (${detail.totalDays} days)</p>
                            <p class="text-muted mb-0"><i class="fa-solid fa-tag me-2"></i>$<fmt:formatNumber value="${detail.pricePerDay}" maxFractionDigits="2"/>/day</p>
                        </div>
                        <div class="text-end">
                            <h4 class="fw-bold text-primary mb-2">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></h4>
                            <c:if test="${order.status == 'Pending'}">
                                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Cancel this order? Amount will be refunded to your wallet.')">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3">Cancel Order</button>
                                </form>
                            </c:if>
                            <c:if test="${order.status == 'Confirmed'}">
                                <a href="${pageContext.request.contextPath}/orders?action=contract&orderId=${order.orderId}" class="btn btn-sm btn-outline-primary rounded-pill px-3"><i class="fa-solid fa-file-contract me-1"></i>Sign Contract</a>
                            </c:if>
                            <c:if test="${order.status == 'Renting'}">
                                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Confirm you have received the motorbike?')">
                                    <input type="hidden" name="action" value="received">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn btn-sm btn-info rounded-pill px-3 text-white"><i class="fa-solid fa-hand-holding me-1"></i>Confirm Received</button>
                                </form>
                            </c:if>
                            <c:if test="${order.status == 'Received'}">
                                <a href="${pageContext.request.contextPath}/orders?action=returnInspection&orderId=${order.orderId}" class="btn btn-sm btn-outline-warning rounded-pill px-3"><i class="fa-solid fa-camera me-1"></i>Return Evidence</a>
                            </c:if>
                            <c:if test="${order.status == 'Returned' || order.status == 'Fined' || order.status == 'Completed'}">
                                <a href="${pageContext.request.contextPath}/orders?action=returnInspection&orderId=${order.orderId}" class="btn btn-sm btn-outline-success rounded-pill px-3"><i class="fa-solid fa-clipboard-check me-1"></i>View Return</a>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${order.status == 'Cancelled' && not empty order.rejectReason}">
                    <div class="mt-3 alert alert-danger mb-0 py-2">
                        <i class="fa-solid fa-ban me-1"></i><strong>Rejection Reason:</strong> ${order.rejectReason}
                    </div>
                </c:if>
                <div class="mt-3 pt-3 border-top text-muted small">
                    <i class="fa-regular fa-clock me-1"></i>Ordered on <fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy 'at' HH:mm"/>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty orders}">
            <div class="text-center py-5">
                <i class="fa-solid fa-motorcycle text-muted" style="font-size: 64px;"></i>
                <h3 class="mt-4 text-muted">No rentals yet</h3>
                <p class="text-muted">Start exploring our motorbikes and book your first ride!</p>
                <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-primary rounded-pill px-5">Browse Motorbikes</a>
            </div>
        </c:if>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav class="mt-4">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/orders?action=history&page=${currentPage - 1}">&laquo;</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/orders?action=history&page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/orders?action=history&page=${currentPage + 1}">&raquo;</a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
