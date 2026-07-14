package controller;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.MotorbikeDAO;
import dao.ReviewDAO;
import dao.WalletDAO;
import model.Brand;
import model.Category;
import model.Motorbike;
import model.Review;
import model.User;
import model.Wallet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Motorbike Controller - Handles motorbike listing, search, detail.
 * URL: /motorbikes?action=list|detail|search
 */
public class MotorbikeController extends HttpServlet {

    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final WalletDAO walletDAO = new WalletDAO();

    private static final int PAGE_SIZE = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "detail":
                showDetail(request, response);
                break;
            case "list":
            default:
                showList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Show motorbike listing page with search, filter, sort, pagination.
     */
    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get filter parameters
        String keyword = request.getParameter("keyword");
        String brandIdStr = request.getParameter("brandId");
        String categoryIdStr = request.getParameter("categoryId");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String sortBy = request.getParameter("sortBy");
        String pageStr = request.getParameter("page");

        int brandId = 0, categoryId = 0, page = 1;
        double minPrice = 0, maxPrice = 0;

        try {
            if (brandIdStr != null && !brandIdStr.isEmpty()) brandId = Integer.parseInt(brandIdStr);
            if (categoryIdStr != null && !categoryIdStr.isEmpty()) categoryId = Integer.parseInt(categoryIdStr);
            if (minPriceStr != null && !minPriceStr.isEmpty()) minPrice = Double.parseDouble(minPriceStr);
            if (maxPriceStr != null && !maxPriceStr.isEmpty()) maxPrice = Double.parseDouble(maxPriceStr);
            if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
        } catch (NumberFormatException e) {
            // Use default values
        }

        if (page < 1) page = 1;

        // Get motorbikes
        List<Motorbike> motorbikes = motorbikeDAO.searchMotorbikes(
                keyword, brandId, categoryId, minPrice, maxPrice, sortBy, page, PAGE_SIZE);
        int totalCount = motorbikeDAO.countMotorbikes(keyword, brandId, categoryId, minPrice, maxPrice);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

        // Get brands and categories for filter sidebar
        List<Brand> brands = brandDAO.getAllBrands();
        List<Category> categories = categoryDAO.getAllCategories();

        // Set attributes
        request.setAttribute("motorbikes", motorbikes);
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("sortBy", sortBy);

        request.getRequestDispatcher("/views/motorbike/list.jsp").forward(request, response);
    }

    /**
     * Show motorbike detail page.
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=list");
            return;
        }

        try {
            int motorbikeId = Integer.parseInt(idStr);
            Motorbike motorbike = motorbikeDAO.getMotorbikeById(motorbikeId);

            if (motorbike == null) {
                response.sendRedirect(request.getContextPath() + "/motorbikes?action=list");
                return;
            }

            // Get reviews for this motorbike
            List<Review> reviews = reviewDAO.getReviewsByMotorbikeId(motorbikeId);

            request.setAttribute("motorbike", motorbike);
            request.setAttribute("reviews", reviews);

            // Pass wallet info for logged-in customers
            User user = (User) request.getSession().getAttribute("user");
            if (user != null && user.getRoleId() == 2) {
                Wallet wallet = walletDAO.getWalletByUserId(user.getUserId());
                request.setAttribute("wallet", wallet);
            }

            request.getRequestDispatcher("/views/motorbike/detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/motorbikes?action=list");
        }
    }
}
