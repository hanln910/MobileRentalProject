<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wallet - MotoRent</title>
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
                <a href="${pageContext.request.contextPath}/orders?action=dashboard" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i> Dashboard</a>
                <div class="dropdown">
                    <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" width="36" height="36" class="rounded-circle me-2" alt="User">
                        <span class="fw-semibold">${sessionScope.user.fullName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                        <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container py-5">
        <h2 class="fw-bold mb-4"><i class="fa-solid fa-wallet text-primary me-2"></i>My Wallet</h2>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.walletSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.walletSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="walletSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.walletError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.walletError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="walletError" scope="session"/>
        </c:if>

        <div class="row g-4">
            <!-- Balance Card -->
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm p-4 text-center" style="background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); color: white; border-radius: 16px;">
                    <div class="mb-3"><i class="fa-solid fa-wallet" style="font-size: 48px; opacity: 0.8;"></i></div>
                    <p class="mb-1 fw-semibold" style="opacity: 0.8;">Available Balance</p>
                    <h1 class="display-5 fw-bold mb-0">$<fmt:formatNumber value="${wallet.balance}" maxFractionDigits="2"/></h1>
                </div>

                <!-- Top Up Form -->
                <div class="card border-0 shadow-sm p-4 mt-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-plus-circle text-success me-2"></i>Top Up Wallet</h5>
                    <form action="${pageContext.request.contextPath}/wallet" method="POST">
                        <input type="hidden" name="action" value="topup">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Amount ($)</label>
                            <input type="number" name="amount" class="form-control form-control-lg" placeholder="0.00" min="10" max="10000" step="0.01" required>
                            <div class="form-text">Min: $10.00 | Max: $10,000.00</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Payment Method</label>
                            <select name="method" class="form-select">
                                <option value="Bank Transfer">Bank Transfer</option>
                                <option value="Credit Card">Credit Card</option>
                                <option value="Momo">Momo</option>
                                <option value="ZaloPay">ZaloPay</option>
                            </select>
                        </div>
                        <!-- Quick amounts -->
                        <div class="d-flex gap-2 mb-3 flex-wrap">
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill quick-amount" data-amount="50">$50</button>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill quick-amount" data-amount="100">$100</button>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill quick-amount" data-amount="200">$200</button>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill quick-amount" data-amount="500">$500</button>
                        </div>
                        <button type="submit" class="btn btn-success w-100 rounded-pill fw-semibold">
                            <i class="fa-solid fa-plus me-2"></i>Top Up
                        </button>
                    </form>
                </div>
            </div>

            <!-- Transaction History -->
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm p-4">
                    <h5 class="fw-bold mb-4"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Transaction History</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Date</th>
                                    <th>Type</th>
                                    <th>Description</th>
                                    <th>Amount</th>
                                    <th>Balance</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="tx" items="${transactions}">
                                    <tr>
                                        <td><small><fmt:formatDate value="${tx.createdAt}" pattern="MM/dd/yyyy HH:mm"/></small></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${tx.type == 'TopUp'}"><span class="badge bg-success">Top Up</span></c:when>
                                                <c:when test="${tx.type == 'Payment'}"><span class="badge bg-primary">Payment</span></c:when>
                                                <c:when test="${tx.type == 'Refund'}"><span class="badge bg-warning text-dark">Refund</span></c:when>
                                                <c:when test="${tx.type == 'Fine'}"><span class="badge bg-danger">Fine</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td><small>${tx.description}</small></td>
                                        <td class="fw-bold ${(tx.type == 'Payment' || tx.type= 'Fine')?'text-danger':'text-success'}">
                                            ${(tx.type == 'Payment' || tx.type= 'Fine')?'-' : '+'}$<fmt:formatNumber value="${tx.amount}" maxFractionDigits="2"/>
                                        </td>
                                        <td class="fw-semibold">$<fmt:formatNumber value="${tx.balanceAfter}" maxFractionDigits="2"/></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty transactions}">
                                    <tr><td colspan="5" class="text-center text-muted py-4">No transactions yet.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav class="mt-3">
                            <ul class="pagination justify-content-center mb-0">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/wallet?page=${currentPage - 1}">&laquo;</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/wallet?page=${i}">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/wallet?page=${currentPage + 1}">&raquo;</a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelectorAll('.quick-amount').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelector('input[name="amount"]').value = this.dataset.amount;
            });
        });
    </script>
</body>
</html>
