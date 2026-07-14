package filter;
import dao.ReturnInspectionDAO;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

/**
 * Authentication and Authorization Filter.
 * Controls access to resources based on user roles.
 * 
 * Role IDs: 1 = Admin, 2 = Customer, 3 = Staff
 */
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());
    private static long lastFineCheckTime = 0;
    private static final long FINE_CHECK_INTERVAL = 5 * 60 * 1000; // 5 minutes

    // Public URLs accessible by everyone (Guest)
    private static final List<String> PUBLIC_URLS = Arrays.asList(
            "/home", "/HomeController",
            "/auth", "/motorbikes",
            "/reviews", "/chatbot"
    );

    // URLs that require Customer role
    private static final List<String> CUSTOMER_URLS = Arrays.asList(
            "/orders", "/profile", "/wallet"
    );

    // URLs that require Staff role
    private static final List<String> STAFF_URLS = Arrays.asList(
            "/staff"
    );

    // URLs that require Admin role
    private static final List<String> ADMIN_URLS = Arrays.asList(
            "/admin"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Filter initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.substring(contextPath.length());

        // Allow access to static resources (CSS, JS, images, fonts)
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Allow access to public URLs
        if (isPublicUrl(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Allow access to JSP views inside WEB-INF (should not be accessed directly)
        if (path.startsWith("/views/") || path.startsWith("/WEB-INF/")) {
            httpResponse.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Get user from session
        HttpSession session = httpRequest.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("user");
        }

        // Periodically enforce overdue fines (every 5 minutes)
        long now = System.currentTimeMillis();
        if (now - lastFineCheckTime > FINE_CHECK_INTERVAL) {
            lastFineCheckTime = now;
            try {
                ReturnInspectionDAO inspDAO = new ReturnInspectionDAO();
                int enforced = inspDAO.enforceOverdueFines();
                if (enforced > 0) {
                    LOGGER.info("Enforced " + enforced + " overdue fine(s). Accounts locked.");
                }
            } catch (Exception e) {
                LOGGER.warning("Fine enforcement check failed: " + e.getMessage());
            }
        }

        // Check if user is logged in
        if (user == null) {

            // Save the requested URL for redirect after login
            String queryString = httpRequest.getQueryString();
            String redirectUrl = path;
            if (queryString != null && !queryString.isEmpty()){
                redirectUrl += "?" + queryString;
            }
            httpRequest.getSession().setAttribute("redirectUrl", uri);
            httpResponse.sendRedirect(contextPath + "/auth?action=login");
            return;
        }

        // Check if user account has been locked (e.g. due to overdue fines)
        if (!user.isIsActive()) {
            // Refresh from DB to confirm
            try {
                UserDAO userDAO = new UserDAO();
                User fresh = userDAO.getUserById(user.getUserId());
                if (fresh != null && !fresh.isIsActive()) {
                    session.invalidate();
                    httpRequest.getSession().setAttribute("error",
                            "Your account has been locked due to unpaid fines. Please contact support.");
                    httpResponse.sendRedirect(contextPath + "/auth?action=login");
                    return;
                } else if (fresh != null) {
                    session.setAttribute("user", fresh);
                    user = fresh;
                }
            } catch (Exception e) {
                LOGGER.warning("Error checking user active status: " + e.getMessage());
            }
        }

        int roleId = user.getRoleId();

        // Check authorization based on URL and role
        if (isCustomerUrl(path)) {
            // Customer URLs: accessible by Customer (2), Staff (3), Admin (1)
            if (roleId == 2 || roleId == 3 || roleId == 1) {
                chain.doFilter(request, response);
            } else {
                httpResponse.sendRedirect(contextPath + "/home");
            }
            return;
        }

        if (isStaffUrl(path)) {
            // Staff URLs: accessible by Staff (3) and Admin (1)
            if (roleId == 3 || roleId == 1) {
                chain.doFilter(request, response);
            } else {
                httpResponse.sendRedirect(contextPath + "/home");
            }
            return;
        }

        if (isAdminUrl(path)) {
            // Admin URLs: accessible by Admin (1) only
            if (roleId == 1) {
                chain.doFilter(request, response);
            } else {
                httpResponse.sendRedirect(contextPath + "/home");
            }
            return;
        }

        // Default: allow access for logged-in users
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Filter cleanup
    }

    /**
     * Check if the path is a static resource.
     */
    private boolean isStaticResource(String path) {
        return path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/fonts/")
                || path.startsWith("/assets/")
                || path.startsWith("/view/")
                || path.endsWith(".css")
                || path.endsWith(".js")
                || path.endsWith(".png")
                || path.endsWith(".jpg")
                || path.endsWith(".jpeg")
                || path.endsWith(".gif")
                || path.endsWith(".svg")
                || path.endsWith(".ico")
                || path.endsWith(".woff")
                || path.endsWith(".woff2")
                || path.endsWith(".ttf");
    }

    /**
     * Check if the URL is public.
     */
    private boolean isPublicUrl(String path) {
        if (path.equals("/") || path.isEmpty()) {
            return true;
        }
        for (String url : PUBLIC_URLS) {
            if (path.startsWith(url)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Check if the URL requires Customer role.
     */
    private boolean isCustomerUrl(String path) {
        for (String url : CUSTOMER_URLS) {
            if (path.startsWith(url)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Check if the URL requires Staff role.
     */
    private boolean isStaffUrl(String path) {
        for (String url : STAFF_URLS) {
            if (path.startsWith(url)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Check if the URL requires Admin role.
     */
    private boolean isAdminUrl(String path) {
        for (String url : ADMIN_URLS) {
            if (path.startsWith(url)) {
                return true;
            }
        }
        return false;
    }
}
