<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ include file="../../cmmn/commonLocale.jsp"%>
<%
	/**
	* @Class Name : ddlRegForm2.jsp
	* @Description : ddl추출 등록 화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2020.12.22     최초 생성
	*
	* author 신예은
	* since 2020.12.22
	*
	*/
%>
<script type="text/javascript">
var db2pg_ddl_wrk_nmChk ="fail";
var output_path ="fail";

var infoTable = null;
var extTable = null;

$(window.document).ready(function(){
	fn_init_tables();
	
});

// 테이블 init
function fn_init_tables() {
	infoTable = $('#info_tableList').DataTable({
		scrollY : "500px",
		scrollX: true,	
		processing : true,
		searching : false,
		paging : true,
		bSort: false,
		columns : [
			{data : "table_name", defaultContent : "", className : "dt-center"},
			{data : "obj_type", defaultContent : "", className : "dt-center"},
			{data : "obj_description", defaultContent : "", className : "dt-center"},
		], 'select': {'style' : 'multi'}
	});
	
	infoTable.tables().header().to$().find('th:eq(0)').css('min-width', '150px');
	infoTable.tables().header().to$().find('th:eq(1)').css('min-width', '150px');
	infoTable.tables().header().to$().find('th:eq(2)').css('min-width', '150px');
	
	extTable = $('#ext_tableList').DataTable({
		scrollY : "500px",
		scrollX: true,	
		processing : true,
		searching : false,
		paging : true,
		bSort: false,
		columns : [
			{data : "table_name", defaultContent : "", className : "dt-center"},
			{data : "obj_type", defaultContent : "", className : "dt-center"},
			{data : "obj_description", defaultContent : "", className : "dt-center"},
		], 'select': {'style' : 'multi'}
	});
	
	extTable.tables().header().to$().find('th:eq(0)').css('min-width', '150px');
	extTable.tables().header().to$().find('th:eq(1)').css('min-width', '150px');
	extTable.tables().header().to$().find('th:eq(2)').css('min-width', '150px');
	
	$(window).trigger('resize');
}

/* ********************************************************
 * Validation Check
 ******************************************************** */
function valCheck_reg(){
	if($("#db2pg_ddl_wrk_nm").val() == ""){
		showSwalIcon('<spring:message code="message.msg107" />', '<spring:message code="common.close" />', '', 'error');
		$("#db2pg_ddl_wrk_nm").focus();
		return false;
	}else if(db2pg_ddl_wrk_nmChk =="fail"){
		showSwalIcon('<spring:message code="backup_management.work_overlap_check" />', '<spring:message code="common.close" />', '', 'error');
		return false;
	}else if($("#db2pg_ddl_wrk_exp").val() == ""){
		showSwalIcon('<spring:message code="message.msg108" />', '<spring:message code="common.close" />', '', 'error');
		$("#db2pg_ddl_wrk_exp").focus();
		return false;
	}else if($("#db2pg_sys_id").val() == ""){
		showSwalIcon('<spring:message code="migration.msg07" />', '<spring:message code="common.close" />', '', 'error');
		$("#db2pg_sys_id").focus();
		return false;
	}else{
		return true;
	}
}

/* ********************************************************
 * WORK NM Validation Check
 ******************************************************** */
function fn_check_reg() {
	var db2pg_ddl_wrk_nm = $("#db2pg_ddl_wrk_nm").val().replace(/ /g, '_');
	$("#db2pg_ddl_wrk_nm").val(db2pg_ddl_wrk_nm);
	// var db2pg_ddl_wrk_nm = document.getElementById("db2pg_ddl_wrk_nm");
	if (db2pg_ddl_wrk_nm.value == "") {
		showSwalIcon('<spring:message code="message.msg107" />', '<spring:message code="common.close" />', '', 'error');
		document.getElementById('db2pg_ddl_wrk_nm').focus();
		return;
	}
	
	
	if(fnCheckNotKorean(db2pg_ddl_wrk_nm)){	
		$.ajax({
			url : '/wrk_nmCheck.do',
			type : 'post',
			data : {
				wrk_nm : $("#db2pg_ddl_wrk_nm").val()
			},
			success : function(result) {
				if (result == "true") {
					showSwalIcon('<spring:message code="backup_management.reg_possible_work_nm"/>', '<spring:message code="common.close" />', '', 'success');
					document.getElementById("db2pg_ddl_wrk_nm").focus();
					db2pg_ddl_wrk_nmChk = "success";		
				} else {
					showSwalIcon('<spring:message code="backup_management.effective_work_nm" />', '<spring:message code="common.close" />', '', 'error');
					document.getElementById("db2pg_ddl_wrk_nm").focus();
				}
			},
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
			}
		});
	}
}

