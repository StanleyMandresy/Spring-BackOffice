<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Planning des Transports - ${date}</title>
</head>
<body>
<h2>Planning des Transports pour la date : ${date}</h2>


    <table border="1" cellpadding="5">
        <thead>
            <tr>
                <th>Véhicule</th>
                <th>Réservation</th>
                <th>Heure départ</th>
                <th>Heure arrivée hôtel</th>
                <th>Heure retour aéroport</th>
            </tr>
        </thead>
        <tbody>
        <c:forEach var="p" items="${planningList}">
            <tr>
                <td>${p.vehicule.reference}</td>
                <td>
                    <c:if test="${p.reservation != null}">
                        ${p.reservation.idClient} - ${p.reservation.nombrePassagers} passagers
                    </c:if>
                    <c:if test="${p.reservation == null}">
                        ---
                    </c:if>
                </td>
                <td>${p.heureDepart}</td>
                <td>${p.heureArrive}</td>
                <td>
                    <c:if test="${p.heureRetour != null}">
                        ${p.heureRetour}
                    </c:if>
                    <c:if test="${p.heureRetour == null}">
                        ---
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>




<br>
<a href="planification">Retour au formulaire</a>
</body>
</html>