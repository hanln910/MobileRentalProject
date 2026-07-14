package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Profile Controller - Handles user profile operations.
 * URL: /profile?action=view|update|changePassword
 */
public class ProfileController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        // Refresh user data
        User freshUser = userDAO.getUserById(user.getUserId());
        if (freshUser != null) {
            session.setAttribute("user", freshUser);
        }
        request.getRequestDispatcher("/views/customer/dashboard.jsp").forward(request, response);
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
        if ("update".equals(action)) {
            updateProfile(request, response, user);
        } else if ("changePassword".equals(action)) {
            changePassword(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/profile");
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        StringBuilder errors = new StringBuilder();
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.append("Full name is required. ");
        }
        if (phone == null || phone.trim().isEmpty()) {
            errors.append("Phone number is required. ");
        }

        if (errors.length() > 0) {
            request.getSession().setAttribute("profileError", errors.toString().trim());
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
            return;
        }

        user.setFullName(fullName.trim());
        user.setPhone(phone.trim());
        user.setAddress(address != null ? address.trim() : "");

        if (userDAO.updateProfile(user)) {
            User freshUser = userDAO.getUserById(user.getUserId());
            request.getSession().setAttribute("user", freshUser);
            request.getSession().setAttribute("profileSuccess", "Profile updated successfully!");
        } else {
            request.getSession().setAttribute("profileError", "Failed to update profile.");
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        StringBuilder errors = new StringBuilder();
        if (currentPassword == null || !currentPassword.equals(user.getPassword())) {
            errors.append("Current password is incorrect. ");
        }
        if (newPassword == null || newPassword.length() < 6) {
            errors.append("New password must be at least 6 characters. ");
        }
        if (confirmPassword == null || !confirmPassword.equals(newPassword)) {
            errors.append("Passwords do not match. ");
        }

        if (errors.length() > 0) {
            request.getSession().setAttribute("profileError", errors.toString().trim());
            response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
            return;
        }

        if (userDAO.changePassword(user.getUserId(), newPassword)) {
            user.setPassword(newPassword);
            request.getSession().setAttribute("user", user);
            request.getSession().setAttribute("profileSuccess", "Password changed successfully!");
        } else {
            request.getSession().setAttribute("profileError", "Failed to change password.");
        }
        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
    }
}
