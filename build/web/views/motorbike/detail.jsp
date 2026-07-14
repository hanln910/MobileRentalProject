<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${motorbike.name} - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/views/components/navbar.jsp"><jsp:param name="active" value="motorbikes"/></jsp:include>

    <div class="container py-5">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/motorbikes?action=list" class="text-decoration-none">Motorbikes</a></li>
                <li class="breadcrumb-item active" aria-current="page">${motorbike.brandName} ${motorbike.name}</li>
            </ol>
        </nav>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.orderError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.orderError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="orderError" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.reviewSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.reviewSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="reviewSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.reviewError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.reviewError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="reviewError" scope="session"/>
        </c:if>

        <div class="row g-5">
            <!-- Left side: Image Gallery -->
            <div class="col-lg-7">
                <div class="gallery-main mb-3">
                    <img id="mainImage" src="${motorbike.imageUrl}" class="img-fluid w-100" alt="${motorbike.name}" style="height: 500px; object-fit: cover;">
                </div>
                <c:if test="${not empty motorbike.images}">
                    <div class="row g-2 gallery-thumbs">
                        <c:forEach var="img" items="${motorbike.images}">
                            <div class="col-3">
                                <img src="${img.imageUrl}" class="img-fluid ${img.isPrimary ? 'active' : ''}" alt="Thumbnail" onclick="changeMainImage('${img.imageUrl}')">
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <!-- Right side: Information & Booking -->
            <div class="col-lg-5">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted fw-semibold text-uppercase">${motorbike.brandName}</span>
                    <c:choose>
                        <c:when test="${motorbike.status == 'Available'}"><span class="badge badge-available">Available</span></c:when>
                        <c:when test="${motorbike.status == 'Rented'}"><span class="badge badge-rented">Rented</span></c:when>
                        <c:otherwise><span class="badge badge-maintenance">Maintenance</span></c:otherwise>
                    </c:choose>
                </div>
                <h1 class="fw-bold mb-3">${motorbike.name}</h1>

                <div class="d-flex align-items-center mb-4">
                    <div class="text-warning me-2">
                        <c:forEach begin="1" end="${motorbike.avgRating > 0 ? motorbike.avgRating : 0}"><i class="fa-solid fa-star"></i></c:forEach>
                        <c:if test="${motorbike.avgRating % 1 > 0}"><i class="fa-solid fa-star-half-stroke"></i></c:if>
                    </div>
                    <span class="text-muted">(${motorbike.reviewCount} Reviews)</span>
                    <span class="mx-3 text-muted">|</span>
                    <span class="text-muted">Year: ${motorbike.year}</span>
                    <span class="mx-3 text-muted">|</span>
                    <span class="text-muted">${motorbike.categoryName}</span>
                </div>

                <div class="mb-4">
                    <span class="display-5 fw-bold text-primary" id="pricePerDay" data-price="${motorbike.pricePerDay}">$<fmt:formatNumber value="${motorbike.pricePerDay}" maxFractionDigits="0"/></span>
                    <span class="text-muted fs-5">/day</span>
                </div>

                <p class="text-muted mb-5">${motorbike.description}</p>

                <!-- Booking Form -->
                <c:if test="${motorbike.status == 'Available'}">
                    <div class="card bg-light p-4 border-0 mb-4">
                        <h5 class="fw-bold mb-4">Book this Motorbike</h5>
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <!-- Wallet Balance -->
                                <c:if test="${not empty wallet}">
                                    <div class="d-flex justify-content-between align-items-center mb-3 p-2 rounded" style="background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white;">
                                        <span class="fw-semibold"><i class="fa-solid fa-wallet me-1"></i> Wallet Balance</span>
                                        <span class="fw-bold">$<fmt:formatNumber value="${wallet.balance}" maxFractionDigits="2"/></span>
                                    </div>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/orders" method="POST" onsubmit="return validateBookingForm()">
                                    <input type="hidden" name="action" value="create">
                                    <input type="hidden" name="motorbikeId" value="${motorbike.motorbikeId}">
                                    <div class="row g-3 mb-4">
                                        <div class="col-6">
                                            <label class="form-label fw-semibold text-muted">Pickup Date</label>
                                            <input type="date" class="form-control" id="pickupDate" name="rentalDate" required>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label fw-semibold text-muted">Return Date</label>
                                            <input type="date" class="form-control" id="returnDate" name="returnDate" required>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="fw-semibold">Duration:</span>
                                        <span class="fw-semibold" id="totalDays">0 day(s)</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="fw-semibold">Total Price:</span>
                                        <span class="fs-4 fw-bold text-primary" id="totalPrice">$0.00</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                                        <span class="fw-semibold text-muted small">Payment via Wallet</span>
                                        <a href="${pageContext.request.contextPath}/wallet" class="small text-decoration-none">Top up wallet</a>
                                    </div>
                                    <button type="submit" class="btn btn-primary w-100 rounded-pill py-2 fw-semibold"><i class="fa-solid fa-wallet me-2"></i>Pay & Rent Now</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted mb-3">Please login to book this motorbike.</p>
                                <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-primary w-100 rounded-pill py-2 fw-semibold">Login to Book</a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- Tabs: Description, Specs, Reviews -->
        <div class="row mt-5 pt-5">
            <div class="col-12">
                <ul class="nav nav-tabs mb-4" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active fw-semibold" id="desc-tab" data-bs-toggle="tab" data-bs-target="#desc" type="button" role="tab">Description</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link fw-semibold" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews" type="button" role="tab">Reviews (${motorbike.reviewCount})</button>
                    </li>
                </ul>
                <div class="tab-content" id="myTabContent">
                    <div class="tab-pane fade show active text-muted" id="desc" role="tabpanel">
                        <p>${motorbike.description}</p>
                        <table class="table table-bordered mt-4">
                            <tbody>
                                <tr><th class="w-25 bg-light">Brand</th><td>${motorbike.brandName}</td></tr>
                                <tr><th class="bg-light">Category</th><td>${motorbike.categoryName}</td></tr>
                                <tr><th class="bg-light">Year</th><td>${motorbike.year}</td></tr>
                                <tr><th class="bg-light">Price/Day</th><td>$<fmt:formatNumber value="${motorbike.pricePerDay}" maxFractionDigits="2"/></td></tr>
                                <tr><th class="bg-light">Status</th><td>${motorbike.status}</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="tab-pane fade" id="reviews" role="tabpanel">
                        <c:forEach var="review" items="${reviews}">
                            <div class="d-flex mb-4 pb-4 border-bottom">
                                <img src="https://ui-avatars.com/api/?name=${review.userName}&background=random" class="rounded-circle me-3" width="50" height="50" alt="User">
                                <div>
                                    <h6 class="fw-bold mb-1">${review.userName}</h6>
                                    <div class="text-warning small mb-2">
                                        <c:forEach begin="1" end="${review.rating}"><i class="fa-solid fa-star"></i></c:forEach>
                                        <c:forEach begin="1" end="${5 - review.rating}"><i class="fa-regular fa-star"></i></c:forEach>
                                    </div>
                                    <p class="text-muted mb-0">${review.comment}</p>
                                    <small class="text-muted"><fmt:formatDate value="${review.createdAt}" pattern="MMM dd, yyyy"/></small>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty reviews}">
                            <p class="text-muted">No reviews yet. Be the first to review this motorbike!</p>
                        </c:if>

                        <!-- Add Review Form (only for logged-in customers) -->
                        <c:if test="${not empty sessionScope.user && sessionScope.user.roleId == 2}">
                            <div class="card bg-light border-0 p-4 mt-4">
                                <h5 class="fw-bold mb-3">Write a Review</h5>
                                <form action="${pageContext.request.contextPath}/reviews" method="POST" onsubmit="return validateReviewForm()">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="motorbikeId" value="${motorbike.motorbikeId}">
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Order ID</label>
                                        <input type="number" name="orderId" class="form-control" placeholder="Enter your completed order ID" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Rating</label>
                                        <div class="d-flex gap-2">
                                            <c:forEach begin="1" end="5" var="i">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="rating" value="${i}" id="rating${i}" ${i == 5 ? 'checked' : ''}>
                                                    <label class="form-check-label" for="rating${i}">${i} <i class="fa-solid fa-star text-warning"></i></label>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Comment</label>
                                        <textarea id="reviewComment" name="comment" class="form-control" rows="3" placeholder="Share your experience..."></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-primary rounded-pill px-4">Submit Review</button>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/components/footer.jsp"/>

    <%@ include file="/views/includes/chatbot-widget.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
