<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ include file="../../cmmn/commonLocale.jsp"%>
<%
	/**
	* @Class Name : dataRegForm.jsp
	* @Description : 데이터 이행 등록 화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2019.09.18     최초 생성
	*
	* author kimjy
	* since 2019.09.18
	*
	*/
%>
<!doctype html>
<html lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>eXperDB</title>
<link rel="stylesheet" type="text/css" href="/css/common.css">
<script type="text/javascript" src="/js/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript">
var db2pg_trsf_wrk_nmChk ="fail";
$(window.document).ready(function() {

});

/* ********************************************************
 * Validation Check
 ******************************************************** */
function valCheck(){
	if($("#db2pg_trsf_wrk_nm").val() == ""){
		alert('<spring:message code="message.msg107" />');
		$("#db2pg_trsf_wrk_nm").focus();
		return false;
	}else if(db2pg_trsf_wrk_nmChk =="fail"){
		alert('<spring:message code="backup_management.work_overlap_check"/>');
		return false;
	}else if($("#db2pg_trsf_wrk_exp").val() == ""){
		alert('<spring:message code="message.msg108" />');
		$("#db2pg_trsf_wrk_exp").focus();
		return false;
	}else if($("#db2pg_source_system_id").val() == ""){
		alert("소스 시스템정보를 등록해주세요.");
		$("#db2pg_source_system_id").focus();
		return false;
	}else if($("#db2pg_trg_sys_id").val() == ""){
		alert("타겟 시스템정보를 등록해주세요.");
		$("#db2pg_trg_sys_id").focus();
		return false;
	}else{
		return true;
	}
}

/* ********************************************************
 * 사용자쿼리 체크박스 제어
 ******************************************************** */
function fn_checkBox(result){
	if(result == 'true'){
		$("#db2pg_usr_qry_id").removeAttr("readonly");
	}else{
		$('#db2pg_usr_qry_id').val('');
		$('#db2pg_usr_qry_id').attr('readonly', true);
	}
	
}

/* ********************************************************
 * WORK NM 중복 체크
 ******************************************************** */
function fn_check() {
	var db2pg_trsf_wrk_nm = document.getElementById("db2pg_trsf_wrk_nm");
	if (db2pg_trsf_wrk_nm.value == "") {
		alert('<spring:message code="message.msg107" /> ');
		document.getElementById('db2pg_trsf_wrk_nm').focus();
		return;
	}
	$.ajax({
		url : '/wrk_nmCheck.do',
		type : 'post',
		data : {
			wrk_nm : $("#db2pg_trsf_wrk_nm").val()
		},
		success : function(result) {
			if (result == "true") {
				alert('<spring:message code="backup_management.reg_possible_work_nm"/>');
				document.getElementById("db2pg_trsf_wrk_nm").focus();
				db2pg_trsf_wrk_nmChk = "success";
			} else {
				alert('<spring:message code="backup_management.effective_work_nm"/>');
				document.getElementById("db2pg_trsf_wrk_nm").focus();
			}
		},
		beforeSend: function(xhr) {
	        xhr.setRequestHeader("AJAX", true);
	     },
		error : function(xhr, status, error) {
			if(xhr.status == 401) {
				alert('<spring:message code="message.msg02" />');
				top.location.href = "/";
			} else if(xhr.status == 403) {
				alert('<spring:message code="message.msg03" />');
				top.location.href = "/";
			} else {
				alert("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""));
			}
		}
	});
}

/* ********************************************************
 * 등록 버튼 클릭시
 ******************************************************** */
function fn_insert_work(){
	if(valCheck()){
		$.ajax({
			async : false,
			url : "/db2pg/insertDataWork.do",
		  	data : {  
		  		db2pg_trsf_wrk_nm : $("#db2pg_trsf_wrk_nm").val().trim(),
		  		db2pg_trsf_wrk_exp : $("#db2pg_trsf_wrk_exp").val(),
		  		db2pg_source_system_id : $("#db2pg_source_system_id").val(),
		  		db2pg_trg_sys_id : $("#db2pg_trg_sys_id").val(),
		  		exrt_dat_cnt : $("#exrt_dat_cnt").val(),
		  		db2pg_exrt_trg_tb_wrk_id : $("#db2pg_exrt_trg_tb_wrk_id").val(),
		  		db2pg_exrt_exct_tb_wrk_id : $("#db2pg_exrt_exct_tb_wrk_id").val(),
		  		exrt_dat_ftch_sz : $("#exrt_dat_ftch_sz").val(),
		  		dat_ftch_bff_sz : $("#dat_ftch_bff_sz").val(),
		  		exrt_prl_prcs_ecnt : $("#exrt_prl_prcs_ecnt").val(),
		  		lob_dat_bff_sz : $("#lob_dat_bff_sz").val(),
		  		tb_rbl_tf : $("#tb_rbl_tf").val(),
		  		ins_opt_cd : $("#ins_opt_cd").val(),
		  		cnst_cnd_exrt_tf : $("#cnst_cnd_exrt_tf").val(),
		  		src_where_condition : $("#src_where_condition").val(),
		  		usr_qry_use_tf : $("#usr_qry_use_tf").val(),
		  		db2pg_usr_qry_id : $("#db2pg_usr_qry_id").val()
		  	},
			type : "post",
			beforeSend: function(xhr) {
		        xhr.setRequestHeader("AJAX", true);
		     },
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					alert('<spring:message code="message.msg02" />');
					top.location.href = "/";
				} else if(xhr.status == 403) {
					alert('<spring:message code="message.msg03" />');
					top.location.href = "/";
				} else {
					alert("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""));
				}
			},
			success : function(result) {
				alert(result);
			}
		});
	}
}

