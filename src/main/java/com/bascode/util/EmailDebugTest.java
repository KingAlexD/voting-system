package com.bascode.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailDebugTest {

    public static void main(String[] args) throws Exception {

        System.out.println("\n🔍 Testing Email Configuration...\n");

        String host = "smtp.gmail.com";
        String port = "587";
        String username = "rook6859@gmail.com";
        String password = "ymcmnwrpsfmqvwzr";

        System.out.println("📧 USERNAME: " + username);
        System.out.println("🔑 PASSWORD SET: " + (password != null ? "***SET*** length=" + password.length() : "❌ NOT SET"));
        System.out.println("🏢 HOST: " + host);
        System.out.println("🔌 PORT: " + port);
        System.out.println();

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(username, password);
                    }
                });

        session.setDebug(true); // 🔥 FULL SMTP DEBUG

        try {
            System.out.println("🔄 Connecting to SMTP server...");
            Transport transport = session.getTransport("smtp");
            transport.connect();
            System.out.println("✅ SMTP connection successful!");

            System.out.println("📨 Sending test email...");

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(username));
            message.setSubject("✅ Java SMTP Test - " + System.currentTimeMillis());
            message.setText("If you see this, SMTP works.");

            Transport.send(message);

            System.out.println("🎉 Test email sent successfully!");

        } catch (AuthenticationFailedException e) {
            System.out.println("\n❌ AUTHENTICATION FAILED");
            e.printStackTrace();
            System.out.println("\n👉 Your Gmail app password is wrong OR 2FA is not enabled.");

        } catch (MessagingException e) {
            System.out.println("\n❌ MESSAGING ERROR");
            e.printStackTrace();
            System.out.println("\n👉 Likely host/port/firewall issue.");

        } catch (Exception e) {
            System.out.println("\n❌ UNKNOWN ERROR");
            e.printStackTrace();
        }
    }
}