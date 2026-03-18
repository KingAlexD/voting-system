package com.bascode.util;

import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.ServletContext;

public final class EmailService {

    private EmailService() {
    }

    public static boolean isConfigured(ServletContext context) {
        return !isBlank(get(context, "mail.smtp.host", "MAIL_SMTP_HOST"))
                && !isBlank(get(context, "mail.smtp.port", "MAIL_SMTP_PORT"))
                && !isBlank(get(context, "mail.smtp.username", "MAIL_SMTP_USERNAME"))
                && !isBlank(get(context, "mail.smtp.password", "MAIL_SMTP_PASSWORD"))
                && !isBlank(get(context, "mail.smtp.from", "MAIL_SMTP_FROM"));
    }

    public static void sendVerificationCode(ServletContext context, String toEmail, String code) throws MessagingException {
        sendPlainEmail(context, toEmail, "Online Voting System - Verification Code",
                "Your verification code is: " + code + "\n\nThis code expires when replaced by a new one.");
    }

    public static void sendPlainEmail(ServletContext context, String toEmail, String subject, String textBody)
            throws MessagingException {
        String host = get(context, "mail.smtp.host", "MAIL_SMTP_HOST");
        String port = get(context, "mail.smtp.port", "MAIL_SMTP_PORT");
        String username = get(context, "mail.smtp.username", "MAIL_SMTP_USERNAME");
        String password = get(context, "mail.smtp.password", "MAIL_SMTP_PASSWORD");
        String from = get(context, "mail.smtp.from", "MAIL_SMTP_FROM");
        String auth = getOrDefault(context, "mail.smtp.auth", "MAIL_SMTP_AUTH", "true");
        String starttls = getOrDefault(context, "mail.smtp.starttls.enable", "MAIL_SMTP_STARTTLS", "true");
        String ssl = getOrDefault(context, "mail.smtp.ssl.enable", "MAIL_SMTP_SSL", "false");

        if (isBlank(host) || isBlank(port) || isBlank(username) || isBlank(password) || isBlank(from)) {
            throw new MessagingException("SMTP configuration is missing. Update web.xml mail.smtp.* context-params.");
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", auth);
        props.put("mail.smtp.starttls.enable", "true"); 
        props.put("mail.smtp.ssl.trust", "*");          
        props.put("mail.smtp.ssl.checkserveridentity", "false"); 

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        System.out.println("SMTP HOST: " + host);
        System.out.println("SMTP PORT: " + port);
        System.out.println("SMTP USERNAME: " + username);
        System.out.println("SMTP PASSWORD LENGTH: " + (password == null ? "null" : password.length()));
        System.out.println("SMTP FROM: " + from);
        
        
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setText(textBody);

        Transport.send(message);
    }

    private static String get(ServletContext context, String key, String envKey) {
        String env = trimToNull(System.getenv(envKey));
        if (env != null) {
            return env;
        }
        return trimToNull(context.getInitParameter(key));
    }

    private static String getOrDefault(ServletContext context, String key, String envKey, String defaultValue) {
        String value = get(context, key, envKey);
        return value == null ? defaultValue : value;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
