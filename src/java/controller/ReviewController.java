package controller;

import dao.OrderDAO;
import dao.ReviewDAO;
import model.RentalOrder;
import model.Review;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Review Controller - Handles review operations.
 * URL: /reviews?action=add
 */
public class ReviewController extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addReview(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    /**
     * Add a new review for a motorbike after completing rental.
     */
    private void addReview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String motorbikeIdStr = request.getParameter("motorbikeId");
        String orderIdStr = request.getParameter("orderId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        // Validation
        if (motorbikeIdStr == null || orderIdStr == null || ratingStr == null
                || motorbikeIdStr.isEmpty() || orderIdStr.isEmpty() || ratingStr.isEmpty()) {
            session.setAttribute("reviewError", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeIdStr);
            return;
        }

        try {
            int motorbikeId = Integer.parseInt(motorbikeIdStr);
            int orderId = Integer.parseInt(orderIdStr);
            int rating = Integer.parseInt(ratingStr);

            if (rating < 1 || rating > 5) {
                session.setAttribute("reviewError", "Rating must be between 1 and 5.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Check if order belongs to user and is completed
            RentalOrder order = orderDAO.getOrderById(orderId);
            if (order == null || order.getUserId() != user.getUserId()
                    || (!"Returned".equals(order.getStatus()) && !"Completed".equals(order.getStatus()))) {
                session.setAttribute("reviewError", "You can only review completed rentals.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            // Check if already reviewed
            if (reviewDAO.hasReviewed(user.getUserId(), orderId)) {
                session.setAttribute("reviewError", "You have already reviewed this order.");
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);
                return;
            }

            Review review = new Review();
            review.setUserId(user.getUserId());
            review.setMotorbikeId(motorbikeId);
            review.setOrderId(orderId);
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");

            if (reviewDAO.addReview(review)) {
                session.setAttribute("reviewSuccess", "Review submitted successfully!");
            } else {
                session.setAttribute("reviewError", "Failed to submit review.");
            }
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=detail&id=" + motorbikeId);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