/* ********************************************************
 * work name change check
 ******************************************************** */
 function fn_checkWrkNm_change_ddl() {
	db2pg_ddl_wrk_nmChk = "fail";
}

/* 한글입력 체크 */
function fnCheckNotKorean(koreanStr){
    for(var i=0;i<koreanStr.length;i++){
        var koreanChar = koreanStr.charCodeAt(i);
        if( !( 0xAC00 <= koreanChar && koreanChar <= 0xD7A3 ) && !( 0x3131 <= koreanChar && koreanChar <= 0x318E ) ) {
        }else{
        	showSwalIcon('한글은 사용할수 없습니다.', '<spring:message code="common.close" />', '', 'error');
            return false;
        }
    }
    return true;
}


/* ********************************************************
 * output path Validation Check
 ******************************************************** */
function fn_pathCheck() {
	var ddl_save_pth = document.getElementById("ddl_save_pth");
	if (ddl_save_pth.value == "") {
		showSwalIcon('경로를 입력하세요.', '<spring:message code="common.close" />', '', 'error');
		document.getElementById('ddl_save_pth').focus();
		return;
	}
	$.ajax({
		url : '/db2pgPathCheck.do',
		type : 'post',
		data : {
			ddl_save_pth : $("#ddl_save_pth").val()
		},
		success : function(result) {
			if (result == true) {
				showSwalIcon('유효한 경로입니다.', '<spring:message code="common.close" />', '', 'success');
				output_path = "success";		
			} else {
				showSwalIcon('유효하지 않은 경로입니다.', '<spring:message code="common.close" />', '', 'error');
				document.getElementById("ddl_save_pth").focus();
			}
		},
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
		}
	});	
}

/* ********************************************************
 * 등록 버튼 클릭시
 ******************************************************** */
function fn_insert_work_reg(){
	if(valCheck_reg()){
		var rowList = [];
		if($("#src_table_total_cnt").val() == ""){
			var src_table_total_cnt = 0
		}else{
			var src_table_total_cnt = $("#src_table_total_cnt").val()
		}
		// extTable에 있는 table들(작업 대상 테이블)의 이름을 넣어줌
		for(var i =0; i< extTable.rows().data().length; i++){				
			rowList.push(extTable.rows().data()[i].table_name);
		}
		if($("#src_tables").val() == "include"){
			$('#src_include_table_nm').val(rowList);
		}else {
			$('#src_exclude_table_nm').val(rowList);
		}

		//등록하기 전 work명 한번 더 중복 체크
		$.ajax({
			url : '/wrk_nmCheck.do',
			type : 'post',
			data : {
				wrk_nm : $("#db2pg_ddl_wrk_nm").val()
			},
			success : function(result) {
				if (result == "true") {
						$.ajax({
							url : "/db2pg/insertDDLWork.do",
						  	data : {
						  		db2pg_ddl_wrk_nm : $("#db2pg_ddl_wrk_nm").val().trim(),
						  		db2pg_ddl_wrk_exp : $("#db2pg_ddl_wrk_exp").val(),
						  		db2pg_sys_id : $("#db2pg_sys_id").val(),
						  		db2pg_uchr_lchr_val : $("#db2pg_uchr_lchr_val").val(),
						  		src_tb_ddl_exrt_tf : $("#src_tb_ddl_exrt_tf").val(),
						  		src_include_tables : $("#src_include_table_nm").val(),
						  		src_exclude_tables : $("#src_exclude_table_nm").val(),
						  		src_index_origin : $("#src_index_origin").val(),
						  		src_table_total_cnt : src_table_total_cnt
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
							success : function(result) {
								if(result.resultCode == "0000000000"){
									showSwalIconRst('<spring:message code="message.msg07" />', '<spring:message code="common.close" />', '', 'success');
									$('#pop_layer_ddl_reg').modal("hide");
									selectTab("ddlWork");

								}else{
									showSwalIcon('<spring:message code="migration.msg06" />', '<spring:message code="common.close" />', '', 'error');
								}	
							}
						});	
				} else {
					showSwalIcon('<spring:message code="backup_management.effective_work_nm" />', '<spring:message code="common.close" />', '', 'error');
					document.getElementById("db2pg_ddl_wrk_nm").focus();
				}
			},
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
			}
		});
	}
}

