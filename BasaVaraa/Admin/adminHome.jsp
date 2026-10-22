<%@ page import="java.sql.*,java.time.*,java.time.format.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../includes/db.jsp" %>
<%
/* ── Simple admin session check (no role in users table for admin) ─
   Admin accesses via direct URL; add a real admin table for production. */
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

int totalBariwala = 0, totalVaratia = 0, totalHouses = 0, totalRequests = 0;
int[] bariwalaPerMonth = new int[6];
int[] varatiaPerMonth  = new int[6];
int[] housesPerMonth   = new int[6];
String[] monthLabels   = new String[6];

Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
try {
    con = getConnection();

    ps = con.prepareStatement("SELECT COUNT(*) FROM basavara_users WHERE userType='Bariwala'");
    rs = ps.executeQuery(); if (rs.next()) totalBariwala = rs.getInt(1); rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM basavara_users WHERE userType='Varatia'");
    rs = ps.executeQuery(); if (rs.next()) totalVaratia = rs.getInt(1); rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM HOUSE_POST");
    rs = ps.executeQuery(); if (rs.next()) totalHouses = rs.getInt(1); rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM TENANT_REQUESTS");
    rs = ps.executeQuery(); if (rs.next()) totalRequests = rs.getInt(1); rs.close(); ps.close();

    // Monthly data for last 6 months
    LocalDate today = LocalDate.now();
    for (int i=5; i>=0; i--) {
        LocalDate m = today.minusMonths(i);
        int idx = 5-i;
        monthLabels[idx] = m.getMonth().getDisplayName(TextStyle.SHORT, java.util.Locale.ENGLISH) + " " + m.getYear();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM basavara_users WHERE userType=? " +
            "AND EXTRACT(MONTH FROM created_at)=? AND EXTRACT(YEAR FROM created_at)=?");
        ps.setString(1,"Bariwala"); ps.setInt(2,m.getMonthValue()); ps.setInt(3,m.getYear());
        rs = ps.executeQuery(); if (rs.next()) bariwalaPerMonth[idx]=rs.getInt(1); rs.close(); ps.close();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM basavara_users WHERE userType=? " +
            "AND EXTRACT(MONTH FROM created_at)=? AND EXTRACT(YEAR FROM created_at)=?");
        ps.setString(1,"Varatia"); ps.setInt(2,m.getMonthValue()); ps.setInt(3,m.getYear());
        rs = ps.executeQuery(); if (rs.next()) varatiaPerMonth[idx]=rs.getInt(1); rs.close(); ps.close();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM HOUSE_POST WHERE EXTRACT(MONTH FROM created_at)=? AND EXTRACT(YEAR FROM created_at)=?");
        ps.setInt(1,m.getMonthValue()); ps.setInt(2,m.getYear());
        rs = ps.executeQuery(); if (rs.next()) housesPerMonth[idx]=rs.getInt(1); rs.close(); ps.close();
    }
} catch(Exception e) {
    logError("adminHome.jsp", e);
} finally { closeDB(con,ps,rs); }

// Build JS arrays safely
StringBuilder jsL=new StringBuilder("["), jsBw=new StringBuilder("["),
              jsVa=new StringBuilder("["), jsH=new StringBuilder("[");
