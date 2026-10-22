<%-- Admin navbar --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../includes/db.jsp" %>
<%
int openComplaints=0;
Connection _navCon=null; PreparedStatement _navPs=null; ResultSet _navRs=null;
try{
    _navCon=getConnection();
    _navPs=_navCon.prepareStatement("SELECT COUNT(*) FROM COMPLAINTS WHERE STATUS='Open'");
    _navRs=_navPs.executeQuery(); if(_navRs.next()) openComplaints=_navRs.getInt(1);
}catch(Exception _ne){}finally{closeDB(_navCon,_navPs,_navRs);}
%>
<nav class="bv-nav">
    <a class="bv-nav-brand" href="../Admin/adminHome.jsp">&#9881; Admin Panel</a>
    <div class="bv-ham" id="bvHam"><span></span><span></span><span></span></div>
    <div class="bv-nav-links" id="bvNavLinks">
        <a href="../Admin/adminHome.jsp">&#128250; Dashboard</a>
        <a href="../Admin/bariwala.jsp">&#127968; Bariwala</a>
        <a href="../Admin/varatia.jsp">&#128101; Varatia</a>
        <a href="../Admin/properties.jsp">&#127963; Properties</a>
        <a href="../Admin/requests.jsp">&#128203; Requests</a>
        <a href="../Admin/complaints.jsp">&#128226; Complaints<%if(openComplaints>0){%> <span style="background:var(--danger);color:#fff;border-radius:10px;padding:1px 6px;font-size:0.7rem;"><%=openComplaints%></span><%}%></a>
        <a href="../Admin/bannedUsers.jsp">&#128683; Banned</a>
        <a href="../User/Login.jsp" class="bv-nav-logout">&#128682; Logout</a>
    </div>
</nav>
