<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inspect Return - MotoRent Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg sticky-top bg-white border-bottom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-motorcycle me-2"></i>MotoRent</a>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/staff?action=dashboard" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard</a>
            </div>
        </div>
    </nav>

    <div class="container py-5" style="max-width: 1000px;">
        <!-- Alerts -->
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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1"><i class="fa-solid fa-magnifying-glass text-primary me-2"></i>Inspect Return</h2>
                <p class="text-muted mb-0">Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/>
                    — Customer: <strong>${order.customerName}</strong></p>
            </div>
            <c:if test="${not empty inspection}">
                <span class="badge ${inspection.condition == 'Good' ? 'bg-success' : inspection.condition == 'Damaged' ? 'bg-danger' : 'bg-warning text-dark'} px-3 py-2 fs-6">
                    ${inspection.condition}
                </span>
            </c:if>
        </div>

        <!-- Order Summary -->
        <div class="card border-0 shadow-sm p-4 mb-4">
            <h5 class="fw-bold mb-3">Order Summary</h5>
            <c:if test="${not empty order.orderDetails}">
                <c:set var="detail" value="${order.orderDetails[0]}"/>
                <div class="row">
                    <div class="col-md-4">
                        <p class="mb-1"><strong>Motorbike:</strong> ${detail.brandName} ${detail.motorbikeName}</p>
                        <p class="mb-1"><strong>Total:</strong> $<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></p>
                    </div>
                    <div class="col-md-4">
                        <p class="mb-1"><strong>Rental:</strong> <fmt:formatDate value="${detail.rentalDate}" pattern="MM/dd"/> - <fmt:formatDate value="${detail.returnDate}" pattern="MM/dd/yyyy"/></p>
                        <p class="mb-1"><strong>Duration:</strong> ${detail.totalDays} day(s)</p>
                    </div>
                    <div class="col-md-4">
                        <p class="mb-1"><strong>Customer:</strong> ${order.customerName}</p>
                        <p class="mb-1"><strong>Email:</strong> ${order.customerEmail}</p>
                    </div>
                </div>
            </c:if>
        </div>

        <c:if test="${not empty inspection}">
            <!-- Customer Evidence -->
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3"><i class="fa-solid fa-images text-info me-2"></i>Customer Evidence</h5>
                <div class="row g-3">
                    <c:if test="${not empty inspection.photoUrl1}">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small text-muted">Photo 1 - Front View</label>
                            <a href="${inspection.photoUrl1}" target="_blank">
                                <img src="${inspection.photoUrl1}" class="img-fluid rounded border" alt="Photo 1" style="max-height: 250px; object-fit: cover; width: 100%;">
                            </a>
                        </div>
                    </c:if>
                    <c:if test="${not empty inspection.photoUrl2}">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small text-muted">Photo 2 - Side View</label>
                            <a href="${inspection.photoUrl2}" target="_blank">
                                <img src="${inspection.photoUrl2}" class="img-fluid rounded border" alt="Photo 2" style="max-height: 250px; object-fit: cover; width: 100%;">
                            </a>
                        </div>
                    </c:if>
                    <c:if test="${not empty inspection.photoUrl3}">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small text-muted">Photo 3</label>
                            <a href="${inspection.photoUrl3}" target="_blank">
                                <img src="${inspection.photoUrl3}" class="img-fluid rounded border" alt="Photo 3" style="max-height: 250px; object-fit: cover; width: 100%;">
                            </a>
                        </div>
                    </c:if>
                </div>
                <c:if test="${not empty inspection.videoUrl}">
                    <div class="mt-3">
                        <a href="${inspection.videoUrl}" target="_blank" class="btn btn-sm btn-outline-info rounded-pill">
                            <i class="fa-solid fa-video me-1"></i>View Video
                        </a>
                    </div>
                </c:if>
                <c:if test="${not empty inspection.customerNotes}">
                    <div class="mt-3 p-3 bg-light rounded">
                        <label class="form-label fw-semibold small text-muted">Customer Notes</label>
                        <p class="mb-0">${inspection.customerNotes}</p>
                    </div>
                </c:if>
                <div class="mt-2">
                    <small class="text-muted">Submitted: <fmt:formatDate value="${inspection.submittedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                </div>
            </div>

            <!-- Staff Action Section -->
            <c:if test="${inspection.condition == 'Pending'}">
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-gavel text-warning me-2"></i>Your Decision</h5>

                    <!-- Approve -->
                    <div class="p-3 border border-success rounded mb-3 bg-success bg-opacity-10">
                        <h6 class="fw-bold text-success"><i class="fa-solid fa-check-circle me-1"></i> Approve - No Damage</h6>
                        <form action="${pageContext.request.contextPath}/staff" method="POST">
                            <input type="hidden" name="action" value="approveReturn">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <div class="mb-2">
                                <textarea name="staffNotes" class="form-control" rows="2" placeholder="Optional notes..."></textarea>
                            </div>
                            <button type="submit" class="btn btn-success rounded-pill px-4" onclick="return confirm('Approve return? Order will be marked as Returned and customer will receive a thank-you email.')">
                                <i class="fa-solid fa-check me-1"></i>Approve Return
                            </button>
                        </form>
                    </div>

                    <!-- Issue Fine -->
                    <div class="p-3 border border-danger rounded bg-danger bg-opacity-10">
                        <h6 class="fw-bold text-danger"><i class="fa-solid fa-triangle-exclamation me-1"></i> Damage Found - Issue Fine</h6>
                        <form action="${pageContext.request.contextPath}/staff" method="POST">
                            <input type="hidden" name="action" value="issueFine">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <div class="row g-2 mb-2">
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold small">Fine Amount ($) *</label>
                                    <input type="number" name="fineAmount" class="form-control" step="0.01" min="0.01" required placeholder="e.g. 50.00">
                                </div>
                                <div class="col-md-8">
                                    <label class="form-label fw-semibold small">Fine Reason *</label>
                                    <input type="text" name="fineReason" class="form-control" required placeholder="e.g. Scratched left panel, broken mirror">
                                </div>
                            </div>
                            <div class="mb-2">
                                <label class="form-label fw-semibold small">Staff Notes</label>
                                <textarea name="staffNotes" class="form-control" rows="2" placeholder="Detailed inspection notes..."></textarea>
                            </div>
                            <button type="submit" class="btn btn-danger rounded-pill px-4" onclick="return confirm('Issue a damage fine? Customer will be notified by email and must pay within 48 hours.')">
                                <i class="fa-solid fa-gavel me-1"></i>Issue Fine
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>

            <!-- Already Reviewed -->
            <c:if test="${inspection.condition != 'Pending'}">
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-clipboard-check text-primary me-2"></i>Inspection Result</h5>
                    <c:if test="${inspection.condition == 'Good'}">
                        <div class="alert alert-success mb-0">
                            <i class="fa-solid fa-check-circle me-2"></i><strong>Approved</strong> - No damage found.
                            <c:if test="${not empty inspection.staffNotes}"><br>Notes: ${inspection.staffNotes}</c:if>
                            <br><small class="text-muted">Reviewed: <fmt:formatDate value="${inspection.reviewedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                        </div>
                    </c:if>
                    <c:if test="${inspection.condition == 'Damaged'}">
                        <div class="alert alert-danger mb-3">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Damaged</strong>
                            <c:if test="${not empty inspection.staffNotes}"><br>Notes: ${inspection.staffNotes}</c:if>
                            <br><small class="text-muted">Reviewed: <fmt:formatDate value="${inspection.reviewedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                        </div>
                        <div class="bg-light p-3 rounded mb-3">
                            <p class="mb-1"><strong>Fine:</strong> $<fmt:formatNumber value="${inspection.fineAmount}" maxFractionDigits="2"/></p>
                            <p class="mb-1"><strong>Reason:</strong> ${inspection.fineReason}</p>
                            <p class="mb-1"><strong>Status:</strong>
                                <c:choose>
                                    <c:when test="${inspection.fineStatus == 'Pending'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                                    <c:when test="${inspection.fineStatus == 'Paid'}"><span class="badge bg-success">Paid</span></c:when>
                                    <c:when test="${inspection.fineStatus == 'Overdue'}"><span class="badge bg-danger">Overdue</span></c:when>
                                    <c:when test="${inspection.fineStatus == 'Waived'}"><span class="badge bg-secondary">Waived</span></c:when>
                                </c:choose>
                            </p>
                            <c:if test="${not empty inspection.fineDeadline}">
                                <p class="mb-0"><strong>Deadline:</strong> <fmt:formatDate value="${inspection.fineDeadline}" pattern="MMM dd, yyyy HH:mm"/></p>
                            </c:if>
                        </div>
                        <!-- Waive Fine Button (only if fine is Pending or Overdue) -->
                        <c:if test="${inspection.fineStatus == 'Pending' || inspection.fineStatus == 'Overdue' || inspection.fineStatus == 'Paid'}">
                            <div class="p-3 border border-info rounded bg-info bg-opacity-10">
                                <h6 class="fw-bold text-info"><i class="fa-solid fa-hand-holding-dollar me-1"></i> Waive Fine</h6>
                                <p class="text-muted small mb-2">Waive this fine (e.g. after complaint review). Customer will be notified by email.
                                    <c:if test="${inspection.fineStatus == 'Paid'}"><br><strong class="text-warning">Note:</strong> Fine was already paid — amount will be refunded to customer wallet.</c:if>
                                </p>
                                <form action="${pageContext.request.contextPath}/staff" method="POST">
                                    <input type="hidden" name="action" value="waiveFine">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn btn-info text-white rounded-pill px-4"
                                            onclick="return confirm('Are you sure you want to waive this fine? This action cannot be undone.')">
                                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>Waive Fine
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </c:if>
                </div>
            </c:if>
        </c:if>

        <c:if test="${empty inspection}">
            <div class="alert alert-info">
                <i class="fa-solid fa-info-circle me-2"></i>Customer has not yet submitted return evidence for this order.
            </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
