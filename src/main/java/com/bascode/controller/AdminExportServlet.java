package com.bascode.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.repository.AdminAuditLogRepository;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.UserRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.ServletUtil;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfWriter;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/export")
public class AdminExportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();
    private final AdminAuditLogRepository auditLogRepository = new AdminAuditLogRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        String format = request.getParameter("format");
        if (type == null || type.isBlank()) {
            type = "votes";
        }
        if (format == null || format.isBlank()) {
            format = "csv";
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            String content = switch (type) {
            case "users" -> buildUsersCsv(em);
            case "contesters" -> buildContestersCsv(em);
            case "audit" -> buildAuditCsv(em);
            default -> buildVotesCsv(em);
            };

            if ("pdf".equalsIgnoreCase(format)) {
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + type + "-report.pdf\"");
                writePdf(response, type + " report", content);
                return;
            }

            response.setContentType("text/csv");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + type + "-report.csv\"");
            response.getOutputStream().write(content.getBytes(StandardCharsets.UTF_8));
        } finally {
            em.close();
        }
    }

    private String buildUsersCsv(EntityManager em) {
        StringBuilder sb = new StringBuilder("firstName,lastName,email,role,birthYear,verified\n");
        for (var u : userRepository.findAllVotersAndContesters(em)) {
            sb.append(csv(u.getFirstName())).append(',').append(csv(u.getLastName())).append(',').append(csv(u.getEmail()))
                    .append(',').append(csv(u.getRole().name())).append(',').append(u.getBirthYear()).append(',')
                    .append(u.isEmailVerified()).append('\n');
        }
        return sb.toString();
    }

    private String buildContestersCsv(EntityManager em) {
        var voteCounts = voteRepository.voteCountByContester(em);
        StringBuilder sb = new StringBuilder("name,email,position,status,votes,manifesto\n");
        for (var c : contesterRepository.findAll(em)) {
            String name = c.getUser().getFirstName() + " " + c.getUser().getLastName();
            sb.append(csv(name)).append(',').append(csv(c.getUser().getEmail())).append(',').append(csv(c.getPosition().name()))
                    .append(',').append(csv(c.getStatus().name())).append(',').append(voteCounts.getOrDefault(c.getId(), 0L))
                    .append(',').append(csv(c.getManifesto())).append('\n');
        }
        return sb.toString();
    }

    private String buildVotesCsv(EntityManager em) {
        StringBuilder sb = new StringBuilder("voter,contester,position\n");
        for (var v : voteRepository.findAll(em)) {
            String voter = v.getVoter().getFirstName() + " " + v.getVoter().getLastName();
            String contester = v.getContester().getUser().getFirstName() + " " + v.getContester().getUser().getLastName();
            sb.append(csv(voter)).append(',').append(csv(contester)).append(',').append(csv(v.getContester().getPosition().name()))
                    .append('\n');
        }
        return sb.toString();
    }

    private String buildAuditCsv(EntityManager em) {
        StringBuilder sb = new StringBuilder("createdAt,admin,actionType,actionDetail\n");
        for (var a : auditLogRepository.findRecent(em, 500)) {
            sb.append(csv(String.valueOf(a.getCreatedAt()))).append(',').append(csv(a.getAdminUser().getEmail())).append(',')
                    .append(csv(a.getActionType())).append(',').append(csv(a.getActionDetail())).append('\n');
        }
        return sb.toString();
    }

    private String csv(String value) {
        if (value == null) {
            return "\"\"";
        }
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }

    private void writePdf(HttpServletResponse response, String title, String text) throws IOException {
        Document document = new Document();
        try {
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            document.add(new Paragraph(title));
            document.add(new Paragraph(" "));
            for (String line : text.split("\\n")) {
                document.add(new Paragraph(line));
            }
        } catch (DocumentException ex) {
            throw new IOException(ex);
        } finally {
            document.close();
        }
    }
}
