<%-- BariWala navbar with notifications --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../includes/db.jsp" %>
<%
int bwUnread=0;
String _bwEmail=(String)session.getAttribute("userEmail");
if(_bwEmail!=null){
    Connection _bwCon=null; PreparedStatement _bwPs=null; ResultSet _bwRs=null;
    try{
        _bwCon=getConnection();
        _bwPs=_bwCon.prepareStatement("SELECT COUNT(*) FROM NOTIFICATIONS WHERE USER_EMAIL=? AND IS_READ=0");
        _bwPs.setString(1,_bwEmail); _bwRs=_bwPs.executeQuery(); if(_bwRs.next())bwUnread=_bwRs.getInt(1);
    }catch(Exception _be){}finally{closeDB(_bwCon,_bwPs,_bwRs);}
}
%>
<nav class="bv-nav">
    <a class="bv-nav-brand" href="../BariWala/BaBody.jsp">&#127968; Bariwala Panel</a>
    <div class="bv-ham" id="bvHam"><span></span><span></span><span></span></div>
    <div class="bv-nav-links" id="bvNavLinks">
        <a href="../BariWala/BaBody.jsp">&#128250; Dashboard</a>
        <a href="../BariWala/AddHouse.jsp">&#127968; Add House</a>
        <a href="../BariWala/manageHouse.jsp">&#127963; Manage Houses</a>
        <a href="../BariWala/tenantRequests.jsp">&#128101; Tenant Requests</a>
        <a href="../BariWala/myComplaints.jsp">&#128226; Complaints</a>
        <a href="../includes/notifications.jsp" class="bv-notif-bell">&#128276;<%if(bwUnread>0){%><span class="bv-notif-count"><%=bwUnread>9?"9+":bwUnread%></span><%}%></a>
        <a href="../User/Logout.jsp" class="bv-nav-logout">&#128682; Logout</a>
    </div>
</nav>
