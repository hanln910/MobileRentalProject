<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Motorbikes - Admin - MotoRent</title>
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
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageMotorbikes"><i class="fa-solid fa-motorcycle"></i> Motorbikes</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageCategories"><i class="fa-solid fa-tags"></i> Categories</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageBrands"><i class="fa-solid fa-copyright"></i> Brands</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageComplaints"><i class="fa-solid fa-flag"></i> Complaints</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-4 border-bottom">
                    <h1 class="h2 fw-bold">Manage Motorbikes</h1>
                    <button class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addMotorbikeModal">
                        <i class="fa-solid fa-plus me-2"></i>Add Motorbike
                    </button>
                </div>

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

                <div class="card border-0 shadow-sm p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Motorbike</th>
                                    <th>Brand</th>
                                    <th>Category</th>
                                    <th>Year</th>
                                    <th>Price/Day</th>
                                    <th>Status</th>
                                    <th>Rating</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="bike" items="${motorbikes}">
                                    <tr>
                                        <td>${bike.motorbikeId}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="${bike.imageUrl}" class="rounded me-3" width="60" height="45" style="object-fit: cover;" alt="Bike">
                                                <span class="fw-bold">${bike.name}</span>
                                            </div>
                                        </td>
                                        <td>${bike.brandName}</td>
                                        <td>${bike.categoryName}</td>
                                        <td>${bike.year}</td>
                                        <td class="fw-bold">$<fmt:formatNumber value="${bike.pricePerDay}" maxFractionDigits="2"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${bike.status == 'Available'}"><span class="badge badge-available">Available</span></c:when>
                                                <c:when test="${bike.status == 'Rented'}"><span class="badge badge-rented">Rented</span></c:when>
                                                <c:otherwise><span class="badge badge-maintenance">Maintenance</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <i class="fa-solid fa-star text-warning me-1"></i>
                                            <fmt:formatNumber value="${bike.avgRating}" maxFractionDigits="1"/>
                                            <small class="text-muted">(${bike.reviewCount})</small>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-1">
                                                <button class="btn btn-sm btn-outline-primary rounded-pill" data-bs-toggle="modal" data-bs-target="#editModal${bike.motorbikeId}" title="Edit">
                                                    <i class="fa-solid fa-pen"></i>
                                                </button>
                                                <form action="${pageContext.request.contextPath}/admin" method="POST" style="display:inline;" onsubmit="return confirm('Delete this motorbike?')">
                                                    <input type="hidden" name="action" value="deleteMotorbike">
                                                    <input type="hidden" name="motorbikeId" value="${bike.motorbikeId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill" title="Delete">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>

                                    <!-- Edit Modal for each bike -->
                                    <div class="modal fade" id="editModal${bike.motorbikeId}" tabindex="-1">
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <div class="modal-header border-0"><h5 class="modal-title fw-bold">Edit Motorbike</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                                <form action="${pageContext.request.contextPath}/admin" method="POST">
                                                    <input type="hidden" name="action" value="editMotorbike">
                                                    <input type="hidden" name="motorbikeId" value="${bike.motorbikeId}">
                                                    <div class="modal-body">
                                                        <div class="row g-3">
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-semibold">Name</label>
                                                                <input type="text" name="name" class="form-control" value="${bike.name}" required>
                                                            </div>
                                                            <div class="col-md-3">
                                                                <label class="form-label fw-semibold">Brand</label>
                                                                <select name="brandId" class="form-select">
                                                                    <c:forEach var="b" items="${brands}">
                                                                        <option value="${b.brandId}" ${bike.brandId == b.brandId ? 'selected' : ''}>${b.brandName}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-3">
                                                                <label class="form-label fw-semibold">Category</label>
                                                                <select name="categoryId" class="form-select">
                                                                    <c:forEach var="cat" items="${categories}">
                                                                        <option value="${cat.categoryId}" ${bike.categoryId == cat.categoryId ? 'selected' : ''}>${cat.categoryName}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Year</label>
                                                                <input type="number" name="year" class="form-control" value="${bike.year}" min="2000" max="2030">
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Price/Day ($)</label>
                                                                <input type="number" name="pricePerDay" class="form-control" value="${bike.pricePerDay}" step="0.01" min="0" required>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Status</label>
                                                                <select name="status" class="form-select">
                                                                    <option value="Available" ${bike.status == 'Available' ? 'selected' : ''}>Available</option>
                                                                    <option value="Rented" ${bike.status == 'Rented' ? 'selected' : ''}>Rented</option>
                                                                    <option value="Maintenance" ${bike.status == 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Image URL</label>
                                                                <input type="text" name="imageUrl" class="form-control" value="${bike.imageUrl}">
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Description</label>
                                                                <textarea name="description" class="form-control" rows="3">${bike.description}</textarea>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer border-0">
                                                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="btn btn-primary rounded-pill px-4">Save Changes</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty motorbikes}">
                                    <tr><td colspan="9" class="text-center text-muted py-4">No motorbikes found. Add your first motorbike!</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Add Motorbike Modal -->
    <div class="modal fade" id="addMotorbikeModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header border-0"><h5 class="modal-title fw-bold">Add New Motorbike</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <form action="${pageContext.request.contextPath}/admin" method="POST" onsubmit="return validateMotorbikeForm()">
                    <input type="hidden" name="action" value="addMotorbike">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Name *</label>
                                <input type="text" id="motorbikeName" name="name" class="form-control" placeholder="e.g. CBR600RR" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Brand *</label>
                                <select id="brandId" name="brandId" class="form-select" required>
                                    <option value="">Select Brand</option>
                                    <c:forEach var="b" items="${brands}">
                                        <option value="${b.brandId}">${b.brandName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Category *</label>
                                <select id="categoryId" name="categoryId" class="form-select" required>
                                    <option value="">Select Type</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Year</label>
                                <input type="number" name="year" class="form-control" value="2024" min="2000" max="2030">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Price/Day ($) *</label>
                                <input type="number" id="pricePerDay" name="pricePerDay" class="form-control" placeholder="0.00" step="0.01" min="0" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Status</label>
                                <select name="status" class="form-select">
                                    <option value="Available" selected>Available</option>
                                    <option value="Maintenance">Maintenance</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Image URL</label>
                                <input type="text" name="imageUrl" class="form-control" placeholder="https://images.unsplash.com/...">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Description</label>
                                <textarea name="description" class="form-control" rows="3" placeholder="Describe the motorbike..."></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Add Motorbike</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
