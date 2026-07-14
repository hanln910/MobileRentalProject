package controller;

import dao.UserDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.*;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthControllerTest {

    private AuthController controller;
    private UserDAO userDAO;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    @BeforeEach
    void setUp() {
        userDAO = mock(UserDAO.class);
        controller = new AuthController(userDAO);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/MotoRent");
    }

    private User mockUser(int roleId, boolean active) {
        User user = new User();
        user.setUserId(1);
        user.setEmail("john@gmail.com");
        user.setPassword("123456");
        user.setRoleId(roleId);
        user.setIsActive(active);
        return user;
    }

    // ============================
    // doLogin tests
    // ============================

    @Test
    void testDoLoginCustomerSuccess() throws Exception {
        when(request.getParameter("email")).thenReturn("john@gmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(userDAO.login("john@gmail.com", "123456")).thenReturn(mockUser(2, true));
        when(session.getAttribute("redirectUrl")).thenReturn(null);

        controller.doLogin(request, response);

        verify(session).setAttribute(eq("user"), any(User.class));
        verify(session).setMaxInactiveInterval(1800);
        verify(response).sendRedirect("/MotoRent/orders?action=dashboard");
    }

    @Test
    void testDoLoginAdminSuccess() throws Exception {
        when(request.getParameter("email")).thenReturn("admin@gmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(userDAO.login("admin@gmail.com", "123456")).thenReturn(mockUser(1, true));
        when(session.getAttribute("redirectUrl")).thenReturn(null);

        controller.doLogin(request, response);

        verify(response).sendRedirect("/MotoRent/admin?action=dashboard");
    }

    @Test
    void testDoLoginStaffSuccess() throws Exception {
        when(request.getParameter("email")).thenReturn("staff@gmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(userDAO.login("staff@gmail.com", "123456")).thenReturn(mockUser(3, true));
        when(session.getAttribute("redirectUrl")).thenReturn(null);

        controller.doLogin(request, response);

        verify(response).sendRedirect("/MotoRent/staff?action=dashboard");
    }

    @Test
    void testDoLoginWrongPassword() throws Exception {
        when(request.getParameter("email")).thenReturn("john@gmail.com");
        when(request.getParameter("password")).thenReturn("wrong");
        when(userDAO.login("john@gmail.com", "wrong")).thenReturn(null);
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doLogin(request, response);

        verify(request).setAttribute(eq("error"), anyString());
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoLoginEmailEmpty() throws Exception {
        when(request.getParameter("email")).thenReturn("");
        when(request.getParameter("password")).thenReturn("123456");
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doLogin(request, response);

        verify(request).setAttribute(eq("error"), contains("Email is required"));
        verify(dispatcher).forward(request, response);
        verify(userDAO, never()).login(anyString(), anyString());
    }

    @Test
    void testDoLoginInvalidEmailFormat() throws Exception {
        when(request.getParameter("email")).thenReturn("johngmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doLogin(request, response);

        verify(request).setAttribute(eq("error"), contains("Invalid email format"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoLoginPasswordEmpty() throws Exception {
        when(request.getParameter("email")).thenReturn("john@gmail.com");
        when(request.getParameter("password")).thenReturn("");
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doLogin(request, response);

        verify(request).setAttribute(eq("error"), contains("Password is required"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoLoginInactiveAccount() throws Exception {
        when(request.getParameter("email")).thenReturn("lock@gmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(userDAO.login("lock@gmail.com", "123456")).thenReturn(mockUser(2, false));
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doLogin(request, response);

        verify(request).setAttribute(eq("error"), contains("locked"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoLoginWithRedirectUrl() throws Exception {
        when(request.getParameter("email")).thenReturn("john@gmail.com");
        when(request.getParameter("password")).thenReturn("123456");
        when(userDAO.login("john@gmail.com", "123456")).thenReturn(mockUser(2, true));
        when(session.getAttribute("redirectUrl")).thenReturn("/MotoRent/cart");

        controller.doLogin(request, response);

        verify(session).removeAttribute("redirectUrl");
        verify(response).sendRedirect("/MotoRent/cart");
    }

    // ============================
    // doRegister tests
    // ============================

    private void mockValidRegisterParams() {
        when(request.getParameter("fullName")).thenReturn("JUnit User");
        when(request.getParameter("email")).thenReturn("new@gmail.com");
        when(request.getParameter("phone")).thenReturn("0912345678");
        when(request.getParameter("address")).thenReturn("Ha Noi");
        when(request.getParameter("password")).thenReturn("123456");
        when(request.getParameter("confirmPassword")).thenReturn("123456");
    }

    @Test
    void testDoRegisterSuccess() throws Exception {
        mockValidRegisterParams();
        when(userDAO.isEmailExists("new@gmail.com")).thenReturn(false);
        when(userDAO.register(any(User.class))).thenReturn(true);
        when(request.getRequestDispatcher("/views/auth/login.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("success"), anyString());
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterEmailExists() throws Exception {
        mockValidRegisterParams();
        when(userDAO.isEmailExists("new@gmail.com")).thenReturn(true);
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Email already exists"));
        verify(dispatcher).forward(request, response);
        verify(userDAO, never()).register(any(User.class));
    }

    @Test
    void testDoRegisterFullNameEmpty() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("fullName")).thenReturn("");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Full name is required"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterInvalidEmailFormat() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("email")).thenReturn("abcgmail.com");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Invalid email format"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterInvalidPhone() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("phone")).thenReturn("abc123");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Invalid phone number format"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterAddressEmpty() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("address")).thenReturn("");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Address is required"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterPasswordTooShort() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("password")).thenReturn("123");
        when(request.getParameter("confirmPassword")).thenReturn("123");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Password must be at least 6 characters"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterConfirmPasswordMismatch() throws Exception {
        mockValidRegisterParams();
        when(request.getParameter("confirmPassword")).thenReturn("654321");
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Passwords do not match"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoRegisterDAOFailed() throws Exception {
        mockValidRegisterParams();
        when(userDAO.isEmailExists("new@gmail.com")).thenReturn(false);
        when(userDAO.register(any(User.class))).thenReturn(false);
        when(request.getRequestDispatcher("/views/auth/register.jsp")).thenReturn(dispatcher);

        controller.doRegister(request, response);

        verify(request).setAttribute(eq("error"), contains("Registration failed"));
        verify(dispatcher).forward(request, response);
    }
}