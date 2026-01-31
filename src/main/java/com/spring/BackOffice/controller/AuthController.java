package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.User;


import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;



@Controller
public class AuthController {

    private JdbcTemplate jdbcTemplate;

    public AuthController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ ATTENTION: JdbcTemplate est null dans AuthController !");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    @PostMapping("/auth/login")
    public String login(String email, String password) {
        if (jdbcTemplate == null) {
            return "Erreur : JdbcTemplate non initialisé";
        }
        User user = User.authenticate(jdbcTemplate, email, password);
        if(user != null) {
            return "Connexion réussie pour : " + user.getNom();
        } else {
            return "Email ou mot de passe incorrect !";
        }
    }

    @RestAPI
    @GetMapping("/auth/users")
    public String listUsers() {
        if (jdbcTemplate == null) {
            return "Erreur : JdbcTemplate non initialisé";
        }
        try {
            List<User> users = User.findAll(jdbcTemplate);
            StringBuilder sb = new StringBuilder();
            sb.append("Liste des utilisateurs :\n");
            for(User u : users) {
                sb.append(u.toString()).append("\n");
            }
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "Erreur lors de la récupération des utilisateurs";
        }
    }

}
