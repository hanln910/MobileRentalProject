package controller;

import dao.ContractDAO;
import dao.MotorbikeDAO;
import dao.OrderDAO;
import dao.OverduePenaltyDAO;
import dao.ReturnInspectionDAO;
import dao.WalletDAO;
import model.OverduePenalty;
import model.RentalContract;
import model.RentalOrder;
import model.RentalOrderDetail;
import model.ReturnInspection;
import model.User;
import util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Staff Controller - Handles staff operations (order management).
 * URL: /staff?action=dashboard|orders|confirm|startRental|complete|signContract
 * Order workflow: Pending -> Confirmed -> Renting -> Received -> Returned
 */
public class StaffController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final WalletDAO walletDAO = new WalletDAO();
    private final ReturnInspectionDAO inspectionDAO = new ReturnInspectionDAO();
    private final OverduePenaltyDAO overduePenaltyDAO = new OverduePenaltyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 3 && user.getRoleId() != 1)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "dashboard":
                showDashboard(request, response);
                break;
            case "orders":
                showOrders(request, response);
                break;
            case "viewContract":
                viewContract(request, response);
                break;
            case "inspectReturn":
                showInspectReturn(request, response);
                break;
            case "overdueOrders":
                showOverdueOrders(request, response);
                break;
            default:
                showDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 3 && user.getRoleId() != 1)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "confirm":
                confirmOrder(request, response, user);
                break;
            case "startRental":
                startRental(request, response, user);
                break;
            case "complete":
                completeRental(request, response);
                break;
            case "signContract":
                staffSignContract(request, response, user);
                break;
            case "cancelOrder":
                staffCancelOrder(request, response);
                break;
            case "rejectOrder":
                rejectOrder(request, response);
                break;
            case "approveReturn":
                approveReturn(request, response, user);
                break;
            case "issueFine":
                issueFine(request, response, user);
                break;
            case "waiveFine":
                waiveFine(request, response, user);
                break;
            case "issueOverdueWarning":
                issueOverdueWarning(request, response, user);
                break;
            case "waiveOverduePenalty":
                waiveOverduePenalty(request, response, user);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
                break;
        }
    }

    /**
     * Show staff dashboard with order statistics and pagination.
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int totalOrders = orderDAO.getTotalOrders();
        int pendingOrders = orderDAO.getOrderCountByStatus("Pending");
        int confirmedOrders = orderDAO.getOrderCountByStatus("Confirmed");
        int activeRentals = orderDAO.getOrderCountByStatus("Renting");
        int receivedOrders = orderDAO.getOrderCountByStatus("Received");
        int returnedOrders = orderDAO.getOrderCountByStatus("Returned");
        int finedOrders = orderDAO.getOrderCountByStatus("Fined");

        // Filtering
        String statusFilter = request.getParameter("status");

        // Pagination
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) { }
        if (page < 1) page = 1;

        List<RentalOrder> orders;
        int totalRecords;
        if (statusFilter != null && !statusFilter.isEmpty()) {
            orders = orderDAO.getOrdersByStatusPaged(statusFilter, page, pageSize);
            totalRecords = orderDAO.getOrderCountByStatus(statusFilter);
        } else {
            orders = orderDAO.getAllOrdersPaged(page, pageSize);
            totalRecords = totalOrders;
        }
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("pendingOrders", pendingOrders);
        request.setAttribute("confirmedOrders", confirmedOrders);
        request.setAttribute("activeRentals", activeRentals);
        request.setAttribute("receivedOrders", receivedOrders);
        request.setAttribute("returnedOrders", returnedOrders);
        request.setAttribute("finedOrders", finedOrders);
        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("statusFilter", statusFilter);

        request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
    }

    /**
     * Show all orders for management with pagination.
     */
    private void showOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = 1;
        int pageSize = 15;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) { }
        if (page < 1) page = 1;

        List<RentalOrder> orders = orderDAO.getAllOrdersPaged(page, pageSize);
        int totalRecords = orderDAO.getTotalOrders();
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/views/staff/manage-orders.jsp").forward(request, response);
    }

    /**
     * Confirm order (Pending -> Confirmed) + send email.
     */
    private void confirmOrder(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && "Pending".equals(order.getStatus())) {
                    orderDAO.updateOrderStatus(orderId, "Confirmed");

                    // Get motorbike name for email
                    String motorbikeName = getMotorbikeName(order);

                    // Send email notification
                    EmailService.sendOrderConfirmedEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName);

                    request.getSession().setAttribute("staffSuccess",
                            "Order #ORD-" + String.format("%04d", orderId) + " confirmed. Customer notified by email.");
                } else {
                    request.getSession().setAttribute("staffError", "Order must be in Pending status to confirm.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Start rental (Confirmed -> Renting). Requires contract to be fully signed.
     * Updates motorbike status + sends email.
     */
    private void startRental(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && "Confirmed".equals(order.getStatus())) {
                    // Check contract is fully signed
                    if (!contractDAO.isFullySigned(orderId)) {
                        request.getSession().setAttribute("staffError",
                                "Contract must be signed by both parties before starting rental. Please sign the contract first.");
                        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
                        return;
                    }

                    orderDAO.updateOrderStatus(orderId, "Renting");
                    // Update motorbike status to Rented
                    if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                        for (RentalOrderDetail detail : order.getOrderDetails()) {
                            motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Rented");
                        }
                    }

                    String motorbikeName = getMotorbikeName(order);
                    EmailService.sendRentalStartedEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName);

                    request.getSession().setAttribute("staffSuccess",
                            "Rental started for Order #ORD-" + String.format("%04d", orderId) + ". Customer notified.");
                } else {
                    request.getSession().setAttribute("staffError", "Order must be confirmed before starting rental.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Complete rental (Received -> Returned). Update motorbike + contract + send email.
     */
    private void completeRental(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && "Received".equals(order.getStatus())) {
                    orderDAO.updateOrderStatus(orderId, "Returned");
                    // Update motorbike status back to Available
                    if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                        for (RentalOrderDetail detail : order.getOrderDetails()) {
                            motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Available");
                        }
                    }
                    // Complete contract
                    contractDAO.completeContract(orderId);

                    String motorbikeName = getMotorbikeName(order);
                    EmailService.sendRentalCompletedEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName);

                    request.getSession().setAttribute("staffSuccess",
                            "Rental completed for Order #ORD-" + String.format("%04d", orderId) + ". Customer notified.");
                } else {
                    request.getSession().setAttribute("staffError",
                            "Order must be in 'Received' status (customer confirmed bike receipt) to complete.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * View contract page for a given order.
     */
    private void viewContract(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                RentalContract contract = contractDAO.getContractByOrderId(orderId);
                request.setAttribute("order", order);
                request.setAttribute("contract", contract);
                request.getRequestDispatcher("/views/customer/contract.jsp").forward(request, response);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Staff signs the contract for an order.
     */
    private void staffSignContract(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                if (contractDAO.staffSign(orderId, staff.getUserId())) {
                    request.getSession().setAttribute("staffSuccess",
                            "Contract signed for Order #ORD-" + String.format("%04d", orderId));
                } else {
                    request.getSession().setAttribute("staffError", "Failed to sign contract. Contract may not exist yet.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=viewContract&orderId=" + orderId);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Staff cancels an order + refund to wallet + send email.
     */
    private void staffCancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && ("Pending".equals(order.getStatus()) || "Confirmed".equals(order.getStatus()))) {
                    orderDAO.updateOrderStatus(orderId, "Cancelled");
                    // Refund wallet
                    boolean refunded = walletDAO.refundToWallet(order.getUserId(), order.getTotalAmount(), orderId);
                    // Void contract if exists
                    contractDAO.voidContract(orderId);

                    String motorbikeName = getMotorbikeName(order);
                    EmailService.sendOrderCancelledEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName, refunded);

                    request.getSession().setAttribute("staffSuccess",
                            "Order #ORD-" + String.format("%04d", orderId) + " cancelled." + (refunded ? " Wallet refunded." : ""));
                } else {
                    request.getSession().setAttribute("staffError", "Only Pending or Confirmed orders can be cancelled.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Reject a pending order with a reason. Refund wallet + send email.
     */
    private void rejectOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        String rejectReason = request.getParameter("rejectReason");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && "Pending".equals(order.getStatus())) {
                    if (rejectReason == null || rejectReason.trim().isEmpty()) {
                        rejectReason = "Order rejected by staff.";
                    }
                    orderDAO.rejectOrder(orderId, rejectReason.trim());
                    boolean refunded = walletDAO.refundToWallet(order.getUserId(), order.getTotalAmount(), orderId);

                    String motorbikeName = getMotorbikeName(order);
                    EmailService.sendOrderRejectedEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName, rejectReason.trim(), refunded);

                    request.getSession().setAttribute("staffSuccess",
                            "Order #ORD-" + String.format("%04d", orderId) + " rejected." + (refunded ? " Wallet refunded." : ""));
                } else {
                    request.getSession().setAttribute("staffError", "Only Pending orders can be rejected.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Show inspect return page for a given order.
     */
    private void showInspectReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                ReturnInspection inspection = inspectionDAO.getByOrderId(orderId);
                request.setAttribute("order", order);
                request.setAttribute("inspection", inspection);
                request.getRequestDispatcher("/views/staff/inspect-return.jsp").forward(request, response);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Approve return - bike in good condition. Complete the order + send thank-you email.
     */
    private void approveReturn(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                String staffNotes = request.getParameter("staffNotes");
                if (order != null && "Received".equals(order.getStatus())) {
                    if (inspectionDAO.approveReturn(orderId, staff.getUserId(), staffNotes)) {
                        // Mark order as Completed (no damage)
                        orderDAO.updateOrderStatus(orderId, "Completed");
                        // Update motorbike status
                        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                            for (RentalOrderDetail detail : order.getOrderDetails()) {
                                motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Available");
                            }
                        }
                        contractDAO.completeContract(orderId);

                        String motorbikeName = getMotorbikeName(order);
                        EmailService.sendThankYouEmail(
                                order.getCustomerEmail(), order.getCustomerName(),
                                orderId, motorbikeName);

                        request.getSession().setAttribute("staffSuccess",
                                "Return approved for Order #ORD-" + String.format("%04d", orderId) + ". Customer received thank-you email.");
                    } else {
                        request.getSession().setAttribute("staffError", "Failed to approve return. Inspection may not exist.");
                    }
                } else {
                    request.getSession().setAttribute("staffError", "Order must be in 'Received' status.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=inspectReturn&orderId=" + orderId);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Issue a damage fine. Send fine notification email to customer.
     * Order stays in Received status until fine is paid, then staff completes.
     */
    private void issueFine(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                String staffNotes = request.getParameter("staffNotes");
                String fineAmountStr = request.getParameter("fineAmount");
                String fineReason = request.getParameter("fineReason");

                if (order != null && "Received".equals(order.getStatus())
                        && fineAmountStr != null && fineReason != null && !fineReason.isEmpty()) {
                    double fineAmount = Double.parseDouble(fineAmountStr);
                    if (fineAmount <= 0) {
                        request.getSession().setAttribute("staffError", "Fine amount must be greater than 0.");
                        response.sendRedirect(request.getContextPath() + "/staff?action=inspectReturn&orderId=" + orderId);
                        return;
                    }

                    if (inspectionDAO.issueFine(orderId, staff.getUserId(), staffNotes, fineAmount, fineReason)) {
                        // Mark order as Fined (pending fine payment)
                        orderDAO.updateOrderStatus(orderId, "Fined");
                        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                            for (RentalOrderDetail detail : order.getOrderDetails()) {
                                motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Maintenance");
                            }
                        }
                        contractDAO.completeContract(orderId);

                        String motorbikeName = getMotorbikeName(order);
                        EmailService.sendFineNotificationEmail(
                                order.getCustomerEmail(), order.getCustomerName(),
                                orderId, motorbikeName, fineAmount, fineReason);

                        request.getSession().setAttribute("staffSuccess",
                                "Fine of $" + String.format("%.2f", fineAmount) + " issued for Order #ORD-"
                                + String.format("%04d", orderId) + ". Customer notified by email (48h deadline).");
                    } else {
                        request.getSession().setAttribute("staffError", "Failed to issue fine. Inspection may not exist.");
                    }
                } else {
                    request.getSession().setAttribute("staffError", "Invalid data. Ensure order is in Received status and fine details are provided.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=inspectReturn&orderId=" + orderId);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid input.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Staff waives a fine (e.g. after admin approves complaint).
     * Marks order Completed, unlocks account if locked, refunds if already paid, sends email.
     */
    private void waiveFine(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                ReturnInspection insp = inspectionDAO.getByOrderId(orderId);

                if (order != null && insp != null && "Damaged".equals(insp.getCondition())
                        && ("Pending".equals(insp.getFineStatus()) || "Overdue".equals(insp.getFineStatus()) || "Paid".equals(insp.getFineStatus()))) {

                    double fineAmount = insp.getFineAmount();
                    boolean wasPaid = "Paid".equals(insp.getFineStatus());

                    // If fine was already paid, refund to customer wallet
                    if (wasPaid) {
                        walletDAO.refundToWallet(order.getUserId(), fineAmount, orderId);
                    }

                    // Waive the fine
                    inspectionDAO.waiveFine(orderId);

                    // Mark order as Completed
                    orderDAO.updateOrderStatus(orderId, "Completed");

                    // Release motorbike from Maintenance
                    if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                        for (RentalOrderDetail detail : order.getOrderDetails()) {
                            motorbikeDAO.updateMotorbikeStatus(detail.getMotorbikeId(), "Available");
                        }
                    }

                    // Unlock customer account if it was locked
                    try {
                        dao.UserDAO userDAO = new dao.UserDAO();
                        model.User customer = userDAO.getUserById(order.getUserId());
                        if (customer != null && !customer.isIsActive()) {
                            userDAO.toggleUserStatus(order.getUserId());
                        }
                    } catch (Exception e) { /* best effort */ }

                    // Send email to customer
                    String motorbikeName = getMotorbikeName(order);
                    EmailService.sendFineWaivedEmail(
                            order.getCustomerEmail(), order.getCustomerName(),
                            orderId, motorbikeName, fineAmount);

                    String refundMsg = wasPaid ? " Fine amount has been refunded to customer wallet." : "";
                    request.getSession().setAttribute("staffSuccess",
                            "Fine of $" + String.format("%.2f", fineAmount) + " waived for Order #ORD-"
                            + String.format("%04d", orderId) + ". Customer notified by email." + refundMsg);
                } else {
                    request.getSession().setAttribute("staffError", "Cannot waive fine. Order or fine status is invalid.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=inspectReturn&orderId=" + orderId);
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
    }

    /**
     * Show overdue orders list for staff management.
     */
    private void showOverdueOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<OverduePenalty> overdueOrders = overduePenaltyDAO.getOverdueOrders();
        request.setAttribute("overdueOrders", overdueOrders);
        request.getRequestDispatcher("/views/staff/overdue-orders.jsp").forward(request, response);
    }

    /**
     * Staff issues an overdue warning: creates/updates penalty record and sends email.
     */
    private void issueOverdueWarning(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                RentalOrder order = orderDAO.getOrderById(orderId);
                if (order != null && ("Renting".equals(order.getStatus()) || "Received".equals(order.getStatus()))) {
                    // Calculate overdue days from order detail returnDate
                    if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                        RentalOrderDetail detail = order.getOrderDetails().get(0);
                        long diffMillis = System.currentTimeMillis() - detail.getReturnDate().getTime();
                        int overdueDays = (int) (diffMillis / (1000 * 60 * 60 * 24));
                        if (overdueDays > 0) {
                            double totalPenalty = overdueDays * 10.00;
                            overduePenaltyDAO.issuePenalty(orderId, order.getUserId(), overdueDays);

                            String motorbikeName = getMotorbikeName(order);
                            EmailService.sendOverdueWarningEmail(
                                    order.getCustomerEmail(), order.getCustomerName(),
                                    orderId, motorbikeName, overdueDays, totalPenalty);

                            request.getSession().setAttribute("staffSuccess",
                                    "Overdue warning issued for Order #ORD-" + String.format("%04d", orderId)
                                    + " (" + overdueDays + " days, $" + String.format("%.2f", totalPenalty) + "). Customer notified.");
                        } else {
                            request.getSession().setAttribute("staffError", "This order is not overdue yet.");
                        }
                    }
                } else {
                    request.getSession().setAttribute("staffError", "Order not found or not in rental status.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=overdueOrders");
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=overdueOrders");
    }

    /**
     * Staff waives an overdue penalty.
     */
    private void waiveOverduePenalty(HttpServletRequest request, HttpServletResponse response, User staff)
            throws IOException {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                OverduePenalty penalty = overduePenaltyDAO.getByOrderId(orderId);
                if (penalty != null && "Pending".equals(penalty.getStatus())) {
                    overduePenaltyDAO.waivePenalty(orderId);
                    request.getSession().setAttribute("staffSuccess",
                            "Overdue penalty of $" + String.format("%.2f", penalty.getTotalPenalty())
                            + " waived for Order #ORD-" + String.format("%04d", orderId) + ".");
                } else {
                    request.getSession().setAttribute("staffError", "No pending penalty found for this order.");
                }
                response.sendRedirect(request.getContextPath() + "/staff?action=overdueOrders");
                return;
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("staffError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff?action=overdueOrders");
    }

    /**
     * Helper: get motorbike name from order details.
     */
    private String getMotorbikeName(RentalOrder order) {
        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
            RentalOrderDetail d = order.getOrderDetails().get(0);
            return d.getBrandName() + " " + d.getMotorbikeName();
        }
        return "N/A";
    }
}
