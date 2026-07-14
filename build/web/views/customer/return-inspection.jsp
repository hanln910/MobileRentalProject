<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Inspection - MotoRent</title>
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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1"><i class="fa-solid fa-clipboard-check text-primary me-2"></i>Return Inspection</h2>
                <p class="text-muted mb-0">Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></p>
            </div>
            <a href="${pageContext.request.contextPath}/orders?action=history" class="btn btn-outline-secondary btn-sm rounded-pill">
                <i class="fa-solid fa-arrow-left me-1"></i> Back to Orders
            </a>
        </div>

        <!-- Order Summary -->
        <div class="card border-0 shadow-sm p-4 mb-4">
            <h5 class="fw-bold mb-3">Order Summary</h5>
            <c:if test="${not empty order.orderDetails}">
                <c:set var="detail" value="${order.orderDetails[0]}"/>
                <div class="row">
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Motorbike:</strong> ${detail.brandName} ${detail.motorbikeName}</p>
                        <p class="mb-1"><strong>Rental Date:</strong> <fmt:formatDate value="${detail.rentalDate}" pattern="MMM dd, yyyy"/></p>
                        <p class="mb-1"><strong>Return Date:</strong> <fmt:formatDate value="${detail.returnDate}" pattern="MMM dd, yyyy"/></p>
                    </div>
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Duration:</strong> ${detail.totalDays} day(s)</p>
                        <p class="mb-1"><strong>Total Amount:</strong> <span class="text-primary fw-bold">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></span></p>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Overdue Penalty Alert -->
        <c:if test="${not empty overduePenalty && overduePenalty.status == 'Pending'}">
            <div class="card border-0 shadow-sm p-4 mb-4 border-start border-danger border-4">
                <div class="d-flex align-items-center mb-3">
                    <i class="fa-solid fa-triangle-exclamation text-danger fs-3 me-3"></i>
                    <div>
                        <h5 class="fw-bold text-danger mb-0">Overdue Penalty</h5>
                        <p class="text-muted mb-0">Your rental is <strong>${overduePenalty.overdueDays} day(s) overdue</strong>. A penalty has been applied.</p>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-4"><strong>Daily Rate:</strong> $<fmt:formatNumber value="${overduePenalty.dailyRate}" maxFractionDigits="2"/></div>
                    <div class="col-md-4"><strong>Overdue Days:</strong> ${overduePenalty.overdueDays}</div>
                    <div class="col-md-4"><strong>Total Penalty:</strong> <span class="text-danger fw-bold fs-5">$<fmt:formatNumber value="${overduePenalty.totalPenalty}" maxFractionDigits="2"/></span></div>
                </div>
                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;"
                      onsubmit="return confirm('Pay overdue penalty of $${overduePenalty.totalPenalty} from your wallet?')">
                    <input type="hidden" name="action" value="payOverduePenalty">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <button type="submit" class="btn btn-danger rounded-pill px-4 fw-semibold">
                        <i class="fa-solid fa-wallet me-2"></i>Pay Penalty ($<fmt:formatNumber value="${overduePenalty.totalPenalty}" maxFractionDigits="2"/>)
                    </button>
                </form>
            </div>
        </c:if>
        <c:if test="${not empty overduePenalty && overduePenalty.status == 'Paid'}">
            <div class="alert alert-success"><i class="fa-solid fa-circle-check me-2"></i>Overdue penalty of $<fmt:formatNumber value="${overduePenalty.totalPenalty}" maxFractionDigits="2"/> has been paid.</div>
        </c:if>
        <c:if test="${not empty overduePenalty && overduePenalty.status == 'Waived'}">
            <div class="alert alert-info"><i class="fa-solid fa-hand-holding-dollar me-2"></i>Overdue penalty has been waived by staff.</div>
        </c:if>

        <c:choose>
            <%-- No inspection submitted yet: show upload form --%>
            <c:when test="${empty inspection}">
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-camera text-warning me-2"></i>Submit Return Evidence</h5>
                    <p class="text-muted mb-4">Please provide photos and optionally a video of the motorbike's current condition. This is required for the return process.</p>

                    <form action="${pageContext.request.contextPath}/orders" method="POST">
                        <input type="hidden" name="action" value="submitReturnEvidence">
                        <input type="hidden" name="orderId" value="${order.orderId}">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Photo 1 (URL) - Front View *</label>
                                <input type="url" name="photoUrl1" class="form-control" placeholder="https://example.com/photo1.jpg" required>
                                <small class="text-muted">Upload your photo to an image host and paste the URL here</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Photo 2 (URL) - Side View *</label>
                                <input type="url" name="photoUrl2" class="form-control" placeholder="https://example.com/photo2.jpg" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Photo 3 (URL) - Any Damage (Optional)</label>
                                <input type="url" name="photoUrl3" class="form-control" placeholder="https://example.com/photo3.jpg">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Video (URL) - Walk-around (Optional)</label>
                                <input type="url" name="videoUrl" class="form-control" placeholder="https://youtube.com/watch?v=...">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Notes about the bike's condition</label>
                                <textarea name="customerNotes" class="form-control" rows="3" placeholder="Describe the current condition of the motorbike..."></textarea>
                            </div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary rounded-pill px-5 fw-semibold" onclick="return confirm('Submit return evidence? Staff will review and process your return.')">
                                <i class="fa-solid fa-paper-plane me-2"></i>Submit Return Evidence
                            </button>
                        </div>
                    </form>
                </div>
            </c:when>

            <%-- Inspection submitted: show status --%>
            <c:otherwise>
                <!-- Submitted Evidence -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-images text-info me-2"></i>Submitted Evidence</h5>
                    <div class="row g-3">
                        <c:if test="${not empty inspection.photoUrl1}">
                            <div class="col-md-4">
                                <label class="form-label fw-semibold small text-muted">Photo 1 - Front View</label>
                                <img src="${inspection.photoUrl1}" class="img-fluid rounded border" alt="Photo 1" style="max-height: 200px; object-fit: cover; width: 100%;">
                            </div>
                        </c:if>
                        <c:if test="${not empty inspection.photoUrl2}">
                            <div class="col-md-4">
                                <label class="form-label fw-semibold small text-muted">Photo 2 - Side View</label>
                                <img src="${inspection.photoUrl2}" class="img-fluid rounded border" alt="Photo 2" style="max-height: 200px; object-fit: cover; width: 100%;">
                            </div>
                        </c:if>
                        <c:if test="${not empty inspection.photoUrl3}">
                            <div class="col-md-4">
                                <label class="form-label fw-semibold small text-muted">Photo 3</label>
                                <img src="${inspection.photoUrl3}" class="img-fluid rounded border" alt="Photo 3" style="max-height: 200px; object-fit: cover; width: 100%;">
                            </div>
                        </c:if>
                    </div>
                    <c:if test="${not empty inspection.videoUrl}">
                        <div class="mt-3">
                            <label class="form-label fw-semibold small text-muted">Video</label>
                            <a href="${inspection.videoUrl}" target="_blank" class="btn btn-sm btn-outline-info rounded-pill">
                                <i class="fa-solid fa-video me-1"></i>View Video
                            </a>
                        </div>
                    </c:if>
                    <c:if test="${not empty inspection.customerNotes}">
                        <div class="mt-3">
                            <label class="form-label fw-semibold small text-muted">Your Notes</label>
                            <p class="mb-0">${inspection.customerNotes}</p>
                        </div>
                    </c:if>
                    <div class="mt-3">
                        <small class="text-muted">Submitted: <fmt:formatDate value="${inspection.submittedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                    </div>
                </div>

                <!-- Inspection Status -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-magnifying-glass text-primary me-2"></i>Inspection Status</h5>
                    <c:choose>
                        <c:when test="${inspection.condition == 'Pending'}">
                            <div class="alert alert-warning mb-0">
                                <i class="fa-solid fa-hourglass-half me-2"></i>
                                <strong>Pending Review</strong> - Staff is reviewing your submitted evidence. You will be notified once the inspection is complete.
                            </div>
                        </c:when>
                        <c:when test="${inspection.condition == 'Good'}">
                            <div class="alert alert-success mb-0">
                                <i class="fa-solid fa-circle-check me-2"></i>
                                <strong>Approved!</strong> - The motorbike has been returned in good condition. Thank you!
                                <c:if test="${not empty inspection.staffNotes}">
                                    <br><small class="text-muted">Staff notes: ${inspection.staffNotes}</small>
                                </c:if>
                            </div>
                        </c:when>
                        <c:when test="${inspection.condition == 'Damaged'}">
                            <div class="alert alert-danger mb-3">
                                <i class="fa-solid fa-triangle-exclamation me-2"></i>
                                <strong>Damage Detected</strong>
                                <c:if test="${not empty inspection.staffNotes}">
                                    <br>Staff notes: ${inspection.staffNotes}
                                </c:if>
                            </div>

                            <!-- Fine Details -->
                            <div class="bg-light p-4 rounded">
                                <h6 class="fw-bold mb-3"><i class="fa-solid fa-money-bill-wave text-danger me-2"></i>Fine Details</h6>
                                <div class="row">
                                    <div class="col-md-6">
                                        <p class="mb-1"><strong>Fine Amount:</strong> <span class="text-danger fw-bold fs-5">$<fmt:formatNumber value="${inspection.fineAmount}" maxFractionDigits="2"/></span></p>
                                        <p class="mb-1"><strong>Reason:</strong> ${inspection.fineReason}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="mb-1"><strong>Status:</strong>
                                            <c:choose>
                                                <c:when test="${inspection.fineStatus == 'Pending'}"><span class="badge bg-warning text-dark">Pending Payment</span></c:when>
                                                <c:when test="${inspection.fineStatus == 'Paid'}"><span class="badge bg-success">Paid</span></c:when>
                                                <c:when test="${inspection.fineStatus == 'Overdue'}"><span class="badge bg-danger">Overdue - Account may be locked!</span></c:when>
                                                <c:when test="${inspection.fineStatus == 'Waived'}"><span class="badge bg-secondary">Waived</span></c:when>
                                            </c:choose>
                                        </p>
                                        <c:if test="${not empty inspection.fineDeadline}">
                                            <p class="mb-1"><strong>Deadline:</strong> <span class="text-danger"><fmt:formatDate value="${inspection.fineDeadline}" pattern="MMM dd, yyyy HH:mm"/></span></p>
                                        </c:if>
                                        <c:if test="${not empty inspection.finePaidAt}">
                                            <p class="mb-1"><strong>Paid at:</strong> <fmt:formatDate value="${inspection.finePaidAt}" pattern="MMM dd, yyyy HH:mm"/></p>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- Pay Fine Button -->
                                <c:if test="${inspection.fineStatus == 'Pending' || inspection.fineStatus == 'Overdue'}">
                                    <div class="mt-3">
                                        <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Pay fine of $${inspection.fineAmount} from your wallet?')">
                                            <input type="hidden" name="action" value="payFine">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-danger rounded-pill px-4 fw-semibold">
                                                <i class="fa-solid fa-wallet me-2"></i>Pay Fine ($<fmt:formatNumber value="${inspection.fineAmount}" maxFractionDigits="2"/>)
                                            </button>
                                        </form>
                                        <a href="${pageContext.request.contextPath}/orders?action=complaint&orderId=${order.orderId}" class="btn btn-outline-warning rounded-pill px-4 ms-2">
                                            <i class="fa-solid fa-flag me-1"></i>File Complaint
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </c:when>
                    </c:choose>
                </div>

                <!-- Review Section (only if completed without issues or fine paid) -->
                <c:if test="${(inspection.condition == 'Good') || (inspection.condition == 'Damaged' && (inspection.fineStatus == 'Paid' || inspection.fineStatus == 'Waived'))}">
                    <c:if test="${(order.status == 'Returned' || order.status == 'Completed') && !hasReviewed}">
                        <div class="card border-0 shadow-sm p-4 mb-4">
                            <h5 class="fw-bold mb-3"><i class="fa-solid fa-star text-warning me-2"></i>Leave a Review</h5>
                            <form action="${pageContext.request.contextPath}/orders" method="POST">
                                <input type="hidden" name="action" value="submitReview">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Rating *</label>
                                    <div class="d-flex gap-2">
                                        <c:forEach begin="1" end="5" var="i">
                                            <div class="form-check form-check-inline">
                                                <input type="radio" name="rating" value="${i}" class="form-check-input" id="star${i}" ${i == 5 ? 'checked' : ''}>
                                                <label class="form-check-label" for="star${i}">${i} <i class="fa-solid fa-star text-warning"></i></label>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Comment</label>
                                    <textarea name="comment" class="form-control" rows="3" placeholder="Share your experience..."></textarea>
                                </div>
                                <button type="submit" class="btn btn-warning rounded-pill px-4 fw-semibold">
                                    <i class="fa-solid fa-paper-plane me-2"></i>Submit Review
                                </button>
                            </form>
                        </div>
                    </c:if>
                    <c:if test="${hasReviewed}">
                        <div class="alert alert-info">
                            <i class="fa-solid fa-check me-2"></i>You have already submitted a review for this order. Thank you!
                        </div>
                    </c:if>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
