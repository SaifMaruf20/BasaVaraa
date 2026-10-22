<%-- Varatia navbar with notifications --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../includes/db.jsp" %>
<%
int vaUnread=0;
String _vaEmail=(String)session.getAttribute("userEmail");
if(_vaEmail!=null){
    Connection _vaCon=null; PreparedStatement _vaPs=null; ResultSet _vaRs=null;
    try{
        _vaCon=getConnection();
        _vaPs=_vaCon.prepareStatement("SELECT COUNT(*) FROM NOTIFICATIONS WHERE USER_EMAIL=? AND IS_READ=0");
        _vaPs.setString(1,_vaEmail); _vaRs=_vaPs.executeQuery(); if(_vaRs.next())vaUnread=_vaRs.getInt(1);
    }catch(Exception _ve){}finally{closeDB(_vaCon,_vaPs,_vaRs);}
}
%>
<nav class="bv-nav">
    <a class="bv-nav-brand" href="../Varatia/VaBody.jsp">&#128247; Varatia Panel</a>
    <div class="bv-ham" id="bvHam"><span></span><span></span><span></span></div>
    <div class="bv-nav-links" id="bvNavLinks">
        <a href="../Varatia/VaBody.jsp">&#128250; Dashboard</a>
        <a href="../Varatia/browseProperties.jsp">&#127963; Browse Properties</a>
        <a href="../Varatia/myRequests.jsp">&#128203; My Requests</a>
        <a href="../Varatia/myComplaints.jsp">&#128226; Complaints</a>
        <a href="../Varatia/vaProfile.jsp">&#128100; Profile</a>
        <a href="../includes/notifications.jsp" class="bv-notif-bell">&#128276;<%if(vaUnread>0){%><span class="bv-notif-count"><%=vaUnread>9?"9+":vaUnread%></span><%}%></a>
        <a href="../User/Logout.jsp" class="bv-nav-logout">&#128682; Logout</a>
    </div>
</nav>