/* ********************************************************
 * 소스시스템 등록 버튼 클릭시
 ******************************************************** */
function fn_dbmsInfo(){
	var popUrl = "/db2pg/popup/dbmsInfo.do";
	var width = 920;
	var height = 670;
	var left = (window.screen.width / 2) - (width / 2);
	var top = (window.screen.height /2) - (height / 2);
	var popOption = "width="+width+", height="+height+", top="+top+", left="+left+", resizable=no, scrollbars=yes, status=no, toolbar=no, titlebar=yes, location=no,";
	
	var winPop = window.open(popUrl,"dbmsInfoPop",popOption);
}


/* ********************************************************
 * 추출 대상 테이블, 추출 제외 테이블 등록 버튼 클릭시
 ******************************************************** */
function fn_tableList(){
	var popUrl = "/db2pg/popup/tableInfo.do";
	var width = 930;
	var height = 675;
	var left = (window.screen.width / 2) - (width / 2);
	var top = (window.screen.height /2) - (height / 2);
	var popOption = "width="+width+", height="+height+", top="+top+", left="+left+", resizable=no, scrollbars=yes, status=no, toolbar=no, titlebar=yes, location=no,";
	
	var winPop = window.open(popUrl,"tableInfoPop",popOption);
}

</script>
</head>
<body>
<div class="pop_container">
	<div class="pop_cts">
		<p class="tit">데이터이행 등록</p>
		<div class="pop_cmm">
			<table class="write">
				<caption>데이터이행 등록</caption>
				<colgroup>
					<col style="width:105px;" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th scope="row" class="ico_t1"><spring:message code="common.work_name" /></th>
						<td><input type="text" class="txt" name="db2pg_trsf_wrk_nm" id="db2pg_trsf_wrk_nm" maxlength="20" onkeyup="fn_checkWord(this,20)" placeholder="20<spring:message code='message.msg188'/>" onblur="this.value=this.value.trim()"/>
						<span class="btn btnC_01"><button type="button" class= "btn_type_02" onclick="fn_check()" style="width: 60px; margin-right: -60px; margin-top: 0;"><spring:message code="common.overlap_check" /></button></span>
						</td>
					</tr>
					<tr>
						<th scope="row" class="ico_t1"><spring:message code="common.work_description" /></th>
						<td>
							<div class="textarea_grp">
								<textarea name="db2pg_trsf_wrk_exp" id="db2pg_trsf_wrk_exp" maxlength="25" onkeyup="fn_checkWord(this,25)" placeholder="25<spring:message code='message.msg188'/>"></textarea>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="pop_cmm mt25">
		<div class="sub_tit"><p>시스템정보</p></div>
			<table class="write">
				<colgroup>
					<col style="width:105px;" />
					<col />
					<col style="width:105px;" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th scope="row" class="ico_t1">소스시스템</th>
						<td><input type="text" class="txt" name="db2pg_source_system_id" id="db2pg_source_system_id"/>
							<span class="btn btnC_01"><button type="button" class= "btn_type_02" onclick="fn_dbmsInfo()" style="width: 60px; margin-right: -60px; margin-top: 0;">등록</button></span>							
						</td>
					</tr>
					<tr>
					<th scope="row" class="ico_t1">타겟시스템</th>
						<td><input type="text" class="txt" name="db2pg_trg_sys_id" id="db2pg_trg_sys_id"/>
							<span class="btn btnC_01"><button type="button" class= "btn_type_02" onclick="fn_dbmsInfo()" style="width: 60px; margin-right: -60px; margin-top: 0;">등록</button></span>							
						</td>
					</tr>
				</tbody>
			</table>
		</div>

		<div class="pop_cmm c2 mt25">
		<div class="sub_tit"><p>소스옵션</p></div>
			<div class="addOption_grp">
				<ul class="tab">
					<li class="on"><a href="#n">옵션 #1</a></li>
					<li><a href="#n">옵션 #2</a></li>
					<li><a href="#n">옵션 #3</a></li>
				</ul>
				<div class="tab_view">
					<div class="view on addOption_inr">	
						<table class="write">
							<caption>옵션정보</caption>
							<colgroup>
								<col style="width:20%" />
								<col style="width:30%" />
								<col style="width:20%" />
								</col>
							</colgroup>
							<tbody>
								<tr>
									<th scope="row" class="ico_t2">테이블에서 추출할 데이터 건수</th>
									<td><input type="text" class="txt t4" name="exrt_dat_cnt" id="exrt_dat_cnt"/></td>
								</tr>
								<tr>
									<th scope="row" class="ico_t2">추출 대상 테이블</th>
									<td colspan="3"><input type="text" class="txt" name="db2pg_exrt_trg_tb_wrk_id" id="db2pg_exrt_trg_tb_wrk_id"/>
										<span class="btn btnC_01"><button type="button" class= "btn_type_02" onclick="fn_tableList()" style="width: 60px; margin-right: -60px; margin-top: 0;">등록</button></span>							
									</td>
								</tr>
								<tr>
									<th scope="row" class="ico_t2">추출 제외 테이블</th>
									<td colspan="3"><input type="text" class="txt" name="db2pg_exrt_exct_tb_wrk_id" id="db2pg_exrt_exct_tb_wrk_id"/>
										<span class="btn btnC_01"><button type="button" class= "btn_type_02" onclick="fn_tableList()" style="width: 60px; margin-right: -60px; margin-top: 0;">등록</button></span>							
									</td>
								</tr>
								<tr>
									<th scope="row" class="ico_t2">추출 데이터 Fetch 사이즈</th>
									<td><input type="text" class="txt t5" name="exrt_dat_ftch_sz" id="exrt_dat_ftch_sz"/></td>
									<th scope="row" class="ico_t2">데이터 Fetch 버퍼 사이즈</th>
									<td><input type="text" class="txt t5" name="dat_ftch_bff_sz" id="dat_ftch_bff_sz"/></td>
								</tr>
								<tr>
									<th scope="row" class="ico_t2">추출 병렬처리 개수</th>
									<td><input type="text" class="txt t5" name="exrt_prl_prcs_ecnt" id="exrt_prl_prcs_ecnt"/></td>
									<th scope="row" class="ico_t2">LOB 데이터 LOB 버퍼 사이즈</th>
									<td><input type="text" class="txt t5" name="lob_dat_bff_sz" id="lob_dat_bff_sz"/></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="view addOption_inr">
						<ul>
							<li style="border-bottom: none;">
								<p class="op_tit" style="width: 200PX;">추출 조건(WHERE문 제외)</p>
								<span>
									<div class="textarea_grp">
										<textarea name="src_where_condition" id="src_where_condition" style="height: 250px; width: 700px;"></textarea>
									</div>
								</span>
							</li>
						</ul>
					</div>
					<div class="view addOption_inr">
						<ul>
							<li style="border-bottom: none;">
								<p class="op_tit" style="width: 70px;">사용여부</p>
								<div class="inp_rdo">
									<input name="rdo_r" id="rdo_r_1" type="radio" value="TC002001" checked="checked" onchange="fn_checkBox('true')">
										<label for="rdo_r_1">사용</label> 
									<input name="rdo_r" id="rdo_r_2" type="radio" value="TC002002" onchange="fn_checkBox('false')"> 
										<label for="rdo_r_2">미사용</label>
								</div>
							</li>
							<li style="border-bottom: none;">
								<p class="op_tit">사용자 쿼리</p>
								<span>
									<div class="textarea_grp">
										<textarea name="db2pg_usr_qry_id" id="db2pg_usr_qry_id" style="height: 250px; width: 700px;"></textarea>
									</div>
								</span>
							</li>
						</ul>
					</div>
				</div>
			</div>

		</div>
		<div class="pop_cmm mt25">
		<div class="sub_tit"><p>타겟옵션</p></div>
			<table class="write">
				<caption><spring:message code="dashboard.Register_backup" /></caption>
				<colgroup>
					<col style="width:12.5%;" />
					<col style="width:20%;" />
					<col style="width:10%;" />
					<col style="width:25%;" />
					<col style="width:12.5%;" />
					<col style="width:20%;" />
					</col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row" class="ico_t2">테이블 리빌드 여부</th>
						<td>
							<select name="tb_rbl_tf" id="tb_rbl_tf" class="select t8">
								<c:forEach var="codeTF" items="${codeTF}">
									<option value="${codeTF.sys_cd_nm}" ${false eq codeTF.sys_cd_nm ? "selected='selected'" : ""}>${codeTF.sys_cd_nm}</option>
								</c:forEach>
							</select>
						</td>
						<th scope="row" class="ico_t2">입력모드</th>
						<td>
							<select name="ins_opt_cd" id="ins_opt_cd" class="select t5">
								<c:forEach var="codeInputMode" items="${codeInputMode}">
									<option value="${codeInputMode.sys_cd_nm}">${codeInputMode.sys_cd_nm}</option>
								</c:forEach>
							</select>
						</td>
						<th scope="row" class="ico_t2">제약조건 추출 여부</th>
						<td>
							<select name="cnst_cnd_exrt_tf" id="cnst_cnd_exrt_tf" class="select t8">
								<c:forEach var="codeTF" items="${codeTF}">
									<option value="${codeTF.sys_cd_nm}" ${false eq codeTF.sys_cd_nm ? "selected='selected'" : ""}>${codeTF.sys_cd_nm}</option>
								</c:forEach>
							</select>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		
		<div class="btn_type_02">
			<span class="btn btnC_01" onClick="fn_insert_work();"><button type="button"><spring:message code="common.registory" /></button></span>
			<a href="#n" class="btn" onclick="self.close();"><span><spring:message code="common.cancel" /></span></a>
		</div>
	</div>
</div>
</body>
</html>
 