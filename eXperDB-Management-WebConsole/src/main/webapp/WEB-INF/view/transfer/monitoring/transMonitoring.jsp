<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="../../cmmn/cs2.jsp"%>
<%@include file="../../cmmn/commonLocaleTrans.jsp" %> 

<%
	/**
	* @Class Name : transMonitoring.jsp
	* @Description : 전송관리 모니터링
	* @Modification Information
	*
	*	수정일			수정자						 수정내용
	*  ------------	 -----------	 ---------------------------
	*  2021.07.26	  최초 생성
	*
	* author 윤정 매니저
	* since 2021.07.26
	*
	*/
%>
<STYLE TYPE="text/css">
/*툴팁 스타일*/
a.tip {
    position: relative;
    color:black;
}

a.tip span {
    display: none;
    position: absolute;
    top: 20px;
    left: -10px;
    width: 200px;
    padding: 5px;
    z-index: 10000;
    background: #000;
    color: #fff;
    line-height: 20px;
    -moz-border-radius: 5px; /* 파폭 박스 둥근 정도 */
    -webkit-border-radius: 5px; /* 사파리 박스 둥근 정도 */
}

a:hover.tip span {
    display: block;
}


.blinking{ 
 -webkit-animation:blink 5.0s ease-in-out infinite alternate; 
 -moz-animation:blink 1.0s ease-in-out infinite alternate; 
 animation:blink 3.0s ease-in-out infinite alternate;
} 

.txt_line { width:70px; padding:0 5px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }

@-webkit-keyframes blink{ 
 0% {opacity:0;} 
 100% {opacity:1;} 
} 

@-moz-keyframes blink{ 
 0% {opacity:0;} 
 100% {opacity:1;} 
} 

@keyframes blink{ 
 0% {opacity:0;} 
 100% {opacity:1;} 
}
</STYLE>

<script src="/vertical-dark-sidebar/js/trans_monitoring.js"></script>

<script type="text/javascript">
	var cpuChart = "";
	var memChart = "";
