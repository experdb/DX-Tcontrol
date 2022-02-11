<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
	/**
	* @Class Name : connectRegForm2.jsp
	* @Description : connectRegForm 화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2020.04.07     최초 생성
	*
	* author 
	* since 2020. 04. 07
	*
	*/
%>

<script type="text/javascript">
	var ins_tableList = null;
	var ins_connector_tableList = null;
	
	var ins_connect_status_Chk = "fail";
	var ins_connect_nm_Chk = "fail";

	var ins_schema_status_Chk = "fail";
	
	var ins_kc_ip_msg = '<spring:message code="data_transfer.ip" />';
	var ins_kc_port_msg = '<spring:message code="data_transfer.port" />';
	var ins_databaseMsg = '<spring:message code="eXperDB_CDC.database" />';
	var ins_connectNmMsg = '<spring:message code="eXperDB_CDC.connect_name_set" />';
	var ins_conn_Test_msg = '<spring:message code="dbms_information.conn_Test" />';
	var ins_kafka_server_nm = '<spring:message code="data_transfer.server_name" />';
	var ins_trans_com_cng_nm_val = '<spring:message code="eXperDB_CDC.default_setting" />';

	$(window.document).ready(function() {
		//테이블셋팅
		fn_ins_init();
		$("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg4" />');	

		//스냅샷 모드 change
		$("#ins_snapshot_mode", "#insRegForm").change(function(){ 
			 if(this.value == "TC003601"){
				 $("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg2" />'); //(초기스냅샷 1회만 수행) 미사용
			 }else if(this.value == "TC003602"){
				 $("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg3" />'); //(스냅샷 항상 수행)
			 }else if (this.value == "TC003603"){
				 $("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg1" />'); //(초기적재 미수행, 스트리밍 수행)
			 }else if (this.value == "TC003604"){
				 $("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg4" />'); //(스냅샷만 수행하고 종료)
			 }else if (this.value == "TC003605"){
				 $("#ins_snapshotModeDetail", "#insRegForm").html('<spring:message code="eXperDB_CDC.msg5" />'); //(복제슬롯이 생성된 시접부터의 스냅샷 lock 없는 효율적방법) 미사용
			 }
		});
		
		//데이터베이스 change
		$("#ins_db_id", "#insRegForm").change(function(){ 
			ins_tableList.clear().draw();
			ins_connector_tableList.clear().draw();
		});

		$("#searchRegForm").validate({
			rules: {
				ins_kc_ip: {
					required: true
				},
				ins_kc_port: {
					required: true,
					number: true
				}
			},
			messages: {
				ins_kc_ip: {
					required: '<spring:message code="errors.required" arguments="'+ ins_kc_ip_msg +'" />'
				},
				ins_kc_port: {
					required: '<spring:message code="errors.required" arguments="'+ ins_kc_port_msg +'" />',
					number: '<spring:message code="eXperDB_scale.msg15" />'
				}
			},
			submitHandler: function(form) { //모든 항목이 통과되면 호출됨 ★showError 와 함께 쓰면 실행하지않는다★
				fn_ins_kcConnectTest();
			},
			errorPlacement: function(label, element) {
				label.addClass('mt-2 text-danger');
				label.insertAfter(element);
		    },
		    highlight: function(element, errorClass) {
		        $(element).parent().addClass('has-danger')
		        $(element).addClass('form-control-danger')
		    }
		});
		
		//table 탭 이동시
		$('a[href="#insTableTab"]').on('shown.bs.tab', function (e) {
  			if(nvlPrmSet($("#ins_db_id", "#insRegForm").val(), '') == ""){
 				e.preventDefault();
				showSwalIcon('<spring:message code="eXperDB_scale.msg3" arguments="'+ ins_databaseMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
				$('a[href="#insSettingTab"]').tab('show');
				return;
			}
  			
			ins_tableList.columns.adjust().draw();
			ins_connector_tableList.columns.adjust().draw();
  			
  			var tableDatas = ins_connector_tableList.rows().data();

  			//재조회
  			if(tableDatas.length == 0){
  				fn_table_search_ins();
  			}
		});
	});

	/* ********************************************************
	 * 테이블 설정
	 ******************************************************** */
	function fn_ins_init(){
		ins_tableList = $('#ins_tableList').DataTable({
			scrollY : "220px",
			scrollX: true,	
			processing : true,
			searching : false,
			paging : false,
			bSort: false,
			columns : [
				{
					data : "schema_name", className : "dt-center", defaultContent : ""
				},
				{
					data : "table_name", className : "dt-center", defaultContent : ""
				},
			],'select': {'style': 'multi'}
		});

 		ins_tableList.tables().header().to$().find('th:eq(0)').css('min-width', '161px');
 		ins_tableList.tables().header().to$().find('th:eq(1)').css('min-width', '162px');
 		
 		ins_connector_tableList = $('#ins_connector_tableList').DataTable({
			scrollY : "220px",
			scrollX: true,	
			processing : true,
			searching : false,
			paging : false,	
			bSort: false,
			columns : [
				{data : "schema_name", className : "dt-center", defaultContent : ""},
				{data : "table_name", className : "dt-center", defaultContent : ""},			
			 ],'select': {'style': 'multi'}
		});
		
 		ins_connector_tableList.tables().header().to$().find('th:eq(0)').css('min-width', '161px');
 		ins_connector_tableList.tables().header().to$().find('th:eq(1)').css('min-width', '162px');

		$(window).trigger('resize'); 
	}

	/* ********************************************************
	 * 커넥터 연결테스트
	 ******************************************************** */
	function fn_ins_kcConnectTest() {
		var kafkaIp = $("#ins_kc_ip", "#searchRegForm").val();
		var kafkaPort=	$("#ins_kc_port", "#searchRegForm").val();

		$.ajax({
			url : '/kafkaConnectionTest.do',
			type : 'post',
			data : {
				db_svr_id : $("#db_svr_id","#findList").val(),
				kafkaIp : kafkaIp,
				kafkaPort : kafkaPort,
				connect_gbn : "kafka"
			},
			success : function(result) {
				if(result.RESULT_DATA =="success"){
					ins_connect_status_Chk ="success";
					showSwalIcon('kafka-Connection ' + '<spring:message code="message.msg93"/>', '<spring:message code="common.close" />', '', 'success');
				}else{
					ins_connect_status_Chk ="fail";
					showSwalIcon('kafka-Connection ' + '<spring:message code="message.msg92"/>', '<spring:message code="common.close" />', '', 'error');
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
		$('#loading').hide();
	}
	
	/* ********************************************************
	 * 커넥터명 중복체크
	 ******************************************************** */
	function fn_insConNmCheck() {
		var connect_nm_val = nvlPrmSet($("#ins_connect_nm", "#insRegForm").val(), '');

		if (connect_nm_val == "") {
			showSwalIcon('<spring:message code="eXperDB_CDC.msg18" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}
		console.log(connect_nm_val);
		if(/\w$/g.test(connect_nm_val)) {//영어,_,숫자만 포함 문자열
			if(/[A-Z]/g.test(connect_nm_val)){//대문자 포함
				console.log(connect_nm_val);
				connect_nm_val = connect_nm_val.toLowerCase();
				console.log(connect_nm_val);
				$("#ins_connect_nm", "#insRegForm").val(connect_nm_val);
				showSwalIcon('<spring:message code="eXperDB_CDC.msg54"/>', '<spring:message code="common.close" />', '', 'warning');
			}
		}else{
			showSwalIcon('<spring:message code="eXperDB_CDC.msg53"/>', '<spring:message code="common.close" />', '', 'warning');
			return;
		}
		
		$.ajax({
			url : '/connect_nm_Check.do',
			type : 'post',
			data : {
				connect_nm : connect_nm_val,
				connect_gbn : "source"
			},
			success : function(result) {
				if (result == "true") {
					ins_connect_nm_Chk = "success";
					showSwalIcon('<spring:message code="eXperDB_CDC.msg19" />', '<spring:message code="common.close" />', '', 'success');
				} else {
					ins_connect_nm_Chk = "fail";
					showSwalIcon('<spring:message code="eXperDB_CDC.msg20" />', '<spring:message code="common.close" />', '', 'error');
				}
			},
			beforeSend : function(xhr) {
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
	 * 테이블 리스트 조회
	 ******************************************************** */
	function fn_table_search_ins(){
		
		var db_svr_id = $("#db_svr_id","#findList").val();
		var db_nm = $("#ins_db_id option:checked", "#insRegForm").text();
		
		var table_nm = null;

		if(nvlPrmSet($("#ins_table_nm").val(), '') == ""){
			table_nm = "%";
		}else{
			table_nm = nvlPrmSet($("#ins_table_nm").val(), '');
		}
		
		$.ajax({
			url : "/selectTableMappList.do",
			data : {
				db_svr_id : db_svr_id,
				db_nm : db_nm,
				table_nm : table_nm
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
				//크기고정 및 현재고정
/* 				ins_connector_tableList.columns.adjust().draw();
				 */
				ins_tableList.rows({selected: true}).deselect();
				ins_tableList.clear().draw();

				//조회 후, connector_tableList과 비교 후 같으면 리스트에서 제외
				if (result.RESULT_DATA != null) {
					fn_trableListRemove(result.RESULT_DATA);
				} 

			}
		});
	}

	/* ********************************************************
	 * 조회 데이터 중복 내역 방지
	 ******************************************************** */
 	function fn_trableListRemove(result){
		var connTableRows = ins_connector_tableList.rows().data();

		if (connTableRows.length > 0 && result.length > 0) {
			for(var i=0; i<result.length; i++){
				for(var j=0; j<connTableRows.length; j++){
					if(result[i].table_name == connTableRows[j].table_name){
						result.splice(i, 1);
					}
				}
			}
		}

		ins_tableList.rows.add(result).draw();
	}

	/* ********************************************************
	 * Validation Check
	 ******************************************************** */
	function ins_valCheck(){
		var valideMsg = "";
		
		if(nvlPrmSet($("#ins_source_kc_nm", "#searchRegForm").val(), '') == "") {
			valideMsg = "Kafka-Connect " + ins_kafka_server_nm;
			showSwalIcon('<spring:message code="errors.required" arguments="'+ valideMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		} else if(nvlPrmSet($("#ins_kc_ip", "#searchRegForm").val(), '') == "") {
			valideMsg = "Kafka-Connect " + " " + ins_kc_ip_msg;
			showSwalIcon('<spring:message code="errors.required" arguments="'+ valideMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		} else if(nvlPrmSet($("#ins_kc_port", "#searchRegForm").val(), '') == "") {
			valideMsg = "Kafka-Connect " + " " + ins_kc_port_msg;
			showSwalIcon('<spring:message code="errors.required" arguments="'+ valideMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		}else if(ins_connect_status_Chk == "fail"){
			showSwalIcon('<spring:message code="eXperDB_CDC.msg36" />', '<spring:message code="common.close" />', '', 'error');
			return false;
		
		} else if(nvlPrmSet($("#ins_connect_nm", "#insRegForm").val(), '') == "") {
			showSwalIcon('<spring:message code="errors.required" arguments="'+ ins_connectNmMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		} else if(nvlPrmSet($("#ins_db_id", "#insRegForm").val(), '') == "") {
			showSwalIcon('<spring:message code="errors.required" arguments="'+ ins_databaseMsg +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		} else if(ins_connect_nm_Chk == "fail") {
			showSwalIcon('<spring:message code="eXperDB_CDC.msg6" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		} else if(nvlPrmSet($("#ins_trans_com_id", "#insRegForm").val(), '') == "") {
			showSwalIcon('<spring:message code="errors.required" arguments="'+ ins_trans_com_cng_nm_val +'" />', '<spring:message code="common.close" />', '', 'warning');
			return false;
		}

		//전성대상테이블 length 체크
		if (ins_connector_tableList.rows().data().length <= 0) {
			showSwalIcon('<spring:message code="eXperDB_CDC.msg24"/>', '<spring:message code="common.close" />', '', 'error');
			return false;
		}

		return true;
	}

	/* ********************************************************
	 * DBMS 시스템 등록 버튼 클릭시
	 ******************************************************** */
	function fn_ins_sc_comConCho(){
		$('#cho_trans_com_con_cho_mod').hide();
		$('#cho_trans_com_con_cho_add').show();
		
		$('#cho_trans_com_cng_nm').val("");
		
		cho_proc_gbn = "ins";

		fn_cho_trans_search_com_con();
		

		$('#pop_layer_trans_com_con_cho').modal("show");
	}
	
	/* ********************************************************
	 * Schema Regsitry 등록 버튼 클릭 시 
	 ******************************************************** */
	function fn_ins_regiInfo(){
		$('#cho_trans_sel_schem_mod').hide();
		$('#cho_trans_sel_schem_add').show();
		
		$('#cho_trans_com_cng_nm').val("");
		
		 cho_schema_gbn = "ins";

		fn_cho_trans_search_schema();
		

		$('#pop_layer_trans_sel_schem').modal("show");
	}
	
	

	/* ********************************************************
	 * DBMS 서버 호출하여 입력
	 ******************************************************** */
	function fn_trans_com_conAddCallback(trans_com_id, trans_com_cng_nm){
		 $("#ins_trans_com_id", "#insRegForm").val(nvlPrmSet(trans_com_id, ''));
		 $("#ins_trans_com_cng_nm", "#insRegForm").val(nvlPrmSet(trans_com_cng_nm, ''));
	}

	/* ********************************************************
	 * Schema Regsitry 정보 팝업에서 호출하여 입력
	 ******************************************************** */
	function fn_trans_schema_AddCallback(regi_id, regi_nm, regi_ip, regi_port){
		 $("#ins_trans_regi_id", "#insRegForm").val(nvlPrmSet(regi_id, ''));
		 $("#ins_trans_regi_nm", "#insRegForm").val(nvlPrmSet(regi_nm, ''));
		 $("#ins_trans_regi_ip", "#insRegForm").val(nvlPrmSet(regi_ip, ''));
		 $("#ins_trans_regi_port", "#insRegForm").val(nvlPrmSet(regi_port, ''));
	}
</script>

<div class="modal fade" id="pop_layer_con_reg_two" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog  modal-xl-top" role="document" style="margin: 30px 350px;">
		<div class="modal-content" style="width:1000px;">		 
			<div class="modal-body" style="margin-bottom:-30px;">
				<h4 class="modal-title mdi mdi-alert-circle text-info" id="ModalLabel" style="padding-left:5px;">
					<spring:message code="menu.reg_transfer_set"/>
				</h4>
				
				<div class="card" style="margin-top:10px;border:0px;">
					<form class="cmxform" id="searchRegForm">
						<fieldset>
							<div class="card-body" style="border: 1px solid #adb5bd;">
								<div class="table-responsive">
									<table id="connectRegPopList" class="table system-tlb-scroll" style="width:100%;">
										<colgroup>
											<col style="width: 35%;" />
											<col style="width: 27%;" />
											<col style="width: 18%;" />
											<col style="width: 15%;" />
										</colgroup>
										<thead>
											<tr class="bg-info text-white">
												<th class="table-text-align-c">Kafka-Connect <spring:message code="data_transfer.server_name" /></th>
												<th class="table-text-align-c"><spring:message code="data_transfer.ip" /></th>
												<th class="table-text-align-c"><spring:message code="data_transfer.port" /></th>
												<th class="table-text-align-c"><spring:message code="eXperDB_CDC.connection_status" /></th>
											</tr>
										</thead>
										<tbody>
											<tr style="border-bottom: 1px solid #adb5bd;">
												<td class="table-text-align-c">
													<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_source_kc_nm" id="ins_source_kc_nm" onChange="fn_kc_nm_chg('source_ins');" tabindex=1>
														<option value=""><spring:message code="common.choice" /></option>
														<c:forEach var="result" items="${kafkaConnectList}" varStatus="status">
															<option value="<c:out value="${result.kc_id}"/>"><c:out value="${result.kc_nm}"/></option>
														</c:forEach>
													</select>
												</td>				
												<td class="table-text-align-c">
													<input type="text" class="form-control form-control-xsm" maxlength="50" id="ins_kc_ip" name="ins_kc_ip" onblur="this.value=this.value.trim()" disabled tabindex=1 />
												</td>												
												<td class="table-text-align-c">
													<input type="text" class="form-control form-control-xsm" maxlength="5" id="ins_kc_port" name="ins_kc_port" onblur="this.value=this.value.trim()" onKeyUp="chk_Number(this);" disabled tabindex=2 />						
												</td>
												<td class="table-text-align-c" id="ins_kc_connect_td" >
													<%-- <input class="btn btn-inverse-danger btn-sm btn-icon-text mdi mdi-lan-connect" type="submit" value='<spring:message code="eXperDB_CDC.test_connection" />' />
												 --%>
												</td>											
											</tr>					
										</tbody>
									</table>
								</div>
							</div>
						</fieldset>
					</form>

					<br/>
	
					<div class="card-body" style="padding: 0px 0px 0px 0px;">
						<div class="form-group row div-form-margin-z">
							<div class="col-12" >
								<ul class="nav nav-pills nav-pills-setting" style="border-bottom:0px;" id="server-tab" role="tablist">
									<li class="nav-item tab-pop-two-style">
										<!-- <a class="nav-link active" id="ins-tab-1" data-toggle="pill" href="#insSettingTab" role="tab" aria-controls="insSettingTab" aria-selected="true" onclick="javascript:selectInsTab('setting');" > -->
										<a class="nav-link active" id="ins-tab-1" data-toggle="pill" href="#insSettingTab" role="tab" aria-controls="insSettingTab" aria-selected="true" >
											<spring:message code="eXperDB_CDC.connect_set" />
										</a>
									</li>
									<li class="nav-item tab-pop-two-style">
										<!-- <a class="nav-link" id="ins-tab-2" data-toggle="pill" href="#insTableTab" role="tab" aria-controls="insTableTab" aria-selected="false" onclick="javascript:selectInsTab('table');"> -->
										<a class="nav-link" id="ins-tab-2" data-toggle="pill" href="#insTableTab" role="tab" aria-controls="insTableTab" aria-selected="false">
											<spring:message code="eXperDB_CDC.table_mapping" />
										</a>
									</li>
								</ul>
							</div>
						</div>
						
						<div class="tab-content" id="pills-tabContent" style="border-top: 1px solid #c9ccd7;margin-bottom:-10px;">
							<div class="tab-pane fade show active" role="tabpanel" id="insSettingTab">
								<form class="cmxform" id="insRegForm">
									<input type="hidden" name="ins_table_mapp_nm" id="ins_table_mapp_nm" />
									<input type="hidden" name="ins_meta_data" id="ins_meta_data" />
									<input type="hidden" name="ins_trans_com_id" id="ins_trans_com_id" />

									<fieldset>
										<!-- Connect명 -->
										<div class="form-group row" style="margin-bottom:10px;">
											<label for="ins_connect_nm" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.connect_name_set" />
											</label>
											<div class="col-sm-3">
												<input type="text" class="form-control form-control-xsm" id="ins_connect_nm" name="ins_connect_nm" maxlength="50" placeholder='<spring:message code='eXperDB_CDC.msg18'/>' onblur="this.value=this.value.trim()" tabindex=3 />
											</div>
											<div class="col-sm-2">
												<button type="button" class="btn btn-inverse-danger btn-sm btn-icon-text" onclick="fn_insConNmCheck();"><spring:message code="common.overlap_check" /></button>
											</div>
											<label for="ins_connect_type" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												Schema Registry<%-- <spring:message code="eXperDB_CDC.connect_name_set" /> --%>
											</label>
											<div class="col-sm-3">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_connect_type" id="ins_connect_type" tabindex=4 onchange="fn_conType_change(1);">
													<option value=""><spring:message code="common.choice" /></option>
													<option value="TC004501"><spring:message code="dbms_information.unuse" /></option>
													<option value="TC004502"><spring:message code="dbms_information.use" /></option>
												</select>
											</div>
										</div>
										
										<!-- Schema Registry -->
										<div id="ins_schema_registry_info" class="card-body" style="border: 1px solid #adb5bd; margin-bottom:20px;display: none;">
											<div class="table-responsive">
												<label for="ins_connect_type" class="col-sm-12 col-form-label-sm pop-label-index" style="margin-top:-10px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													Schema Registry <spring:message code="dashboard.server"/>
												</label>
												<table id="connectRegPopList" class="table system-tlb-scroll" style="width:100%;">
													<colgroup>
														<col style="width: 35%;" />
														<col style="width: 27%;" />
														<col style="width: 18%;" />
														<col style="width: 15%;" />
													</colgroup>
													<thead>
														<tr class="bg-info text-white">
															<th class="table-text-align-c">Schema Registry <spring:message code="data_transfer.server_name" /></th>
															<th class="table-text-align-c"><spring:message code="data_transfer.ip" /></th>
															<th class="table-text-align-c"><spring:message code="data_transfer.port" /></th>
															<th class="table-text-align-c"><spring:message code="eXperDB_CDC.connection_status" /></th>
														</tr>
													</thead>
													<tbody>
														<tr style="border-bottom: 1px solid #adb5bd;">
															<td class="table-text-align-c">
																<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_source_sch_nm" id="ins_source_sch_nm" onChange="fn_sch_nm_chg('source_ins');" tabindex=1>
																	<option value=""><spring:message code="common.choice" /></option>
																	<c:forEach var="result" items="${schemaRegistryList}" varStatus="status">
																		<option value="<c:out value="${result.regi_id}"/>"><c:out value="${result.regi_nm}"/></option>
																	</c:forEach>
																</select>
															</td>				
															<td class="table-text-align-c">
																<input type="text" class="form-control form-control-xsm" maxlength="50" id="ins_sch_ip" name="ins_sch_ip" onblur="this.value=this.value.trim()" disabled tabindex=1 />
															</td>												
															<td class="table-text-align-c">
																<input type="text" class="form-control form-control-xsm" maxlength="5" id="ins_sch_port" name="ins_sch_port" onblur="this.value=this.value.trim()" onKeyUp="chk_Number(this);" disabled tabindex=2 />						
															</td>
															<td class="table-text-align-c" id="ins_sch_connect_td" >
																<%-- <input class="btn btn-inverse-danger btn-sm btn-icon-text mdi mdi-lan-connect" type="submit" value='<spring:message code="eXperDB_CDC.test_connection" />' />
															--%>
															</td>											
														</tr>					
													</tbody>
												</table>
											</div>
										</div>
										
										<!-- 데이터베이스 -->
										<div class="form-group row" style="margin-bottom:10px;">
											<label for="ins_db_id" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.database" />
											</label>
											<div class="col-sm-3">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_db_id" id="ins_db_id" tabindex=4>
													<option value=""><spring:message code="common.choice" /></option>
													<c:forEach var="result" items="${dbList}" varStatus="status">
														<option value="<c:out value="${result.db_id}"/>"><c:out value="${result.db_nm}"/></option>
													</c:forEach>
												</select>
											</div>
											<div class="col-sm-2"></div>
											<label for="ins_compression_type" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.metadata" />
											</label>
											<div class="col-sm-3">
												<div class="onoffswitch-pop">
													<input type="checkbox" name="ins_meta_data_chk" class="onoffswitch-pop-checkbox" id="ins_meta_data_chk" />
													<label class="onoffswitch-pop-label" for="ins_meta_data_chk">
														<span class="onoffswitch-pop-inner"></span>
														<span class="onoffswitch-pop-switch"></span>
													</label>
												</div>
											</div>
										</div>
										<!--  스냅샷 모드  -->
										<div class="form-group row" style="margin-bottom:10px;">
											<label for="ins_snapshot_mode" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.snapshot_mode" />
											</label>
											<div class="col-sm-3">
											<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_snapshot_mode" id="ins_snapshot_mode" tabindex=5>
													<c:forEach var="result" items="${snapshotModeList}">
													<option value="<c:out value="${result.sys_cd}"/>"><c:out value="${result.sys_cd_nm}"/></option>
													</c:forEach>
												</select>
											</div>
											<div class="col-sm-2" style="height:30px;display: flex;align-items: center;padding-right: 0px;">
												<span class="text-sm-left" style="font-size: 0.75rem;" id="ins_snapshotModeDetail"></span>	
											</div>
											<label for="ins_compression_type" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.compression_type" />
											</label>
											<div class="col-sm-3">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;" name="ins_compression_type" id="ins_compression_type" tabindex=5>
													<c:forEach var="result" items="${compressionTypeList}">
														<option value="<c:out value="${result.sys_cd}"/>"><c:out value="${result.sys_cd_nm}"/></option>
													</c:forEach>
												</select>
											</div>
										</div>
										<!--  기본 설정 -->
										<div class="form-group row" style="margin-bottom:10px;">
											<label for="ins_trans_com_cng_nm" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.default_setting"/>
											</label>
											<div class="col-sm-8">
												<input type="text" class="form-control form-control-xsm" id="ins_trans_com_cng_nm" name="ins_trans_com_cng_nm" readonly="readonly" />
											</div>
											<div class="col-sm-2">
												<button type="button" class="btn btn-inverse-info btn-sm btn-icon-text" style="min-width: 84px;" onclick="fn_ins_sc_comConCho()"><spring:message code="button.create" /></button>
											</div>
										</div>	
										<!-- Schema Registry 설정 -->
										<div class="form-group row schemRow" style="margin-bottom:10px; display: none;">
											<label for="ins_trans_regi_id" class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
												<i class="item-icon fa fa-dot-circle-o"></i>
												Schema Registry
											</label>
											<div class="col-sm-3">
												<input type="hidden" class="form-control form-control-xsm" id="ins_trans_regi_id" name="ins_trans_regi_id" readonly="readonly" />
												<input type="text" class="form-control form-control-xsm" id="ins_trans_regi_nm" name="ins_trans_regi_nm" placeholder="Schema Registry명" readonly="readonly" />
											</div>
											<div class="col-sm-3">
												<input type="text" class="form-control form-control-xsm" id="ins_trans_regi_ip" name="ins_trans_regi_ip" placeholder="아이피" readonly="readonly" />
											</div>
											<div class="col-sm-2">
												<input type="text" class="form-control form-control-xsm" id="ins_trans_regi_port" name="ins_trans_regi_port" placeholder="포트"  readonly="readonly" />
											</div>
											<div class="col-sm-2">
												<button type="button" class="btn btn-inverse-info btn-sm btn-icon-text" style="min-width: 84px;" onclick="fn_ins_regiInfo()"><spring:message code="button.create" /></button>
											</div>
										</div>	
										<!-- 활성화  -->
										<div class="form-group row" style="margin-bottom:-15px;">
											<label for="ins_compression_type" class="col-sm-2 col-form-label-sm pop-label-index">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="access_control_management.activation" />
											</label>
											<div class="col-sm-3">
												<div class="onoffswitch-pop-play">
													<input type="checkbox" name="ins_source_transActive_act" class="onoffswitch-pop-play-checkbox" id="ins_source_transActive_act" onclick="fn_transActivation_msg_set('ins_source')" >
													<label class="onoffswitch-pop-play-label" for="ins_source_transActive_act">
														<span class="onoffswitch-pop-play-inner"></span>
														<span class="onoffswitch-pop-play-switch"></span>
													</label>
												</div>
											</div>
											<div class="col-sm-7 col-form-label-sm">
												<span class="text-sm-left text-info" style="font-size: 0.75rem;"  id="ins_source_trans_active_div">
													<spring:message code="eXperDB_CDC.msg27" />
												</span>	
												<%-- <div class="alert alert-info" id="ins_source_trans_active_div" style="display:none; margin-top:5px;margin-bottom:-15px;" >
													<spring:message code="eXperDB_CDC.msg27" />
												</div> --%>
											</div>
										</div>
									</fieldset>
								</form>	
							</div>
								
							<div class="tab-pane fade" role="tabpanel" id="insTableTab">
								<div class="card" style="margin-top:-20px;">
									<div class="card-body" style="margin:-10px -10px -15px -10px;">
										<form class="form-inline row" onsubmit="return false">
											<div class="input-group mb-2 mr-sm-2 col-sm-6">
												<input type="text" class="form-control form-control-xsm" maxlength="25" id="ins_table_nm" name="ins_table_nm" onblur="this.value=this.value.trim()" placeholder='<spring:message code="migration.table_name" />'/>				
											</div>
				
											<button type="button" class="btn btn-inverse-primary btn-sm btn-icon-text mb-2 btn-search-disable" id="btnConAddSearch" onClick="fn_table_search_ins();" >
												<i class="ti-search btn-icon-prepend "></i><spring:message code="data_transfer.tableList" />
											</button>
										</form>
									</div>
								</div>
									
								<div class="row">
									<div class="col-5 stretch-card div-form-margin-table" style="max-width: 47%;margin-top:5px;" id="left_list">
										<div class="card" style="border:0px;">
											<div class="card-body" style="padding-left:0px;padding-right:0px;">
												<h4 class="card-title">
													<i class="item-icon fa fa-dot-circle-o"></i>
													<spring:message code="data_transfer.tableList" />
												</h4>
	
									 			<table id="ins_tableList" class="table table-hover system-tlb-scroll" style="width:100%;">
													<thead>
														<tr class="bg-info text-white">
															<th width="161" class="dt-center" ><spring:message code="migration.schema_Name" /></th>
															<th width="162" class="dt-center" ><spring:message code="migration.table_name" /></th>	
														</tr>
													</thead>
												</table>
											</div>
										</div>
									</div>
	 									
									<div class="col-1 stretch-card div-form-margin-table" style="max-width: 6%;" id="center_div">
										<div class="card" style="background-color: transparent !important;border:0px;">
											<div class="card-body">	
												<div class="card my-sm-2 connectRegForm2" style="border:0px;background-color: transparent !important;">
													<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-top:15px;margin-bottom:-15px;">
														<a href="#" class="tip" onclick="fn_ins_t_allRightMove();">
															<i class="fa fa-angle-double-right" style="font-size: 35px;cursor:pointer;"></i>
															<span style="width: 200px;"><spring:message code="data_transfer.move_right_line" /></span>
														</a>
													</label>
													
													<br/>
														
													<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
														<a href="#" class="tip" onclick="fn_ins_t_rightMove();">
															<i class="fa fa-angle-right" style="font-size: 35px;cursor:pointer;"></i>
															<span style="width: 200px;"><spring:message code="data_transfer.move_right_line" /></span>
														</a>
													</label>
													
													<br/>
	
													<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
														<a href="#" class="tip" onclick="fn_ins_t_leftMove();">
															<i class="fa fa-angle-left" style="font-size: 35px;cursor:pointer;"></i>
															<span style="width: 200px;"><spring:message code="data_transfer.move_left_line" /></span>
														</a>
													</label>
													
													<br/>
	
													<label for="com_auto_run_cycle" class="col-sm-12 col-form-label pop-label-index" style="margin-left:-30px;margin-bottom:-15px;">
														<a href="#" class="tip" onclick="fn_ins_t_allLeftMove();">
															<i class="fa fa-angle-double-left" style="font-size: 35px;cursor:pointer;"></i>
															<span style="width: 200px;"><spring:message code="data_transfer.move_all_left" /></span>
														</a>
													</label>
												</div>
											</div>
										</div>
									</div>
											
									<div class="col-5 stretch-card div-form-margin-table" style="max-width: 47%;margin-top:5px;" id="right_list">
										<div class="card" style="border:0px;">
											<div class="card-body" style="padding-left:0px;padding-right:0px;">
												<h4 class="card-title">
													<i class="item-icon fa fa-dot-circle-o"></i>
													<spring:message code="eXperDB_CDC.transfer_table" />
												</h4>
	
								 				<table id="ins_connector_tableList" class="table table-hover system-tlb-scroll" style="width:100%;">
													<thead>
														<tr class="bg-info text-white">
															<th width="161" class="dt-center" ><spring:message code="migration.schema_Name" /></th>
															<th width="162" class="dt-center" ><spring:message code="migration.table_name" /></th>	
														</tr>
													</thead>
												</table>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<br/>

			<div class="top-modal-footer" style="text-align: center !important; margin: -10px 0 0 -10px;" >
				<button type="button" class="btn btn-primary" onclick="fn_ins_insert();"><spring:message code="common.registory"/></button>
				<button type="button" class="btn btn-light" data-dismiss="modal"><spring:message code="common.close"/></button>
			</div>
		</div>
	</div>
</div>	