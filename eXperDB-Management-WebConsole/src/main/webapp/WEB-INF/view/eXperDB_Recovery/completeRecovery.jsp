<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ include file="../cmmn/cs2.jsp"%>
   

<%
	/**
	* @Class Name : completeRecovery.jsp
	* @Description : 완전복구 화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2021-06-09	신예은 매니저		최초 생성
	*  2021-11-30 변승우 책임 			기능 및 전체 메세지 적용
	*
	* author 신예은 매니저
	* since 2021.06.09
	*
	*/
%>

<style>
.moving-square-loader:before {
    content: "";
    position: absolute;
    width: 14px;
    height: 14px;
    top: calc(50% - -15px);
    left: 0px;
    background-color: #68afff;
    animation: rotatemove 1s infinite;
}
</style>

<script type="text/javascript">

var storageList = [];
var CIFSList = [];
var NFSList = [];
var storageExist = "N";
var recLogList;
var jobend = 0;
/* ********************************************************
 * 페이지 시작시
 ******************************************************* */
$(window.document).ready(function() {
	fn_init();
	fn_getBackupDBList();
	$("#storageDiv").hide();
	$(".moving-square-loader").hide();
	$("#status_basic").show();
	/* $("#status_ing").hide();
	$("#status_basic").show(); */

});


function fn_init(){
	recLogList = $("#recLogList").DataTable({
		scrollY : "480px",
		scrollX: true,	
		searching : false,
		processing : true,
		paging : false,
		lengthChange: false,
		deferRender : true,
		info : false,
		bSort : false,
		columns : [
		{
			data : "type",
			render : function(data, type, full, meta) {	 						
				var html = '';
				// TYPE_INFO
				if (full.type == 1) {
				html += "<div class='badge badge-light' style='background-color: transparent !important;font-size: 0.875rem;'>";
				html += "	<i class='fa fa-info-circle text-primary' /> </i>";
				html += "</div>";
				// TYPE_ERROR
				}else if(full.type == 2){
					html += "<div class='badge badge-light' style='background-color: transparent !important;font-size: 0.875rem;'>";
					html += "	<i class='fa fa-times-circle text-danger' /> </i>";
					html += "</div>";
				// TYPE_WARNING
				}  else if(full.type == 3){
				html += "<div class='badge badge-light' style='background-color: transparent !important;font-size: 0.875rem;'>";
				html += "	<i class='fa fa-warning text-warning' /> </i>";
				html += "</div>";				
				} 
				return html;
			},
			className : "dt-center",
			defaultContent : ""
		},				
		{data : "time", className : "dt-center", defaultContent : ""},	
		{data : "message", className : "dt-left", defaultContent : ""}
		]
	});

	recLogList.tables().header().to$().find('th:eq(0)').css('min-width');
	recLogList.tables().header().to$().find('th:eq(1)').css('min-width');
	recLogList.tables().header().to$().find('th:eq(2)').css('min-width');

	$(window).trigger('resize'); 

}

 
function fn_bmrInstanceClick(){
	var instance = $("#bmrInstant").val();
	$("#bmrInstantAlert").empty();
	if(instance == 1){
		$("#bmrInstantAlert").append("* 먼저 서버 시작에 필요한 데이터를 복구합니다. 이후 나머지 데이터는 서버 시작 후 복구 됩니다.");
	}
}


function fn_getBackupDBList(){
	$.ajax({
		url : "/experdb/nodeInfoList.do",
		type : "post"
	})
	.done(function(result){
		fn_setBackupDBList(result.serverList);
	})
	.fail (function(xhr, status, error){
		 if(xhr.status == 401) {
			showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
		} else if (xhr.status == 403){
			showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
		} else {
			showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
		}
	 })
}

function fn_setBackupDBList(data){
	var html;
	for(var i =0; i<data.length; i++){
		html += '<option value="'+data[i].ipadr+'">'+data[i].ipadr+ ' [' + data[i].masterGbn + ']'+'</option>';
	}
	$("#backupDBList").append(html);
}

