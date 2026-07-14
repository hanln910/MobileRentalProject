<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Complaints - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <%@ include file="/views/components/navbar.jsp" %>

    <div class="container py-5" style="max-width: 900px;">
        <!-- Alerts -->
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

        <h2 class="fw-bold mb-4"><i class="fa-solid fa-flag text-warning me-2"></i>File a Complaint</h2>

        <!-- Complaint Form -->
        <c:if test="${not empty order}">
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3">Complaint for Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></h5>
                <form action="${pageContext.request.contextPath}/orders" method="POST">
                    <input type="hidden" name="action" value="submitComplaint">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Subject *</label>
                        <input type="text" name="subject" class="form-control" required placeholder="e.g. Unfair damage fine, Service complaint">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description *</label>
                        <textarea name="description" class="form-control" rows="5" required placeholder="Please describe your complaint in detail. Include any evidence or reasoning..."></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning rounded-pill px-4 fw-semibold">
                        <i class="fa-solid fa-paper-plane me-2"></i>Submit Complaint
                    </button>
                    <a href="${pageContext.request.contextPath}/orders?action=returnInspection&orderId=${order.orderId}" class="btn btn-outline-secondary rounded-pill px-4 ms-2">Cancel</a>
                </form>
            </div>
        </c:if>

        <!-- My Complaints List -->
        <c:if test="${not empty complaints}">
            <h4 class="fw-bold mb-3 mt-5"><i class="fa-solid fa-list me-2"></i>My Complaints</h4>
            <c:forEach var="c" items="${complaints}">
                <div class="card border-0 shadow-sm p-4 mb-3">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div>
                            <h6 class="fw-bold mb-1">${c.subject}</h6>
                            <small class="text-muted">Order #ORD-<fmt:formatNumber value="${c.orderId}" minIntegerDigits="4" groupingUsed="false"/> • <fmt:formatDate value="${c.createdAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                        </div>
                        <c:choose>
                            <c:when test="${c.status == 'Open'}"><span class="badge bg-warning text-dark">${c.status}</span></c:when>
                            <c:when test="${c.status == 'InProgress'}"><span class="badge bg-info text-dark">In Progress</span></c:when>
                            <c:when test="${c.status == 'Resolved'}"><span class="badge bg-success">${c.status}</span></c:when>
                            <c:when test="${c.status == 'Rejected'}"><span class="badge bg-danger">${c.status}</span></c:when>
                        </c:choose>
                    </div>
                    <p class="mb-2">${c.description}</p>
                    <c:if test="${not empty c.adminResponse}">
                        <div class="bg-light p-3 rounded mt-2">
                            <small class="fw-bold text-primary"><i class="fa-solid fa-reply me-1"></i>Admin Response:</small>
                            <p class="mb-0 mt-1">${c.adminResponse}</p>
                            <c:if test="${not empty c.resolvedByName}">
                                <small class="text-muted">By ${c.resolvedByName} • <fmt:formatDate value="${c.resolvedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                            </c:if>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