/* ********************************************************
 * DBMS 서버 호출하여 입력
 ******************************************************** */
 function fn_dbmsAddCallback(db2pg_sys_id,db2pg_sys_nm){
	 $('#db2pg_sys_id').val(db2pg_sys_id);
	 $('#db2pg_sys_nm').val(db2pg_sys_nm);
	 $('#src_include_table_nm').val("");
	 $('#src_exclude_table_nm').val("");
	 var type = $('#src_tables').val();
	 fn_tableList(type);
}

/* ********************************************************
 * DBMS 시스템 등록 버튼 클릭시
 ******************************************************** */
function fn_dbmsInfo(){
	document.getElementById("sourceSystem_add").style.display ='block';
	document.getElementById("sourceSystem_mod").style.display ='none';
	$('#pop_layer_dbmsInfo_reg').modal("show");
}

/* ********************************************************
 * DBMS 등록 후 정보 넣어주기
 ******************************************************** */
function fn_tableList(gbn){
	if($('#db2pg_sys_nm').val() == ""){
		showSwalIcon('<spring:message code="migration.msg03" />', '<spring:message code="common.close" />', '', 'error');
		return false;
	}
	if(gbn == 'include'){
		var src_include_table_nm = $('#src_include_table_nm').val();  
	}else{
		var src_exclude_table_nm = $('#src_exclude_table_nm').val();  
	}
	$.ajax({
		url : "/db2pg/popup/tableInfo.do",
		data : {
			src_include_table_nm : src_include_table_nm,
			src_exclude_table_nm : src_exclude_table_nm,
			db2pg_sys_id : $('#db2pg_sys_id').val(),
			tableGbn : gbn
		},
		dataType : "json",
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
		success : function(result) {
			$("#db2pg_sys_nm_table").val(nvlPrmSet(result.dbmsInfo[0].db2pg_sys_nm, ""));
			$("#ipadr_table").val(nvlPrmSet(result.dbmsInfo[0].ipadr, ""));
			$("#scm_nm_table").val(nvlPrmSet(result.dbmsInfo[0].scm_nm, ""));
			$("#dbms_dscd_table").val(nvlPrmSet(result.dbmsInfo[0].dbms_dscd, ""));
			$("#dtb_nm_table").val(nvlPrmSet(result.dbmsInfo[0].dtb_nm, ""));
			$("#spr_usr_id_table").val(nvlPrmSet(result.dbmsInfo[0].spr_usr_id, ""));
			$("#pwd_table").val(nvlPrmSet(result.dbmsInfo[0].pwd, ""));
			$("#portno_table").val(nvlPrmSet(result.dbmsInfo[0].portno, ""));
			$("#object_type_table").val("");
			
			extTable.clear().draw();
			fn_search_tableInfo();
		}
	});
}

function fn_table_clear_reg(){
	extTable.clear().draw();
	infoTable.clear().draw();
}

/* ********************************************************
 * 테이블 옵션 조회 버튼 눌렀을 때
 ******************************************************** */
