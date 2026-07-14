package util;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.*;
import javax.mail.internet.*;

/**
 * Email Service for sending notification emails to customers.
 * Uses Jakarta Mail (javax.mail successor).
 * 
 * Uses javax.mail-1.6.2.jar (already in WEB-INF/lib).
 * Configure SMTP settings below (Gmail example provided).
 */
public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());

    // SMTP Configuration - Update these with your actual credentials
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USERNAME = "hungnguyen12367f@gmail.com";
    private static final String SMTP_PASSWORD = "brfa lifu dtwz cysh";
    private static final String FROM_EMAIL = "hungnguyen12367f@gmail.com";
    private static final String FROM_NAME = "MotoRent";

    /**
     * Send email notification to a customer about order status change.
     */
    public static void sendOrderStatusEmail(String toEmail, String customerName, int orderId,
                                             String oldStatus, String newStatus, String motorbikeName) {
        String subject = "MotoRent - Order #ORD-" + String.format("%04d", orderId) + " Status Update";
        String body = buildOrderStatusEmailBody(customerName, orderId, oldStatus, newStatus, motorbikeName);
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email for order confirmation.
     */
    public static void sendOrderConfirmedEmail(String toEmail, String customerName, int orderId, String motorbikeName) {
        String subject = "MotoRent - Order #ORD-" + String.format("%04d", orderId) + " Confirmed!";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Confirmed",
                "Your rental order has been <b>confirmed</b> by our staff! Please proceed to sign the rental contract before we can start the rental.",
                "#2563eb");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email for rental started.
     */
    public static void sendRentalStartedEmail(String toEmail, String customerName, int orderId, String motorbikeName) {
        String subject = "MotoRent - Rental Started for Order #ORD-" + String.format("%04d", orderId);
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Renting",
                "Your rental has officially <b>started</b>! The motorbike is now handed over to you. Please ride safely and return on time.",
                "#0d6efd");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email for rental completed / returned.
     */
    public static void sendRentalCompletedEmail(String toEmail, String customerName, int orderId, String motorbikeName) {
        String subject = "MotoRent - Rental Completed for Order #ORD-" + String.format("%04d", orderId);
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Returned",
                "Your rental has been <b>completed</b> successfully! Thank you for choosing MotoRent. We hope you had a great experience. Don't forget to leave a review!",
                "#198754");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email for order cancellation.
     */
    public static void sendOrderCancelledEmail(String toEmail, String customerName, int orderId, String motorbikeName, boolean refunded) {
        String refundNote = refunded ? "<br><br>The payment amount has been <b>refunded</b> to your wallet." : "";
        String subject = "MotoRent - Order #ORD-" + String.format("%04d", orderId) + " Cancelled";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Cancelled",
                "Your rental order has been <b>cancelled</b>." + refundNote,
                "#dc3545");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email for bike received confirmation.
     */
    public static void sendBikeReceivedEmail(String toEmail, String customerName, int orderId, String motorbikeName) {
        String subject = "MotoRent - Bike Received for Order #ORD-" + String.format("%04d", orderId);
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Received",
                "You have confirmed <b>receiving the motorbike</b>. Enjoy your ride and stay safe! Remember to return the bike on time.",
                "#0dcaf0");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Build a standard status notification email body.
     */
    private static String buildStatusBody(String customerName, int orderId, String motorbikeName,
                                           String status, String message, String color) {
        return "<!DOCTYPE html>"
                + "<html><head><meta charset='UTF-8'></head>"
                + "<body style='font-family: Inter, Arial, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px;'>"
                + "<div style='max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>"
                + "  <div style='background: " + color + "; color: white; padding: 30px; text-align: center;'>"
                + "    <h1 style='margin: 0; font-size: 24px;'>MotoRent</h1>"
                + "    <p style='margin: 10px 0 0; opacity: 0.9;'>Order Status Update</p>"
                + "  </div>"
                + "  <div style='padding: 30px;'>"
                + "    <p style='font-size: 16px;'>Hello <b>" + customerName + "</b>,</p>"
                + "    <p style='font-size: 15px; line-height: 1.6;'>" + message + "</p>"
                + "    <div style='background: #f8f9fa; border-radius: 8px; padding: 20px; margin: 20px 0;'>"
                + "      <table style='width: 100%; border-collapse: collapse;'>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Order ID</td><td style='padding: 8px 0; text-align: right; font-weight: bold;'>#ORD-" + String.format("%04d", orderId) + "</td></tr>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Motorbike</td><td style='padding: 8px 0; text-align: right; font-weight: bold;'>" + motorbikeName + "</td></tr>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Status</td><td style='padding: 8px 0; text-align: right;'><span style='background: " + color + "; color: white; padding: 4px 12px; border-radius: 20px; font-size: 13px;'>" + status + "</span></td></tr>"
                + "      </table>"
                + "    </div>"
                + "    <p style='font-size: 14px; color: #6c757d;'>If you have any questions, feel free to contact us.</p>"
                + "  </div>"
                + "  <div style='background: #f8f9fa; padding: 20px; text-align: center; font-size: 13px; color: #6c757d;'>"
                + "    &copy; 2026 MotoRent. All rights reserved."
                + "  </div>"
                + "</div></body></html>";
    }

    /**
     * Send email for order rejection with reason + refund note.
     */
    public static void sendOrderRejectedEmail(String toEmail, String customerName, int orderId,
                                                String motorbikeName, String rejectReason, boolean refunded) {
        String refundNote = refunded ? "<br><br>The payment amount has been <b>refunded</b> to your wallet." : "";
        String subject = "MotoRent - Order #ORD-" + String.format("%04d", orderId) + " Rejected";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Rejected",
                "We're sorry, your rental order has been <b>rejected</b> by our staff."
                + "<br><br><b>Reason:</b> " + rejectReason + refundNote,
                "#dc3545");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send fine notification email with amount and 48h deadline.
     */
    public static void sendFineNotificationEmail(String toEmail, String customerName, int orderId,
                                                   String motorbikeName, double fineAmount, String fineReason) {
        String subject = "MotoRent - Damage Fine for Order #ORD-" + String.format("%04d", orderId);
        String message = "After inspecting the returned motorbike, our staff found <b>damage</b>."
                + "<br><br><b>Fine Amount:</b> $" + String.format("%.2f", fineAmount)
                + "<br><b>Reason:</b> " + fineReason
                + "<br><br><span style='color: #dc3545; font-weight: bold;'>You must pay this fine within 48 hours.</span>"
                + " If the fine is not paid within the deadline, your account will be <b>locked</b>."
                + "<br><br>You can pay the fine from your wallet on the order details page."
                + " If you believe this is unfair, you may file a complaint.";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Fine Issued", message, "#dc3545");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send thank-you email after staff accepts the returned bike.
     */
    public static void sendThankYouEmail(String toEmail, String customerName, int orderId, String motorbikeName) {
        String subject = "MotoRent - Thank You! Order #ORD-" + String.format("%04d", orderId) + " Completed";
        String message = "Your rental has been <b>completed</b> successfully! The motorbike has been returned in good condition."
                + "<br><br>Thank you for choosing MotoRent! We hope you had a wonderful experience."
                + "<br><br>We'd love to hear your feedback — please leave a <b>review</b> on the order page.";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Completed", message, "#198754");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send confirmation that fine has been paid.
     */
    public static void sendFinePaidEmail(String toEmail, String customerName, int orderId, double fineAmount) {
        String subject = "MotoRent - Fine Paid for Order #ORD-" + String.format("%04d", orderId);
        String message = "Your damage fine of <b>$" + String.format("%.2f", fineAmount) + "</b> has been <b>paid successfully</b>."
                + "<br><br>Your account is in good standing. Thank you for resolving this promptly.";
        String body = buildStatusBody(customerName, orderId, "N/A", "Fine Paid", message, "#198754");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email when staff waives a fine.
     */
    public static void sendFineWaivedEmail(String toEmail, String customerName, int orderId,
                                             String motorbikeName, double fineAmount) {
        String subject = "MotoRent - Fine Waived for Order #ORD-" + String.format("%04d", orderId);
        String message = "Good news! The damage fine of <b>$" + String.format("%.2f", fineAmount) + "</b> for your order has been <b>waived</b> by our staff."
                + "<br><br>Your account is in good standing. Thank you for your patience.";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "Fine Waived", message, "#198754");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send email when admin responds to a complaint.
     */
    public static void sendComplaintResponseEmail(String toEmail, String customerName, int complaintId,
                                                    String subject, String newStatus, String adminResponse) {
        String emailSubject = "MotoRent - Complaint #" + complaintId + " " + newStatus;
        String statusColor = "Resolved".equals(newStatus) ? "#198754" : "#dc3545";
        String htmlBody = "<!DOCTYPE html>"
                + "<html><head><meta charset='UTF-8'></head>"
                + "<body style='font-family: Inter, Arial, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px;'>"
                + "<div style='max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>"
                + "  <div style='background: " + statusColor + "; color: white; padding: 30px; text-align: center;'>"
                + "    <h1 style='margin: 0; font-size: 24px;'>MotoRent</h1>"
                + "    <p style='margin: 10px 0 0; opacity: 0.9;'>Complaint Update</p>"
                + "  </div>"
                + "  <div style='padding: 30px;'>"
                + "    <p style='font-size: 16px;'>Hello <b>" + customerName + "</b>,</p>"
                + "    <p style='font-size: 15px; line-height: 1.6;'>Your complaint has been reviewed and marked as <b>" + newStatus + "</b>.</p>"
                + "    <div style='background: #f8f9fa; border-radius: 8px; padding: 20px; margin: 20px 0;'>"
                + "      <table style='width: 100%; border-collapse: collapse;'>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Complaint</td><td style='padding: 8px 0; text-align: right; font-weight: bold;'>#" + complaintId + "</td></tr>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Subject</td><td style='padding: 8px 0; text-align: right; font-weight: bold;'>" + subject + "</td></tr>"
                + "        <tr><td style='padding: 8px 0; color: #6c757d;'>Status</td><td style='padding: 8px 0; text-align: right;'><span style='background: " + statusColor + "; color: white; padding: 4px 12px; border-radius: 20px; font-size: 13px;'>" + newStatus + "</span></td></tr>"
                + "      </table>"
                + "    </div>"
                + "    <div style='background: #e9ecef; border-left: 4px solid " + statusColor + "; padding: 15px; border-radius: 4px; margin: 20px 0;'>"
                + "      <p style='margin: 0 0 5px; font-weight: bold; color: #495057;'>Admin Response:</p>"
                + "      <p style='margin: 0; color: #495057;'>" + adminResponse + "</p>"
                + "    </div>"
                + "    <p style='font-size: 14px; color: #6c757d;'>If you have further questions, feel free to contact us.</p>"
                + "  </div>"
                + "  <div style='background: #f8f9fa; padding: 20px; text-align: center; font-size: 13px; color: #6c757d;'>"
                + "    &copy; 2026 MotoRent. All rights reserved."
                + "  </div>"
                + "</div></body></html>";
        sendEmail(toEmail, emailSubject, htmlBody);
    }

    /**
     * Send overdue rental warning email.
     */
    public static void sendOverdueWarningEmail(String toEmail, String customerName, int orderId,
                                                 String motorbikeName, int overdueDays, double totalPenalty) {
        String subject = "MotoRent - OVERDUE WARNING: Order #ORD-" + String.format("%04d", orderId);
        String message = "Your rental is <b>" + overdueDays + " day(s) overdue</b>!"
                + "<br><br>An overdue penalty of <b>$" + String.format("%.2f", totalPenalty)
                + "</b> ($10.00/day) has been applied."
                + "<br><br>Please return the motorbike and pay the overdue fee as soon as possible. "
                + "You will not be able to rent or return other motorbikes until this penalty is paid.";
        String body = buildStatusBody(customerName, orderId, motorbikeName, "OVERDUE", message, "#dc3545");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Send overdue penalty paid confirmation email.
     */
    public static void sendOverduePaidEmail(String toEmail, String customerName, int orderId, double amount) {
        String subject = "MotoRent - Overdue Penalty Paid for Order #ORD-" + String.format("%04d", orderId);
        String message = "Your overdue penalty of <b>$" + String.format("%.2f", amount)
                + "</b> has been paid successfully. You may now proceed with returning your motorbike."
                + "<br><br>Thank you for settling your balance promptly.";
        String body = buildStatusBody(customerName, orderId, "N/A", "Penalty Paid", message, "#198754");
        sendEmail(toEmail, subject, body);
    }

    /**
     * Build generic order status email body.
     */
    private static String buildOrderStatusEmailBody(String customerName, int orderId,
                                                     String oldStatus, String newStatus, String motorbikeName) {
        String message = "Your order status has been updated from <b>" + oldStatus + "</b> to <b>" + newStatus + "</b>.";
        String color = "#2563eb";
        switch (newStatus) {
            case "Confirmed": color = "#2563eb"; break;
            case "Renting": color = "#0d6efd"; break;
            case "Received": color = "#0dcaf0"; break;
            case "Returned": color = "#198754"; break;
            case "Cancelled": color = "#dc3545"; break;
        }
        return buildStatusBody(customerName, orderId, motorbikeName, newStatus, message, color);
    }

    /**
     * Send an HTML email.
     */
    private static void sendEmail(String toEmail, String subject, String htmlBody) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.log(Level.INFO, "Email sent successfully to: " + toEmail);

        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to send email to: " + toEmail + " - " + ex.getMessage());
            // Don't throw exception - email failure should not break the main flow
        }
    }
}
