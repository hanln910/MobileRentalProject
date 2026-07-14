<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MotoRent - Rent Your Perfect Motorbike Today</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/views/components/navbar.jsp"><jsp:param name="active" value="home"/></jsp:include>

    <!-- Hero Section -->
    <section class="hero-section text-center d-flex align-items-center">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <h1 class="display-4 fw-bold mb-4">Rent Your Perfect Motorbike Today</h1>
                    <p class="lead mb-5">Affordable, Fast, and Reliable Motorbike Rental Service</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Search Box -->
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="search-box">
                    <form class="row g-3 align-items-end" action="${pageContext.request.contextPath}/motorbikes" method="GET">
                        <input type="hidden" name="action" value="list">
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-semibold">Search Motorbike</label>
                            <input type="text" name="keyword" class="form-control form-control-lg" placeholder="Search by name or brand...">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-semibold">Category</label>
                            <select name="categoryId" class="form-select form-select-lg">
                                <option value="">All Categories</option>
                                <option value="1">Sport</option>
                                <option value="2">Cruiser</option>
                                <option value="3">Scooter</option>
                                <option value="4">Off-Road</option>
                                <option value="5">Touring</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill">Search Motorbikes</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- How It Works Section -->
    <section class="py-5 mt-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="fw-bold">How It Works</h2>
                <p class="text-muted">Rent a motorbike in 3 easy steps</p>
            </div>
            <div class="row g-4 text-center">
                <div class="col-md-4">
                    <div class="p-4">
                        <div class="stat-icon primary mx-auto mb-4">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </div>
                        <h4 class="fw-bold">Search Motorbike</h4>
                        <p class="text-muted">Choose from our wide range of premium motorbikes.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-4">
                        <div class="stat-icon warning mx-auto mb-4">
                            <i class="fa-regular fa-calendar-check"></i>
                        </div>
                        <h4 class="fw-bold">Book Online</h4>
                        <p class="text-muted">Select your dates and book instantly online.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-4">
                        <div class="stat-icon success mx-auto mb-4">
                            <i class="fa-solid fa-motorcycle"></i>
                        </div>
                        <h4 class="fw-bold">Ride Anywhere</h4>
                        <p class="text-muted">Pick up your bike and enjoy the ride.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Motorbikes Section -->
    <section class="py-5 bg-light">
        <div class="container">
            <div class="d-flex justify-content-between align-items-end mb-5">
                <div>
                    <h2 class="fw-bold mb-0">Featured Motorbikes</h2>
                    <p class="text-muted mb-0 mt-2">Explore our most popular rentals</p>
                </div>
                <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-outline-primary rounded-pill px-4">View All</a>
            </div>

            <div class="row g-4">
                <c:forEach var="bike" items="${featuredBikes}">
                    <div class="col-lg-4 col-md-6">
                        <div class="card hover-lift h-100">
                            <img src="${bike.imageUrl}" class="card-img-top" alt="${bike.name}" style="height: 250px; object-fit: cover;">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div>
                                        <span class="text-muted small fw-semibold text-uppercase">${bike.brandName}</span>
                                        <h5 class="card-title fw-bold mb-0">${bike.name}</h5>
                                    </div>
                                    <div class="badge bg-light text-dark border">
                                        <i class="fa-solid fa-star text-warning me-1"></i>
                                        <fmt:formatNumber value="${bike.avgRating}" maxFractionDigits="1"/>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mt-4">
                                    <div>
                                        <span class="fs-4 fw-bold text-primary">$<fmt:formatNumber value="${bike.pricePerDay}" maxFractionDigits="0"/></span>
                                        <span class="text-muted">/day</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/motorbikes?action=detail&id=${bike.motorbikeId}" class="btn btn-primary rounded-pill px-4">View Details</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty featuredBikes}">
                    <div class="col-12 text-center py-5">
                        <i class="fa-solid fa-motorcycle text-muted" style="font-size: 48px;"></i>
                        <h4 class="mt-3 text-muted">No motorbikes available yet</h4>
                        <p class="text-muted">Check back soon for new additions!</p>
                    </div>
                </c:if>
            </div>
        </div>
    </section>

    <!-- Customer Reviews Section -->
    <section class="py-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="fw-bold">What Our Customers Say</h2>
                <p class="text-muted">Real reviews from our riders</p>
            </div>
            <div class="row g-4">
                <c:forEach var="review" items="${recentReviews}">
                    <div class="col-md-4">
                        <div class="card p-4 h-100 bg-light border-0">
                            <div class="text-warning mb-3">
                                <c:forEach begin="1" end="${review.rating}"><i class="fa-solid fa-star"></i></c:forEach>
                                <c:forEach begin="1" end="${5 - review.rating}"><i class="fa-regular fa-star"></i></c:forEach>
                            </div>
                            <p class="mb-4">"${review.comment}"</p>
                            <div class="d-flex align-items-center">
                                <img src="https://ui-avatars.com/api/?name=${review.userName}&background=random" class="rounded-circle me-3" width="48" height="48" alt="User">
                                <div>
                                    <h6 class="mb-0 fw-bold">${review.userName}</h6>
                                    <small class="text-muted">Rented ${review.motorbikeName}</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty recentReviews}">
                    <div class="col-md-4">
                        <div class="card p-4 h-100 bg-light border-0">
                            <div class="text-warning mb-3">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            </div>
                            <p class="mb-4">"Amazing experience! The bike was in perfect condition and the booking process was incredibly smooth."</p>
                            <div class="d-flex align-items-center">
                                <img src="https://ui-avatars.com/api/?name=John+Doe&background=random" class="rounded-circle me-3" width="48" height="48" alt="User">
                                <div><h6 class="mb-0 fw-bold">John Doe</h6><small class="text-muted">Rented Honda CBR600RR</small></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card p-4 h-100 bg-light border-0">
                            <div class="text-warning mb-3">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                            </div>
                            <p class="mb-4">"Great customer service. They delivered the bike to my hotel on time. Highly recommended!"</p>
                            <div class="d-flex align-items-center">
                                <img src="https://ui-avatars.com/api/?name=Sarah+Smith&background=random" class="rounded-circle me-3" width="48" height="48" alt="User">
                                <div><h6 class="mb-0 fw-bold">Sarah Smith</h6><small class="text-muted">Rented Yamaha R1</small></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card p-4 h-100 bg-light border-0">
                            <div class="text-warning mb-3">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star"></i>
                            </div>
                            <p class="mb-4">"Very affordable prices compared to other rental services. Will definitely use MotoRent again."</p>
                            <div class="d-flex align-items-center">
                                <img src="https://ui-avatars.com/api/?name=Mike+Johnson&background=random" class="rounded-circle me-3" width="48" height="48" alt="User">
                                <div><h6 class="mb-0 fw-bold">Mike Johnson</h6><small class="text-muted">Rented Kawasaki Ninja 400</small></div>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </section>

    <jsp:include page="/views/components/footer.jsp"/>

    <%@ include file="/views/includes/chatbot-widget.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
