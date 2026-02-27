<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Planning des Transports - ${date}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            margin: 0;
            padding: 20px;
        }

        h2 {
            text-align: center;
            color: #333;
        }

        table {
            border-collapse: collapse;
            width: 90%;
            margin: 20px auto;
            background-color: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.15);
        }

        th, td {
            padding: 12px 15px;
            text-align: center;
        }

        thead {
            background-color: #4CAF50;
            color: white;
        }

        tbody tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        tbody tr:hover {
            background-color: #e0f7fa;
        }

        a {
            display: block;
            width: 150px;
            margin: 20px auto;
            text-align: center;
            text-decoration: none;
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            border-radius: 5px;
        }

        a:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
<h2>Planning des Transports pour la date : ${date}</h2>

<table>
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
                    ${p.reservation.idClient} - Hotel ${p.reservation.idHotel} - ${p.reservation.nombrePassagers} passagers
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

<a href="planification">Retour au formulaire</a>
</body>
</html>