function fn_backupDBChoice(){
	var ipadr = $("#backupDBList").val();
	if(ipadr != 0) {
		$.ajax({
			url : "/experdb/recStorageList.do",
			type : "post",
			data : {
				ipadr : ipadr
			}
		})
		.done(function(result){
			fn_setStorageList(result.storageList);
		})
		.fail (function(xhr, status, error){
			if(xhr.status == 401) {
				showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else if (xhr.status == 403){
				showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else {
				showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
			}
		})
		.always(function(){
			fn_recoveryDBReset();
		})
	}
}


function fn_recoveryDBReset(){
	$("#recMachineMAC").val("");
	$("#recMachineIP").val("");
	$("#recoveryDB").val("");
	$("#recMachineSNM").val("");
	$("#recMachineGateWay").val("");
	$("#recMachineDNS").val("");
}

function fn_setStorageList(data) {
	storageList.length=0;
	CIFSList.length=0;
	NFSList.length=0;
	storageList = data;
	$("#storageDiv").hide();
	$("#recStorageType").val("");
	$("#recStoragePath").val("");
	
	if(storageList.length == 0){
		storageExist = "N";
		showSwalIcon('<spring:message code="eXperDB_backup.msg101" />', '<spring:message code="common.close" />', '', 'error');
		$("#backupDBList").val(0);
		
	}else if(storageList.length == 1){
		storageExist = "Y";
		
		$("#recStorageType").val(data[0].type);
		$("#recStoragePath").val(data[0].path);
		
	}else{
		storageExist = "Y";
		for(var i =0; i<storageList.length; i++){
			if(storageList[i].type == "2"){
				CIFSList.push(storageList[i]);
			}else{
				NFSList.push(storageList[i]);
			}
		}
		$("#storageDiv").show();
	}
}

function fn_storageTypeClick(){
	var type = $("#storageType").val();
	var html;
	$("#storageList").empty();
	if(type == 2){
		for(var i =0; i<CIFSList.length; i++){			
			html += '<option value="'+CIFSList[i].path+'">'+CIFSList[i].path+'</option>';
		}
	}else{
		for(var i =0; i<NFSList.length; i++){			
			html += '<option value="'+NFSList[i].path+'">'+NFSList[i].path+'</option>';
		}
	}
	$("#storageList").append(html);
}

function fn_targetListPopup(){
	if($("#backupDBList").val() != 0){
		$.ajax({
			url : "/experdb/recoveryDBList.do",
			type : "post"
		})
		.done(function(result){
			TargetList.clear();
			TargetList.rows.add(result.recoveryList).draw();
			fn_setIpList(result.recoveryList);
			$("#pop_layer_popup_recoveryTargetList").modal("show");
		})
		.fail (function(xhr, status, error){
			if(xhr.status == 401) {
				showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else if (xhr.status == 403){
				showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else {
				showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
			}
		})
	}else{
		showSwalIcon('<spring:message code="eXperDB_backup.msg102" />', '<spring:message code="common.close" />', '', 'error');
	}
}

function fn_runNowClick(){
	if(fn_valCheck()){
		confile_title = '<spring:message code="eXperDB_backup.msg103" />';
		$('#con_multi_gbn', '#findConfirmMulti').val("recovery_run");
		$('#confirm_multi_tlt').html(confile_title);
		$('#confirm_multi_msg').html('<spring:message code="eXperDB_backup.msg104" />');
		$('#pop_confirm_multi_md').modal("show");
	}
}

function fn_valCheck(){
	if($("#bmrInstant").val() == 0){
		showSwalIcon('Instance BMR을 선택해주세요', '<spring:message code="common.close" />', '', 'error', 'top');
		return false;
	}else if($("#backupDBList").val() == 0){
		showSwalIcon('<spring:message code="eXperDB_backup.msg105" />', '<spring:message code="common.close" />', '', 'error', 'top');
		return false;
	}else if($("#recMachineIP").val() == ""){
		showSwalIcon('<spring:message code="eXperDB_backup.msg106" />', '<spring:message code="common.close" />', '', 'error', 'top');
		return false;
	}
	return true;
}

function fnc_confirmMultiRst(gbn){
	  if(gbn == "recovery_run"){
		  fn_passwordCheckPopup();
	  }else if(gbn == "recoveryDB_del"){
		  fn_recMachineDel();
	  }
}

function fn_passwordCheckPopup(){
	 fn_pwCheckFormReset();
	 $("#pop_layer_popup_recoveryPasswordCheckForm").modal("show");
}

// recovery run
function fn_recoveryRun(){
	if($("#recoveryPW").val() != ""){
		
		// console.log("=================================================");
		// console.log("password		" + $("#recoveryPW").val());
		// console.log("bmrInstant		" + $("#bmrInstant").val());
		// console.log("sourceDB		" + $("#backupDBList").val());
		// console.log("storageType	" + $("#recStorageType").val());
		// console.log("storagePath	" + $("#recStoragePath").val());
		// console.log("targetMac		" + $("#recMachineMAC").val());
		// console.log("targetIp		" + $("#recMachineIP").val());
		// console.log("targetSNM		" + $("#recMachineSNM").val());
		// console.log("targetGW		" + $("#recMachineGateWay").val());
		// console.log("targetDNS		" + $("#recMachineDNS").val());
		// console.log("=================================================");
		
		if($("#recStorageType").val() == "" || $("#recStoragePath").val() == ""){
			$("#recStorageType").val($("#storageType").val());
			$("#recStoragePath").val($("#storageList").val());
		}
		
		$.ajax({
			url : "/experdb/completeRecoveryRun.do",
			type : "post",
			data : {
				password : $("#recoveryPW").val(),
				bmrInstant : $("#bmrInstant").val(),
				sourceDB : $("#backupDBList").val(),
				storageType : $("#recStorageType").val(),
				storagePath : $("#recStoragePath").val(),
				targetMac : $("#recMachineMAC").val(),
				targetIp : $("#recMachineIP").val(),
				targetSNM : $("#recMachineSNM").val(),
				targetGW : $("#recMachineGateWay").val(),
				targetDNS : $("#recMachineDNS").val()
			}
		})
		.done(function(data){
			if(data.result_code == 5){
				showSwalIcon('<spring:message code="eXperDB_backup.msg107" />', '<spring:message code="common.close" />', '', 'error', 'top');
				fn_pwCheckFormReset();
			}else{
				showSwalIcon('<spring:message code="eXperDB_backup.msg108" />', '<spring:message code="common.close" />', '', 'success');
				// 생성된 jobName
				var jobName = data.jobName;
				// 실행된 Job의 id 조회
				var jobId = fn_selectJobId(jobName);
				// logCheck 함수 called
				fn_selectActivityLogCheck(jobId, jobName);
				$("#pop_layer_popup_recoveryPasswordCheckForm").modal("hide");			
				$(".moving-square-loader").show();
				$("#status_basic").hide();
				
			}
		})
		.fail (function(xhr, status, error){
			if(xhr.status == 401) {
				showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else if (xhr.status == 403){
				showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else {
				showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
			}
		})
	}else{
		showSwalIcon('<spring:message code="eXperDB_backup.msg109" />', '<spring:message code="common.close" />', '', 'error', 'top');
		$("#recoveryPW").focus();
	}
}

// logcheck 함수
function fn_selectActivityLogCheck(jobid, jobname){
		
		// console.log("fn_selectActivityLogCheck!! --> " + jobid + " // " + jobname);
		setTimeout(fn_selectJobEnd, 8000, jobid,jobname);	
		setTimeout(fn_selectActivityLog, 5000, jobid,jobname);			
}

// jobId 조회
function fn_selectJobId(jobname){
	var result = 0;
	// jobId가 0이 아닐때까지(제대로 조회 될 때까지) 조회
	while(!result){		
		$.ajax({
			url : "/experdb/selectJobId.do",
			data : {
				jobname : jobname
			},
			async: false, 
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(data) {
				result = data;
			}
		});
		console.log("jobId : " + result);
	}
	return result;
	//$('#loading').hide();	
}

// log 조회
function fn_selectActivityLog(jobid, jobname) {
	$.ajax({
		url : "/experdb/backupActivityLogList.do",
		data : {
			jobid : jobid
		},
		type : "post",
		beforeSend: function(xhr) {
			xhr.setRequestHeader("AJAX", true);
		},
		error : function(xhr, status, error) {
			if(xhr.status == 401) {
				showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else if(xhr.status == 403) {
				showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else {
				showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
			}
		},
		success : function(data) {
			if(jobend == 0){
				recLogList.clear().draw();
				recLogList.rows.add(data).draw();	
			}else{
				recLogList.clear().draw();
			}
		}
	});
	$('#loading').hide();
} 

// job 종료 여부 조회
function fn_selectJobEnd(jobid,jobname){
	
	$.ajax({
		url : "/experdb/selectJobEnd.do",
		data : {
			jobname:jobname
		},
		type : "post",
		beforeSend: function(xhr) {
			xhr.setRequestHeader("AJAX", true);
		},
		error : function(xhr, status, error) {
			if(xhr.status == 401) {
				showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else if(xhr.status == 403) {
				showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
			} else {
				showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
			}
		},
		success : function(data) {	
			//console.log('종료 데이터= '+data);		
			 if(data == 1){		
				jobend = 1;
				recLogList.clear().draw();
				$("#status_basic").show();
				$(".moving-square-loader").hide();
			}else{	
				jobend = 0;
				fn_selectActivityLogCheck(jobid, jobname);
			} 						
		}
	});
	$('#loading').hide();	
}

</script>

<%@include file="./../popup/confirmMultiForm.jsp"%>
<%@include file="./popup/recTargetListForm.jsp"%>
<%@include file="./popup/recTargetDBRegForm.jsp"%>
<%@include file="./popup/recPwChkForm.jsp"%>

<form name="recoveryInfo">
	<input type="hidden" name="recStorageType" id="recStorageType">
	<input type="hidden" name="recStoragePath"  id="recStoragePath">
	<input type="hidden" name="recMachineMAC"  id="recMachineMAC">
	<input type="hidden" name="recMachineIP"  id="recMachineIP">
	<input type="hidden" name="recMachineSNM"  id="recMachineSNM">
	<input type="hidden" name="recMachineGateWay"  id="recMachineGateWay">
	<input type="hidden" name="recMachineDNS"  id="recMachineDNS">	
</form>


<div class="content-wrapper main_scroll" style="min-height: calc(100vh);" id="contentsDiv">
	<div class="row">
		<div class="col-12 div-form-margin-srn stretch-card">
			<div class="card">
				<div class="card-body">
					<!-- title start -->
					<div class="accordion_main accordion-multi-colored" id="accordion" role="tablist">
						<div class="card" style="margin-bottom:0px;">
							<div class="card-header" role="tab" id="page_header_div">
								<div class="row">
									<div class="col-5"  style="padding-top:3px;">
										<h6 class="mb-0">
											<a data-toggle="collapse" href="#page_header_sub" aria-expanded="false" aria-controls="page_header_sub" onclick="fn_profileChk('titleText')">
												<i class="ti-desktop menu-icon"></i>
												<span class="menu-title">Complete Recovery</span>
												<i class="menu-arrow_user" id="titleText" ></i>
											</a>
										</h6>
									</div>
									<div class="col-7">
					 					<ol class="mb-0 breadcrumb_main justify-content-end bg-info" >
					 						<li class="breadcrumb-item_main" style="font-size: 0.875rem;">BnR</li>
					 						<li class="breadcrumb-item_main" style="font-size: 0.875rem;" aria-current="page">Recovery</li>
											<li class="breadcrumb-item_main active" style="font-size: 0.875rem;" aria-current="page">Complete Recovery</li>
										</ol>
									</div>
								</div>
							</div>
							<div id="page_header_sub" class="collapse" role="tabpanel" aria-labelledby="page_header_div" data-parent="#accordion">
								<div class="card-body">
									<div class="row">
										<div class="col-12">
											<p class="mb-0"><spring:message code="help.eXperDB_backup_completeRecovery01" /></p>
											<p class="mb-0"><spring:message code="help.eXperDB_backup_completeRecovery02" /></p>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- title end -->
				</div>
			</div>
		</div>
		
		<div class="col-12 grid-margin stretch-card" style="margin-bottom: 0px;">
			<div class="card-body" style="padding-bottom:0px; padding-top: 0px;">
				<div id="wrt_button" style="float: right;">
					<button type="button" class="btn btn-success btn-icon-text mb-2" onclick="fn_runNowClick()">
						<i class="ti-control-forward btn-icon-prepend "></i><spring:message code="eXperDB_backup.msg110" />
					</button>
				</div>
			</div>
		</div>
		
		<!-- recovery setting -->
		<div class="col-lg-5">
			<!-- <div class="card grid-margin stretch-card" style="height: 130px;margin-bottom: 10px;">
				<div class="card-body">
					<div style="border: 1px solid rgb(200, 200, 200); height: 90px;">
						<div class="form-group row" style="margin-top: 20px; margin-bottom: 5px; margin-left: 15px;">
							<div  class="col-3 col-form-label pop-label-index" style="padding-top:7px;">
								Instant BMR
							</div>
							<div class="col-2" style="padding-left: 0px;">
								<select class="form-control form-control-xsm" id="bmrInstant" style=" width: 200px; height: 35px;" onchange="fn_bmrInstanceClick()">
									<option value="0">선택</option>
									<option value="1">enable</option>
									<option value="2">disable</option>
								</select>
							</div>
						</div>
						<div class="form-group row" style="margin-top: 10px;margin-left: 0px;">
							<div  class="col-12 col-form-label pop-label-index" id="bmrInstantAlert" name="bmrInstantAlert" style="padding-top:0px; color:red; font-size:0.8em; padding-bottom: 0px;">
								
							</div>
						</div>
					</div>
				</div>
			</div> -->
			<div class="card grid-margin stretch-card" style="height: 570px;">
				<div class="card-body" style="height: 140px; margin-top: 140px;">
					<div style="width:900px; text-align:center;">
						<div class="row" style="position:absolute; left:50%;transform: translateX(-50%);">
							<div class="col-4" style="text-align:center;">
								<i class="fa fa-database icon-md mb-0 mb-md-3 mb-xl-0 text-info" style="font-size: 9.0em;margin-left: -100px;"></i>
								<h5 style="margin-top: 20px;width:100px; margin-left: -60px;">SOURCE DB</h5>
								<select class="form-control form-control-xsm" id="backupDBList" style="width: 200px; height: 35px; margin-top: 20px; margin-left: -100px;" onchange="fn_backupDBChoice()">
									<option value="0"><spring:message code="common.choice" /></option>
								</select>
							</div>
							<div id="status_basic" ><i class="mdi mdi-arrow-right-bold icon-md mb-0 mb-md-3 mb-xl-0 text-info" style="padding-left: 20px;margin-right: 20p;font-size: 6.0em;margin-top: 20px;"></i></div>
							<i class="moving-square-loader"></i>
							<div class="col-4" style="text-align:center;">
								<i class="fa fa-database icon-md mb-0 mb-md-3 mb-xl-0 text-info" style="font-size: 9.0em;margin-right: -150px;"></i>
								<h5 style="margin-top: 20px;width:100px;margin-left: 68px;">TARGET DB</h5>
								<div class="col-4" style="padding-left: 0px;">
									<input type="text" id="recoveryDB" name="recoveryDB" class="form-control form-control-sm" style="height: 35px;background-color:#ffffffdd;margin-top: 20px;margin-left: 20px;width: 200px;" readonly/>								
								</div>
								<div class="col-4" style="padding-left: 157px;margin-top: -35px;">
									<button type="button" class="btn btn-inverse-primary btn-icon-text btn-sm btn-search-disable" onClick="fn_targetListPopup()" style="width: 63px;height: 35px;">등록</button>
								</div>
							</div>
						</div>
					</div>
				</div>
				<!-- <div class="card-body">
					<div class="form-group row" style="margin-top: 10px;margin-left: 0px;">
						<div  class="col-3 col-form-label pop-label-index" style="padding-top:7px;">
							백업 DB
						</div>
						<div class="col-4" style="padding-left: 0px;">
							<select class="form-control form-control-xsm" id="backupDBList" style=" width: 200px; height: 35px;" onchange="fn_backupDBChoice()">
								<option value="0">선택</option>
							</select>
						</div>
					</div>
					<div class="form-group row" id="storageDiv" style="margin-top: 10px;margin-left: 0px; ">
						<div  class="col-3 col-form-label pop-label-index" style="padding-top:7px;">
							Storage
						</div>
						<select class="form-control form-control-xsm" id="storageType" name="storageType" style="width:130px; height:35px;margin-right: 10px; color:black;" onchange="fn_storageTypeClick()">
							<option value="1">NFS share</option>
							<option value="2">CIFS share</option>
						</select>
						<select class="form-control form-control-xsm" id="storageList" name="storageList" style="width:200px; height:35px; color:black;">
							
						</select>
					</div>
					<div class="form-group row" style="margin-top: 10px;margin-left: 0px;">
						<div  class="col-3 col-form-label pop-label-index" style="padding-top:7px;">
							복구 DB
						</div>
						<div class="col-4" style="padding-left: 0px;">
							<input type="text" id="recoveryDB" name="recoveryDB" class="form-control form-control-sm" style="height: 40px; background-color:#ffffffdd;" readonly/>
						</div>
						<div class="col-4" style="padding-left: 0px;">
							<button type="button" class="btn btn-inverse-primary btn-icon-text btn-sm btn-search-disable" onClick="fn_targetListPopup()">등록</button>
						</div>
					</div>
				</div> -->
			</div>
		</div>
		<!-- recovery setting end-->
		
		<!-- log -->
		<div class="col-lg-7 grid-margin stretch-card">
			<div class="card">
				<div class="card-body">
					<div class="table-responsive" style="overflow:hidden;min-height:500px;">
						<table id="recLogList" class="table table-hover system-tlb-scroll" style="width:100%; align:dt-center; ">
							<thead>
								<tr class="bg-info text-white">
									<th width="70" style="background-color: #7e7e7e;">Status</th>
									<th width="70" style="background-color: #7e7e7e;">Time</th>
									<th width="500" style="background-color: #7e7e7e;">Message</th>
								</tr>
							</thead>
						</table>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>