package controller;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ComplaintDAO;
import dao.ContractDAO;
import dao.MotorbikeDAO;
import dao.OrderDAO;
import dao.UserDAO;
import model.Brand;
import model.Category;
import model.Complaint;
import model.Motorbike;
import model.RentalContract;
import model.RentalOrder;
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
 * Admin Controller - Handles admin operations.
 * URL: /admin?action=dashboard|manageUsers|manageMotorbikes|manageOrders|addMotorbike|editMotorbike|deleteMotorbike|toggleUser|deleteUser|createStaff|manageCategories
 */
public class AdminController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "dashboard":
                showDashboard(request, response);
                break;
            case "manageUsers":
                manageUsers(request, response);
                break;
            case "manageMotorbikes":
                manageMotorbikes(request, response);
                break;
            case "manageOrders":
                manageOrders(request, response);
                break;
            case "addMotorbike":
                showAddMotorbikeForm(request, response);
                break;
            case "editMotorbike":
                showEditMotorbikeForm(request, response);
                break;
            case "manageCategories":
                manageCategories(request, response);
                break;
            case "manageBrands":
                manageBrands(request, response);
                break;
            case "viewContract":
                viewContract(request, response);
                break;
            case "manageComplaints":
                manageComplaints(request, response);
                break;
            default:
                showDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "addMotorbike":
                doAddMotorbike(request, response);
                break;
            case "editMotorbike":
                doEditMotorbike(request, response);
                break;
            case "deleteMotorbike":
                doDeleteMotorbike(request, response);
                break;
            case "toggleUser":
                doToggleUser(request, response);
                break;
            case "deleteUser":
                doDeleteUser(request, response);
                break;
            case "createStaff":
                doCreateStaff(request, response);
                break;
            case "addCategory":
                doAddCategory(request, response);
                break;
            case "editCategory":
                doEditCategory(request, response);
                break;
            case "deleteCategory":
                doDeleteCategory(request, response);
                break;
            case "addBrand":
                doAddBrand(request, response);
                break;
            case "editBrand":
                doEditBrand(request, response);
                break;
            case "deleteBrand":
                doDeleteBrand(request, response);
                break;
            case "signContract":
                doSignContract(request, response);
                break;
            case "respondComplaint":
                doRespondComplaint(request, response, user);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin?action=dashboard");
                break;
        }
    }

    // =============================================
    // GET HANDLERS
    // =============================================

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int totalUsers = userDAO.getTotalUsers();
        int totalMotorbikes = motorbikeDAO.getTotalMotorbikes();
        int totalOrders = orderDAO.getTotalOrders();
        double totalRevenue = orderDAO.getTotalRevenue();
        List<Double> monthlyRevenue = orderDAO.getMonthlyRevenue();
        List<Integer> monthlyOrderCounts = orderDAO.getMonthlyOrderCounts();

        // Order status breakdown
        int pendingOrders = orderDAO.getOrderCountByStatus("Pending");
        int confirmedOrders = orderDAO.getOrderCountByStatus("Confirmed");
        int activeRentals = orderDAO.getOrderCountByStatus("Renting");
        int receivedOrders = orderDAO.getOrderCountByStatus("Received");
        int returnedOrders = orderDAO.getOrderCountByStatus("Returned");
        int finedOrders = orderDAO.getOrderCountByStatus("Fined");
        int completedOrders = orderDAO.getOrderCountByStatus("Completed");
        int cancelledOrders = orderDAO.getOrderCountByStatus("Cancelled");

        List<RentalOrder> recentOrders = orderDAO.getAllOrders();

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalMotorbikes", totalMotorbikes);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("monthlyOrderCounts", monthlyOrderCounts);
        request.setAttribute("pendingOrders", pendingOrders);
        request.setAttribute("confirmedOrders", confirmedOrders);
        request.setAttribute("activeRentals", activeRentals);
        request.setAttribute("receivedOrders", receivedOrders);
        request.setAttribute("returnedOrders", returnedOrders);
        request.setAttribute("finedOrders", finedOrders);
        request.setAttribute("completedOrders", completedOrders);
        request.setAttribute("cancelledOrders", cancelledOrders);
        request.setAttribute("recentOrders", recentOrders);

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    private void manageUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/views/admin/manage-users.jsp").forward(request, response);
    }

    private void manageMotorbikes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Motorbike> motorbikes = motorbikeDAO.getAllMotorbikes();
        List<Brand> brands = brandDAO.getAllBrands();
        List<Category> categories = categoryDAO.getAllCategories();

        request.setAttribute("motorbikes", motorbikes);
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/views/admin/manage-motorbikes.jsp").forward(request, response);
    }

    private void manageOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<RentalOrder> orders = orderDAO.getAllOrders();
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/views/admin/manage-orders.jsp").forward(request, response);
    }

    private void showAddMotorbikeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Brand> brands = brandDAO.getAllBrands();
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/views/admin/manage-motorbikes.jsp").forward(request, response);
    }

    private void showEditMotorbikeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                Motorbike motorbike = motorbikeDAO.getMotorbikeById(id);
                request.setAttribute("editMotorbike", motorbike);
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        manageMotorbikes(request, response);
    }

    private void manageCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/views/admin/manage-categories.jsp").forward(request, response);
    }

    private void manageBrands(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Brand> brands = brandDAO.getAllBrands();
        request.setAttribute("brands", brands);
        request.getRequestDispatcher("/views/admin/manage-brands.jsp").forward(request, response);
    }


    // =============================================
    // POST HANDLERS
    // =============================================

    private void doAddMotorbike(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = request.getParameter("name");
        String brandIdStr = request.getParameter("brandId");
        String categoryIdStr = request.getParameter("categoryId");
        String yearStr = request.getParameter("year");
        String priceStr = request.getParameter("pricePerDay");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String imageUrl = request.getParameter("imageUrl");

        // Validation
        if (name == null || name.trim().isEmpty() || brandIdStr == null || categoryIdStr == null
                || priceStr == null || priceStr.trim().isEmpty()) {
            request.getSession().setAttribute("adminError", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
            return;
        }

        try {
            int year = yearStr.isEmpty() ? Integer.parseInt(yearStr) : 2024;
            double pricePerDay = Double.parseDouble(priceStr);
            if (pricePerDay <= 0){
                request.getSession().setAttribute("adminError", "Price per day must be greater than 0");;
                response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
            }
            Motorbike motorbike = new Motorbike();
            motorbike.setName(name.trim());
            motorbike.setBrandId(Integer.parseInt(brandIdStr));
            motorbike.setCategoryId(Integer.parseInt(categoryIdStr));
            motorbike.setYear(yearStr != null && !yearStr.isEmpty() ? Integer.parseInt(yearStr) : 2024);
            motorbike.setPricePerDay(Double.parseDouble(priceStr));
            motorbike.setDescription(description != null ? description.trim() : "");
            motorbike.setStatus(status != null ? status : "Available");
            motorbike.setImageUrl(imageUrl != null && !imageUrl.trim().isEmpty() ? imageUrl.trim()
                    : "https://images.unsplash.com/photo-1568772585407-9361f9bf3c87?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80");

            int id = motorbikeDAO.addMotorbike(motorbike);
            if (id > 0) {
                request.getSession().setAttribute("adminSuccess", "Motorbike added successfully!");
            } else {
                request.getSession().setAttribute("adminError", "Failed to add motorbike.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("adminError", "Invalid input data.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
    }

    private void doEditMotorbike(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("motorbikeId");
        String name = request.getParameter("name");
        String brandIdStr = request.getParameter("brandId");
        String categoryIdStr = request.getParameter("categoryId");
        String yearStr = request.getParameter("year");
        String priceStr = request.getParameter("pricePerDay");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String imageUrl = request.getParameter("imageUrl");

        if (idStr == null || name == null || name.trim().isEmpty()) {
            request.getSession().setAttribute("adminError", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
            return;
        }

        try {
            int year = yearStr.isEmpty() ? Integer.parseInt(yearStr) : 2024;
            double pricePerDay = Double.parseDouble(priceStr);
            if (pricePerDay <= 0){
                request.getSession().setAttribute("adminError", "Price per day must be greater than 0");;
                response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
            }
            Motorbike motorbike = new Motorbike();
            motorbike.setMotorbikeId(Integer.parseInt(idStr));
            motorbike.setName(name.trim());
            motorbike.setBrandId(Integer.parseInt(brandIdStr));
            motorbike.setCategoryId(Integer.parseInt(categoryIdStr));
            motorbike.setYear(yearStr != null && !yearStr.isEmpty() ? Integer.parseInt(yearStr) : 2024);
            motorbike.setPricePerDay(Double.parseDouble(priceStr));
            motorbike.setDescription(description != null ? description.trim() : "");
            motorbike.setStatus(status != null ? status : "Available");
            motorbike.setImageUrl(imageUrl != null ? imageUrl.trim() : "");

            if (motorbikeDAO.updateMotorbike(motorbike)) {
                request.getSession().setAttribute("adminSuccess", "Motorbike updated successfully!");
            } else {
                request.getSession().setAttribute("adminError", "Failed to update motorbike.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("adminError", "Invalid input data.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
    }

    private void doDeleteMotorbike(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("motorbikeId");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                if (motorbikeDAO.deleteMotorbike(id)) {
                    request.getSession().setAttribute("adminSuccess", "Motorbike deleted successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to delete motorbike. It may have active orders.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid motorbike ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
    }

    private void doToggleUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String userIdStr = request.getParameter("userId");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                if (userDAO.toggleUserStatus(userId)) {
                    request.getSession().setAttribute("adminSuccess", "User status updated successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to update user status.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid user ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageUsers");
    }

    private void doDeleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String userIdStr = request.getParameter("userId");
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                int userId = Integer.parseInt(userIdStr);
                if (userDAO.deleteUser(userId)) {
                    request.getSession().setAttribute("adminSuccess", "User deleted successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to delete user. User may have active orders.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid user ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageUsers");
    }

    private void doCreateStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        // Validation
        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.getSession().setAttribute("adminError", "Full name, email and password are required.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageUsers");
            return;
        }
        if (userDAO.isEmailExists(email.trim())) {
            request.getSession().setAttribute("adminError", "Email already exists.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageUsers");
            return;
        }

        User staff = new User();
        staff.setFullName(fullName.trim());
        staff.setEmail(email.trim());
        staff.setPhone(phone != null ? phone.trim() : "");
        staff.setPassword(password);
        staff.setAddress(address != null ? address.trim() : "");

        if (userDAO.createStaffAccount(staff)) {
            request.getSession().setAttribute("adminSuccess", "Staff account created successfully!");
        } else {
            request.getSession().setAttribute("adminError", "Failed to create staff account.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageUsers");
    }

    private void doAddCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");

        if (categoryName == null || categoryName.trim().isEmpty()) {
            request.getSession().setAttribute("adminError", "Category name is required.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageMotorbikes");
            return;
        }

        Category category = new Category();
        category.setCategoryName(categoryName.trim());
        category.setDescription(description != null ? description.trim() : "");

        if (categoryDAO.addCategory(category)) {
            request.getSession().setAttribute("adminSuccess", "Category added successfully!");
        } else {
            request.getSession().setAttribute("adminError", "Failed to add category. Name may already exist.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageCategories");
    }

    private void doEditCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("categoryId");
        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");
        if (idStr != null && categoryName != null && !categoryName.trim().isEmpty()) {
            try {
                Category category = new Category();
                category.setCategoryId(Integer.parseInt(idStr));
                category.setCategoryName(categoryName.trim());
                category.setDescription(description != null ? description.trim() : "");
                if (categoryDAO.updateCategory(category)) {
                    request.getSession().setAttribute("adminSuccess", "Category updated successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to update category.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid category ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageCategories");
    }

    private void doDeleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("categoryId");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                if (categoryDAO.deleteCategory(id)) {
                    request.getSession().setAttribute("adminSuccess", "Category deleted successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to delete category. It may be in use by motorbikes.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid category ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageCategories");
    }

    private void doAddBrand(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String brandName = request.getParameter("brandName");
        String logo = request.getParameter("logo");
        if (brandName == null || brandName.trim().isEmpty()) {
            request.getSession().setAttribute("adminError", "Brand name is required.");
            response.sendRedirect(request.getContextPath() + "/admin?action=manageBrands");
            return;
        }
        Brand brand = new Brand();
        brand.setBrandName(brandName.trim());
        brand.setLogo(logo != null ? logo.trim() : "");
        if (brandDAO.addBrand(brand)) {
            request.getSession().setAttribute("adminSuccess", "Brand added successfully!");
        } else {
            request.getSession().setAttribute("adminError", "Failed to add brand. Name may already exist.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageBrands");
    }

    private void doEditBrand(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("brandId");
        String brandName = request.getParameter("brandName");
        String logo = request.getParameter("logo");
        if (idStr != null && brandName != null && !brandName.trim().isEmpty()) {
            try {
                Brand brand = new Brand();
                brand.setBrandId(Integer.parseInt(idStr));
                brand.setBrandName(brandName.trim());
                brand.setLogo(logo != null ? logo.trim() : "");
                if (brandDAO.updateBrand(brand)) {
                    request.getSession().setAttribute("adminSuccess", "Brand updated successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to update brand.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid brand ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageBrands");
    }

    private void doDeleteBrand(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("brandId");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                if (brandDAO.deleteBrand(id)) {
                    request.getSession().setAttribute("adminSuccess", "Brand deleted successfully!");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to delete brand. It may be in use by motorbikes.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid brand ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageBrands");
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
                request.getSession().setAttribute("adminError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageOrders");
    }

    /**
     * Admin signs the contract (as staff role).
     */
    private void doSignContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                if (contractDAO.staffSign(orderId, user.getUserId())) {
                    session.setAttribute("adminSuccess",
                            "Contract signed for Order #ORD-" + String.format("%04d", orderId));
                } else {
                    session.setAttribute("adminError", "Failed to sign contract. Contract may not exist yet.");
                }
                response.sendRedirect(request.getContextPath() + "/admin?action=viewContract&orderId=" + orderId);
                return;
            } catch (NumberFormatException e) {
                session.setAttribute("adminError", "Invalid order ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageOrders");
    }

    /**
     * Show all complaints for admin management.
     */
    private void manageComplaints(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Complaint> complaints = complaintDAO.getAllComplaints();
        int openCount = complaintDAO.countOpenComplaints();
        request.setAttribute("complaints", complaints);
        request.setAttribute("openCount", openCount);
        request.getRequestDispatcher("/views/admin/manage-complaints.jsp").forward(request, response);
    }

    /**
     * Admin responds to a complaint.
     */
    private void doRespondComplaint(HttpServletRequest request, HttpServletResponse response, User admin)
            throws IOException {
        String complaintIdStr = request.getParameter("complaintId");
        String adminResponse = request.getParameter("adminResponse");
        String newStatus = request.getParameter("newStatus");

        if (complaintIdStr != null && adminResponse != null && !adminResponse.isEmpty()
                && newStatus != null && !newStatus.isEmpty()) {
            try {
                int complaintId = Integer.parseInt(complaintIdStr);
                if (complaintDAO.respondToComplaint(complaintId, newStatus, adminResponse, admin.getUserId())) {
                    // Send email notification to customer
                    Complaint complaint = complaintDAO.getById(complaintId);
                    if (complaint != null && complaint.getCustomerEmail() != null) {
                        EmailService.sendComplaintResponseEmail(
                                complaint.getCustomerEmail(), complaint.getCustomerName(),
                                complaintId, complaint.getSubject(), newStatus, adminResponse);
                    }
                    request.getSession().setAttribute("adminSuccess", "Complaint responded successfully. Customer notified by email.");
                } else {
                    request.getSession().setAttribute("adminError", "Failed to respond to complaint.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("adminError", "Invalid complaint ID.");
            }
        } else {
            request.getSession().setAttribute("adminError", "Please provide a response and status.");
        }
        response.sendRedirect(request.getContextPath() + "/admin?action=manageComplaints");
    }
}
