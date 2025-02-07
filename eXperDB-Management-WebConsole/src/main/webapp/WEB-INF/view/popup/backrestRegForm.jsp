<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	/**
	* @Class Name :backrestRegForm.jsp
	* @Description : backrest 백업등록 화면
	* @Modification Information
	*
	*/
%>

<script type="text/javascript">
	var svrBckCheck = 'local';
	var selectedAgentServer = null;
	var backrestServerTable = null;
	var backrestServerTable2 = null;
	var db_info_arr = [];
	var remoteConn = "Fail";
	
	$(window.document).ready(function() {
		
		$("#workRegFormBckr").validate({
	        rules: {
	        	ins_wrk_nm_bckr: {
					required: true
				},
				ins_wrk_exp_bckr: {
					required: true
				}
	        },
	        messages: {
	        	ins_wrk_nm_bckr: {
	        		required: '<spring:message code="message.msg107" />'
				},
				ins_wrk_exp_bckr: {
	        		required: '<spring:message code="message.msg108" />'
				}
	        },
			submitHandler: function(form) { //모든 항목이 통과되면 호출됨 ★showError 와 함께 쓰면 실행하지않는다★
				fn_backrest_insert_work();
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
	});

	function fn_init_backrest_reg_form() {
		backrestServerTable = $('#backrest_svr_info').DataTable({
			scrollY : "140px",
			scrollX: "100%",	
			bSort: false,
			searching : false,
			paging : false,
			deferRender : true,
			destroy: true,
			info: false,
			bScrollCollapse: true,
			columns : [
						{data : "rownum", defaultContent : "", className : "dt-center"}, 
						{data : "master_gbn", className : "dt-center", defaultContent : "",
						render: function(data, type, full, meta){
							if(data == "M"){
								data = '<div class="badge badge-pill badge-success" title="" style="margin-right: 30px;"><b>Primary</b></div>'
							}else if(data == "S"){
								data = '<i class="mdi mdi-subdirectory-arrow-right" style="margin-left: 50px;"><div class="badge badge-pill badge-outline-warning" title="" style="margin-right: 30px"><b>Standby</b></div>'
							}
							return data;
						}},
						{data : "ipadr", defaultContent : "" },
						{data : "portno", defaultContent: "" },
						{data : "svr_spr_usr_id", defaultContent : ""},
						{data : "pgdata_pth", defaultContent : ""},
						{data : "bck_svr_id", defaultContent : "", visible: false }
			],'select': {'style': 'single'}
		});
		
		backrestServerTable.tables().header().to$().find('th:eq(0)').css('min-width', '20px');
		backrestServerTable.tables().header().to$().find('th:eq(1)').css('min-width', '135px');
		backrestServerTable.tables().header().to$().find('th:eq(2)').css('min-width', '135px');
		backrestServerTable.tables().header().to$().find('th:eq(3)').css('min-width', '60px');
		backrestServerTable.tables().header().to$().find('th:eq(4)').css('min-width', '100px');
		backrestServerTable.tables().header().to$().find('th:eq(5)').css('min-width', '250px');
		backrestServerTable.tables().header().to$().find('th:eq(6)').css('min-width', '0px');

		$(window).trigger('resize'); 

	}

	function fn_init_backrest_reg_form2() {
		backrestServerTable2 = $('#backrest_svr_info2').DataTable({
			scrollY : "140px",
			scrollX: "100%",	
			bSort: false,
			searching : false,
			paging : false,
			deferRender : true,
			destroy: true,
			info: false,
			bScrollCollapse: true,
			columns : [
						{data : "rownum", defaultContent : "", className : "dt-center"}, 
						{data : "master_gbn", className : "dt-center", defaultContent : "",
						render: function(data, type, full, meta){
							if(data == "M"){
								if(single_chk){
									data = '<div class="badge badge-pill badge-primary " title=""><b>Single</b></div>'
								}else{
									data = '<div class="badge badge-pill badge-success" title="" style="margin-right: 30px;"><b>Primary</b></div>'
								}
							}else if(data == "S"){
								data = '<i class="mdi mdi-subdirectory-arrow-right" style="margin-left: 50px;"><div class="badge badge-pill badge-outline-warning" title="" style="margin-right: 30px"><b>Standby</b></div>'
							}
							return data;
						}},
						{data : "ipadr", defaultContent : "" },
						{data : "portno", defaultContent: "" },
						{data : "svr_spr_usr_id", defaultContent : ""},
						{data : "pgdata_pth", defaultContent : ""},
						{data : "bck_svr_id", defaultContent : "", visible: false }
			],'select': {'style': 'single'}
		});
		
		backrestServerTable2.tables().header().to$().find('th:eq(0)').css('min-width', '20px');
		backrestServerTable2.tables().header().to$().find('th:eq(1)').css('min-width', '135px');
		backrestServerTable2.tables().header().to$().find('th:eq(2)').css('min-width', '135px');
		backrestServerTable2.tables().header().to$().find('th:eq(3)').css('min-width', '60px');
		backrestServerTable2.tables().header().to$().find('th:eq(4)').css('min-width', '100px');
		backrestServerTable2.tables().header().to$().find('th:eq(5)').css('min-width', '250px');
		backrestServerTable2.tables().header().to$().find('th:eq(6)').css('min-width', '0px');

		$(window).trigger('resize'); 

	}

	$(function() {
		$("#backrest_svr_info2").on('click', 'tbody tr', function(){
			$(this).toggleClass('selected');

			selectedAgentServer = backrestServerTable2.rows(this).data()[0];
			
			var words = this.className.split(' ');

			if($("#remote_radio").is(':checked')){
				$("#ins_bckr_pth", "#workRegFormBckr").val("");
				$("#ins_bckr_log_pth", "#workRegFormBckr").val("");
			}else{
				if(words.length == 2){
					$.ajax({
						url : "/backup/backrestPath.do",
						data : {
							db_svr_id : $("#db_svr_id", "#findList").val(),
							ipadr : selectedAgentServer.ipadr
						},
						dataType : "json",
						type : "post",
						beforeSend: function(xhr) {
							xhr.setRequestHeader("AJAX", true);
						},
						error : function(xhr, status, error) {
							if(xhr.status == 401) {
								showSwalIconRst(message_msg02, closeBtn, '', 'error', 'top');
							} else if(xhr.status == 403) {
								showSwalIconRst(message_msg03, closeBtn, '', 'error', 'top');
							} else {
								showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), closeBtn, '', 'error');
							}
						},
						success : function(data) {	
							if($("#remote_radio").is(':checked')){
								$("#ins_bckr_pth", "#workRegFormBckr").val("");
								$("#ins_bckr_log_pth", "#workRegFormBckr").val("");
							}else{
								$("#ins_bckr_pth", "#workRegFormBckr").val(data.RESULT_DATA.PGBBAK);
								$("#ins_bckr_log_pth", "#workRegFormBckr").val(data.RESULT_DATA.PGBLOG);	
							}	
						}
					});
				}else{
					$("#ins_bckr_pth", "#workRegFormBckr").val("");
					$("#ins_bckr_log_pth", "#workRegFormBckr").val("");
					$("#bckr_standby_alert", "#workRegFormBckr").html("");
					$("#bckr_standby_alert", "#workRegFormBckr").hide();
				}
			}
		});
	})

	function fn_bck_srv_check(svrBckRadioCheck) {
		fn_select_agent_info();
		$('#backrest_svr_info_div2').css('width', "98%");

		var bckSrvLocal = document.getElementById("bck_srv_local_check"); 
		var bckSrvRemote = document.getElementById("bck_srv_remote_check"); 
		var bckSrvCloud = document.getElementById("bck_srv_cloud_check");

		var ins_bak_path_label = document.getElementById("ins_bak_path_label");
		var ins_bckr_pth = document.getElementById("ins_bckr_pth");
		
		if(svrBckCheck !== svrBckRadioCheck){
			fn_bckr_opt_reset();
		}

		svrBckCheck = svrBckRadioCheck;

		if(svrBckRadioCheck == "local"){
			$("#ins_bckr_pth", "#workRegFormBckr").css("width", "410px");
			$("#bck_pth_chk", "#workRegFormBckr").css("display", "none");
			$("#ins_bckr_log_pth", "#workRegFormBckr").css("width", "410px");
			$("#log_pth_chk", "#workRegFormBckr").css("display", "none");
		
			bckSrvLocal.style.backgroundColor = "white"
			bckSrvRemote.style.backgroundColor = "#e7e7e7"
			bckSrvCloud.style.backgroundColor = "#e7e7e7"
			ins_bak_path_label.style.display = ""
			ins_bckr_pth.style.display = ""

			$('#ins_bckr_pth').prop("readonly", true);
			$("#local_radio").prop("checked", true);
			$("#bck_pth_chk").hide();
			$("#log_pth_chk").hide();
			
			$("#remote_opt").hide();
			$("#cloud_opt").hide();

			if(single_chk){
				// $('#backrest_svr_info_div2').css('width', "98%");
				$('#backrest_svr_info_div').css('display', "none");
				$('#ins_bckr_svr_div').css('display', "none");

				$('#backrest_svr_info_div2').css('margin-left', "15px");;

				backrestServerTable2.columns.adjust().draw();
				backrestServerTable.columns(5).visible(true);
				backrestServerTable2.columns(5).visible(true);	
				backrestServerTable2.tables().header().to$().find('th:eq(5)').css('display', '');
			}else{
				$('#backrest_svr_info_div').css('width', "680px");
				$('#backrest_svr_info_div2').css('width', "680px");
				$('#backrest_svr_info_div').css('display', "");

				$('#backrest_svr_info_div2').css('margin-left', "0");

				$('#ins_bckr_svr_div').css('display', "");
				backrestServerTable.tables().header().to$().find('th:eq(5)').css('display', 'none');
				backrestServerTable2.tables().header().to$().find('th:eq(5)').css('display', 'none');
				backrestServerTable.columns(5).visible(false);
				backrestServerTable2.columns(5).visible(false);	
			}

		}else if(svrBckRadioCheck == "remote"){
			$("#ins_bckr_pth", "#workRegFormBckr").val("");
			$("#ins_bckr_log_pth", "#workRegFormBckr").val("");
			$("#ins_bckr_pth", "#workRegFormBckr").css("width", "320px");
			$("#bck_pth_chk", "#workRegFormBckr").css("display", "");
			$("#ins_bckr_log_pth", "#workRegFormBckr").css("width", "320px");
			$("#log_pth_chk", "#workRegFormBckr").css("display", "");
			
			bckSrvLocal.style.backgroundColor = "#e7e7e7"
			bckSrvRemote.style.backgroundColor = "white"
			bckSrvCloud.style.backgroundColor = "#e7e7e7"
			ins_bak_path_label.style.display = ""
			ins_bckr_pth.style.display = ""
			
			$('#ins_bckr_pth').prop("readonly", false);
			$("#remote_radio").prop("checked", true);
			$("#bck_pth_chk").show();
			$("#log_pth_chk").show();

			$("#remote_opt").show();
			$("#cloud_opt").hide();

			// $('#backrest_svr_info_div2').css('width', "98%");
			$('#backrest_svr_info_div').css('display', "none");
			$('#ins_bckr_svr_div').css('display', "none");
			$('#backrest_svr_info_div2').css('margin-left', "15px");

			backrestServerTable.columns(5).visible(true);
			backrestServerTable2.columns(5).visible(true);	
			backrestServerTable2.tables().header().to$().find('th:eq(5)').css('display', '');
			

		}else{
			$("#ins_bckr_pth", "#workRegFormBckr").css("width", "410px");
			$("#bck_pth_chk", "#workRegFormBckr").css("display", "none");
			$("#ins_bckr_log_pth", "#workRegFormBckr").css("width", "410px");
			$("#log_pth_chk", "#workRegFormBckr").css("display", "none");
			
			bckSrvLocal.style.backgroundColor = "#e7e7e7"
			bckSrvRemote.style.backgroundColor = "#e7e7e7"
			bckSrvCloud.style.backgroundColor = "white"
			ins_bak_path_label.style.display = "none"
			ins_bckr_pth.style.display = "none"

			$("#cloud_radio").prop("checked", true);
			$('#ins_bckr_pth').prop("readonly", true);
			$("#bck_pth_chk").hide();
			$("#log_pth_chk").hide();
			
			$("#remote_opt").hide();
			$("#cloud_opt").show();

			// $('#backrest_svr_info_div2').css('width', "98%");
			$('#backrest_svr_info_div').css('display', "none");
			$('#ins_bckr_svr_div').css('display', "none");

			$('#backrest_svr_info_div2').css('margin-left', "15px");

			backrestServerTable.columns(5).visible(true);
			backrestServerTable2.columns(5).visible(true);	

			backrestServerTable2.tables().header().to$().find('th:eq(5)').css('display', '');
			
		}

		backrestServerTable.rows({selected: true}).deselect();
		$("#bckr_standby_alert", "#workRegFormBckr").html("");
		$("#bckr_standby_alert", "#workRegFormBckr").hide();

		$(window).trigger('resize'); 
	}

	/* ********************************************************
	 * work명 중복체크
	 ******************************************************** */
	 function fn_ins_worknm_bckr_check() {
		if ($('#ins_wrk_nm_bckr', '#workRegFormBckr').val() == "") {
			showSwalIcon('<spring:message code="message.msg107" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}
		
		//msg 초기화
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").html('');
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").hide();
		
		$.ajax({
			url : '/backrest_nmCheck.do',
			type : 'post',
			data : {
				backrest_nm : $('#ins_wrk_nm_bckr', '#workRegFormBckr').val()
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
				if (result == "true") {
					showSwalIcon('<spring:message code="backup_management.reg_possible_work_nm" />', '<spring:message code="common.close" />', '', 'success');
					$('#ins_wrk_nmChk_bckr', '#workRegFormBckr').val("success");
				} else {
					showSwalIcon('<spring:message code="backup_management.effective_work_nm" />', '<spring:message code="common.close" />', '', 'error');
					$('#ins_wrk_nmChk_bckr', '#workRegFormBckr').val("fail");
				}
			}
		});
	}

	/* ********************************************************
	 * work 명 변경시
	 ******************************************************** */
	 function fn_ins_wrk_bckr_nmChk() {
		$('#ins_wrk_nmChk_bckr', '#workRegFormBckr').val("fail");
		
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").html('');
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").hide();
	}

	function fn_bckr_opt_reset(){
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").html("");
		$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").hide();

		//백업옵션 초기화
		$("#ins_bckr_opt_cd", "#workRegFormBckr").val('').prop("selected", true);	//백업유형
		$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").hide();
		$("#ins_bckr_pth", "#workRegFormBckr").val("");	//백업경로
		$("#ins_bckr_cnt", "#workRegFormBckr").val(1); //풀백업보관일
		$("#ins_bckr_log_pth", "#workRegFormBckr").val("");	//로그경로

		//압축옵션 초기화
		$("input:checkbox[id='ins_bckr_cps_yn_chk']").prop("checked", true); //압축여부
		$("#ins_cps_opt_type", "#workRegFormBckr").val('gzip').prop("selected", true);	//압축타입
		$("#ins_cps_opt_type", "#workRegFormBckr").attr("disabled",false);
		$("#ins_cps_opt_prcs", "#workRegFormBckr").val(1);

		//Remote 옵션 초기화
		$("#ins_remt_str_ip", "#workRegFormBckr").val("");	//IP
		$("#ins_remt_str_ssh", "#workRegFormBckr").val(""); //SSH Port
		$("#ins_remt_str_usr", "#workRegFormBckr").val("");	//User Name
		$("#ins_remt_str_pw", "#workRegFormBckr").val("");	//Password

		//Cloud 옵션 초기화
		$("#ins_bckr_cld_opt_cd", "#workRegFormBckr").val('S3').prop("selected", true);	//Cloud 유형
		$("#ins_cloud_bckr_s3_buk", "#workRegFormBckr").val("");	//s3-bucket
		$("#ins_cloud_bckr_s3_rgn", "#workRegFormBckr").val(""); 	//s3-region
		$("#ins_cloud_bckr_s3_key", "#workRegFormBckr").val("");	//s3-key
		$("#ins_cloud_bckr_s3_npt", "#workRegFormBckr").val("");	//s3-endpoint
		$("#ins_cloud_bckr_s3_pth", "#workRegFormBckr").val("");	//s3-path
		$("#ins_cloud_bckr_s3_scrk", "#workRegFormBckr").val("");	//s3-key-secret

		//기본옵션 alert창 초기화
		$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").hide();
		$("#ins_bckr_pth_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_pth_alert", "#workRegFormBckr").hide();
		$("#ins_bckr_cnt_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_cnt_alert", "#workRegFormBckr").hide();
		$("#ins_bckr_log_pth_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_log_pth_alert", "#workRegFormBckr").hide();
		$("#ins_cps_opt_prcs_alert", "#workRegFormBckr").html("");
		$("#ins_cps_opt_prcs_alert", "#workRegFormBckr").hide();		

		//Remote 옵션 초기화
		$("#ins_remt_str_ip_alert", "#workRegFormBckr").html("");
		$("#ins_remt_str_ip_alert", "#workRegFormBckr").hide();
		$("#ins_remt_str_ssh_alert", "#workRegFormBckr").html("");
		$("#ins_remt_str_ssh_alert", "#workRegFormBckr").hide();
		$("#ins_remt_str_usr_alert", "#workRegFormBckr").html("");
		$("#ins_remt_str_usr_alert", "#workRegFormBckr").hide();
		$("#ins_remt_str_pw_alert", "#workRegFormBckr").html("");
		$("#ins_remt_str_pw_alert", "#workRegFormBckr").hide();
		$("#ssh_con_alert", "#workRegFormBckr").html("");
		$("#ssh_con_alert", "#workRegFormBckr").hide();
		$("#ins_bckr_pth_alert", "#workRegFormBckr").html("");
		$("#ins_bckr_pth_alert", "#workRegFormBckr").hide();

		//Cloud 옵션 초기화
		$("#ins_cloud_bckr_s3_buk_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_buk_alert", "#workRegFormBckr").hide();
		$("#ins_cloud_bckr_s3_rgn_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_rgn_alert", "#workRegFormBckr").hide();
		$("#ins_cloud_bckr_s3_key_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_key_alert", "#workRegFormBckr").hide();
		$("#ins_cloud_bckr_s3_npt_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_npt_alert", "#workRegFormBckr").hide();
		$("#ins_cloud_bckr_s3_pth_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_pth_alert", "#workRegFormBckr").hide();
		$("#ins_cloud_bckr_s3_scrk_alert", "#workRegFormBckr").html("");
		$("#ins_cloud_bckr_s3_scrk_alert", "#workRegFormBckr").hide();		
		
	}

	//Custom popup
	function fn_reg_custom_popup(){
		$.ajax({
			url : "/popup/backrestRegCustomForm.do",
			data : {
				db_svr_id : $("#db_svr_id", "#findList").val()
			},
			dataType : "json",
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst(message_msg02, closeBtn, '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst(message_msg03, closeBtn, '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), closeBtn, '', 'error');
				}
			},
			success : function(result) {
				
				for(var i=0; i < result['backrest_cus_opt'].length; i++){
					if(result['backrest_cus_opt'][i].opt_gbn == 0 || result['backrest_cus_opt'][i].opt_gbn == 1 ){
						bckr_cst_opt.push(result['backrest_cus_opt'][i]);
					}
				}

				if(custom_map.size == 0){
					fn_deleteCustom();
        		}else{
					if(custom_cancle == true){
						fn_deleteCustom();

						const customKeyList = custom_map.keys();
						var custom_origin_keys = [];

						for (let key of customKeyList) {
							custom_origin_keys.push(key)
						}

						for(var i=0; i < custom_map.size; i++){
							fn_backrest_custom_add(i);

							$("#ins_bckr_cst_opt_" + i).val(custom_origin_keys[i]).attr("selected",true);
							$("#ins_bckr_cst_val_" + i).val(custom_map.get(custom_origin_keys[i]));
						}
					}
				}
	
				$('#pop_layer_reg_backrest_custom').modal("show");
			}
		});
	}

	/* ********************************************************
	 * Validation Check
	 ******************************************************** */
	function ins_backrest_valCheck(){
		var iChkCnt = 0;

		if(!single_chk && svrBckCheck == "local"){
			if($('#backrest_svr_info').DataTable().rows('.selected').data()[0] == undefined){
				showSwalIcon('<spring:message code="message.msg.1" />', '<spring:message code="common.close" />', '', 'warning');

				iChkCnt = iChkCnt + 1;
			}
		}

		if($('#backrest_svr_info2').DataTable().rows('.selected').data()[0] == undefined){
			showSwalIcon('<spring:message code="message.msg.1" />', '<spring:message code="common.close" />', '', 'warning');

			iChkCnt = iChkCnt + 1;
		}

		if(nvlPrmSet($("#ins_wrk_nmChk_bckr", "#workRegFormBckr").val(), "") == "" || nvlPrmSet($("#ins_wrk_nmChk_bckr", "#workRegFormBckr").val(), "") == "fail") {
			$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").html('<spring:message code="backup_management.work_overlap_check"/>');
			$("#ins_wrk_nm_bckr_alert", "#workRegFormBckr").show();
			
			iChkCnt = iChkCnt + 1;
		}

		//기본 옵션 alert
		if(nvlPrmSet($("#ins_bckr_opt_cd", "#workRegFormBckr").val(), "") == "") {
			$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").html('<spring:message code="eXperDB_backup.msg29_1" />');
			$("#ins_bckr_opt_cd_alert", "#workRegFormBckr").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if(nvlPrmSet($("#ins_bckr_cnt", "#workRegFormBckr").val(), "") == "") {
			$("#ins_bckr_cnt_alert", "#workRegFormBckr").html('<spring:message code="backup_management.full_backup_file_maintenance_counts" />');
			$("#ins_bckr_cnt_alert", "#workRegFormBckr").show();
			
			iChkCnt = iChkCnt + 1;
		}

		if(nvlPrmSet($("#ins_cps_opt_prcs", "#workRegFormBckr").val(), "") == "") {
			$("#ins_cps_opt_prcs_alert", "#workRegFormBckr").html('<spring:message code="backup_management.paralles_chk" />');
			$("#ins_cps_opt_prcs_alert", "#workRegFormBckr").show();
			
			iChkCnt = iChkCnt + 1;
		}

		if(nvlPrmSet($("#ins_bckr_log_pth", "#workRegFormBckr").val(), "") == "") {
			$("#ins_bckr_log_pth_alert", "#workRegFormBckr").html('로그경로를 확인해주세요');
			$("#ins_bckr_log_pth_alert", "#workRegFormBckr").show();
		
			iChkCnt = iChkCnt + 1;
		}

		//Remote 옵션 alert
		if(svrBckCheck == "remote"){
			if(nvlPrmSet($("#ins_remt_str_ip", "#workRegFormBckr").val(), "") == "") {
				$("#ins_remt_str_ip_alert", "#workRegFormBckr").html('<spring:message code="message.msg62" />');
				$("#ins_remt_str_ip_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}

			if(nvlPrmSet($("#ins_remt_str_ssh", "#workRegFormBckr").val(), "") == "") {
				$("#ins_remt_str_ssh_alert", "#workRegFormBckr").html('<spring:message code="message.msg83" />');
				$("#ins_remt_str_ssh_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}

			if(nvlPrmSet($("#ins_remt_str_usr", "#workRegFormBckr").val(), "") == "") {
				$("#ins_remt_str_usr_alert", "#workRegFormBckr").html('<spring:message code="properties.os_user.chk" />');
				$("#ins_remt_str_usr_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}

			if(nvlPrmSet($("#ins_remt_str_pw", "#workRegFormBckr").val(), "") == "") {
				$("#ins_remt_str_pw_alert", "#workRegFormBckr").html('<spring:message code="user_management.password.chk" />');
				$("#ins_remt_str_pw_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
			if(remoteConn != "Success"){
				$("#ssh_con_alert", "#workRegFormBckr").html('<spring:message code="eXperDB_CDC.test_connection.chk" />');
				$("#ssh_con_alert", "#workRegFormBckr").show();
				iChkCnt = iChkCnt + 1;
			}
			
			if(!bck_pth_chk){
				$("#ins_bckr_pth_alert", "#workRegFormBckr").html('<spring:message code="properties.backup_path.chk" />');
				$("#ins_bckr_pth_alert", "#workRegFormBckr").show();
				iChkCnt = iChkCnt + 1;
			}
			
			if(!log_pth_chk) {
				$("#ins_bckr_log_pth_alert", "#workRegFormBckr").html('<spring:message code="properties.log_path_chk" />');
				$("#ins_bckr_log_pth_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
			
		}else if(svrBckCheck == "local"){
			if(nvlPrmSet($("#ins_bckr_pth", "#workRegFormBckr").val(), "") == ""){
				$("#ins_bckr_pth_alert", "#workRegFormBckr").html('백업경로를 확인해주세요');
				$("#ins_bckr_pth_alert", "#workRegFormBckr").show();
				iChkCnt = iChkCnt + 1;
			}
		}

		//Cloud 옵션 alert
		if(svrBckCheck == "cloud"){
			if(nvlPrmSet($("#ins_cloud_bckr_s3_buk", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_buk_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.bucket" />');
				$("#ins_cloud_bckr_s3_buk_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
			
			if(nvlPrmSet($("#ins_cloud_bckr_s3_rgn", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_rgn_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.region" />');
				$("#ins_cloud_bckr_s3_rgn_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
			
			if(nvlPrmSet($("#ins_cloud_bckr_s3_key", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_key_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.key" />');
				$("#ins_cloud_bckr_s3_key_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
			
			if(nvlPrmSet($("#ins_cloud_bckr_s3_npt", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_npt_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.endpoint" />');
				$("#ins_cloud_bckr_s3_npt_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}

			if(nvlPrmSet($("#ins_cloud_bckr_s3_pth", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_pth_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.path" />');
				$("#ins_cloud_bckr_s3_pth_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}

			if(nvlPrmSet($("#ins_cloud_bckr_s3_scrk", "#workRegFormBckr").val(), "") == "") {
				$("#ins_cloud_bckr_s3_scrk_alert", "#workRegFormBckr").html('<spring:message code="backup_management.s3.secretkey" />');
				$("#ins_cloud_bckr_s3_scrk_alert", "#workRegFormBckr").show();
				
				iChkCnt = iChkCnt + 1;
			}
		}

		if (iChkCnt > 0) {
			return false;
		}
		
		return true;
	}

	//압축여부에 따라 압축타입 활성화 비활성화
	function ins_backrest_compress_chk(){
		if($('#ins_bckr_cps_yn_chk').is(':checked')){
			$("#ins_cps_opt_type", "#workRegFormBckr").attr("disabled",false);
        }else{
			$("#ins_cps_opt_type", "#workRegFormBckr").attr("disabled",true);
		}
	}

	//alert창 onchange
	function fn_backrest_chg_alert(obj){
		$("#"+obj.id+"_alert", "#workRegFormBckr").html("");
		$("#"+obj.id+"_alert", "#workRegFormBckr").hide();

		console.log(obj)
		
		if($("#remote_radio").is(':checked')){
			if(obj.id == 'ins_bckr_pth') bck_pth_chk = false;
			if(obj.id == 'ins_bckr_log_pth') log_pth_chk = false;
		} 
	}

	function fn_select_agent_info(){
		db_info_arr = [];

		$.ajax({
			url : "/backup/backrestAgentList.do",
			data : {
				db_svr_id : $("#db_svr_id", "#findList").val(),
				ipadr : nvlPrmSet($('#ipadr', '#workRegFormBckr').val(), "")
			},
			dataType : "json",
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst(message_msg02, closeBtn, '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst(message_msg03, closeBtn, '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), closeBtn, '', 'error');
				}
			},
			success : function(data) {
				backrestServerTable.rows({selected: true}).deselect();
				backrestServerTable2.rows({selected: true}).deselect();

				var db_server_data = data['agent_list'];
				backrestServerTable.clear().draw();
				backrestServerTable2.clear().draw();

				// for(var i=0; i < db_server_data.length; i++){
				// 	if(db_server_data[i].master_gbn == "M"){
				// 		db_info_arr.push(db_server_data[i]);
				// 		for(var j=0; j < db_server_data.length; j++){
				// 			if(svrBckCheck == "local"){
				// 				if(db_server_data[j].master_gbn == "S"){
				// 					if(db_server_data[i].db_svr_id == db_server_data[j].db_svr_id){
				// 						db_info_arr.push(db_server_data[j]);
				// 					}
				// 				}
				// 			}else{
				// 				break;
				// 			}		
				// 		}
				// 	}
				// }

				if (nvlPrmSet(data, "") != '') {
					backrestServerTable.rows.add(db_server_data).draw();
					backrestServerTable2.rows.add(db_server_data).draw();
				}
			}
		});
	}

	//PG Backrest Work 등록
	function fn_backrest_insert_work(){
		if (!ins_backrest_valCheck()) return false;

		if($("#ins_bckr_cps_yn_chk", "#workRegFormBckr").is(":checked") == true){
			$("#ins_cps_brkr_yn", "#workRegFormBckr").val("Y");
		} else {
			$("#ins_cps_brkr_yn", "#workRegFormBckr").val("N");
		}

		var cloud_map = new Map();
		var cloud_data = null;
		
		var remote_map = new Map();
		var remote_data = null;

		var selectedBckAgent = null;
		var target_svr_ipadr = "";
		var target_svr_master_gbn = "";
		var target_svr_pgpath = "";
		var target_svr_user = "";
		var target_svr_port = "";
		var bck_target_ipadr_id = "";

		if(svrBckCheck == "cloud"){
			cloud_map.set("s3_bucket", nvlPrmSet($('#ins_cloud_bckr_s3_buk', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("s3_region", nvlPrmSet($('#ins_cloud_bckr_s3_rgn', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("s3_key", nvlPrmSet($('#ins_cloud_bckr_s3_key', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("s3_endpoint", nvlPrmSet($('#ins_cloud_bckr_s3_npt', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("s3_path", nvlPrmSet($('#ins_cloud_bckr_s3_pth', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("s3_key-secret", nvlPrmSet($('#ins_cloud_bckr_s3_scrk', '#workRegFormBckr').val(), "").trim());
			cloud_map.set("cloud_type", $("#ins_bckr_cld_opt_cd", '#workRegFormBckr').val());

			cloud_data = JSON.stringify(Object.fromEntries(cloud_map))
		}else if (svrBckCheck == 'remote'){
			remote_map.set("remote_ip", nvlPrmSet($('#ins_remt_str_ip', '#workRegFormBckr').val(), "").trim());
			remote_map.set("remote_port", nvlPrmSet($('#ins_remt_str_ssh', '#workRegFormBckr').val(), "").trim());
			remote_map.set("remote_usr", nvlPrmSet($('#ins_remt_str_usr', '#workRegFormBckr').val(), "").trim());
			remote_map.set("remote_pw", nvlPrmSet($('#ins_remt_str_pw', '#workRegFormBckr').val(), "").trim());
			
			remote_data = JSON.stringify(Object.fromEntries(remote_map));
		}

		var selectedAgent = $('#backrest_svr_info2').DataTable().rows('.selected').data()[0];
		var custom_data = JSON.stringify(Object.fromEntries(custom_map))

		if(single_chk || svrBckCheck != "local"){
			target_svr_ipadr = selectedAgent.ipadr;
			target_svr_master_gbn = selectedAgent.master_gbn;
			target_svr_pgdata = selectedAgent.pgdata_pth;
			target_svr_user = selectedAgent.svr_spr_usr_id;
			target_svr_port = selectedAgent.portno
			bck_target_ipadr_id = selectedAgent.db_svr_ipadr_id;	
		}else{
			selectedBckAgent = $('#backrest_svr_info').DataTable().rows('.selected').data()[0];

			if(selectedBckAgent != null){
				target_svr_ipadr = selectedBckAgent.ipadr;
				target_svr_master_gbn = selectedBckAgent.master_gbn;
				target_svr_pgdata = selectedBckAgent.pgdata_pth;
				target_svr_user = selectedBckAgent.svr_spr_usr_id;
				target_svr_port = selectedBckAgent.portno
				bck_target_ipadr_id = selectedBckAgent.db_svr_ipadr_id;
			}
		}
		
		$.ajax({
			async : false,
			url : "/popup/workBackrestWrite.do",
			data : {
				db_svr_id : selectedAgent.db_svr_id,
				wrk_nm : nvlPrmSet($('#ins_wrk_nm_bckr', '#workRegFormBckr').val(), "").trim(),
				wrk_exp : nvlPrmSet($('#ins_wrk_exp_bckr', '#workRegFormBckr').val(), ""),
				cps_yn : $("#ins_cps_brkr_yn", "#workRegFormBckr").val(),
				bck_opt_cd : $("#ins_bckr_opt_cd", '#workRegFormBckr').val(),
				bck_mtn_ecnt : $("#ins_bckr_cnt", '#workRegFormBckr').val(),
				db_id : 0,
				bck_bsn_dscd : "TC000205",
				bck_pth : $("#ins_bckr_pth", "#workRegFormBckr").val(),
				log_file_pth : $("#ins_bckr_log_pth", "#workRegFormBckr").val(),
				bck_filenm : ($('#ins_wrk_nm_bckr', '#workRegFormBckr').val()) + ".conf",
				prcs_cnt: $("#ins_cps_opt_prcs", "#workRegFormBckr").val(),
				cps_type: $("#ins_cps_opt_type", "#workRegFormBckr").val(),
				ipadr: selectedAgent.ipadr,
				pgdata_pth: selectedAgent.pgdata_pth,
				portno: selectedAgent.portno,
				svr_spr_usr_id: selectedAgent.svr_spr_usr_id,
				master_gbn: selectedAgent.master_gbn,
				db_svr_ipadr_id: selectedAgent.db_svr_ipadr_id,
				backrest_gbn: svrBckCheck,
				custom_map: custom_data,
				cloud_map: cloud_data,
				remote_map: remote_data,
				target_svr_ipadr: target_svr_ipadr,
				target_svr_master_gbn: target_svr_master_gbn,
				target_svr_pgdata: target_svr_pgdata,
				target_svr_user: target_svr_user,
				target_svr_port: target_svr_port,
				bck_target_ipadr_id: bck_target_ipadr_id
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
				if(data == "F"){ //중복 work명 일경우
					showSwalIcon('<spring:message code="message.msg191" />', '<spring:message code="common.close" />', '', 'error');
					return;
				} else if (data == "I") { 
					showSwalIcon('<spring:message code="backup_management.bckPath_fail" />', '<spring:message code="common.close" />', '', 'error');
					$('#pop_layer_reg_backrest').modal('show');
					return;
				} else if(data == "S"){
					showSwalIcon('<spring:message code="message.msg106" />', '<spring:message code="common.close" />', '', 'success');
					$('#pop_layer_reg_backrest').modal('hide');
					fn_get_backrest_list();
					remoteConn = "Fail";
				}else if (data == "N"){
					showSwalIcon('<spring:message code="message.msg229" />', '<spring:message code="common.close" />', '', 'error');
					$('#pop_layer_reg_backrest').modal('show');
					return;
				}else{
					showSwalIcon('<spring:message code="migration.msg06" />', '<spring:message code="common.close" />', '', 'error');
					$('#pop_layer_reg_backrest').modal('show');
					return;
				}
			}
		});
	}

	function fn_backrest_ip_select_check(){
		var selectedIp = $('#backrest_svr_info2').DataTable().rows('.selected').data()[0]

		if(selectedIp == undefined){
			showSwalIcon('<spring:message code="message.msg.1" />', '<spring:message code="common.close" />', '', 'warning');
		}

		if(!single_chk && svrBckCheck == "local"){
			var selectedIp2 = $('#backrest_svr_info').DataTable().rows('.selected').data()[0]

			if(selectedIp2 == undefined){
				showSwalIcon('<spring:message code="message.msg.1" />', '<spring:message code="common.close" />', '', 'warning');
			}
		}
	}
	
function fn_ssh_connection(){
		var remote_ip = nvlPrmSet($('#ins_remt_str_ip', '#workRegFormBckr').val(), "").trim();
		var remote_port = nvlPrmSet($('#ins_remt_str_ssh', '#workRegFormBckr').val(), "").trim();
		var remote_usr = nvlPrmSet($('#ins_remt_str_usr', '#workRegFormBckr').val(), "").trim();
		var remote_pw = nvlPrmSet($('#ins_remt_str_pw', '#workRegFormBckr').val(), "").trim();
		
		if(remote_ip == "" || remote_port=="" || remote_usr=="" || remote_pw ==""){
			showSwalIcon('<spring:message code="backup_management.storage.chk" />', '<spring:message code="common.close" />', '', 'warning');
			remoteConn = "Fail";
		}else{
			$.ajax({
				url : "/backup/RemoteConn.do",
				data : {
					remote_ip : remote_ip,
					remote_port : remote_port,
					remote_usr : remote_usr,
					remote_pw : remote_pw
				},
				dataType : "json",
				type : "post",
				beforeSend: function(xhr) {
					xhr.setRequestHeader("AJAX", true);
				},
				error : function(xhr, status, error) {
					if(xhr.status == 401) {
						showSwalIconRst(message_msg02, closeBtn, '', 'error', 'top');
					} else if(xhr.status == 403) {
						showSwalIconRst(message_msg03, closeBtn, '', 'error', 'top');
					} else {
						showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), closeBtn, '', 'error');
					}
				},
				success : function(data) {
					if(data == 'success'){
						showSwalIcon('<spring:message code="message.msg93" />', '<spring:message code="common.close" />', '', 'success');
						remoteConn = "Success";
						$("#ssh_con_alert", "#workRegFormBckr").html("");
						$("#ssh_con_alert", "#workRegFormBckr").hide();
						$("#ins_remt_str_ip_alert", "#workRegFormBckr").html("");
						$("#ins_remt_str_ip_alert", "#workRegFormBckr").hide();
						$("#ins_remt_str_ssh_alert", "#workRegFormBckr").html("");
						$("#ins_remt_str_ssh_alert", "#workRegFormBckr").hide();
						$("#ins_remt_str_usr_alert", "#workRegFormBckr").html("");
						$("#ins_remt_str_usr_alert", "#workRegFormBckr").hide();
						$("#ins_remt_str_pw_alert", "#workRegFormBckr").html("");
						$("#ins_remt_str_pw_alert", "#workRegFormBckr").hide();
					}else {
						showSwalIcon('<spring:message code="message.msg92" />', '<spring:message code="common.close" />', '', 'error');
						remoteConn = "Fail";
					}
				}
			})
		}		
	}
	
	function remote_chg_chk(txt){
		remoteConn = "Fail";
	}
	
	function removeKoreanCharacters(input) {
		if (/[\u3131-\u318E\uAC00-\uD7A3]+/.test(input.value)) {
			showSwalIcon('<spring:message code="encrypt_msg.msg22" />', '<spring:message code="common.close" />', '', 'error');	
	    }
		
        input.value = input.value.replace(/[\u3131-\u318E\uAC00-\uD7A3]+/g, '');
    }

</script>

<%@include file="../popup/backrestRegCustomForm.jsp"%>

<form name="search_backrestRegForm" id="search_backrestReForm" method="post">
	<input type="hidden" name="backrest_call_gbn"  id="backrest_call_gbn" value="" />
</form>

<div class="modal fade" id="pop_layer_reg_backrest" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog  modal-xl-top" role="document" style="margin: 10px 110px;">
		<div class="modal-content" style="width:1500px; ">		 	 
			<div class="modal-body" style="margin-bottom:-30px;">
				<h4 class="modal-title mdi mdi-alert-circle text-info" id="ModalLabel" style="padding-left:5px;">
					<spring:message code="dashboard.backrest_backup" />
				</h4>
				
				<div class="card system-tlb-scroll" style="margin-top:10px;border:0px;height:885px;overflow-y:auto;">
					<form class="cmxform" id="workRegFormBckr">
						<input type="hidden" name="ins_check_path3" id="ins_check_path3" value="N"/>
						<input type="hidden" name="ins_wrk_nmChk_bckr" id="ins_wrk_nmChk_bckr" value="fail" />
						<input type="hidden" name="ins_cps_brkr_yn" id="ins_cps_brkr_yn" value="" />

						<br>
							<div class="card-body" style="border: 1px solid #adb5bd;">
								<div class="form-group row div-form-margin-z">
									<label for="ins_wrk_nm_bckr" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
										<i class="item-icon fa fa-dot-circle-o"></i>
										<spring:message code="common.work_name" />
									</label>

									<div class="col-sm-8">
										<input type="text" class="form-control form-control-sm" maxlength="20" id="ins_wrk_nm_bckr" name="ins_wrk_nm_bckr" placeholder="20<spring:message code='message.msg188'/>" onchange="fn_ins_wrk_bckr_nmChk();" onblur="this.value=this.value.trim()" oninput="removeKoreanCharacters(this)" tabindex=1 required />
									</div>

									<div class="col-sm-2">
										<button type="button" class="btn btn-inverse-danger btn-fw" style="width: 115px;" onclick="fn_ins_worknm_bckr_check()"><spring:message code="common.overlap_check" /></button>
									</div>
								</div>

								<div class="form-group row div-form-margin-z">
									<div class="col-sm-2">
									</div>

									<div class="col-sm-10">
										<div class="alert alert-danger" style="margin-top:5px;display:none; width: 1062px;" id="ins_wrk_nm_bckr_alert"></div>
									</div>
								</div>

								<div class="form-group row div-form-margin-z">
									<label for="ins_wrk_exp_bckr" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
										<i class="item-icon fa fa-dot-circle-o"></i>
										<spring:message code="common.work_description" />
									</label>

									<div class="col-sm-10">
										<textarea class="form-control" id="ins_wrk_exp_bckr" name="ins_wrk_exp_bckr" rows="2" maxlength="200" onkeyup="fn_checkWord(this,25)" placeholder="200<spring:message code='message.msg188'/>" required tabindex=2></textarea>
									</div>
								</div>
							</div>
							
							<br/>

							<div class="card-body" style="border: 1px solid #adb5bd;">
								<!-- <div class="form-group row div-form-margin-z"> -->
									<!-- <div class="input-group mb-2 mr-sm-2 col-sm-2">
										<input hidden="hidden" />
										<input type="text" class="form-control" style="margin-right: -0.7rem;" maxlength="25" id="ipadr" name="ipadr" onblur="this.value=this.value.trim()" placeholder='<spring:message code="message.msg62" />' />
									</div>

									<button type="button" class="btn btn-inverse-primary btn-icon-text mb-2 btn-search-disable" onclick="fn_select_agent_info()">
										<i class="ti-search btn-icon-prepend "></i><spring:message code="common.search" />
									</button> -->

									<!-- <div class="col-sm-4">
										<div class="alert alert-info " style="display:none; width: 300px; margin-bottom: 0px;" id="bckr_standby_alert" ></div>
									</div> -->
								<!-- </div> -->
								
								<div class="form-group row div-form-margin-z">
									<div id="ins_bckr_tar_svr_div" style="width:50%;">
										<label for="ins_bckr_tar_svr" class="col-sm-6 col-form-label pop-label-index">
											<i class="item-icon fa fa-dot-circle-o"></i>
											백업대상서버
										</label>
									</div>

									<div id="ins_bckr_svr_div" style="width:50%;">
										<label for="ins_bckr_svr" class="col-sm-2 col-form-label pop-label-index">
											<i class="item-icon fa fa-dot-circle-o"></i>
											백업서버
										</label>
									</div>
								</div>
								
								<div class="form-group row div-form-margin-z">
									<div id="backrest_svr_info_div" style="margin-right: 30px; margin-left: 15px;" >
										<div class="table-responsive">
									   		<div id="order-listing_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
										   		<div class="row">
											   		<div class="col-sm-12 col-md-6">
												   		<div class="dataTables_length" id="order-listing_length">
												   		</div>
											   		</div>
										   		</div>
									   		</div>
								   		</div>
										
								   		<table id="backrest_svr_info" class="table table-hover table-striped system-tlb-scroll" style="width:100%;">
											<thead>
												<tr class="bg-info text-white">
													<th width="20" class="dt-center"><spring:message code="common.no" /></th>
													<th width="135" class="dt-center"><spring:message code="data_transfer.type" /></th>
													<th width="135">IP</th>
													<th width="60">PORT</th>
													<th width="100">USER</th>
													<th width="250">DATA_PATH</th>
													<th width="0"></th>
												</tr>
											</thead>
										</table>
									</div>

									<div id="backrest_svr_info_div2" >
										<div class="table-responsive">
									   		<div id="order-listing_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
										   		<div class="row">
											   		<div class="col-sm-12 col-md-6">
												   		<div class="dataTables_length" id="order-listing_length">
												   		</div>
											   		</div>
										   		</div>
									   		</div>
								   		</div>
										
								   		<table id="backrest_svr_info2" class="table table-hover table-striped system-tlb-scroll" style="width:100%;">
											<thead>
												<tr class="bg-info text-white">
													<th width="20" class="dt-center"><spring:message code="common.no" /></th>
													<th width="135" class="dt-center"><spring:message code="data_transfer.type" /></th>
													<th width="135">IP</th>
													<th width="60">PORT</th>
													<th width="100">USER</th>
													<th width="250">DATA_PATH</th>
													<th width="0"></th>
												</tr>
											</thead>
										</table>
									</div>

									<div class="col-sm-0_5" style="display:none;" id="center_div" >
										<div class="card" style="background-color: transparent !important;border:0px;top:30%;position: inline-block;">
											<div class="card-body" style="" onclick="fn_schedule_leftListSize();">	
												<i class='fa fa-angle-double-right text-info' style="font-size: 35px;cursor:pointer;"></i>
											</div>
										</div>
									</div>
								</div>
							</div>

							</br>
							
							<div style="border: 1px solid #adb5bd;">
								<div class="card-body">
									<div class="form-group row div-form-margin-z">
										<div class="col-12" style="background-color: #e7e7e7; height: 50px;">
											<div id="bck_srv_local_check" style="background-color:white; width: 120px; padding-left: 5px; height: 40px; margin-top: 10px; border-radius: 0.4em; float: left;" onclick="fn_bck_srv_check('local')">
												<input type="radio" class="form-control" style="width: 20px; margin-left: 10px;" id="local_radio" name="bck_srv" checked/>
												<label style="margin: -48px 0 0 35px;" class="col-form-label pop-label-index">
													LOCAL
												</label>
											</div>

											<div id="bck_srv_remote_check" style="background-color: #e7e7e7; width: 130px; padding-left: 5px; height: 40px; margin: 10px 0 0 25px; border-radius: 0.4em; float: left;" onclick="fn_bck_srv_check('remote')">
												<input type="radio" class="form-control" style="width: 20px; margin-left: 10px;" id="remote_radio" name="bck_srv"/>
												<label style="margin: -48px 0 0 35px;" class="col-form-label pop-label-index">
													REMOTE
												</label>
											</div>

											<div id="bck_srv_cloud_check" style="background-color: #e7e7e7; width: 120px; padding-left: 5px; height: 40px; margin: 10px 0 0 30px; border-radius: 0.4em; float: left;" onclick="fn_bck_srv_check('cloud')">
												<input type="radio" class="form-control" style="width: 20px; margin-left: 10px;" id="cloud_radio" name="bck_srv"/>
												<label style="margin: -48px 0 0 35px;" class="col-form-label pop-label-index">
													CLOUD
												</label>
											</div>

											<div style="margin-top: 3px; float: right;">
												<input class="btn btn-primary" width="200px;" style="vertical-align:middle;" type="button" value='CUSTOM' onclick="fn_reg_custom_popup()" />
											</div>
										</div>
									</div>
								</div>

								<div>
									<div id="remote_opt" style="display: none;" >
										<div style="border: 1px solid #adb5bd; margin: -10px 10px 10px 10px;">
											<div style="padding-top:7px;">
												<label for="ins_remt_opt_cd" class="col-sm-2_2 col-form-label pop-label-index" >
													<i class="item-icon fa fa-dot-circle-o"></i>
													<spring:message code="backup_management.storage.option" />
												</label>

												<div class="d-flex" style="margin-bottom: 20px;">
													<div class="col-sm-2_3">
														<input type="text" class="form-control form-control-xsm" maxlength="50" id="ins_remt_str_ip" name="ins_remt_str_ip" style="width: 250px;" placeholder="<spring:message code='message.msg62' />" onchange="remote_chg_chk(this)" onclick="fn_backrest_ip_select_check()"/>
													</div>

													<div class="col-sm-2" style="margin-left: 6px;">
														<input type="text" class="form-control form-control-xsm" maxlength="3" id="ins_remt_str_ssh" name="ins_remt_str_ssh" style="width: 180px;" placeholder="<spring:message code='backup_management.remote.port' />" onchange="remote_chg_chk(this)" onclick="fn_backrest_ip_select_check()"/>
													</div>

													<div class="col-sm-2_3" style="margin-left: -30px;">
														<input type="text" class="form-control form-control-xsm" maxlength="50" id="ins_remt_str_usr" name="ins_remt_str_usr" style="width: 250px;" placeholder="<spring:message code='encrypt_policy_management.OS_User' />" onchange="remote_chg_chk(this)" onclick="fn_backrest_ip_select_check()"/>
													</div>
													
													<div class="col-sm-2_3" style="margin-left: 6px;">
														<input type="password" class="form-control form-control-xsm" maxlength="50" id="ins_remt_str_pw" name="ins_remt_str_pw" style="width: 250px;" placeholder="<spring:message code='migration.msg20' />" onchange="remote_chg_chk(this)" onclick="fn_backrest_ip_select_check()"/>
													</div>

													<div class="col-sm-1" style="height: 20px; margin-top: 3px;">
														<button id="ssh_conn" type="button" class="btn btn-outline-primary" style="width: 60px;padding: 5px;" onclick="fn_ssh_connection()">연결</button>
													</div>
													<div class="col-sm-2_3" style="margin-top: -5px;">
														<div class="alert alert-danger" style="display:none; width: 250px; margin-left: -25px;" id="ssh_con_alert"></div>
													</div>
												</div>

												<!-- Remote 옵션 alert창 -->
												<div class="d-flex div-form-margin-z" style="width: 900px; margin-top: -15px;">
													<div class="col-sm-4">
														<div class="alert alert-danger" style="display:none; width: 250px;" id="ins_remt_str_ip_alert"></div>
													</div>
													<div class="col-sm-2_5">
														<div class="alert alert-danger" style="display:none; width: 180px; margin-left: -25px;" id="ins_remt_str_ssh_alert"></div>
													</div>
													<div class="col-sm-4">
														<div class="alert alert-danger" style="display:none; width: 250px; margin-left: -15px;" id="ins_remt_str_usr_alert"></div>
													</div>
													<div class="col-sm-4">
														<div class="alert alert-danger" style="display:none; width: 250px; margin-left: -40px;" id="ins_remt_str_pw_alert"></div>
													</div>
												</div>
											</div>
										</div>
									</div>

									<div id="cloud_opt" style="display: none;">
										<div style="border: 1px solid #adb5bd; margin: -10px 10px 10px 10px;">
											<div class="d-flex" style="padding-top:7px; ">
												<label for="ins_cld_opt_cd" class="col-sm-1_5 col-form-label pop-label-index" >
													<i class="item-icon fa fa-dot-circle-o"></i>
													<spring:message code="backup_management.cloud.type" /> 
												</label>

												<div class="col-sm-2_2" style="margin-top: 5px;">
													<select class="form-control form-control-xsm" style="width:120px; color: black;" name="ins_bckr_cld_opt_cd" id="ins_bckr_cld_opt_cd" tabindex=3>
														<option selected>S3</option>
														<option disabled>Azure</option>
														<option disabled>GCS</option>
													</select>
												</div>
											</div>

											<div class="d-flex">
												<label for="ins_cloud_opt_s3_buk" class="col-sm-1_5 col-form-label pop-label-index" style="padding-top:7px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													s3-bucket
												</label>

												<div class="col-sm-3">
													<input type="text" class="form-control form-control-xsm" maxlength="120" id="ins_cloud_bckr_s3_buk" name="ins_cloud_bckr_s3_buk" style="width: 270px;" placeholder="<spring:message code='backup_management.s3.bucket' />" onchange="fn_backrest_chg_alert(this)"/>
												</div>

												<label for="ins_cloud_opt_s3_rgn" class="col-sm-1 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
													s3-region
												</label>

												<div class="col-sm-2_8">
													<input type="text" class="form-control form-control-xsm" maxlength="100" id="ins_cloud_bckr_s3_rgn" name="ins_cloud_bckr_s3_rgn" style="width: 240px;" placeholder="<spring:message code='backup_management.s3.region' />" onchange="fn_backrest_chg_alert(this)"/>
												</div>

												<label for="ins_cloud_opt_s3_key" class="col-sm-1_5 col-form-label pop-label-index" style="padding-top:7px; ">
														<i class="item-icon fa fa-dot-circle-o"></i>
													s3-key
												</label>

												<div class="col-sm-2">
													<input type="password" class="form-control form-control-xsm" maxlength="50" id="ins_cloud_bckr_s3_key" name="ins_cloud_bckr_s3_key" style="width: 220px;" placeholder="<spring:message code='backup_management.s3.key'/>" onchange="fn_backrest_chg_alert(this)"/>
												</div>
											</div>

											<!-- Cloud 옵션 alert창 -->
											<div class="form-group d-flex div-form-margin-z" style="width: 1200px;">
												<div class="col-sm-5">
													<div class="alert alert-danger" style="display:none; width: 430px;" id="ins_cloud_bckr_s3_buk_alert"></div>
												</div>
												
												<div class="col-sm-5">
													<div class="alert alert-danger" style="display:none; width: 355px; margin-left: 15px;" id="ins_cloud_bckr_s3_rgn_alert"></div>
												</div>

												<div class="col-sm-3_5">
													<div class="alert alert-danger" style="display:none; width: 380px; margin-left: -15px;" id="ins_cloud_bckr_s3_key_alert"></div>
												</div>
											</div>

											<div class="d-flex" style="margin-bottom: 10px;">
												<label for="ins_cloud_opt_s3_npt" class="col-sm-1_5 col-form-label pop-label-index" style="padding-top:7px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													s3-endpoint
												</label>

												<div class="col-sm-3">
													<input type="text" class="form-control form-control-xsm" maxlength="120" id="ins_cloud_bckr_s3_npt" name="ins_cloud_bckr_s3_npt" style="width: 270px;" placeholder="<spring:message code='backup_management.s3.endpoint' />" onchange="fn_backrest_chg_alert(this)"/>
												</div>

												<label for="ins_cloud_opt_s3_pth" class="col-sm-1 col-form-label pop-label-index" style="padding-top:7px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													s3-path
												</label>

												<div class="col-sm-2_8">
													<input type="text" class="form-control form-control-xsm" maxlength="100" id="ins_cloud_bckr_s3_pth" name="ins_cloud_bckr_s3_pth" style="width: 240px;" placeholder="<spring:message code='backup_management.s3.path' />" onchange="fn_backrest_chg_alert(this)"/>
												</div>

												<label for="ins_cloud_opt_s3_scrk" class="col-sm-1_5 col-form-label pop-label-index" style="padding-top:7px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													s3-key-secret
												</label>

												<div class="col-sm-2">
													<input type="password" class="form-control form-control-xsm" maxlength="100" id="ins_cloud_bckr_s3_scrk" name="ins_cloud_bckr_s3_scrk" style="width: 220px;" placeholder="<spring:message code='backup_management.s3.secretkey' /> onchange="fn_backrest_chg_alert(this)"/>
												</div>
											</div>

											<!-- Cloud 옵션 alert창 -->
											<div class="form-group d-flex div-form-margin-z" style="width: 1200px;">
												<div class="col-sm-5">
													<div class="alert alert-danger" style="display:none; width: 430px;" id="ins_cloud_bckr_s3_npt_alert"></div>
												</div>

												<div class="col-sm-5">
													<div class="alert alert-danger" style="display:none; width: 355px; margin-left: 15px;" id="ins_cloud_bckr_s3_pth_alert"></div>
												</div>

												<div class="col-sm-3_5">
													<div class="alert alert-danger" style="display:none; width: 380px; margin-left: -15px;" id="ins_cloud_bckr_s3_scrk_alert"></div>
												</div>
											</div>
										</div>
									</div>

									<div class="d-flex">
										<div class="card-body card-inverse-primary" style="padding:10px 0 10px 0px; width: 900px; margin-left: 10px;">
											<p class="card-text text-xl-center"><spring:message code="backup_management.backup_option" /></p>
										</div>

										<div class="card-body card-inverse-primary" style="padding:10px 0 10px 0px; width: 500px; margin: 0 10px 0 60px;">
											<p class="card-text text-xl-center"><spring:message code="etc.etc45" /></p>
										</div>
									</div>

									<div class="d-flex">
										<div class="d-flex" style="width: 900px; margin: 20px 10px 0 10px;">
											<!-- 왼쪽 메뉴 -->
											<label for="ins_bckr_opt_cd" class="col-sm-2_3 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="backup_management.bck_type" />
											</label>

											<div class="col-sm-2_2">
												<select class="form-control form-control-xsm" style="width:120px; color: black;" name="ins_bckr_opt_cd" id="ins_bckr_opt_cd" tabindex=3 onchange="fn_backrest_chg_alert(this)" onclick="fn_backrest_ip_select_check()">
													<option value=""><spring:message code="common.choice" /></option>
													<option value="TC000301">FULL</option>
													<option value="TC000302">INCR</option>
													<option value="TC000304">DIFF</option>
												</select>
											</div>

											<label id="ins_bak_path_label" for="ins_bckr_opt_path" class="col-sm-1_8 col-form-label pop-label-index" style="padding-top:7px; margin-left: 30px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="properties.backup_path" />
											</label>

											<div class="col-sm-4">
												<input type="text" class="form-control form-control-xsm" maxlength="100" id="ins_bckr_pth" name="ins_bckr_pth" style="width: 410px;" onclick="fn_backrest_ip_select_check()" onchange="fn_backrest_chg_alert(this)"; readonly/>
											</div>

											<div class="col-sm-1" style="margin-top: -2px;">
												<button type="button" id="bck_pth_chk" class="btn btn-inverse-info btn-fw" style="width: 80px; padding: 10px; margin-left: 35px; display:none;" onclick="fn_chk_pth(this)" ><spring:message code="common.dir_check" /></button>
											</div> 
										</div>

										<div class="d-flex" style="width: 500px; margin: 20px 0 0 30px;">
											<!-- 오른쪽 메뉴 -->
											<label for="ins_bckr_cps_yn" class="col-sm-3 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="etc.etc22" />
											</label>

											<div class="col-sm-1_5">
												<div class="onoffswitch-pop" >
													<input type="checkbox" name="ins_bckr_cps_yn_chk" class="onoffswitch-pop-checkbox" id="ins_bckr_cps_yn_chk" checked onchange="ins_backrest_compress_chk()" onclick="fn_backrest_ip_select_check()"/>
													<label class="onoffswitch-pop-label" for="ins_bckr_cps_yn_chk">
														<span class="onoffswitch-pop-inner_YN"></span>
														<span class="onoffswitch-pop-switch" ></span>
													</label>
												</div>
											</div>
										</div>
									</div>

									<!-- 기본옵션 alert창 -->
									<div class="form-group d-flex div-form-margin-z" style="width: 900px; margin: 0px 10px 0px 10px;">
										<div class="col-sm-4">
											<div class="alert alert-danger" style="display:none;" id="ins_bckr_opt_cd_alert"></div>
										</div>
										<div class="col-sm-7" style="margin-left: 40px;">
											<div class="alert alert-danger" style="display:none;" id="ins_bckr_pth_alert"></div>
										</div>
									</div>


									<div class="d-flex">
										<div class="d-flex" style="width: 900px; margin: 0px 10px 10px 10px;">
											<!-- 왼쪽 메뉴 -->
											<label for="ins_bckr_opt_cnt" class="col-sm-2_3 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="backup_management.full_backup_file_maintenance_counts" />
											</label>

											<div class="col-sm-2_2">
												<input type="number" class="form-control form-control-xsm" maxlength="100" id="ins_bckr_cnt" name="ins_bckr_cnt" value="1" min="1" style="width: 120px;" onchange="fn_backrest_chg_alert(this)" onclick="fn_backrest_ip_select_check()"/>
											</div>

											<div id="ins_log_path_label">
												<label for="ins_bckr_opt_log_path" class="col-sm-1_8 col-form-label pop-label-index" style="padding-top:7px; margin-left: 30px;">
													<i class="item-icon fa fa-dot-circle-o"></i>
													<spring:message code="properties.log_path" />
												</label>
											</div>

											<div class="col-sm-4">
												<input type="text" class="form-control form-control-xsm" maxlength="100" id="ins_bckr_log_pth" name="ins_bckr_log_pth" style="width: 410px;" onchange="fn_backrest_chg_alert(this)" onclick="fn_backrest_ip_select_check()"/>
											</div>

											<div class="col-sm-1" style="margin-top: -2px;">
												<button type="button" id="log_pth_chk" class="btn btn-inverse-info btn-fw" style="width: 80px; padding: 10px; margin-left: 35px; display:none;" onclick="fn_chk_pth(this)"><spring:message code="common.dir_check" /></button>
											</div> 
										</div>

										<div class="d-flex" style="width: 500px; margin: 0px 0px 0 30px;">
											<!-- 오른쪽 메뉴 -->
											<label for="ins_bckr_cps_type" class="col-sm-3 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="eXperDB_CDC.compression_type" />
											</label>

											<div class="col-sm-3">
												<select class="form-control form-control-xsm" style="width:80px; color: black;" name="ins_cps_opt_type" id="ins_cps_opt_type" tabindex=1 onclick="fn_backrest_ip_select_check()">
													<option selected>gzip</option>
													<option>lz4</option>>
												</select>
											</div>

											<label for="ins_bckr_prcs" class="col-sm-1_8 col-form-label pop-label-index" style="padding-top:7px; margin-left: 22px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="backup_management.paralles" />
											</label>

											<div class="col-sm-2">
												<input type="number" class="form-control form-control-xsm" maxlength="3" id="ins_cps_opt_prcs" name="ins_cps_opt_prcs" value="1" min="1" style="width: 100px; margin-left: 10px;" onchange="fn_backrest_chg_alert(this)" onclick="fn_backrest_ip_select_check()"/>
											</div>
										</div>
									</div>
								</div>

								<!-- 기본옵션 alert창 -->
								<div class="d-flex" style="width: 900px; margin: 0px 10px 0px 10px;">
									<div class="col-sm-4">
										<div class="alert alert-danger" style="display:none;" id="ins_bckr_cnt_alert"></div>
									</div>
									<div class="col-sm-7" style="margin-left: 40px;">
										<div class="alert alert-danger" style="display:none;" id="ins_bckr_log_pth_alert"></div>
									</div>
									<div class="col-sm-4">
									</div>
									<div class="col-sm-3" style="margin-left: 25px;">
										<div class="alert alert-danger" style="display:none; width: 190px;" id="ins_cps_opt_prcs_alert"></div>
									</div>
								</div>
							</div>

							<div class="card-body">
								<div class="top-modal-footer" style="text-align: center !important; margin: -20px 0 -30px -20px" >
									<input class="btn btn-primary" width="200px;" style="vertical-align:middle;" type="submit" value='<spring:message code="common.registory" />' />
									<button type="button" class="btn btn-light" data-dismiss="modal"><spring:message code="common.cancel"/></button>
								</div>
							</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>