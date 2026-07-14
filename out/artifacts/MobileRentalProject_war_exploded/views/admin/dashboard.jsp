<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light">
    <!-- Top Navbar -->
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
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 d-md-block sidebar collapse bg-white p-3">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column gap-2">
                        <li class="nav-item"><a class="nav-link active d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=dashboard"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageUsers"><i class="fa-solid fa-users"></i> Users</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageMotorbikes"><i class="fa-solid fa-motorcycle"></i> Motorbikes</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageOrders"><i class="fa-solid fa-clipboard-list"></i> Orders</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageCategories"><i class="fa-solid fa-tags"></i> Categories</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageBrands"><i class="fa-solid fa-copyright"></i> Brands</a></li>
                        <li class="nav-item"><a class="nav-link d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/admin?action=manageComplaints"><i class="fa-solid fa-flag"></i> Complaints</a></li>
                        <li class="nav-item mt-5"><a class="nav-link text-danger d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <h1 class="h2 fw-bold pt-3 pb-2 mb-4 border-bottom">Admin Dashboard</h1>

                <!-- Alert Messages -->
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

                <!-- Analytics Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon primary"><i class="fa-solid fa-users"></i></div>
                            <div><h3 class="fw-bold mb-0">${totalUsers}</h3><p class="text-muted mb-0 fw-semibold">Total Users</p></div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon warning"><i class="fa-solid fa-motorcycle"></i></div>
                            <div><h3 class="fw-bold mb-0">${totalMotorbikes}</h3><p class="text-muted mb-0 fw-semibold">Motorbikes</p></div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon success"><i class="fa-solid fa-clipboard-list"></i></div>
                            <div><h3 class="fw-bold mb-0">${totalOrders}</h3><p class="text-muted mb-0 fw-semibold">Total Rentals</p></div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm border-0">
                            <div class="stat-icon danger"><i class="fa-solid fa-dollar-sign"></i></div>
                            <div><h3 class="fw-bold mb-0">$<fmt:formatNumber value="${totalRevenue}" maxFractionDigits="0"/></h3><p class="text-muted mb-0 fw-semibold">Revenue</p></div>
                        </div>
                    </div>
                </div>

                <!-- Charts Row -->
                <div class="row g-4 mb-4">
                    <!-- Monthly Revenue Chart -->
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="fw-bold mb-3"><i class="fa-solid fa-chart-line text-primary me-2"></i>Monthly Revenue (${java.time.Year.now()})</h5>
                            <canvas id="revenueChart" height="100"></canvas>
                        </div>
                    </div>
                    <!-- Order Status Distribution -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="fw-bold mb-3"><i class="fa-solid fa-chart-pie text-warning me-2"></i>Order Status</h5>
                            <canvas id="statusChart" height="200"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Monthly Orders Chart + Order Status Breakdown -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="fw-bold mb-3"><i class="fa-solid fa-chart-bar text-info me-2"></i>Monthly Orders (${java.time.Year.now()})</h5>
                            <canvas id="ordersChart" height="100"></canvas>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="fw-bold mb-3"><i class="fa-solid fa-list-check text-success me-2"></i>Status Breakdown</h5>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Pending</span><span class="badge bg-warning text-dark">${pendingOrders}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Confirmed</span><span class="badge bg-primary">${confirmedOrders}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Renting</span><span class="badge bg-info text-dark">${activeRentals}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Received</span><span class="badge" style="background:#0dcaf0">${receivedOrders}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Returned</span><span class="badge bg-success">${returnedOrders}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Fined</span><span class="badge bg-danger">${finedOrders}</span></div>
                            <div class="d-flex justify-content-between py-2 border-bottom"><span class="text-muted">Completed</span><span class="badge bg-success">${completedOrders}</span></div>
                            <div class="d-flex justify-content-between py-2"><span class="text-muted">Cancelled</span><span class="badge bg-secondary">${cancelledOrders}</span></div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders + Quick Actions -->
                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm p-4">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h5 class="fw-bold mb-0"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Recent Orders</h5>
                                <a href="${pageContext.request.contextPath}/admin?action=manageOrders" class="btn btn-sm btn-outline-primary rounded-pill px-3">View All</a>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr><th>Order ID</th><th>Customer</th><th>Total</th><th>Status</th></tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${recentOrders}" begin="0" end="7">
                                            <tr>
                                                <td class="fw-semibold">#ORD-<fmt:formatNumber value="${order.orderId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                                <td>${order.customerName}</td>
                                                <td class="fw-bold">$<fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="2"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${order.status == 'Pending'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                                                        <c:when test="${order.status == 'Confirmed'}"><span class="badge bg-primary">Confirmed</span></c:when>
                                                        <c:when test="${order.status == 'Renting'}"><span class="badge bg-info text-dark">Renting</span></c:when>
                                                        <c:when test="${order.status == 'Received'}"><span class="badge" style="background-color: #0dcaf0;">Received</span></c:when>
                                                        <c:when test="${order.status == 'Returned'}"><span class="badge bg-success">Returned</span></c:when>
                                                        <c:when test="${order.status == 'Fined'}"><span class="badge bg-danger"><i class="fa-solid fa-gavel me-1"></i>Fined</span></c:when>
                                                        <c:when test="${order.status == 'Completed'}"><span class="badge bg-success">Completed</span></c:when>
                                                        <c:when test="${order.status == 'Cancelled'}"><span class="badge bg-secondary">Cancelled</span></c:when>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="fw-bold mb-4"><i class="fa-solid fa-bolt text-warning me-2"></i>Quick Actions</h5>
                            <div class="d-grid gap-3">
                                <a href="${pageContext.request.contextPath}/admin?action=manageMotorbikes" class="btn btn-outline-primary rounded-pill"><i class="fa-solid fa-plus me-2"></i>Add Motorbike</a>
                                <a href="${pageContext.request.contextPath}/admin?action=manageUsers" class="btn btn-outline-primary rounded-pill"><i class="fa-solid fa-user-plus me-2"></i>Manage Users</a>
                                <a href="${pageContext.request.contextPath}/admin?action=manageOrders" class="btn btn-outline-primary rounded-pill"><i class="fa-solid fa-clipboard-list me-2"></i>View Orders</a>
                                <a href="${pageContext.request.contextPath}/admin?action=manageCategories" class="btn btn-outline-primary rounded-pill"><i class="fa-solid fa-tags me-2"></i>Categories</a>
                                <a href="${pageContext.request.contextPath}/admin?action=manageBrands" class="btn btn-outline-primary rounded-pill"><i class="fa-solid fa-copyright me-2"></i>Brands</a>
                                <a href="${pageContext.request.contextPath}/admin?action=manageComplaints" class="btn btn-outline-danger rounded-pill"><i class="fa-solid fa-flag me-2"></i>Complaints</a>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script>
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

        // Monthly Revenue Chart (Line)
        new Chart(document.getElementById('revenueChart'), {
            type: 'line',
            data: {
                labels: months,
                datasets: [{
                    label: 'Revenue ($)',
                    data: [<c:forEach var="r" items="${monthlyRevenue}" varStatus="s">${r}<c:if test="${!s.last}">,</c:if></c:forEach>],
                    borderColor: '#2563eb',
                    backgroundColor: 'rgba(37,99,235,0.1)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4,
                    pointBackgroundColor: '#2563eb'
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, ticks: { callback: v => '$' + v } }
                }
            }
        });

        // Monthly Orders Chart (Bar)
        new Chart(document.getElementById('ordersChart'), {
            type: 'bar',
            data: {
                labels: months,
                datasets: [{
                    label: 'Orders',
                    data: [<c:forEach var="c" items="${monthlyOrderCounts}" varStatus="s">${c}<c:if test="${!s.last}">,</c:if></c:forEach>],
                    backgroundColor: 'rgba(13,202,240,0.7)',
                    borderColor: '#0dcaf0',
                    borderWidth: 1,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
            }
        });

        // Order Status Doughnut Chart
        new Chart(document.getElementById('statusChart'), {
            type: 'doughnut',
            data: {
                labels: ['Pending','Confirmed','Renting','Received','Returned','Fined','Completed','Cancelled'],
                datasets: [{
                    data: [${pendingOrders},${confirmedOrders},${activeRentals},${receivedOrders},${returnedOrders},${finedOrders},${completedOrders},${cancelledOrders}],
                    backgroundColor: ['#ffc107','#0d6efd','#0dcaf0','#20c997','#198754','#dc3545','#157347','#6c757d'],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, padding: 10, font: { size: 11 } } }
                }
            }
        });
    </script>
</body>
</html>