// 	var allErrorChart = "";
//	var connectorActTable = "";
	var sinkChart = "";
	var sinkCompleteChart = "";
	var sinkErrorChart = "";
	var confile_title = "";
	var src_exe_status = "";
	var tar_exe_status = "";
	
	var reloadTimeout;
	
	/* ********************************************************
	* 화면 onload
	******************************************************** */
	$(window).ready(function(){		
		//금일 날짜 setting
		fn_todaySetting();
		
		//kafka 연결도 setting
		fn_kafkaLoadSetting("start");

		// cpu, memory error chart
		fn_cpu_mem_err_chart();

		// connector 기동정지 table init
		//fn_connector_act_init();

		// 소스 connect setting info init - connect 설정정보
		fn_src_setting_info_init();

		// 소스 connect mapping table init - 전송대상 테이블 정보
		fn_src_mapping_list_init();

		// 소스 connect init	  -- 실시간리스트
		fn_src_connect_init();
		
		// 타겟 connect 토픽 리스트 init -- 전송대상 토픽리스트 정보
		fn_tar_topic_list_init();

		// 타겟 connect 리스트 init	  -- 실시간리스트
		fn_tar_connect_init();
		
		// 소스 snapshot init
		//fn_src_snapshot_init();

		// 소스 streaming init
		//fn_src_streaming_init();

		// 소스 error 리스트 init
		//fn_src_error_init();

		// 타겟 error 리스트 init
		//fn_tar_error_init();
	});

	/* ********************************************************
	* 소스 커넥터 select box 변경
	******************************************************** */
	function fn_srcConnectInfo(strgbn) {
		var langSelect = document.getElementById("src_connect");
		var selectValue = langSelect.options[langSelect.selectedIndex].value;
		
		fn_tar_init();
		fn_src_init();
	
		//kafka 연결도 setting
		fn_kafkaLoadSetting("start");

		if(selectValue != ""){
			$.ajax({
				url : "/transSrcConnectInfo.do",
				dataType : "json",
				type : "post",
				data : {
					trans_id : selectValue,
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
				},
				success : function(result) {
					if (result != null) {
						//소스커넥터 테이블수, 전체완료수, 오류수 setting
						$('#table_cnt').html(result.table_cnt);
						$('#ssconDBResultTable').show();
						if(result.connectInfo[0] != null && result.connectInfo[0] != undefined){
							$('#src_total_poll_cnt').html(result.connectInfo[0].source_record_poll_total);
							$('#src_total_error_cnt').html(result.connectInfo[0].total_record_errors);
							$('#ssconResultCntTable').show();
							$('#ssconResultCntTableNvl').hide();
						}

						//하단 상세화면 출력
						$('#trans_monitoring_source_info').show();
						$('#trans_monitoring_target_info').show();

						//싱크커넥터 select 활성화
						if (strgbn != null && strgbn != "restart") {
							$('#tar_connector_list').empty();
							$('#tar_connector_list').append('<option value=\"\"><spring:message code="eXperDB_CDC.target_connector" /></option>');

							if (nvlPrmSet(result.targetConnectorList, '') != '') {
								for (i = 0; i < result.targetConnectorList.length; i++) {
									if(i == 0){
										$('#tar_connector_list').append('<option selected value=\"'+result.targetConnectorList[i].trans_id+'\">'+result.targetConnectorList[i].connect_nm+'</option>');
										fn_tarConnectInfo();
									} else {
										$('#tar_connector_list').append('<option value=\"'+result.targetConnectorList[i].trans_id+'\">'+result.targetConnectorList[i].connect_nm+'</option>');
									}
								}

								$('#tar_connect').show();
								$('#tar_connect_nvl').hide();
							} else {
							$('#tar_connect').hide();
							$('#tar_connect_nvl').show();

							fn_tarConnectInfo();
							}
						} else {
							fn_tarConnectInfo();
						}
						
						src_exe_status = result.connectInfo[0].exe_status;
						
						//Kafka Connect 별 기동정지이력 setting
						/* connectorActTable.clear().draw();
						if (nvlPrmSet(result.kafkaActCngList, '') != '') {
							connectorActTable.rows.add(result.kafkaActCngList).draw();
						} */

						//소스시스템 connect 설정정보  setting
						srcConnectSettingInfoTable.clear().draw();
						if (nvlPrmSet(result.connectInfo, '') != '') {
							srcConnectSettingInfoTable.rows.add(result.connectInfo).draw();
						}

						//소스시스템 connect 전송대상테이블  setting
						srcMappingListTable.clear().draw();
						if (nvlPrmSet(result.table_name_list, '') != '') {
							srcMappingListTable.rows.add(result.table_name_list).draw();
						}

						//소스시스템 - snapshot tap 선택
						document.getElementById('server-tab-1').click();
//						 selectTab('snapshot');

						//소스시스템 chart setting
						funcSsChartSetting(result);

						//소스시스템 리스트별 setting
						funcSsListSetting(result);

						//상단연결도 setting
						fn_dbmsConnect_digm("source", result);

						//상단연결도 setting
						fn_dbmsConnect_digm("kafka", result);
					}
				}
			});
		} else {
			$('#kc_id', '#transMonitoringForm').val("");

			$('#ssconResultCntTable').hide();
			$('#ssconResultCntTableNvl').show();
			$('#tar_connector_list').empty();
			$('#tar_connector_list').append('<option value=\"\"><spring:message code="eXperDB_CDC.target_connector" /></option>');

			//싱크 커넥터 select change
			fn_tarConnectInfo();

			$('#ssconDBResultTable').hide();
			//connectorActTable.clear().draw();
		}
		$("#loading").hide();
	}

	/* ********************************************************
	 * 싱크 커넥터 select box 변경
	 ******************************************************** */
	function fn_tarConnectInfo(){
		var langSelect = document.getElementById("tar_connector_list");
		var selectValue = langSelect.options[langSelect.selectedIndex].value;
		
		//싱크 커넥터 - 하단 상세화면 초기화
		fn_tar_init();

		if(selectValue != ""){
			$.ajax({
				url : "/transTarConnectInfo.do",
				dataType : "json",
				type : "post",
				data : {
					 trans_id : selectValue,
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
				},
				success : function(result) {
					if (result != null) {
						if (nvlPrmSet(result.targetDBMSInfo, '') != '') {
							//싱크커넥터 - 토픽수, 전체완료수, 오류수
							$('#topic_cnt').html(result.topic_cnt);
							if(result.targetConnectInfo != null && result.targetConnectInfo != undefined){
								$('#tarconResultCntTableNvl').hide();
								$('#tarconResultCntTable').show();
								$('#sink_record_send_total').html(result.targetConnectInfo.sink_record_send_total);
								$('#tar_total_error').html(result.targetConnectInfo.total_record_errors);
								$('#skconResultTable').show();
							} else {
								$('#tarconResultCntTable').hide();
								$('#tarconResultCntTableNvl').show();
							}

							//연결도 dbms setting
							$('#d_tg_connect_nm').text(langSelect.options[langSelect.selectedIndex].text);
							$('#d_tg_sys_nm').text(result.targetDBMSInfo[0].trans_sys_nm);
							$('#d_tg_dbms_type').text(result.targetDBMSInfo[0].dbms_type);
							$('#d_tg_dbms_nm').text(result.targetDBMSInfo[0].dtb_nm);
							$('#d_tg_schema_nm').text(result.targetDBMSInfo[0].scm_nm);
						}

//						if(nvlPrmSet(result.allErrorList, '') != '') {
//							 allErrorChart.setData(result.allErrorList);
//						}

						//싱크 커넥터 - connect 정보 리스트 setting
						funcTarListSetting(result, langSelect);
						
						//싱크 커넥터 - 차트 setting
						fn_sink_chart_init(selectValue);
						// 값 넣어주기

// 						$('#tar_exe_status', '#transMonConStartForm').val(nvlPrmSet(result.targetTopicList[0].exe_status, ''));
// 						tar_exe_status = result.targetTopicList[0].exe_status;
						//상단연결도 setting
						fn_dbmsConnect_digm("tar", result);
					}

				}
			});
		} else {
			$('#tarconResultCntTable').hide();
			$('#tarconResultCntTableNvl').show();
			$('#skconResultTable').hide();
		}
		$("#loading").hide();

		// 30초에 한번씩 reload

		var src_connect = $('#src_connect').val();
		var tar_connector = $('#tar_connector_list').val();
		
		
		setTimeout(function(){
			if ((src_connect != "" || tar_connector != "") && (src_exe_status == "TC001501" && tar_exe_status == "TC001501")) {
				if(reloadTimeout != null)	clearTimeout(reloadTimeout);
				reloadTimeout = setTimeout(function(){
					fn_reload_Src_ConnectInfo();	
				},30000);
			}
		},1000);
	}
		
	/* 주기적으로 Reload*/	
	function 	fn_reload_Src_ConnectInfo(){
    	var langSelect = document.getElementById("src_connect");
		var selectValue = langSelect.options[langSelect.selectedIndex].value;
		
    	$.ajax({
			url : "/transSrcConnectInfo.do",
			dataType : "json",
			type : "post",
			data : {
				trans_id : selectValue,
			},
			beforeSend: function(xhr) {
				$("#loading").hide();
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
				
				//snapshot, streaming Chart reload
				if($("#server-tab-1").attr('class').indexOf("active") > 0){
					fn_snapshot_strem("snapshot");
				}else{
					fn_snapshot_strem("streaming");
				}
				
				 //Connect 실시간 차트 
				funcSsChartSetting(result);
				 
				funcSsListSetting(result);
				
				fn_reload_Tar_ConnectInfo();
			}
		});
    	
    }

	
	function fn_reload_Tar_ConnectInfo(){
		console.log("fn_reload_Tar_ConnectInfo");
		var langSelect = document.getElementById("tar_connector_list");
		var selectValue = langSelect.options[langSelect.selectedIndex].value;
		
		fn_sink_chart_init(selectValue);
		
		if(selectValue != ""){
			$.ajax({
				url : "/transTarConnectInfo.do",
				dataType : "json",
				type : "post",
				data : {
					 trans_id : selectValue,
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
				},
				success : function(result) {
					if (result != null) {
						tarConnectTable.clear().draw();
						if (nvlPrmSet(result.targetSinkInfo, '') != '') {
							for(var i = 0; i < result.targetSinkInfo.length; i++){	
								if(result.targetSinkInfo[i].rownum == 1){
									if(i != result.targetSinkInfo.length-1 && result.targetSinkInfo[i+1].rownum == 2){
										result.targetSinkInfo[i].sink_record_active_count_cng = result.targetSinkInfo[i].sink_record_active_count - result.targetSinkInfo[i+1].sink_record_active_count;
										result.targetSinkInfo[i].put_batch_avg_time_ms_cng = result.targetSinkInfo[i].put_batch_avg_time_ms - result.targetSinkInfo[i+1].put_batch_avg_time_ms;
										result.targetSinkInfo[i].offset_commit_completion_rate_cng = (result.targetSinkInfo[i].offset_commit_completion_rate - result.targetSinkInfo[i+1].offset_commit_completion_rate).toFixed(2);
										result.targetSinkInfo[i].sink_record_send_total_cng = result.targetSinkInfo[i].sink_record_send_total - result.targetSinkInfo[i+1].sink_record_send_total;
										result.targetSinkInfo[i].sink_record_active_count_avg_cng = result.targetSinkInfo[i].sink_record_active_count_avg - result.targetSinkInfo[i+1].sink_record_active_count_avg;
										result.targetSinkInfo[i].offset_commit_completion_total_cng = result.targetSinkInfo[i].offset_commit_completion_total - result.targetSinkInfo[i+1].offset_commit_completion_total;
										result.targetSinkInfo[i].offset_commit_skip_rate_cng = result.targetSinkInfo[i].offset_commit_skip_rate - result.targetSinkInfo[i+1].offset_commit_skip_rate;
										result.targetSinkInfo[i].offset_commit_skip_total_cng = result.targetSinkInfo[i].offset_commit_skip_total - result.targetSinkInfo[i+1].offset_commit_skip_total;
										result.targetSinkInfo[i].sink_record_read_total_cng = result.targetSinkInfo[i].sink_record_read_total - result.targetSinkInfo[i+1].sink_record_read_total;
									}

									if(nvlPrmSet(result.targetSinkInfo[0].time, '') != '') {
										tarConnectTable.row.add(result.targetSinkInfo[i]).draw();
									}
								}
							}
						}
					}
				}
			});
		}
		var src_connect = $('#src_connect').val();
		var tar_connector = $('#tar_connector_list').val();
		
	
		if ((src_connect != "" || tar_connector != "") && (src_exe_status == "TC001501" && tar_exe_status == "TC001501")) {
			if(reloadTimeout != null)	clearTimeout(reloadTimeout);
			reloadTimeout = setTimeout(function(){
				fn_reload_Src_ConnectInfo();	
			},30000);
		}
	}
	/* ********************************************************
	 * kafka / connector 로그 보기 - 클릭
	 ******************************************************** */
	function fn_logView(type){
		var todayYN = 'N';
		var langSel = document.getElementById("src_connect");
		var src_select = langSel.options[langSel.selectedIndex].value;
		var date = new Date().toJSON();
		
		langSel = document.getElementById("tar_connector_list");
		var tar_select = langSel.options[langSel.selectedIndex].value;
		
		var v_db_svr_id = $("#db_svr_id", "#transMonitoringForm").val();
		var v_kc_id = $("#kc_id", "#transMonitoringForm").val();
		
		if(src_select == '') {
			showSwalIcon('<spring:message code="message.msg228" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		} else {
			$.ajax({
				url : "/transLogView.do",
				type : 'post',
				data : {
					db_svr_id : v_db_svr_id,
					date : date,
					kc_id : v_kc_id
				},
				success : function(result) {
					$("#connectorlog", "#transLogViewForm").html("");
					$("#dwLen", "#transLogViewForm").val("0");
					$("#fSize", "#transLogViewForm").val("");
					$("#log_line", "#transLogViewForm").val("1000");
					$("#type", "#transLogViewForm").val(type);
					$("#date", "#transLogViewForm").val(date);
	//				$("#aut_id", "#transLogViewForm").val(aut_id);
	//				$("#todayYN", "#transLogViewForm").val(todayYN);
					$("#todayYN", "#transLogViewForm").val("Y");
					$("#view_file_name", "#transLogViewForm").html("");
					$("#trans_id","#transLogViewForm").val(src_select);
					$("#kc_id", "#transLogViewForm").val(v_kc_id);
					if(type === 'connector'){
						dateCalenderSetting();
						$('#restart_btn').hide();
						$('#wrk_strt_dtm_div').show();
						$('.log_title').html(' <spring:message code="eXperDB_CDC.connect_log" /> ');
					} else if(type === 'kafka'){
						$('#restart_btn').show();
						$('#wrk_strt_dtm_div').hide();
						$('.log_title').html(' <spring:message code="eXperDB_CDC.kafka_log" /> ');
					}
					fn_transLogViewAjax();
					$('#pop_layer_log_view').modal("show");
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
</script>

<!-- log 팝업 -->
<%@ include file="./../popup/transLogView.jsp" %>
<%@include file="./../../popup/confirmMultiForm.jsp"%>
<%@include file="./../../popup/confirmForm.jsp"%>
		
<form name="transMonitoringForm" id="transMonitoringForm" method="post">
	<input type="hidden" name="db_svr_id" id="db_svr_id" value="${db_svr_id}"/>
	<input type="hidden" name="kc_id" id="kc_id" value=""/>
</form>
		
<form name="transMonConStartForm" id="transMonConStartForm" method="post">
	<input type="hidden" name="sou_db_svr_id" id="sou_db_svr_id" value=""/>
	<input type="hidden" name="sou_trans_exrt_trg_tb_id" id="sou_trans_exrt_trg_tb_id" value=""/>
	<input type="hidden" name="sou_trans_id" id="sou_trans_id" value=""/>

	<input type="hidden" name="tar_db_svr_id" id="tar_db_svr_id" value=""/>
	<input type="hidden" name="tar_trans_exrt_trg_tb_id" id="tar_trans_exrt_trg_tb_id" value=""/>
	<input type="hidden" name="tar_trans_id" id="tar_trans_id" value=""/>
	
	<input type="hidden" name="src_exe_status" id="src_exe_status" value=""/>
	<input type="hidden" name="tar_exe_status" id="tar_exe_status" value=""/>
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
												<i class="fa fa-send"></i>
												<span class="menu-title"><spring:message code="menu.monitoring" /></span>
												<i class="menu-arrow_user" id="titleText" ></i>
											</a>
										</h6>
									</div>
									<div class="col-7">
										 <ol class="mb-0 breadcrumb_main justify-content-end bg-info" >
											 <li class="breadcrumb-item_main" style="font-size: 0.875rem;">
												 <a class="nav-link_title" href="/property.do?db_svr_id=${db_svr_id}" style="padding-right: 0rem;">${db_svr_nm}</a>
											 </li>
											 <li class="breadcrumb-item_main" style="font-size: 0.875rem;" aria-current="page"><spring:message code="menu.data_transfer" /></li>
											<li class="breadcrumb-item_main active" style="font-size: 0.875rem;" aria-current="page"><spring:message code="menu.monitoring" /> </li>
										</ol>
									</div>
								</div>
							</div>
							
							<div id="page_header_sub" class="collapse" role="tabpanel" aria-labelledby="page_header_div" data-parent="#accordion">
								<div class="card-body">
									<div class="row">
										<div class="col-12">
											<p class="mb-0"><spring:message code="eXperDB_CDC.msg43"/></p>
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

		<!-- 실시간 chart start -->
		<!-- cpu chart start -->
		<div class="col-4 div-form-margin-cts stretch-card">
			<div class="card">
				<div class="card-body">
					<h4 class="card-title">
						<i class="item-icon fa fa-dot-circle-o"></i> CPU
					</h4>
					<div id="chart-cpu" style="max-height:200px;"></div>
				</div>
			</div>
		</div>
		<!-- cpu chart end -->
		
		<!-- memory chart start -->
		<div class="col-4 div-form-margin-cts stretch-card">
			<div class="card">
				<div class="card-body">
					<h4 class="card-title">
						<i class="item-icon fa fa-dot-circle-o"></i> memory
					</h4>
					<div id="chart-memory" style="max-height:200px;"></div>
				</div>
			</div>
		</div>
		<!-- memory chart end -->
		
		<!-- error chart start -->
		<div class="col-4 div-form-margin-cts stretch-card">
			<div class="card">
				<div class="card-body">
					<h4 class="card-title">
						<i class="item-icon fa fa-dot-circle-o"></i> error
					</h4>
					<div id="chart-allError" style="max-height:200px;"></div>
				</div>
			</div>
		</div>
		<!-- error chart end -->
		<!-- 실시간 chart end -->
		
		<!-- 연결 상태 그림 start -->
		<div class="col-12 div-form-margin-cts stretch-card">
			<div class="card">
				<div class="card-body">
<!--					 <h4 class="card-title"> -->
<!--						 <i class="item-icon fa fa-dot-circle-o"></i> 연결도 -->
<!--					 </h4> -->
					
					<div class="row" id="reg_trans_title">
						<div class="accordion_main accordion-multi-colored col-4" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;">
								<div class="card-header" role="tab" id="page_ss_server" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<span class="menu-title"><spring:message code="eXperDB_CDC.source_connect"/></span>
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>
											
						<div class="accordion_main col-1" style="border:none;" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;border:none;box-shadow: 0 0 0px black;">
								<div class="card-header" role="tab" id="page_ss_connect_server" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												&nbsp;
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>

						<div class="accordion_main col-2" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;border:none;box-shadow: 0 0 0px black;">
								<div class="card-header" role="tab" id="page_kafka_server" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												&nbsp;
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>

						<div class="accordion_main col-1" style="border:none;" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;border:none;box-shadow: 0 0 0px black;">
								<div class="card-header" role="tab" id="page_sk_connect_server" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												&nbsp;
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>
											
						<div class="accordion_main accordion-multi-colored col-4" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;">
								<div class="card-header" role="tab" id="page_sk_server" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<span class="menu-title"><spring:message code="eXperDB_CDC.sink_connect"/></span>
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				
					<!-- proxy 데이터 있는 경우 -->	
					<div class="row" id="reg_trans_detail">
						<div class="accordion_cdc accordion-multi-colored col-4" id="accordion" role="tablist" >
							<div class="card" style="border:none;" >
								<div class="card-body" style="border:none;min-height: 289px;margin: -20px -20px 0px -20px;" id="proxyMonitoringList">
									<table class="table-borderless" style="width:100%;">
										<tr>
											<td style="width:80%;" class="text-center" ">
												<select class="form-control form-control-xsm mb-2 mr-sm-2 col-sm-12" style="margin-right: 1rem;" name="src_connect" id="src_connect" onChange="fn_srcConnectInfo('change')" onblur="this.value=this.value.trim()" tabindex=1>
													<option value=""><spring:message code="eXperDB_CDC.source_connector"/></option>
													<c:forEach var="srcConnectorList" items="${srcConnectorList}">
														<option value="<c:out value="${srcConnectorList.trans_id}"/>"><c:out value="${srcConnectorList.connect_nm}"/>
													</c:forEach>
												</select>
											</td>
										</tr>
										<tr>
											<td style="width:80%;" class="text-center">
												 <table id="ssconResultTable" class="table table-striped system-tlb-scroll" style="width:100%; border-bottom:1px solid;">
													<thead>
														<tr class="bg-info text-white">
															<th style="width:25%;font-size:12px;"><spring:message code="eXperDB_CDC.table_count"/></th>
															<th style="width:37%;font-size:12px;"><spring:message code="eXperDB_CDC.total_poll_count"/></th>
															<th style="width:38%;font-size:12px;"><spring:message code="eXperDB_CDC.error_count"/></th>
														</tr>
														<tr id="ssconResultCntTableNvl" >
<!--															 <td colspan="3" style="font-size:12px;"> -->
															<td colspan="3">
																 <spring:message code="message.msg228" />
															</td>
														</tr>
														<tr id="ssconResultCntTable" style="display:none;">
															<td style="text-align:center;font-size:12px;" id="table_cnt"></td>
															<td style="text-align:center;font-size:12px;" id="src_total_poll_cnt"></td>
															<td style="text-align:center;font-size:12px;" id="src_total_error_cnt"></td>
														</tr>
													</thead>
												</table>
											</td>
										</tr>
										
										<tr>
											<td style="width:80%;" class="text-center">
												 <table id="ssconDBResultTable" class="table-borderless" style="width:100%; display:none;">
													<tr id="ssconDBResultCntTable">
														<td style="width:100%;">
															
															<table class="table-borderless" style="width:100%;text-align:left;">
																<tr>
																	<td colspan="2" style="width:85%;">
																		<h6 class="mb-0 mb-md-2 mb-xl-0 order-md-1 order-xl-0 text-info" style="padding-top:10px;" id="sourceDbmsNm">
																		</h6>
																	</td>
																	<td rowspan="3" style="width:15%;" id="sourceDbmsImg">
																		<i class="fa fa-database icon-md mb-0 mb-md-3 mb-xl-0 text-success" style="font-size: 3em;"></i>
																	</td>
																</tr>
																
																<tr>
																	<td colspan="2" style="padding-top:5px;">
																		<h6 class="mb-0 mb-md-2 mb-xl-0 order-md-1 order-xl-0 text-muted" style="padding-left:20px;" id="sourceDbmsIp"></h6>
																	</td>
																</tr>

																<tr>
																	<td colspan="2" class="text-center" style="vertical-align: middle;padding-top:5px;">
																		<h6 class="text-muted" style="padding-left:10px;" id="sourceDbmsStatus"></h6>
																	</td>
																</tr>
															</table>
															
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
									
								</div>
							</div>
						</div>

						<div class="accordion_main accordion-multi-colored col-1" id="accordion" role="tablist" >
							<div class="card" style="margin-left:-20px;margin-right:-20px;border:none;box-shadow: 0 0 0px black;" >
								<div class="card-body" style="border:none;min-height: 220px;margin-left:-17px;" id="soureConLineInfo">
								</div>
							</div>
						</div>

						<div class="accordion_cdc_none accordion-multi-colored col-2" id="accordion" role="tablist">
							<div class="card" style="margin-bottom:10px;border:none;" >
								<div class="card-body" style="border:none;min-height: 220px;margin: 20px -35px 0px -35px;" id="kafkaMornitoringInfo">
								
								</div>
							</div>
						</div>

<!-- 						<div class="accordion_cdc accordion-multi-colored col-1" id="accordion" role="tablist" >
							<div class="card" style="margin-left:-20px;margin-right:-20px;border:none;box-shadow: 0 0 0px black;" >
								<div class="card-body" style="border:none;min-height: 220px;margin-left:-17px;" id="proxyListnerConLineList">
								
									<table class="table-borderless" style="width:100%;margin-top:35px;">
										<tr>
											<td style="width:100%;height:100%;" class="text-center" id="123">
												<img src="../images/arrow_side.png" class="img-lg" style="max-width:120%;object-fit: contain;width:120px;height:120px;" alt=""/>
											</td>
										</tr>
									</table>

								</div>
							</div>
						</div> -->
						
						<div class="accordion_main accordion-multi-colored col-1" id="accordion" role="tablist" >
							<div class="card" style="margin-left:-20px;margin-right:-20px;border:none;box-shadow: 0 0 0px black;" >
								<div class="card-body" style="border:none;min-height: 220px;margin-left:-17px;" id="targetConLineInfo">
								</div>
							</div>
						</div>

						<div class="accordion_cdc accordion-multi-colored col-4" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:10px;border:none;" >
								<div class="card-body" style="border:none;min-height: 289px;margin: -20px -20px 0px -20px;" id="dbListenerVipList">

									<table class="table-borderless" style="width:100%;">
										<tr>
											<td style="width:80%;" class="text-center" ">
												<select class="form-control form-control-xsm mb-2 mr-sm-2 col-sm-12" style="margin-right: 1rem;" name="tar_connector_list" id="tar_connector_list" onChange="fn_tarConnectInfo()" onblur="this.value=this.value.trim()"  tabindex=1>
													<option value=""><spring:message code="eXperDB_CDC.sink_connect"/></option> <!--  타겟 connect -->
													<c:forEach var="tarConnectorList" items="${targetConnectorList}">
														<option value="<c:out value="${tarConnectorList.trans_id}"/>"><c:out value="${tarConnectorList.connect_nm}"/>
													</c:forEach>
												</select>
											</td>
										</tr>
										<tr>
											<td style="width:80%;" class="text-center">
												 <table id="tarconResultTable" class="table table-striped system-tlb-scroll" style="width:100%; border-bottom:1px solid;">
													<thead>
														<tr class="bg-info text-white">
															<th style="width:25%;font-size:12px;"><spring:message code="eXperDB_CDC.topic_count"/></th>
															<th style="width:37%;font-size:12px;"><spring:message code="eXperDB_CDC.complet_count"/></th> <!-- 완료 건수 -->
															<th style="width:38%;font-size:12px;"><spring:message code="eXperDB_CDC.error_count"/></th> <!-- 오류 건수 -->
														</tr>
														<tr id="tarconResultCntTableNvl">
															<td colspan="3" >
																<spring:message code="message.msg228" />
															</td>
														</tr>
														<tr id="tarconResultCntTable" style="display:none;">
															<td style="text-align:center;font-size:12px;" id="topic_cnt"></td>
															<td style="text-align:center;font-size:12px;" id="sink_record_send_total"></td>
															<td style="text-align:center;font-size:12px;" id="tar_total_error"></td>
														</tr>
													</thead>
												</table>
											</td>
										</tr>
										
										<tr>
											<td style="width:80%;" class="text-center">
												 <table id="skconResultTable" class="table-borderless" style="width:100%; display:none;">
													<tr id="skconResultCntTable" >
														<td style="width:100%;">
															<table class="table-borderless" style="width:100%;text-align:left;">
																<tr>
																	<td colspan="2" style="width:85%;">
																		<h6 class="mb-0 mb-md-2 mb-xl-0 order-md-1 order-xl-0 text-info" style="padding-top:10px;" id="targetDbmsNm">
																			<!-- <div class="badge badge-pill badge-success" title="">M</div> -->
																			<img src="../images/oracle_icon.png" class="img-sm" style="max-width:120%;object-fit: contain;" alt=""/>
																		</h6>
																	</td>
																	<td rowspan="3" style="width:15%;" id="targetDbmsImg">
																		<i class="fa fa-database icon-md mb-0 mb-md-3 mb-xl-0 text-success" style="font-size: 3em;"></i>
																	</td>
																</tr>
																
																<tr>
																	<td colspan="2" style="padding-top:5px;">
																		<h6 class="mb-0 mb-md-2 mb-xl-0 order-md-1 order-xl-0 text-muted" style="padding-left:20px;" id="targetDbmsIp"></h6>
																	</td>
																</tr>

																<tr>
																	<td colspan="2" class="text-center" style="vertical-align: middle;padding-top:5px;">
																		<h6 class="text-muted" style="padding-left:10px;" id="targetDbmsStatus"></h6>
																	</td>
																</tr>
																
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		<%-- <div class="col-4 div-form-margin-cts stretch-card">
			<div class="card">
				<div class="card-body">
					<!-- title -->
				
					<!-- Connector 기동 정지 이력 -->
					<div class="row">
						<!-- title -->
						<div class="accordion_main accordion-multi-colored col-12" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:0px;">
								<div class="card-header" role="tab" id="page_serverlogging_div" >
									<div class="row" style="height: 15px;">
										<div class="col-12">
											<h6 class="mb-0">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<span class="menu-title"><spring:message code="eXperDB_CDC.con_str_stop_hist"/></span> <!-- Connect 기동정지 이력 -->
											</h6>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="row">
						<!-- connector 기동 정지 이력 리스트 -->
						 <div class="accordion_main accordion-multi-colored col-12" id="accordion" role="tablist" >
							<div class="card" style="margin-bottom:10px;border:none;">
								<div class="card-body" style="border:none;margin-top:-25px;margin-left:-25px;margin-right:-25px;">
									<div class="row">
										<div class="col-sm-8">
											<h6 class="mb-0 alert">
												<span class="menu-title text-success"><i class="mdi mdi-chevron-double-right menu-icon" style="font-size:1.1rem; margin-right:5px;"></i><spring:message code="eXperDB_CDC.msg42"/></span>
											</h6>
										</div>
										<div class="col-sm-4.5">
											<button class="btn btn-outline-primary btn-icon-text btn-sm btn-icon-text" type="button" id="connector_log_btn" onClick="fn_logView('connector')">
												<i class="mdi mdi-file-document"></i>
												<spring:message code="eXperDB_CDC.connect_log"/> <!-- connect 로그 -->
											</button>
										</div>
									</div>
									 <table id="connectorActTable" class="table table-striped system-tlb-scroll" style="width:100%;border:none;">
										<thead>
											<tr class="bg-info text-white">
												<th width="0px;"><spring:message code="common.order"/></th> <!-- 순번 -->
												<th width="100px;"><spring:message code="eXperDB_CDC.connect_name_set" /></th> <!-- connect 명 -->
												<th width="100px;"><spring:message code="eXperDB_proxy.act_result"/></th> <!-- 실행결과 -->
												<th width="100px;"><spring:message code="history_management.time"/></th> <!-- 시간 -->
											</tr>
										</thead>
									</table>
								</div>
							</div>
						</div>
					</div>
					<!-- connector 기동 정지 이력 리스트 end -->
				</div>
			</div>
		</div> --%>
		<!-- 연결 상태 그림 end -->
		
		<!-- 소스 시스템 start -->
		<%@ include file="./transSourceMonitoring.jsp" %>
		<!-- 소스 시스템 end -->
		
		<!-- 타겟 시스템 start -->
		<%@ include file="./transTargetMonitoring.jsp" %>
		<!-- 타겟 시스템 end -->
		
	</div>
</div>