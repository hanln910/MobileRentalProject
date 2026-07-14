package controller;

import dao.ComplaintDAO;
import dao.ContractDAO;
import dao.MotorbikeDAO;
import dao.OrderDAO;
import dao.OverduePenaltyDAO;
import dao.ReturnInspectionDAO;
import dao.ReviewDAO;
import dao.WalletDAO;
import model.Complaint;
import model.Motorbike;
import model.OverduePenalty;
import model.RentalContract;
import model.RentalOrder;
import model.RentalOrderDetail;
import model.ReturnInspection;
import model.Review;
import model.User;
import model.Wallet;
import util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Order Controller - Handles customer order operations.
 * URL: /orders?action=dashboard|history|create|cancel|detail|received|contract|signContract
 */
public class OrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();
    private final WalletDAO walletDAO = new WalletDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final ReturnInspectionDAO inspectionDAO = new ReturnInspectionDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final OverduePenaltyDAO overduePenaltyDAO = new OverduePenaltyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "dashboard":
                showDashboard(request, response, user);
                break;
            case "history":
                showHistory(request, response, user);
                break;
            case "detail":
                showDetail(request, response, user);
                break;
            case "contract":
                showContract(request, response, user);
                break;
            case "returnInspection":
                showReturnInspection(request, response, user);
                break;
            case "complaint":
                showComplaint(request, response, user);
                break;
            default:
                showDashboard(request, response, user);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "create":
                createOrder(request, response, user);
                break;
            case "cancel":
                cancelOrder(request, response, user);
                break;
            case "received":
                confirmReceived(request, response, user);
                break;
            case "submitContract":
                submitContract(request, response, user);
                break;
            case "signContract":
                customerSignContract(request, response, user);
                break;
            case "submitReturnEvidence":
                submitReturnEvidence(request, response, user);
                break;
            case "payFine":
                payFine(request, response, user);
                break;
            case "submitComplaint":
                submitComplaint(request, response, user);
                break;
            case "submitReview":
                submitReview(request, response, user);
                break;
            case "payOverduePenalty":
                payOverduePenalty(request, response, user);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
                break;
        }
    }

    /**
     * Show customer dashboard with statistics, wallet balance, and paginated orders.
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int totalOrders = orderDAO.getCustomerOrderCount(user.getUserId(), null);
        int activeOrders = orderDAO.getCustomerOrderCount(user.getUserId(), "Renting")
                + orderDAO.getCustomerOrderCount(user.getUserId(), "Confirmed")
                + orderDAO.getCustomerOrderCount(user.getUserId(), "Pending")
                + orderDAO.getCustomerOrderCount(user.getUserId(), "Received");
        int completedOrders = orderDAO.getCustomerOrderCount(user.getUserId(), "Returned")
                + orderDAO.getCustomerOrderCount(user.getUserId(), "Completed");

        // Pagination
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) { }
        if (page < 1) page = 1;

        List<RentalOrder> orders = orderDAO.getOrdersByUserIdPaged(user.getUserId(), page, pageSize);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        // Wallet balance
        Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());

        int maxRentals = 3;
        int activeRentalCount = orderDAO.getActiveRentalCount(user.getUserId());
        int remainingSlots = Math.max(0, maxRentals - activeRentalCount);
        boolean hasUnpaidPenalties = overduePenaltyDAO.hasUnpaidPenalties(user.getUserId());

        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("activeOrders", activeOrders);
        request.setAttribute("completedOrders", completedOrders);
        request.setAttribute("remainingSlots", remainingSlots);
        request.setAttribute("maxRentals", maxRentals);
        request.setAttribute("hasUnpaidPenalties", hasUnpaidPenalties);
        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("wallet", wallet);

        request.getRequestDispatcher("/views/customer/dashboard.jsp").forward(request, response);
    }

    /**
     * Show full order history with pagination.
     */
    private void showHistory(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) { }
        if (page < 1) page = 1;

        List<RentalOrder> orders = orderDAO.getOrdersByUserIdPaged(user.getUserId(), page, pageSize);
        int totalOrders = orderDAO.getCustomerOrderCount(user.getUserId(), null);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/views/customer/orders.jsp").forward(request, response);
    }

    /**
     * Show order detail.
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
            return;
        }
        try {
            int orderId = Integer.parseInt(orderIdStr);
            RentalOrder order = orderDAO.getOrderById(orderId);
            if (order == null || order.getUserId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
                return;
            }
            request.setAttribute("order", order);
            RentalContract contract = contractDAO.getContractByOrderId(orderId);
            request.setAttribute("contract", contract);
            request.getRequestDispatcher("/views/customer/orders.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
        }
    }

    /**
     * Show contract page for an order.
     */
    private void showContract(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
            return;
        }
        try {
            int orderId = Integer.parseInt(orderIdStr);
            RentalOrder order = orderDAO.getOrderById(orderId);
            if (order == null || order.getUserId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
                return;
            }
            RentalContract contract = contractDAO.getContractByOrderId(orderId);
            request.setAttribute("order", order);
            request.setAttribute("contract", contract);
            request.getRequestDispatcher("/views/customer/contract.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
        }
    }

    /**
     * Create a new rental order with wallet payment.
     */
    private void createOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String motorbikeIdStr = request.getParameter("motorbikeId");
        String rentalDateStr = request.getParameter("rentalDate");
        String returnDateStr = request.getParameter("returnDate");

        // Validation
        StringBuilder errors = new StringBuilder();
        if (motorbikeIdStr == null || motorbikeIdStr.isEmpty()) {
            errors.append("Motorbike is required. ");
        }
        if (rentalDateStr == null || rentalDateStr.isEmpty()) {
            errors.append("Pickup date is required. ");
        }
        if (returnDateStr == null || returnDateStr.isEmpty()) {
            errors.append("Return date is required. ");
        }

        if (errors.length() > 0) {
            request.getSession().setAttribute("orderError", errors.toString().trim());
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeIdStr);
            return;
        }

        try {
            int motorbikeId = Integer.parseInt(motorbikeIdStr);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date rentalDate = sdf.parse(rentalDateStr);
            Date returnDate = sdf.parse(returnDateStr);

            // Validate dates
            Date today = new Date();
            if (rentalDate.before(sdf.parse(sdf.format(today)))) {
                request.getSession().setAttribute("orderError", "Pickup date cannot be in the past.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }
            if (!returnDate.after(rentalDate)) {
                request.getSession().setAttribute("orderError", "Return date must be after pickup date.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Block if user has unpaid overdue penalties
            if (overduePenaltyDAO.hasUnpaidPenalties(user.getUserId())) {
                request.getSession().setAttribute("orderError",
                        "You have unpaid overdue penalties. Please pay them before renting a new motorbike.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Check max 3 active rentals
            int activeRentals = orderDAO.getActiveRentalCount(user.getUserId());
            if (activeRentals >= 3) {
                request.getSession().setAttribute("orderError",
                        "You already have " + activeRentals + " active rentals. Maximum 3 allowed at a time.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Get motorbike and check availability
            Motorbike motorbike = motorbikeDAO.getMotorbikeById(motorbikeId);
            if (motorbike == null || !"Available".equals(motorbike.getStatus())) {
                request.getSession().setAttribute("orderError", "This motorbike is not available for rental.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Calculate total
            long diffMillis = returnDate.getTime() - rentalDate.getTime();
            int totalDays = (int) TimeUnit.DAYS.convert(diffMillis, TimeUnit.MILLISECONDS);
            if (totalDays < 1) totalDays = 1;
            double subTotal = totalDays * motorbike.getPricePerDay();

            // Check wallet balance
            Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());
            if (wallet == null || wallet.getBalance() < subTotal) {
                request.getSession().setAttribute("orderError",
                        "Insufficient wallet balance. You need $" + String.format("%.2f", subTotal)
                        + " but your balance is $" + String.format("%.2f", wallet != null ? wallet.getBalance() : 0)
                        + ". Please top up your wallet first.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Create order
            RentalOrder order = new RentalOrder();
            order.setUserId(user.getUserId());
            order.setTotalAmount(subTotal);

            RentalOrderDetail detail = new RentalOrderDetail();
            detail.setMotorbikeId(motorbikeId);
            detail.setRentalDate(rentalDate);
            detail.setReturnDate(returnDate);
            detail.setTotalDays(totalDays);
            detail.setPricePerDay(motorbike.getPricePerDay());
            detail.setSubTotal(subTotal);

            int orderId = orderDAO.createOrder(order, detail);
            if (orderId > 0) {
                // Deduct from wallet
                walletDAO.payFromWallet(user.getUserId(), subTotal, orderId);
                request.getSession().setAttribute("orderSuccess",
                        "Booking created! Order #ORD-" + String.format("%04d", orderId)
                        + ". $" + String.format("%.2f", subTotal) + " deducted from wallet.");
                response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
            } else {
                request.getSession().setAttribute("orderError", "Failed to create booking. Please try again.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
            }

        } catch (NumberFormatException | ParseException e) {
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=list");
        }
    }

    /**
     * Cancel an order (only if status is Pending). Refund wallet.
     */
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId() && "Pending".equals(order.getStatus())) {
                    orderDAO.cancelOrder(orderId, user.getUserId());
                    // Refund wallet
                    walletDAO.refundToWallet(user.getUserId(), order.getTotalAmount(), orderId);
                    request.getSession().setAttribute("orderSuccess",
                            "Order #ORD-" + String.format("%04d", orderId) + " cancelled. $"
                            + String.format("%.2f", order.getTotalAmount()) + " refunded to wallet.");
                } else {
                    request.getSession().setAttribute("orderError", "Cannot cancel this order. Only pending orders can be cancelled.");
                }
            } catch (NumberFormatException e) {
                // Invalid order ID
            }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Customer confirms they received the bike (Renting -> Received).
     */
    private void confirmReceived(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId() && "Renting".equals(order.getStatus())) {
                    orderDAO.updateOrderStatus(orderId, "Received");

                    // Send email
                    String motorbikeName = "N/A";
                    if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                        RentalOrderDetail d = order.getOrderDetails().get(0);
                        motorbikeName = d.getBrandName() + " " + d.getMotorbikeName();
                    }
                    EmailService.sendBikeReceivedEmail(user.getEmail(), user.getFullName(), orderId, motorbikeName);

                    request.getSession().setAttribute("orderSuccess",
                            "You have confirmed receiving the bike for Order #ORD-" + String.format("%04d", orderId) + ".");
                } else {
                    request.getSession().setAttribute("orderError", "Cannot confirm receipt. Order must be in 'Renting' status.");
                }
            } catch (NumberFormatException e) {
                // Invalid
            }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Customer submits contract information (ID card, emergency contact, etc.).
     */
    private void submitContract(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        String idCard = request.getParameter("customerIdCard");
        String idCardImage = request.getParameter("customerIdCardImage");
        String dob = request.getParameter("customerDOB");
        String emergencyName = request.getParameter("emergencyName");
        String emergencyPhone = request.getParameter("emergencyPhone");
        String emergencyRelation = request.getParameter("emergencyRelation");

        if (orderIdStr == null || idCard == null || idCard.isEmpty()
                || idCardImage == null || idCardImage.isEmpty()
                || emergencyName == null || emergencyName.isEmpty()
                || emergencyPhone == null || emergencyPhone.isEmpty()) {
            request.getSession().setAttribute("orderError", "Please fill in all required contract fields.");
            response.sendRedirect(request.getContextPath() + "/orders?action=contract&orderId=" + orderIdStr);
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            RentalOrder order = orderDAO.getOrderById(orderId);
            if (order == null || order.getUserId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
                return;
            }

            // Check if contract already exists
            RentalContract existing = contractDAO.getContractByOrderId(orderId);
            if (existing != null) {
                request.getSession().setAttribute("orderError", "Contract already submitted for this order.");
                response.sendRedirect(request.getContextPath() + "/orders?action=contract&orderId=" + orderId);
                return;
            }

            // Create contract with default terms
            RentalContract contract = new RentalContract();
            contract.setOrderId(orderId);
            contract.setCustomerIdCard(idCard);
            contract.setCustomerIdCardImage(idCardImage);
            if (dob != null && !dob.isEmpty()) {
                try {
                    contract.setCustomerDOB(new SimpleDateFormat("yyyy-MM-dd").parse(dob));
                } catch (ParseException e) { }
            }
            contract.setEmergencyName(emergencyName);
            contract.setEmergencyPhone(emergencyPhone);
            contract.setEmergencyRelation(emergencyRelation);
            contract.setDepositAmount(order.getTotalAmount() * 0.2); // 20% deposit

            // Default terms
            contract.setTerms(
                "RENTAL AGREEMENT TERMS AND CONDITIONS\n\n"
                + "1. The Renter agrees to use the motorbike solely for lawful purposes.\n"
                + "2. The Renter is responsible for any damage, loss, or theft during the rental period.\n"
                + "3. The Renter must return the motorbike in the same condition as received.\n"
                + "4. Late returns will incur a fee of 150% of the daily rate per day.\n"
                + "5. The Renter must not sub-rent or allow unauthorized persons to operate the motorbike.\n"
                + "6. The Renter must carry a valid driver's license at all times.\n"
                + "7. MotoRent reserves the right to reclaim the motorbike at any time if terms are violated.\n"
                + "8. In case of accident, the Renter must notify MotoRent immediately.\n"
                + "9. The security deposit will be refunded upon satisfactory return of the motorbike.\n"
                + "10. Both parties agree to resolve disputes through negotiation first."
            );

            int contractId = contractDAO.createContract(contract);
            if (contractId > 0) {
                request.getSession().setAttribute("orderSuccess", "Contract submitted! Please review and sign it.");
                response.sendRedirect(request.getContextPath() + "/orders?action=contract&orderId=" + orderId);
            } else {
                request.getSession().setAttribute("orderError", "Failed to create contract. Please try again.");
                response.sendRedirect(request.getContextPath() + "/orders?action=contract&orderId=" + orderId);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
        }
    }

    /**
     * Customer signs the contract.
     */
    private void customerSignContract(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId()) {
                    if (contractDAO.customerSign(orderId)) {
                        request.getSession().setAttribute("orderSuccess", "Contract signed successfully!");
                    } else {
                        request.getSession().setAttribute("orderError", "Failed to sign contract.");
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid
            }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=contract&orderId=" + orderIdStr);
    }

    /**
     * Show return inspection page (customer submits evidence or views status).
     */
    private void showReturnInspection(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId()) {
                    ReturnInspection inspection = inspectionDAO.getByOrderId(orderId);
                    boolean hasReviewed = reviewDAO.hasReviewed(user.getUserId(), orderId);
                    OverduePenalty overduePenalty = overduePenaltyDAO.getByOrderId(orderId);
                    request.setAttribute("order", order);
                    request.setAttribute("inspection", inspection);
                    request.setAttribute("hasReviewed", hasReviewed);
                    request.setAttribute("overduePenalty", overduePenalty);
                    request.getRequestDispatcher("/views/customer/return-inspection.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) { }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Show complaint page for a specific order.
     */
    private void showComplaint(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        RentalOrder order = null;
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() != user.getUserId()) {
                    order = null;
                }
            } catch (NumberFormatException e) { }
        }
        List<Complaint> complaints = complaintDAO.getComplaintsByUserId(user.getUserId());
        request.setAttribute("order", order);
        request.setAttribute("complaints", complaints);
        request.getRequestDispatcher("/views/customer/complaint.jsp").forward(request, response);
    }

    /**
     * Customer submits return evidence (photos, video).
     */
    private void submitReturnEvidence(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId() && "Received".equals(order.getStatus())) {
                    // Block return if customer has unpaid overdue penalties
                    if (overduePenaltyDAO.hasUnpaidPenalties(user.getUserId())) {
                        request.getSession().setAttribute("orderError",
                                "You have unpaid overdue penalties. Please pay all penalties before submitting return evidence.");
                        response.sendRedirect(request.getContextPath() + "/orders?action=returnInspection&orderId=" + orderId);
                        return;
                    }
                    if (inspectionDAO.existsForOrder(orderId)) {
                        request.getSession().setAttribute("orderError", "Return evidence already submitted for this order.");
                    } else {
                        ReturnInspection insp = new ReturnInspection();
                        insp.setOrderId(orderId);
                        insp.setPhotoUrl1(request.getParameter("photoUrl1"));
                        insp.setPhotoUrl2(request.getParameter("photoUrl2"));
                        insp.setPhotoUrl3(request.getParameter("photoUrl3"));
                        insp.setVideoUrl(request.getParameter("videoUrl"));
                        insp.setCustomerNotes(request.getParameter("customerNotes"));

                        if (inspectionDAO.submitInspection(insp)) {
                            request.getSession().setAttribute("orderSuccess",
                                    "Return evidence submitted! Staff will review and process your return.");
                        } else {
                            request.getSession().setAttribute("orderError", "Failed to submit return evidence.");
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/orders?action=returnInspection&orderId=" + orderId);
                    return;
                } else {
                    request.getSession().setAttribute("orderError", "Order must be in 'Received' status to submit return evidence.");
                }
            } catch (NumberFormatException e) { }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Customer pays a damage fine from their wallet.
     */
    private void payFine(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                ReturnInspection insp = inspectionDAO.getByOrderId(orderId);
                if (order != null && order.getUserId() == user.getUserId()
                        && insp != null && ("Pending".equals(insp.getFineStatus()) || "Overdue".equals(insp.getFineStatus()))) {
                    double fineAmount = insp.getFineAmount();
                    Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());
                    if (wallet != null && wallet.getBalance() >= fineAmount) {
                        // Deduct fine from wallet
                        walletDAO.payFineFromWallet(user.getUserId(), fineAmount, orderId);
                        inspectionDAO.markFinePaid(orderId);

                        // Mark order as Completed now that fine is paid
                        orderDAO.updateOrderStatus(orderId, "Completed");

                        // Release motorbike from Maintenance
                        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                            for (model.RentalOrderDetail detail : order.getOrderDetails()) {
                                motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Available");
                            }
                        }

                        // Unlock account if it was locked due to overdue fine
                        if (!user.isIsActive()) {
                            dao.UserDAO userDAO = new dao.UserDAO();
                            if (!inspectionDAO.hasOverdueFines(user.getUserId())) {
                                userDAO.toggleUserStatus(user.getUserId());
                                user.setIsActive(true);
                                request.getSession().setAttribute("user", user);
                            }
                        }

                        // Send confirmation email
                        EmailService.sendFinePaidEmail(user.getEmail(), user.getFullName(), orderId, fineAmount);

                        request.getSession().setAttribute("orderSuccess",
                                "Fine of $" + String.format("%.2f", fineAmount) + " paid successfully. Order is now completed.");
                    } else {
                        request.getSession().setAttribute("orderError",
                                "Insufficient wallet balance. You need $" + String.format("%.2f", insp.getFineAmount())
                                + ". Please top up your wallet first.");
                    }
                    response.sendRedirect(request.getContextPath() + "/orders?action=returnInspection&orderId=" + orderId);
                    return;
                }
            } catch (NumberFormatException e) { }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Customer submits a complaint.
     */
    private void submitComplaint(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");

        if (orderIdStr != null && subject != null && !subject.isEmpty()
                && description != null && !description.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId()) {
                    Complaint c = new Complaint();
                    c.setOrderId(orderId);
                    c.setUserId(user.getUserId());
                    c.setSubject(subject);
                    c.setDescription(description);
                    if (complaintDAO.createComplaint(c)) {
                        request.getSession().setAttribute("orderSuccess", "Complaint submitted successfully. We will review it shortly.");
                    } else {
                        request.getSession().setAttribute("orderError", "Failed to submit complaint.");
                    }
                }
            } catch (NumberFormatException e) { }
        } else {
            request.getSession().setAttribute("orderError", "Please fill in all complaint fields.");
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=complaint&orderId=" + orderIdStr);
    }

    /**
     * Customer submits a review for a completed order.
     */
    private void submitReview(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && order.getUserId() == user.getUserId()
                        && ("Returned".equals(order.getStatus()) || "Completed".equals(order.getStatus()))) {
                    if (reviewDAO.hasReviewed(user.getUserId(), orderId)) {
                        request.getSession().setAttribute("orderError", "You have already reviewed this order.");
                    } else {
                        int rating = 5;
                        try { rating = Integer.parseInt(request.getParameter("rating")); } catch (Exception e) { }
                        if (rating < 1) rating = 1;
                        if (rating > 5) rating = 5;
                        String comment = request.getParameter("comment");

                        int motorbikeId = 0;
                        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                            motorbikeId = order.getOrderDetails().get(0).getMotorbikeId();
                        }

                        Review review = new Review();
                        review.setUserId(user.getUserId());
                        review.setMotorbikeId(motorbikeId);
                        review.setOrderId(orderId);
                        review.setRating(rating);
                        review.setComment(comment);

                        if (reviewDAO.addReview(review)) {
                            request.getSession().setAttribute("orderSuccess", "Thank you for your review!");
                        } else {
                            request.getSession().setAttribute("orderError", "Failed to submit review.");
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/orders?action=returnInspection&orderId=" + orderId);
                    return;
                }
            } catch (NumberFormatException e) { }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    /**
     * Customer pays an overdue penalty from wallet.
     */
    private void payOverduePenalty(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                OverduePenalty penalty = overduePenaltyDAO.getByOrderId(orderId);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (penalty != null && order != null && order.getUserId() == user.getUserId()
                        && "Pending".equals(penalty.getStatus())) {
                    double amount = penalty.getTotalPenalty();
                    Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());
                    if (wallet != null && wallet.getBalance() >= amount) {
                        walletDAO.payFineFromWallet(user.getUserId(), amount, orderId);
                        overduePenaltyDAO.markPaid(orderId);

                        EmailService.sendOverduePaidEmail(user.getEmail(), user.getFullName(), orderId, amount);

                        request.getSession().setAttribute("orderSuccess",
                                "Overdue penalty of $" + String.format("%.2f", amount) + " paid successfully.");
                    } else {
                        request.getSession().setAttribute("orderError",
                                "Insufficient wallet balance. You need $" + String.format("%.2f", amount)
                                + ". Please top up your wallet first.");
                    }
                    response.sendRedirect(request.getContextPath() + "/orders?action=returnInspection&orderId=" + orderId);
                    return;
                }
            } catch (NumberFormatException e) { }
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }
}
