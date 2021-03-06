<%@page import="Model.Permission"%>
<%@page import="utils.PermissionUtil"%>
<%@include file="../globalsub.jsp"  %>
<%@page import="java.util.List"%>
<%@page import="java.util.Arrays"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%    String pageName = "รายงานการอนุมัติ-กำไร";

    request.setAttribute("title", pageName);
    request.setAttribute("sublink", "../");
    request.setAttribute("css", Arrays.asList("../css/sweetalert.css", "../css/bootstrap-datetimepicker.min.css"));
    request.setAttribute("js", Arrays.asList("../js/sweetalert.min.js", "../js/bootstrap-datetimepicker.min.js", "../js/reportsa.js", "../js/SimpleTableCellEditor.js"));
    HttpSession _sess = request.getSession();
%>
<jsp:include  page="../theme/header.jsp" flush="true" />
<style>
    table {
        border-collapse: collapse;
    }
    body {
        color: black;
    }
    table, th, td {

        border: 1px solid #D3D3D3 ;
        padding:0px;
    }
    tr:hover{
        background-color: #F0F8FF;
    }

    .bg-primary{
        background-color: #17a2b8;
    }

    .bg-success{
        background-color: #28a745;
    }

    .bg-warning{
        background-color: #ffc107;
    }

    .bg-danger{
        background-color: #dc3545;
    }
    .editMe{
        color: #dc3545
    }
    .editIt{
        color: #dc3545
    }
</style>
<input type="hidden" value="" id="r_status">
<input type="hidden" value="<%=_sess.getAttribute("user")%>" id="userlogin">
<input type="hidden" value="<%=session.getAttribute("user")%>" id="user_code">
<input type="hidden" value="<%=session.getAttribute("branch_code")%>" id="user_branch">
<input type="hidden" value="${user_name}" id="user_namex">
<input type="hidden" id="hSubLink" value="${sublink}">

<div class="content-wrapper" style="background-color: #fff">
    <!-- Content Header (Page header) -->
    <div class="content-header">
        <div class="container-fluid">
            <div class="alert alert-dark   " role="alert" id="showAlertMsg" style='display:none'>
                <p id="alert-doc-msg">

                </p>
                <a href="javascript:;" class="alert-link btn-alert-ok" style="color:#fff">ตกลง</a>
            </div>
            <div id="doc_list" >
                <div class="row">
                    <div class="col-sm-6 col-md-3">
                        <label>จากวันที่</label>
                        <input type="date" class="form-control form-control-sm" id="from_date" style="height: 34px;"/>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <label>ถึงวันที่</label>
                        <input type="date" class="form-control form-control-sm" id="to_date" style="height: 34px;"/>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <label>รหัสลูกค้า</label>
                        <div class="input-group input-group-sm mb-3">
                            <input type="text" class="form-control" id="cust_code"  style="height: 34px;">
                            <div class="input-group-append">
                                <span class="input-group-text cust_box_click" style="cursor: pointer"><i class="fa fa-search"></i></span>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <label>สาขา</label>
                        <select class="form-control form-control-sm branch_code" style="height: 34px;" id="branch_code" disabled>

                        </select>
                    </div>
                </div>
                <div class="row">

                    <div class="col-sm-6 col-md-3">
                        <label>แบรนด์</label>
                        <select class=" select_brand" id="brand_code" style="width:100%">

                        </select>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <label>พนักงานขาย</label>
                        <select class=" select_sale" id="saler_code" style="width:100%">

                        </select>
                    </div>

                </div>
                <div class="row">
                    <div class="col-sm-12" style="margin-top:0.5rem;">
                        <button class="btn btn-success " onclick="_Process()"><i class="fa fa-play"></i> ประมวลผล</button>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12 table-responsive" style="margin-top:1rem;" id="show_list_detail">

                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
<div class="modal fade" id="modalCust" tabindex="-1" role="dialog"  aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">ค้นหาลูกค้า</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-6">
                        <input type="text" class="form-control" id="search_cust_input" placeholder="ค้นหาลูกค้า">
                    </div>
                    <div class="col-sm-4">
                        <button  class="btn btn-success mb-2" onclick="_searchCust()">ค้นหา</button>
                    </div>

                </div>
                <ul class="list-group" id="list_search_cust" style="height: 65vh;overflow-y: scroll">


                </ul>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" data-dismiss="modal">ยกเลิก</button>
            </div>
        </div>
    </div>
</div>

<jsp:include  page="../theme/footer.jsp" flush="true" />
<script>
    var a = new Date();
    var secrchByItem = false;
    var secrchByBarcode = false;
    var ses = new webkitSpeechRecognition();
    ses.continuous = true;
    ses.lang = 'TH'
    ses.onresult = function (e) {
        if (event.results.length > 0) {
            sonuc = event.results[event.results.length - 1];
            if (sonuc.isFinal) {
                var oldValue = $('#item').val();
                var newValue = sonuc[0].transcript;
                if (oldValue.length > 0)
                {
                    oldValue = oldValue + ' ';
                }
                if (newValue.indexOf('เริ่มใหม่') != -1) {
                    clearValue();
                    $("#item").text('เริ่มใหม่');
                } else {
                    $('#item').val(oldValue + sonuc[0].transcript);
                    secrchByItem = true;
                }
            }
        }
    }

    var $speechworking = false;



    function clearValue() {
        $('#item').val('');
    }

    function eylem() {
        if ($speechworking == false)
        {
            $speechworking = true;
            $('#speech').text('หยุดค้นหาด้วยเสียง');
            ses.start();
        } else {
            $('#speech').text('ค้นหาด้วยเสียง');
            $speechworking = false;
            ses.stop();
        }
    }
</script>