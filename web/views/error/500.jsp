<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Server Error - MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
    <div class="text-center p-5">
        <div class="mb-4">
            <i class="fa-solid fa-wrench text-danger" style="font-size: 80px;"></i>
        </div>
        <h1 class="display-1 fw-bold text-danger">500</h1>
        <h2 class="fw-bold mb-3">Internal Server Error</h2>
        <p class="text-muted mb-5 fs-5">Something went wrong on our end. Please try again later.</p>
        <div class="d-flex gap-3 justify-content-center">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary btn-lg rounded-pill px-5">
                <i class="fa-solid fa-home me-2"></i>Go Home
            </a>
            <a href="javascript:history.back()" class="btn btn-outline-primary btn-lg rounded-pill px-5">
                <i class="fa-solid fa-arrow-left me-2"></i>Go Back
            </a>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