function fn_search_tableInfo(){
	var table_nm = null;
	
	if($("#table_nm_table").val() == ""){
		table_nm="%";
	}else{
		table_nm=$("#table_nm_table").val();
	}

	$.ajax({
		url : "/selectTableList.do",
		data : {
 		 	ipadr : $("#ipadr_table").val(),
 		 	portno : $("#portno_table").val(),
 		  	dtb_nm : $("#dtb_nm_table").val(),
 		  	spr_usr_id : $("#spr_usr_id_table").val(),
 		  	pwd : $("#pwd_table").val(),
 		  	dbms_dscd : $("#dbms_dscd_table").val(),
 		  	table_nm : table_nm,
 		  	scm_nm : $("#scm_nm_table").val(),
 		  	object_type : $("#object_type_table").val()
		},
		dataType : "json",
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
		success : function(result) {
						
			infoTable.rows({selected: true}).deselect();
			infoTable.clear().draw();
			
			if (result.RESULT_DATA != null) {
				infoTable.rows.add(result.RESULT_DATA).draw();
				var infoLength = infoTable.rows().data().length;
				var extLength = extTable.rows().data().length;
				
				// extTable에 있는 테이블들을 infoTable에서 제외시킴
				if(extLength>0){
					for(var i=0;i<infoLength;i++){
						for(var j=0;j<extLength;j++){
							if(infoTable.row(i).data().table_name == extTable.row(j).data().table_name){
								infoTable.row(i).select();
								break;
							}
						}
					}
					infoTable.rows('.selected').remove().draw();
				}
			}
		}
	});
}

///////////////////////////////////////////////////////////////
/////////////////////// 테이블 리스트 조정 ///////////////////////////
///////////////////////////////////////////////////////////////

/*
 * 우측 이동 (>)
 */
 function fn_ins_t_rightMove_reg(){
	var datas = infoTable.rows('.selected').data();
	var rows = [];
	
	if(datas.length <1) {
		showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'warning');
		return;
	}
	
	for(var i =0; i<datas.length;i++){
		rows.push(infoTable.rows('.selected').data()[i]);
	}
	
	extTable.rows.add(rows).draw();
	infoTable.rows('.selected').remove().draw();
	
}

/*
 * 좌측 이동 (<)
 */
 function fn_ins_t_leftMove_reg() {
	var datas = extTable.rows('.selected').data();
	var rows = [];
	
	if(datas.length < 1) {
		showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'warning');
		return;
	}
	
	for (var i = 0;i<datas.length;i++) {
		rows.push(extTable.rows('.selected').data()[i]); 
	}
	
	infoTable.rows.add(rows).draw();
	extTable.rows('.selected').remove().draw();
	
}

