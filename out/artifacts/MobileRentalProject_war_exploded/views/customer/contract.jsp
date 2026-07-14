<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rental Contract - MotoRent</title>
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
                <c:choose>
                    <c:when test="${sessionScope.user.roleId == 1}">
                        <a href="${pageContext.request.contextPath}/admin?action=manageOrders" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i> Back to Orders</a>
                    </c:when>
                    <c:when test="${sessionScope.user.roleId == 3}">
                        <a href="${pageContext.request.contextPath}/staff?action=dashboard" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/orders?action=dashboard" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i> Dashboard</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1"><i class="fa-solid fa-file-contract text-primary me-2"></i>Rental Contract</h2>
                <p class="text-muted mb-0">Order #ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></p>
            </div>
            <c:if test="${not empty contract}">
                <span class="badge ${contract.status == 'Signed' ? 'bg-success' : contract.status == 'Draft' ? 'bg-warning text-dark' : 'bg-secondary'} px-3 py-2 fs-6">
                    ${contract.status}
                </span>
            </c:if>
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
                        <p class="mb-1"><strong>Price/Day:</strong> $<fmt:formatNumber value="${detail.pricePerDay}" maxFractionDigits="2"/></p>
                        <p class="mb-1"><strong>Total Amount:</strong> <span class="text-primary fw-bold">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></span></p>
                    </div>
                </div>
            </c:if>
        </div>

        <c:choose>
            <%-- No contract yet: show form to fill in personal info --%>
            <c:when test="${empty contract}">
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-user-shield text-warning me-2"></i>Your Identification Information</h5>
                    <p class="text-muted mb-4">Please provide the following information for the rental contract. This is required for security purposes.</p>

                    <form action="${pageContext.request.contextPath}/orders" method="POST">
                        <input type="hidden" name="action" value="submitContract">
                        <input type="hidden" name="orderId" value="${order.orderId}">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">ID Card Number (CCCD/CMND) *</label>
                                <input type="text" name="customerIdCard" class="form-control" placeholder="e.g. 012345678901" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Date of Birth</label>
                                <input type="date" name="customerDOB" class="form-control">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold"><i class="fa-solid fa-id-card text-primary me-1"></i>CCCD Photo (URL) *</label>
                                <input type="url" name="customerIdCardImage" class="form-control" placeholder="https://example.com/cccd-photo.jpg" required>
                                <small class="text-muted">Upload a clear photo of your Citizen ID card (CCCD) to an image host and paste the URL here. Both front and back sides recommended.</small>
                            </div>
                        </div>

                        <hr class="my-4">
                        <h6 class="fw-bold mb-3"><i class="fa-solid fa-phone-volume text-danger me-2"></i>Emergency Contact</h6>
                        <p class="text-muted small mb-3">In case we need to reach someone on your behalf.</p>

                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Full Name *</label>
                                <input type="text" name="emergencyName" class="form-control" placeholder="Emergency contact name" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Phone Number *</label>
                                <input type="text" name="emergencyPhone" class="form-control" placeholder="e.g. 0912345678" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Relationship</label>
                                <select name="emergencyRelation" class="form-select">
                                    <option value="Parent">Parent</option>
                                    <option value="Spouse">Spouse</option>
                                    <option value="Sibling">Sibling</option>
                                    <option value="Friend">Friend</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary rounded-pill px-5 fw-semibold">
                                <i class="fa-solid fa-paper-plane me-2"></i>Submit Contract Information
                            </button>
                        </div>
                    </form>
                </div>
            </c:when>

            <%-- Contract exists: show contract details + signing --%>
            <c:otherwise>
                <!-- Customer Info -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-user-shield text-warning me-2"></i>Renter Information</h5>
                    <div class="row">
                        <div class="col-md-6">
                            <p class="mb-1"><strong>Full Name:</strong> ${contract.customerName}</p>
                            <p class="mb-1"><strong>Email:</strong> ${contract.customerEmail}</p>
                            <p class="mb-1"><strong>Phone:</strong> ${contract.customerPhone}</p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-1"><strong>ID Card:</strong> ${contract.customerIdCard}</p>
                            <p class="mb-1"><strong>Date of Birth:</strong> <fmt:formatDate value="${contract.customerDOB}" pattern="MMM dd, yyyy"/></p>
                            <c:if test="${not empty contract.customerIdCardImage}">
                                <p class="mb-1"><strong>CCCD Photo:</strong></p>
                                <a href="${contract.customerIdCardImage}" target="_blank">
                                    <img src="${contract.customerIdCardImage}" class="img-fluid rounded border mt-1" alt="CCCD Photo" style="max-height: 150px; object-fit: cover;">
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Emergency Contact -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-phone-volume text-danger me-2"></i>Emergency Contact</h5>
                    <div class="row">
                        <div class="col-md-4"><p class="mb-1"><strong>Name:</strong> ${contract.emergencyName}</p></div>
                        <div class="col-md-4"><p class="mb-1"><strong>Phone:</strong> ${contract.emergencyPhone}</p></div>
                        <div class="col-md-4"><p class="mb-1"><strong>Relationship:</strong> ${contract.emergencyRelation}</p></div>
                    </div>
                </div>

                <!-- Terms & Conditions -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-gavel text-primary me-2"></i>Terms & Conditions</h5>
                    <div class="bg-light p-3 rounded" style="white-space: pre-line; font-size: 14px; line-height: 1.8;">
                        ${contract.terms}
                    </div>
                    <div class="mt-3">
                        <p class="mb-1 fw-semibold">Security Deposit: <span class="text-primary">$<fmt:formatNumber value="${contract.depositAmount}" maxFractionDigits="2"/></span></p>
                    </div>
                </div>

                <!-- Signature Status -->
                <div class="card border-0 shadow-sm p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-signature text-success me-2"></i>Signatures</h5>
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="p-3 border rounded text-center ${contract.customerSigned ? 'border-success bg-success bg-opacity-10' : 'border-warning'}">
                                <h6 class="fw-bold">Customer</h6>
                                <c:choose>
                                    <c:when test="${contract.customerSigned}">
                                        <i class="fa-solid fa-circle-check text-success fs-1 mb-2"></i>
                                        <p class="mb-0 text-success fw-semibold">Signed</p>
                                        <small class="text-muted"><fmt:formatDate value="${contract.customerSignedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-regular fa-circle text-warning fs-1 mb-2"></i>
                                        <p class="mb-0 text-warning fw-semibold">Not Signed</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="p-3 border rounded text-center ${contract.staffSigned ? 'border-success bg-success bg-opacity-10' : 'border-secondary'}">
                                <h6 class="fw-bold">Staff (MotoRent)</h6>
                                <c:choose>
                                    <c:when test="${contract.staffSigned}">
                                        <i class="fa-solid fa-circle-check text-success fs-1 mb-2"></i>
                                        <p class="mb-0 text-success fw-semibold">Signed by ${contract.staffName}</p>
                                        <small class="text-muted"><fmt:formatDate value="${contract.staffSignedAt}" pattern="MMM dd, yyyy HH:mm"/></small>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-regular fa-clock text-secondary fs-1 mb-2"></i>
                                        <p class="mb-0 text-muted fw-semibold">Awaiting Staff Signature</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Sign Buttons - Role Aware -->
                    <%-- Customer sign button --%>
                    <c:if test="${sessionScope.user.roleId == 2 && !contract.customerSigned}">
                        <form action="${pageContext.request.contextPath}/orders" method="POST" class="mt-4 text-center" onsubmit="return confirm('By signing, you agree to all terms and conditions above. Proceed?')">
                            <input type="hidden" name="action" value="signContract">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <div class="form-check mb-3 d-inline-block">
                                <input type="checkbox" class="form-check-input" id="agreeTerms" required>
                                <label class="form-check-label fw-semibold" for="agreeTerms">I have read and agree to the terms & conditions above</label>
                            </div>
                            <br>
                            <button type="submit" class="btn btn-success btn-lg rounded-pill px-5 fw-semibold">
                                <i class="fa-solid fa-signature me-2"></i>Sign as Customer
                            </button>
                        </form>
                    </c:if>

                    <%-- Staff sign button --%>
                    <c:if test="${sessionScope.user.roleId == 3 && !contract.staffSigned}">
                        <form action="${pageContext.request.contextPath}/staff" method="POST" class="mt-4 text-center" onsubmit="return confirm('Sign this contract on behalf of MotoRent?')">
                            <input type="hidden" name="action" value="signContract">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <button type="submit" class="btn btn-primary btn-lg rounded-pill px-5 fw-semibold">
                                <i class="fa-solid fa-file-signature me-2"></i>Sign as Staff
                            </button>
                        </form>
                    </c:if>

                    <%-- Admin sign button (signs as staff) --%>
                    <c:if test="${sessionScope.user.roleId == 1 && !contract.staffSigned}">
                        <form action="${pageContext.request.contextPath}/admin" method="POST" class="mt-4 text-center" onsubmit="return confirm('Sign this contract on behalf of MotoRent (Admin)?')">
                            <input type="hidden" name="action" value="signContract">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <button type="submit" class="btn btn-danger btn-lg rounded-pill px-5 fw-semibold">
                                <i class="fa-solid fa-file-signature me-2"></i>Sign as Admin
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${contract.customerSigned && contract.staffSigned}">
                        <div class="alert alert-success mt-4 mb-0 text-center">
                            <i class="fa-solid fa-check-double me-2"></i>Contract fully signed! The rental can now proceed.
                        </div>
                    </c:if>
                    <c:if test="${contract.customerSigned && !contract.staffSigned}">
                        <div class="alert alert-info mt-4 mb-0 text-center">
                            <i class="fa-solid fa-hourglass-half me-2"></i>Waiting for staff to sign the contract.
                        </div>
                    </c:if>
                    <c:if test="${!contract.customerSigned && contract.staffSigned}">
                        <div class="alert alert-info mt-4 mb-0 text-center">
                            <i class="fa-solid fa-hourglass-half me-2"></i>Waiting for customer to sign the contract.
                        </div>
                    </c:if>
                    <c:if test="${!contract.customerSigned && !contract.staffSigned}">
                        <div class="alert alert-warning mt-4 mb-0 text-center">
                            <i class="fa-solid fa-pen me-2"></i>Contract awaiting signatures from both parties.
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