for (int i=0;i<6;i++) {
    jsL.append("'").append(monthLabels[i]).append("'").append(i<5?",":"");
    jsBw.append(bariwalaPerMonth[i]).append(i<5?",":"");
    jsVa.append(varatiaPerMonth[i]).append(i<5?",":"");
    jsH.append(housesPerMonth[i]).append(i<5?",":"");
}
jsL.append("]"); jsBw.append("]"); jsVa.append("]"); jsH.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard – BasaVara</title>
<%@ include file="../includes/styles.jsp" %>
<style>
.widget-box {
    background:rgba(255,255,255,0.08); border:1px solid var(--glass-bdr);
    border-radius:var(--radius); padding:20px; box-shadow:var(--shadow);
}
.widget-title { font-weight:700; color:#fff; font-size:0.95rem; margin-bottom:14px; }
#clock-time { font-size:2.8rem; font-weight:800; color:var(--blue); letter-spacing:3px; text-align:center; }
#clock-day  { text-align:center; color:var(--success); font-weight:700; font-size:1rem; margin-top:4px; }
#clock-date { text-align:center; color:var(--text-muted); font-size:0.85rem; margin-top:2px; }
.cal-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; }
.cal-header span { font-weight:700; color:#fff; }
.cal-nav { background:rgba(255,255,255,0.10); border:1px solid var(--glass-bdr); color:#fff;
           border-radius:6px; padding:2px 10px; cursor:pointer; font-size:0.85rem; }
.cal-nav:hover { background:rgba(255,255,255,0.2); }
.cal-grid { display:grid; grid-template-columns:repeat(7,1fr); gap:4px; }
.cal-dn   { text-align:center; font-size:0.72rem; color:var(--text-muted); font-weight:600; padding:4px 0; }
.cal-day  { text-align:center; padding:6px 2px; border-radius:8px; font-size:0.78rem;
            color:rgba(255,255,255,0.70); cursor:default; transition:0.2s; }
.cal-day:hover { background:rgba(255,255,255,0.10); }
.cal-day.today { background:linear-gradient(135deg,#3b82f6,var(--blue)); color:#fff; font-weight:800; }
.chart-wrap { position:relative; width:100%; height:200px; }
</style>
</head>
<body>
<%@ include file="../Admin/adminNav.jsp" %>

<div class="bv-container">

    <div class="bv-section-title" style="margin-bottom:20px;">&#128250; Dashboard Overview</div>

    <!-- STAT CARDS -->
    <div class="bv-grid bv-grid-4" style="margin-bottom:28px;">
        <a href="bariwala.jsp" style="text-decoration:none;">
            <div class="glass bv-stat">
                <div class="bv-stat-icon" style="color:var(--blue);">&#128100;</div>
                <div class="bv-stat-num" style="color:var(--blue);"><%= totalBariwala %></div>
                <div class="bv-stat-lbl">Bariwala</div>
            </div>
        </a>
        <a href="varatia.jsp" style="text-decoration:none;">
            <div class="glass bv-stat">
                <div class="bv-stat-icon" style="color:var(--success);">&#128101;</div>
                <div class="bv-stat-num" style="color:var(--success);"><%= totalVaratia %></div>
                <div class="bv-stat-lbl">Varatia</div>
            </div>
        </a>
        <a href="properties.jsp" style="text-decoration:none;">
            <div class="glass bv-stat">
                <div class="bv-stat-icon" style="color:var(--warn);">&#127963;</div>
                <div class="bv-stat-num" style="color:var(--warn);"><%= totalHouses %></div>
                <div class="bv-stat-lbl">Properties</div>
            </div>
        </a>
        <div class="glass bv-stat">
            <div class="bv-stat-icon" style="color:var(--accent);">&#128203;</div>
            <div class="bv-stat-num" style="color:var(--accent);"><%= totalRequests %></div>
            <div class="bv-stat-lbl">Requests</div>
        </div>
    </div>

    <!-- CLOCK + CALENDAR -->
    <div class="bv-grid" style="grid-template-columns:1fr 2fr;gap:20px;margin-bottom:24px;">
        <div class="widget-box" style="display:flex;flex-direction:column;justify-content:center;min-height:180px;">
            <div class="widget-title">&#128336; Live Clock</div>
            <div id="clock-time">00:00:00</div>
            <div id="clock-day">Monday</div>
            <div id="clock-date">1 January 2026</div>
        </div>
        <div class="widget-box">
            <div class="widget-title">&#128197; Calendar</div>
            <div class="cal-header">
                <button class="cal-nav" onclick="changeMonth(-1)">&#8249;</button>
                <span id="calMonthYear"></span>
                <button class="cal-nav" onclick="changeMonth(1)">&#8250;</button>
            </div>
            <div class="cal-grid" id="calDayNames"></div>
            <div class="cal-grid" id="calDays"></div>
        </div>
    </div>

    <!-- CHARTS -->
    <div class="bv-grid" style="grid-template-columns:1fr 1fr;gap:20px;">
        <div class="widget-box">
            <div class="widget-title">&#128202; User Registrations (Last 6 Months)</div>
            <div class="chart-wrap"><canvas id="userChart"></canvas></div>
        </div>
        <div class="widget-box">
            <div class="widget-title">&#127963; Properties Listed (Last 6 Months)</div>
            <div class="chart-wrap"><canvas id="houseChart"></canvas></div>
        </div>
    </div>

</div>

<!-- Chart.js from CDN (chart library, not a UI framework) -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
/* ── CLOCK ──────────────────────────────────────────────── */
function updateClock(){
    var now = new Date();
    var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    var months = ['January','February','March','April','May','June',
                  'July','August','September','October','November','December'];
    var h = String(now.getHours()).padStart(2,'0');
    var m = String(now.getMinutes()).padStart(2,'0');
    var s = String(now.getSeconds()).padStart(2,'0');
    document.getElementById('clock-time').textContent = h+':'+m+':'+s;
    document.getElementById('clock-day').textContent  = days[now.getDay()];
    document.getElementById('clock-date').textContent = now.getDate()+' '+months[now.getMonth()]+' '+now.getFullYear();
}
setInterval(updateClock,1000); updateClock();

/* ── CALENDAR ───────────────────────────────────────────── */
var calDate = new Date();
function renderCalendar(){
    var year=calDate.getFullYear(), month=calDate.getMonth(), today=new Date();
    var mNames=['January','February','March','April','May','June','July','August','September','October','November','December'];
    document.getElementById('calMonthYear').textContent = mNames[month]+' '+year;
    var dn=document.getElementById('calDayNames'); dn.innerHTML='';
    ['Su','Mo','Tu','We','Th','Fr','Sa'].forEach(function(d){
        var el=document.createElement('div'); el.className='cal-dn'; el.textContent=d; dn.appendChild(el);
    });
    var dc=document.getElementById('calDays'); dc.innerHTML='';
    var firstDay=new Date(year,month,1).getDay(), total=new Date(year,month+1,0).getDate();
    for(var i=0;i<firstDay;i++){ var el=document.createElement('div'); el.className='cal-day'; dc.appendChild(el); }
    for(var d=1;d<=total;d++){
        var el=document.createElement('div'); el.className='cal-day'; el.textContent=d;
        if(d===today.getDate()&&month===today.getMonth()&&year===today.getFullYear()) el.classList.add('today');
        dc.appendChild(el);
    }
}
function changeMonth(dir){ calDate.setMonth(calDate.getMonth()+dir); renderCalendar(); }
renderCalendar();

/* ── CHARTS ─────────────────────────────────────────────── */
var labels    = <%= jsL %>;
var bwData    = <%= jsBw %>;
var vaData    = <%= jsVa %>;
var houseData = <%= jsH %>;

var chartOpts = {
    responsive:true, maintainAspectRatio:false,
    plugins:{ legend:{ labels:{ color:'#e5e7eb', font:{size:11} } } },
    scales:{
        x:{ ticks:{color:'#cbd5e1',font:{size:10}}, grid:{color:'rgba(255,255,255,0.06)'} },
        y:{ ticks:{color:'#cbd5e1',font:{size:10},stepSize:1,precision:0},
            grid:{color:'rgba(255,255,255,0.06)'}, beginAtZero:true }
    }
};

new Chart(document.getElementById('userChart'),{
    type:'bar', data:{labels:labels, datasets:[
        {label:'Bariwala',data:bwData,backgroundColor:'rgba(96,165,250,0.5)',borderColor:'#60a5fa',borderWidth:2,borderRadius:5},
        {label:'Varatia', data:vaData,backgroundColor:'rgba(52,211,153,0.5)',borderColor:'#34d399',borderWidth:2,borderRadius:5}
    ]}, options:chartOpts
});

new Chart(document.getElementById('houseChart'),{
    type:'line', data:{labels:labels, datasets:[
        {label:'Properties',data:houseData,backgroundColor:'rgba(251,191,36,0.15)',borderColor:'#fbbf24',
         borderWidth:2.5,pointBackgroundColor:'#fbbf24',pointRadius:5,tension:0.4,fill:true}
    ]}, options:chartOpts
});
</script>
<%@ include file="../includes/scripts.jsp" %>
</body>
</html>