/*
 * 전체 우측 이동 (>>)
 */
 function fn_ins_t_allRightMove_reg() {
	 var datas = infoTable.rows().data();
		var rows = [];

		//row 존재 확인
		if(datas.length < 1) {
			showSwalIcon('<spring:message code="message.msg01" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}

		for (var i = 0;i<datas.length;i++) {
			rows.push(infoTable.rows().data()[i]); 	
		}
	
		extTable.rows.add(rows).draw(); 	
		infoTable.rows({selected: true}).deselect();
		infoTable.rows().remove().draw();
}

/*
 * 전체 좌측 이동 (<<)
 */
 function fn_ins_t_allLeftMove_reg() {
		var datas = extTable.rows().data();
		var rows = [];

		//row 존재 확인
		if(datas.length < 1) {
			showSwalIcon('<spring:message code="message.msg01" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}

		for (var i = 0;i<datas.length;i++) {
			rows.push(extTable.rows().data()[i]); 	
		}
	
		infoTable.rows.add(rows).draw(); 	
		extTable.rows({selected: true}).deselect();
		extTable.rows().remove().draw();
}

/* ********************************************************
 * select box control
 ******************************************************** */

 $(function() {
	 $("#src_tables").change(function(){
		 $("#src_include_table_nm").val("");
		 $("#src_exclude_table_nm").val("");
	 });
 });


</script>
<form name="frmPopup">
	<input type="hidden" name="db2pg_sys_id"  id="db2pg_sys_id">
	<input type="hidden" name="src_include_table_nm"  id="src_include_table_nm" >
	<input type="hidden" name="src_exclude_table_nm"  id="src_exclude_table_nm" >
	<input type="hidden" name="tableGbn"  id="tableGbn" >
	<input type="hidden" name="src_table_total_cnt" id="src_table_total_cnt">
</form>

<div class="modal fade" id="pop_layer_ddl_reg" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog  modal-xl-top" role="document" style="margin: 20px 150px;"> 
		<div class="modal-content" style="width:1400px;">		 	 
			<div class="modal-body" style="margin-bottom:-30px;">
				<h4 class="modal-title mdi mdi-alert-circle text-info" id="ModalLabel" style="padding-left:5px;margin-bottom:10px;">
					DDL <spring:message code="common.registory" />
				</h4>
				<div class="card" style="border:0px;max-height:698px;">
					<form class="cmxform" id="ddlRegForm">
						<fieldset>
							<div class="row">
								<div class="col-md-12 system-tlb-scroll" style="border:0px;height: 620px; overflow-x: hidden;  overflow-y: auto; ">
									<!-- work 이름과 설명 -->
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-top:-10px;">
											<label for="ins_dump_wrk_nm" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="common.work_name" />
											</label>
											<div class="col-sm-8">
												<input type="text" class="form-control form-control-sm" maxlength="50" id="db2pg_ddl_wrk_nm" name="db2pg_ddl_wrk_nm" onkeyup="fn_checkWord(this,50)" placeholder='50<spring:message code='message.msg188'/>' onchange="fn_checkWrkNm_change_ddl();" onblur="this.value=this.value.trim()"/>
											</div>
											<div class="col-sm-2">
												<button type="button" class="btn btn-inverse-danger btn-fw" style="width: 115px;" onclick="fn_check_reg()"><spring:message code="common.overlap_check" /></button>
											</div>
										</div>
		
										<div class="form-group row div-form-margin-z" style="margin-bottom:-10px;">
											<label for="ins_dump_wrk_exp" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="common.work_description" />
											</label>
											<div class="col-sm-10">
												<textarea class="form-control" id="db2pg_ddl_wrk_exp" name="db2pg_ddl_wrk_exp" rows="2" maxlength="100" onkeyup="fn_checkWord(this,100)" placeholder="100<spring:message code='message.msg188'/>"></textarea>
											</div>
										</div>
									</div>
									<!-- work 이름과 설명 End -->
									<br/>
									
									<!-- 옵션 정보 -->
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row" style="margin-bottom:-10px;">
									
											<label for="ins_dump_cprt" class="col-sm-2 col-form-label pop-label-index">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="migration.specify_case" />
											</label>						
											<div class="col-sm-2">
												<select name="db2pg_uchr_lchr_val" id="db2pg_uchr_lchr_val"  class="form-control" style="margin-right: 1rem;width:115px;margin-top: 5px;">
													<c:forEach var="codeLetter" items="${codeLetter}">
														<option value="${codeLetter.sys_cd_nm}">${codeLetter.sys_cd_nm}</option>
													</c:forEach>
												</select>
											</div>


											<label for="ins_dump_cprt" class="col-sm-2 col-form-label pop-label-index">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="migration.view_table_exclusion" />
											</label>
											<div class="col-sm-2">
												<select name="src_tb_ddl_exrt_tf" id="src_tb_ddl_exrt_tf"  class="form-control" style="margin-right: 1rem;width:115px;margin-top: 5px;">
													<c:forEach var="codeTF" items="${codeTF}">
														<option value="${codeTF.sys_cd_nm}">${codeTF.sys_cd_nm}</option>
													</c:forEach>
												</select>
											</div>
											
											
											<label for="ins_dump_cprt" class="col-sm-2 col-form-label pop-label-index">
												<i class="item-icon fa fa-dot-circle-o"></i>
												인덱스명 ORIGIN
											</label>
											<div class="col-sm-2">
												<select name="src_index_origin"  id="src_index_origin"  class="form-control" style="margin-right: 1rem;width:115px;margin-top: 5px;">
													<c:forEach var="codeTF" items="${codeTF}">
																<option value="${codeTF.sys_cd_nm}" ${false eq codeTF.sys_cd_nm ? "selected='selected'" : ""}>${codeTF.sys_cd_nm}</option>
															</c:forEach>
												</select>
											</div>
											
											
										</div>
									</div>
									
									<br/>
									<!-- 소스 시스템 등록 -->
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-top:-10px;margin-bottom:-15px;">
											<label for="ins_dump_save_pth" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<spring:message code="migration.source_system" />
											</label>
											<div class="col-sm-6">
												<input type="text" class="form-control form-control-sm" id="db2pg_sys_nm" name="db2pg_sys_nm" readonly="readonly" />
											</div>
											<div class="col-sm-4">
												<div class="input-group input-daterange d-flex align-items-center" >
													<button type="button" class="btn btn-inverse-info btn-fw" style="width: 115px;" onclick="fn_dbmsInfo()"><spring:message code="button.create" /></button>
												</div>
											</div>
										</div>
									</div>
									
									<br/>
									
									<!-- 테이블 옵션 검색 -->
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="card-body" style="border: 1px solid #dee1e4; padding-bottom: 10px;padding-top: 15px;">
											<div class="form-inline row">	
												<div class="input-group mb-2 mr-sm-2 col-sm-1_9">	
													<select name="src_tables" id="src_tables"  class="form-control">
														<option value="include"><spring:message code="migration.inclusion_table"/></option>
														<option value="exclude"><spring:message code="migration.exclusion_table"/></option>
													</select>
												</div>
												<div class="input-group mb-2 mr-sm-2 col-sm-1_7">
													<input type="text" class="form-control" id="db2pg_sys_nm_table" name="db2pg_sys_nm_table" onblur="this.value=this.value.trim()" placeholder='<spring:message code='migration.system_name'/>' readonly />
												</div>
												<div class="input-group mb-2 mr-sm-2 col-sm-1_7">
													<input type="text" class="form-control" id="ipadr_table" name="ipadr_table" onblur="this.value=this.value.trim()" placeholder='<spring:message code='data_transfer.ip'/>' readonly />
												</div>
												<div class="input-group mb-2 mr-sm-2 col-sm-1_7">
													<input type="text" class="form-control" id="scm_nm_table" name="scm_nm_table" onblur="this.value=this.value.trim()" placeholder='<spring:message code='migration.schema_Name'/>' readonly />
												</div>
												<div class="input-group mb-2 mr-sm-2 col-sm-2">
													<select class="form-control" name="work" id="object_type_table">
														<option value=""><spring:message code="migration.table_type"/> 전체</option>
														<option value="TABLE">TABLE</option>
														<option value="VIEW">VIEW</option>
													</select>
												</div>
												<div class="input-group mb-2 mr-sm-2 col-sm-1_7">
													<input type="text" class="form-control" id="table_nm_table" name="table_nm_table" onblur="this.value=this.value.trim()" placeholder='<spring:message code='migration.table_name'/>'  />
												</div>
												<button type="button" class="btn btn-inverse-primary btn-icon-text mb-2 btn-search-disable" onClick="fn_search_tableInfo();" >
													<i class="ti-search btn-icon-prepend "></i><spring:message code="common.search" />
												</button>
											</div>
										</div>
										<input type="hidden" class="txt t4" name="dbms_dscd_table" id="dbms_dscd_table"  />
										<input type="hidden" class="txt t4" name="dtb_nm_table" id="dtb_nm_table" />
										<input type="hidden" class="txt t4" name="spr_usr_id_table" id="spr_usr_id_table" />
										<input type="hidden" class="txt t4" name="pwd_table" id="pwd_table" />
										<input type="hidden" class="txt t4" name="portno_table" id="portno_table" />
										<br/>
										<!-- 테이블 옵션 검색 End -->
										<!-- 테이블 -->
										<div class="card-body" style="border: 1px solid #dee1e4;padding-top: 0px;">
											<!-- 검색한 테이블 (Left Table) -->
											<div class="row">
												<div class="col-7 stretch-card div-form-margin-table" style="max-width: 47%;margin-top:5px;" id="left_list">
													<div class="card" style="border:0px;">
														<div class="card-body" style="padding-left:0px;padding-right:0px;">
															<h4 class="card-title">
																<i class="item-icon fa fa-dot-circle-o"></i>
																<spring:message code="data_transfer.tableList" />
															</h4>
				
												 			<table id="info_tableList" class="table table-hover table-striped system-tlb-scroll" style="width:100%;">
																<thead>
																	<tr class="bg-info text-white">
																		<th width="150" class="dt-center" ><spring:message code="migration.table_name" /></th>
																		<th width="150" class="dt-center" ><spring:message code="migration.table_type" /></th>	
																		<th width="150" class="dt-center"><spring:message code="migration.table_comment"/></th>
																	</tr>
																</thead>
															</table>
														</div>
													</div>
												</div>
				 								<!-- Left Table End -->
				 								<!-- 화살표 -->
												<div class="col-1 stretch-card div-form-margin-table" style="max-width: 6%;" id="center_div">
													<div class="card" style="background-color: transparent !important;border:0px;">
														<div class="card-body">	
															<div class="card my-sm-2 connectRegForm2" style="border:0px;background-color: transparent !important;">
																<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-top:15px;margin-bottom:-15px;">
																	<a href="#" class="tip" onclick="fn_ins_t_allRightMove_reg();">
																		<i class="fa fa-angle-double-right" style="font-size: 35px;cursor:pointer;"></i>
																		<!-- 
																		<span style="width: 200px;"><spring:message code="data_transfer.move_right_line" /></span>
																		 -->
																	</a>
																</label>
																
																<br/>
																	
																<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
																	<a href="#" class="tip" onclick="fn_ins_t_rightMove_reg();">
																		<i class="fa fa-angle-right" style="font-size: 35px;cursor:pointer;"></i>
																		<!-- 
																		<span style="width: 200px;"><spring:message code="data_transfer.move_right_line" /></span>
																		 -->
																	</a>
																</label>
																
																<br/>
				
																<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
																	<a href="#" class="tip" onclick="fn_ins_t_leftMove_reg();">
																		<i class="fa fa-angle-left" style="font-size: 35px;cursor:pointer;"></i>
																		<!--
																		<span style="width: 200px;"><spring:message code="data_transfer.move_left_line" /></span>
																		 -->
																	</a>
																</label>
																
																<br/>
				
																<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
																	<a href="#" class="tip" onclick="fn_ins_t_allLeftMove_reg();">
																		<i class="fa fa-angle-double-left" style="font-size: 35px;cursor:pointer;"></i>
																		<!--
																		<span style="width: 200px;"><spring:message code="data_transfer.move_all_left" /></span>
																		-->
																	</a>
																</label>
															</div>
														</div>
													</div>
												</div>
												<!-- 화살표 End -->
												<!-- 작업 대상 테이블 (Right Table) -->
												<div class="col-7 stretch-card div-form-margin-table" style="max-width: 47%;margin-top:5px;" id="right_list">
													<div class="card" style="border:0px;">
														<div class="card-body" style="padding-left:0px;padding-right:0px;">
															<h4 class="card-title">
																<i class="item-icon fa fa-dot-circle-o"></i>
																<spring:message code="migration.ddl_table_list" />
															</h4>
				
											 				<table id="ext_tableList" class="table table-hover table-striped system-tlb-scroll" style="width:100%;">
																<thead>
																	<tr class="bg-info text-white">
																		<th width="150" class="dt-center" ><spring:message code="migration.table_name" /></th>
																		<th width="150" class="dt-center" ><spring:message code="migration.table_type" /></th>	
																		<th width="150" class="dt-center"><spring:message code="migration.table_comment"/></th>	
																	</tr>
																</thead>
															</table>
														</div>
													</div>
												</div>
												<!-- 작업 대상 테이블 End -->
											</div>
										</div>
									</div>
									<br/>
								</div>
							</div>
							<div class="card-body">
								<div class="top-modal-footer" style="text-align: center !important; margin: -20px 0px -30px -20px;" >
									<input class="btn btn-primary" width="200px;" style="vertical-align:middle;" type="button" onclick="fn_insert_work_reg()" value='<spring:message code="common.registory" />' />
									<button type="button" class="btn btn-light" data-dismiss="modal"><spring:message code="common.cancel"/></button>
								</div>
							</div>
						</fieldset>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
