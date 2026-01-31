package com.spring.BackOffice.config;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import java.io.File;

public class JdbcTemplateProvider {

    private static JdbcTemplate jdbcTemplate;
    private static ApplicationContext context;

    // Bloc static exécuté une seule fois
    static {
        initializeJdbcTemplate();
    }

    private static void initializeJdbcTemplate() {
        try {
            // Essayer avec le chemin de fichier système d'abord
            String webInfPath = getWebInfPath();
            if (webInfPath != null) {
                System.out.println("🔍 Tentative de chargement depuis: " + webInfPath);
                try {
                    context = new FileSystemXmlApplicationContext("file:" + webInfPath + "/spring-context.xml");
                    jdbcTemplate = (JdbcTemplate) context.getBean("jdbcTemplate");
                    System.out.println("✔ JdbcTemplate initialisé avec succès (FileSystem) !");
                    return;
                } catch (Exception e) {
                    System.err.println("⚠ Chargement FileSystem échoué: " + e.getMessage());
                }
            }

            // Essayer avec ClassPathXmlApplicationContext
            System.out.println("🔍 Tentative de chargement depuis classpath...");
            String[] configLocations = {
                "classpath:/spring-context.xml",
                "classpath:spring-context.xml",
                "classpath:/WEB-INF/spring-context.xml"
            };

            for (String location : configLocations) {
                try {
                    System.out.println("  Essai: " + location);
                    context = new ClassPathXmlApplicationContext(location);
                    jdbcTemplate = (JdbcTemplate) context.getBean("jdbcTemplate");
                    System.out.println("✔ JdbcTemplate initialisé avec succès (" + location + ") !");
                    return;
                } catch (Exception e) {
                    System.out.println("  ✗ Échec avec " + location);
                }
            }

            System.err.println("❌ Impossible d'initialiser JdbcTemplate !");

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Erreur lors de l'initialisation du JdbcTemplate !");
        }
    }

    private static String getWebInfPath() {
        try {
            // Récupérer le chemin du répertoire courant
            String classPath = JdbcTemplateProvider.class.getProtectionDomain().getCodeSource().getLocation().getPath();
            System.out.println("📁 ClassPath: " + classPath);

            // Essayer de trouver WEB-INF
            File current = new File(classPath);
            while (current != null) {
                File webInf = new File(current, "WEB-INF");
                if (webInf.exists() && webInf.isDirectory()) {
                    return webInf.getAbsolutePath();
                }
                current = current.getParentFile();
            }
        } catch (Exception e) {
            System.out.println("⚠ Impossible de trouver le chemin WEB-INF: " + e.getMessage());
        }
        return null;
    }

    // Méthode publique pour récupérer l'instance
    public static JdbcTemplate getJdbcTemplate() {
        if (jdbcTemplate == null) {
            System.err.println("⚠️ ATTENTION: jdbcTemplate est NULL !");
        }
        return jdbcTemplate;
    }
    
    // Méthode pour réinitialiser le contexte si nécessaire
    public static void reinitialize() {
        try {
            initializeJdbcTemplate();
            if (jdbcTemplate != null) {
                System.out.println("✔ JdbcTemplate réinitialisé avec succès !");
            } else {
                System.err.println("❌ Réinitialisation échouée - jdbcTemplate toujours NULL !");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Impossible de réinitialiser JdbcTemplate !");
        }
    }

}
