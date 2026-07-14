<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Motorbikes - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/views/components/navbar.jsp"><jsp:param name="active" value="motorbikes"/></jsp:include>

    <!-- Page Header -->
    <div class="bg-light py-5 mb-5">
        <div class="container">
            <h1 class="fw-bold">Our Motorbikes</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Motorbikes</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container mb-5">
        <div class="row">
            <!-- Sidebar Filters -->
            <div class="col-lg-3 mb-4">
                <div class="card p-4 border-0 bg-white">
                    <h5 class="fw-bold mb-4">Filters</h5>
                    <form action="${pageContext.request.contextPath}/motorbikes" method="GET">
                        <input type="hidden" name="action" value="list">

                        <!-- Search -->
                        <div class="mb-4">
                            <label class="fw-semibold mb-2">Search</label>
                            <input type="text" name="keyword" class="form-control" placeholder="Search by name..." value="${keyword}">
                        </div>

                        <!-- Brand Filter -->
                        <div class="mb-4">
                            <label class="fw-semibold mb-2">Brand</label>
                            <c:forEach var="brand" items="${brands}">
                                <div class="form-check mb-2">
                                    <input class="form-check-input" type="radio" name="brandId" value="${brand.brandId}" id="brand${brand.brandId}"
                                           ${selectedBrandId == brand.brandId ? 'checked' : ''}>
                                    <label class="form-check-label" for="brand${brand.brandId}">${brand.brandName}</label>
                                </div>
                            </c:forEach>
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="radio" name="brandId" value="" id="brandAll" ${selectedBrandId == 0 ? 'checked' : ''}>
                                <label class="form-check-label" for="brandAll">All Brands</label>
                            </div>
                        </div>

                        <!-- Category Filter -->
                        <div class="mb-4">
                            <label class="fw-semibold mb-2">Category</label>
                            <select class="form-select" name="categoryId">
                                <option value="">All Types</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" ${selectedCategoryId == cat.categoryId ? 'selected' : ''}>${cat.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Price Range -->
                        <div class="mb-4">
                            <label class="fw-semibold mb-2">Max Price ($/day)</label>
                            <input type="number" name="maxPrice" class="form-control" placeholder="Max price" min="0" value="${maxPrice > 0 ? maxPrice : ''}">
                        </div>

                        <button type="submit" class="btn btn-primary w-100 rounded-pill">Apply Filters</button>
                        <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-outline-secondary w-100 rounded-pill mt-2">Clear Filters</a>
                    </form>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <p class="mb-0 text-muted">
                        Showing <strong>${(currentPage - 1) * 6 + 1}-${currentPage * 6 > totalCount ? totalCount : currentPage * 6}</strong> of <strong>${totalCount}</strong> motorbikes
                    </p>
                    <form action="${pageContext.request.contextPath}/motorbikes" method="GET" class="d-flex align-items-center">
                        <input type="hidden" name="action" value="list">
                        <input type="hidden" name="keyword" value="${keyword}">
                        <input type="hidden" name="brandId" value="${selectedBrandId}">
                        <input type="hidden" name="categoryId" value="${selectedCategoryId}">
                        <select class="form-select w-auto" name="sortBy" onchange="this.form.submit()">
                            <option value="" ${empty sortBy ? 'selected' : ''}>Sort by: Newest</option>
                            <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
                            <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
                            <option value="rating" ${sortBy == 'rating' ? 'selected' : ''}>Rating: High to Low</option>
                        </select>
                    </form>
                </div>

                <div class="row g-4">
                    <c:forEach var="bike" items="${motorbikes}">
                        <div class="col-md-6 col-xl-4">
                            <div class="card hover-lift h-100">
                                <div class="position-relative">
                                    <img src="${bike.imageUrl}" class="card-img-top" alt="${bike.name}" style="height: 200px; object-fit: cover;">
                                    <c:choose>
                                        <c:when test="${bike.status == 'Available'}">
                                            <span class="badge badge-available position-absolute top-0 end-0 m-3">Available</span>
                                        </c:when>
                                        <c:when test="${bike.status == 'Rented'}">
                                            <span class="badge badge-rented position-absolute top-0 end-0 m-3">Rented</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-maintenance position-absolute top-0 end-0 m-3">Maintenance</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="card-body p-4">
                                    <span class="text-muted small fw-semibold text-uppercase">${bike.brandName}</span>
                                    <h5 class="card-title fw-bold mb-3">${bike.name}</h5>
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <span class="fs-5 fw-bold text-primary">$<fmt:formatNumber value="${bike.pricePerDay}" maxFractionDigits="0"/></span>
                                            <span class="text-muted small">/day</span>
                                        </div>
                                        <div class="text-warning small">
                                            <i class="fa-solid fa-star"></i>
                                            <fmt:formatNumber value="${bike.avgRating}" maxFractionDigits="1"/>
                                        </div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <c:choose>
                                            <c:when test="${bike.status == 'Available'}">
                                                <a href="${pageContext.request.contextPath}/motorbikes?action=detail&id=${bike.motorbikeId}" class="btn btn-outline-primary w-50 rounded-pill">Details</a>
                                                <a href="${pageContext.request.contextPath}/motorbikes?action=detail&id=${bike.motorbikeId}" class="btn btn-primary w-50 rounded-pill">Rent</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/motorbikes?action=detail&id=${bike.motorbikeId}" class="btn btn-outline-primary w-100 rounded-pill">View Details</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty motorbikes}">
                        <div class="col-12 text-center py-5">
                            <i class="fa-solid fa-motorcycle text-muted" style="font-size: 48px;"></i>
                            <h4 class="mt-3 text-muted">No motorbikes found</h4>
                            <p class="text-muted">Try adjusting your filters.</p>
                            <a href="${pageContext.request.contextPath}/motorbikes?action=list" class="btn btn-primary rounded-pill px-4">View All Motorbikes</a>
                        </div>
                    </c:if>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav class="mt-5">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/motorbikes?action=list&page=${currentPage - 1}&keyword=${keyword}&brandId=${selectedBrandId}&categoryId=${selectedCategoryId}&sortBy=${sortBy}">Previous</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/motorbikes?action=list&page=${i}&keyword=${keyword}&brandId=${selectedBrandId}&categoryId=${selectedCategoryId}&sortBy=${sortBy}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/motorbikes?action=list&page=${currentPage + 1}&keyword=${keyword}&brandId=${selectedBrandId}&categoryId=${selectedCategoryId}&sortBy=${sortBy}">Next</a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/views/components/footer.jsp"/>

    <%@ include file="/views/includes/chatbot-widget.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
