package controller;

import dao.MotorbikeDAO;
import dao.ReviewDAO;
import model.Motorbike;
import model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Home Controller - Handles homepage requests.
 * Displays featured motorbikes and recent reviews.
 */
public class HomeController extends HttpServlet {

    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get featured motorbikes for homepage
        List<Motorbike> featuredBikes = motorbikeDAO.getFeaturedMotorbikes(6);
        request.setAttribute("featuredBikes", featuredBikes);

        // Get recent reviews for homepage
        List<Review> recentReviews = reviewDAO.getRecentReviews(3);
        request.setAttribute("recentReviews", recentReviews);

        request.getRequestDispatcher("/views/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
