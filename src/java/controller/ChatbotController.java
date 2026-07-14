package controller;

import dao.MotorbikeDAO;
import model.Motorbike;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Chatbot Controller - Proxies chat requests to OpenAI API.
 * Keeps API key secure on the server side.
 * Loads motorbike catalog as context for AI consultation.
 */
public class ChatbotController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ChatbotController.class.getName());
    private final MotorbikeDAO motorbikeDAO = new MotorbikeDAO();

    private static final String OPENAI_API_KEY = "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";
    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";
    private static final String OPENAI_MODEL = "gpt-4o-mini";

    // Cache the catalog context (refreshed every 10 minutes)
    private static String cachedCatalog = null;
    private static long lastCatalogRefresh = 0;
    private static final long CATALOG_REFRESH_INTERVAL = 10 * 60 * 1000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/chatbot.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Read the request body (JSON with messages array)
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }

        String requestBody = body.toString();

        // Extract messages from the request
        String messagesJson = extractMessages(requestBody);
        if (messagesJson == null || messagesJson.isEmpty()) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"No messages provided\"}");
            return;
        }

        // Build system prompt with motorbike catalog
        String systemPrompt = buildSystemPrompt();

        // Build OpenAI API request
        String openAiRequestBody = buildOpenAiRequest(systemPrompt, messagesJson);

        // Call OpenAI API
        try {
            String openAiResponse = callOpenAiApi(openAiRequestBody);
            response.getWriter().write(openAiResponse);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calling OpenAI API", e);
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Failed to get AI response: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    /**
     * Build the system prompt with motorbike catalog context.
     */
    private String buildSystemPrompt() {
        String catalog = getMotorbikeCatalog();
        return "You are MotoBot, an expert motorbike rental consultant for MotoRent. "
                + "You help customers choose the perfect motorbike based on their needs, budget, and preferences. "
                + "Be friendly, professional, and knowledgeable. Use emoji sparingly for a modern feel. "
                + "Always respond in the same language the customer uses (Vietnamese or English). "
                + "\n\nKey information about MotoRent:\n"
                + "- We offer daily motorbike rentals\n"
                + "- Customers can rent up to 3 motorbikes at once\n"
                + "- Payment is via digital wallet (top up first, then pay)\n"
                + "- There is a contract signing process before pickup\n"
                + "- Return inspection is required with photo/video evidence\n"
                + "- Late returns incur a $10/day penalty\n"
                + "- Damage fines are assessed during return inspection\n"
                + "\n\nCurrent Motorbike Catalog:\n" + catalog
                + "\n\nWhen recommending motorbikes:\n"
                + "- Consider the customer's budget (price per day)\n"
                + "- Consider their experience level (suggest appropriate categories)\n"
                + "- Consider their intended use (city commute, touring, sport, off-road)\n"
                + "- Mention specific bikes from our catalog with prices\n"
                + "- If a bike is not available, let them know and suggest alternatives\n"
                + "- Guide them to the motorbikes page to browse and rent\n"
                + "- Keep responses concise but helpful (under 300 words)";
    }

    /**
     * Load and cache the motorbike catalog as a text summary.
     */
    private String getMotorbikeCatalog() {
        long now = System.currentTimeMillis();
        if (cachedCatalog != null && (now - lastCatalogRefresh) < CATALOG_REFRESH_INTERVAL) {
            return cachedCatalog;
        }

        try {
            List<Motorbike> bikes = motorbikeDAO.getAllMotorbikes();
            StringBuilder sb = new StringBuilder();
            for (Motorbike bike : bikes) {
                sb.append("- ").append(bike.getName())
                  .append(" | Brand: ").append(bike.getBrandName())
                  .append(" | Category: ").append(bike.getCategoryName())
                  .append(" | Year: ").append(bike.getYear())
                  .append(" | Price: $").append(String.format("%.2f", bike.getPricePerDay())).append("/day")
                  .append(" | Status: ").append(bike.getStatus())
                  .append(" | Rating: ").append(String.format("%.1f", bike.getAvgRating()))
                  .append("/5 (").append(bike.getReviewCount()).append(" reviews)")
                  .append("\n");
            }
            if (bikes.isEmpty()) {
                sb.append("No motorbikes currently in catalog.\n");
            }
            cachedCatalog = sb.toString();
            lastCatalogRefresh = now;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to load motorbike catalog for chatbot", e);
            if (cachedCatalog == null) {
                cachedCatalog = "Catalog temporarily unavailable.\n";
            }
        }
        return cachedCatalog;
    }

    /**
     * Extract the "messages" JSON array from the request body.
     * Expected format: {"messages": [...]}
     */
    private String extractMessages(String requestBody) {
        int idx = requestBody.indexOf("\"messages\"");
        if (idx == -1) return null;

        int arrStart = requestBody.indexOf('[', idx);
        if (arrStart == -1) return null;

        // Find matching closing bracket, skipping string contents
        int depth = 0;
        boolean inString = false;
        for (int i = arrStart; i < requestBody.length(); i++) {
            char c = requestBody.charAt(i);
            if (c == '\\' && inString) {
                i++; // Skip escaped character
                continue;
            }
            if (c == '"') {
                inString = !inString;
                continue;
            }
            if (inString) continue;
            if (c == '[') depth++;
            else if (c == ']') {
                depth--;
                if (depth == 0) {
                    return requestBody.substring(arrStart, i + 1);
                }
            }
        }
        return null;
    }

    /**
     * Build the OpenAI API request JSON.
     */
    private String buildOpenAiRequest(String systemPrompt, String messagesJson) {
        return "{"
                + "\"model\":\"" + OPENAI_MODEL + "\","
                + "\"messages\":["
                + "{\"role\":\"system\",\"content\":\"" + escapeJson(systemPrompt) + "\"},"
                + messagesJson.substring(1) // Remove leading '[' and append after system message
                + ","
                + "\"max_tokens\":1000,"
                + "\"temperature\":0.7"
                + "}";
    }

    /**
     * Call OpenAI Chat Completions API via HttpURLConnection.
     */
    private String callOpenAiApi(String requestBody) throws IOException {
        URL url = new URL(OPENAI_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + OPENAI_API_KEY);
        conn.setDoOutput(true);
        conn.setConnectTimeout(30000);
        conn.setReadTimeout(60000);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int statusCode = conn.getResponseCode();
        BufferedReader br;
        if (statusCode >= 200 && statusCode < 300) {
            br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        } else {
            br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder responseBody = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            responseBody.append(line);
        }
        br.close();
        conn.disconnect();

        if (statusCode >= 200 && statusCode < 300) {
            // Extract the assistant message content from OpenAI response
            String fullResponse = responseBody.toString();
            String content = extractContentFromResponse(fullResponse);
            return "{\"reply\":" + content + "}";
        } else {
            LOGGER.warning("OpenAI API error " + statusCode + ": " + responseBody);
            throw new IOException("OpenAI API returned status " + statusCode);
        }
    }

    /**
     * Extract "content" field from OpenAI response.
     * Response format: {"choices":[{"message":{"content":"..."}}]}
     */
    private String extractContentFromResponse(String response) {
        // Find "content" in the message object
        String searchKey = "\"content\"";
        int idx = response.indexOf(searchKey, response.indexOf("\"message\""));
        if (idx == -1) {
            idx = response.indexOf(searchKey);
        }
        if (idx == -1) return "\"I apologize, I could not process that request.\"";

        int colonIdx = response.indexOf(':', idx);
        if (colonIdx == -1) return "\"I apologize, I could not process that request.\"";

        // Find the start of the value
        int valueStart = colonIdx + 1;
        while (valueStart < response.length() && response.charAt(valueStart) == ' ') {
            valueStart++;
        }

        if (valueStart >= response.length()) return "\"I apologize, I could not process that request.\"";

        // The content is a JSON string, extract it
        if (response.charAt(valueStart) == '"') {
            // Find the end of the string (handle escaped quotes)
            int valueEnd = valueStart + 1;
            while (valueEnd < response.length()) {
                if (response.charAt(valueEnd) == '\\') {
                    valueEnd += 2; // Skip escaped character
                } else if (response.charAt(valueEnd) == '"') {
                    return response.substring(valueStart, valueEnd + 1);
                } else {
                    valueEnd++;
                }
            }
        } else if (response.substring(valueStart).startsWith("null")) {
            return "\"I apologize, I could not process that request.\"";
        }

        return "\"I apologize, I could not process that request.\"";
    }

    /**
     * Escape a string for safe JSON inclusion.
     */
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
