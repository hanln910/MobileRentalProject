package controller;

import dao.WalletDAO;
import model.User;
import model.Wallet;
import model.WalletTransaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Wallet Controller - Handles wallet operations (view balance, top-up, transaction history).
 * URL: /wallet?action=view|topup
 */
public class WalletController extends HttpServlet {

    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        showWallet(request, response, user);
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
        if ("topup".equals(action)) {
            topUp(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/wallet");
        }
    }

    /**
     * Show wallet page with balance and transaction history.
     */
    private void showWallet(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());

        // Pagination for transactions
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) { }
        if (page < 1) page = 1;

        List<WalletTransaction> transactions = walletDAO.getTransactions(wallet.getWalletId(), page, pageSize);
        int totalTx = walletDAO.countTransactions(wallet.getWalletId());
        int totalPages = (int) Math.ceil((double) totalTx / pageSize);

        request.setAttribute("wallet", wallet);
        request.setAttribute("transactions", transactions);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/views/customer/wallet.jsp").forward(request, response);
    }

    /**
     * Process wallet top-up.
     */
    private void topUp(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String amountStr = request.getParameter("amount");
        String method = request.getParameter("method");

        if (amountStr == null || amountStr.isEmpty()) {
            request.getSession().setAttribute("walletError", "Please enter an amount.");
            response.sendRedirect(request.getContextPath() + "/wallet");
            return;
        }

        try {
            double amount = Double.parseDouble(amountStr);
            if (amount < 10) {
                request.getSession().setAttribute("walletError", "Minimum top-up amount is $10.00.");
                response.sendRedirect(request.getContextPath() + "/wallet");
                return;
            }
            if (amount > 10000) {
                request.getSession().setAttribute("walletError", "Maximum top-up amount is $10,000.00.");
                response.sendRedirect(request.getContextPath() + "/wallet");
                return;
            }

            String description = "Top-up via " + (method != null ? method : "Bank Transfer");
            if (walletDAO.topUp(user.getUserId(), amount, description)) {
                request.getSession().setAttribute("walletSuccess",
                        "$" + String.format("%.2f", amount) + " added to your wallet successfully!");
            } else {
                request.getSession().setAttribute("walletError", "Failed to top up. Please try again.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("walletError", "Invalid amount.");
        }
        response.sendRedirect(request.getContextPath() + "/wallet");
    }
}
