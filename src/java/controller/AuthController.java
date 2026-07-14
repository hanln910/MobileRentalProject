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
 * Authentication Controller - Handles login, register, logout.
 * URL: /auth?action=login|register|logout
 */
public class AuthController extends HttpServlet {

    protected UserDAO userDAO;

    public AuthController() {
        this.userDAO = new UserDAO();
    }

    // Constructor dùng cho test
    public AuthController(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "login":
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
                break;
            case "register":
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "login":
                doLogin(request, response);
                break;
            case "register":
                doRegister(request, response);
                break;
            case "logout":
                doLogout(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
                break;
        }
    }

    /**
     * Handle login request.
     */
    protected void doLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validation
        StringBuilder errors = new StringBuilder();
        if (email == null || email.trim().isEmpty()) {
            errors.append("Email is required. ");
        } else if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            errors.append("Invalid email format. ");
        }
        if (password == null || password.trim().isEmpty()) {
            errors.append("Password is required. ");
        }

        if (errors.length() > 0) {
            request.setAttribute("error", errors.toString().trim());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Authenticate
        User user = userDAO.login(email.trim(), password);

        if (user != null) {
            if (!user.isIsActive()) {
                request.setAttribute("error", "Your account has been locked. Please contact admin.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
                return;
            }

            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Redirect based on role
            String redirectUrl = (String) session.getAttribute("redirectUrl");
            if (redirectUrl != null) {
                session.removeAttribute("redirectUrl");
                response.sendRedirect(request.getContextPath() + redirectUrl);
            } else {
                switch (user.getRoleId()) {
                    case 1: // Admin
                        response.sendRedirect(request.getContextPath() + "/admin?action=dashboard");
                        break;
                    case 3: // Staff
                        response.sendRedirect(request.getContextPath() + "/staff?action=dashboard");
                        break;
                    default: // Customer
                        response.sendRedirect(request.getContextPath() + "/orders?action=dashboard");
                        break;
                }
            }
        } else {
            request.setAttribute("error", "Invalid email or password.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }

    /**
     * Handle registration request.
     */
    protected void doRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        StringBuilder errors = new StringBuilder();
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.append("Full name is required. ");
        } else if (fullName.trim().length() < 2 || fullName.trim().length() > 100) {
            errors.append("Full name must be between 2 and 100 characters. ");
        }
        if (email == null || email.trim().isEmpty()) {
            errors.append("Email is required. ");
        } else if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            errors.append("Invalid email format. ");
        } else if (userDAO.isEmailExists(email.trim())) {
            errors.append("Email already exists. ");
        }
        if (phone == null || phone.trim().isEmpty()) {
            errors.append("Phone number is required. ");
        } else if (!phone.matches("^[0-9+\\-\\s()]{8,20}$")) {
            errors.append("Invalid phone number format. ");
        }
        if (address == null || address.trim().isEmpty()) {
            errors.append("Address is required. ");
        }
        if (password == null || password.trim().isEmpty()) {
            errors.append("Password is required. ");
        } else if (password.length() < 6) {
            errors.append("Password must be at least 6 characters. ");
        }
        if (confirmPassword == null || !confirmPassword.equals(password)) {
            errors.append("Passwords do not match. ");
        }

        if (errors.length() > 0) {
            request.setAttribute("error", errors.toString().trim());
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // Create user
        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPhone(phone.trim());
        user.setPassword(password);
        user.setAddress(address.trim());

        if (userDAO.register(user)) {
            request.setAttribute("success", "Registration successful! Please login.");
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handle logout request.
     */
    private void doLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
