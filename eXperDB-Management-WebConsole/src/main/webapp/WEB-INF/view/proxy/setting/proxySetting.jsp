<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@include file="../../cmmn/cs2.jsp"%>

<%
	/**
	* @Class Name : proxySetting.jsp
	* @Description : proxy 설정 관리  화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2021.02.22     최초 생성
	*
	* author 김민정 책임
	* since 2021.02.22
	*
	*/
%>
<script>

	var proxyServerTable = null; //Proxy Server Table
	var vipInstTable = null; //VIP Instance Table
	var proxyListenTable = null; //Proxy Listener Table
	
	var selPrySvrId = null; //ProxyServerTable에서 선택된 항목의 pry_svr_id
	var selConfInfo = null; //vipInstTable에서 선택된 항목의 Data
	var selListenerInfo = null;//proxyListenTable에서 선택된 항목의 Data
	
	var selPrySvrRow = null; //선택한 proxy 서버 목록
	
	var delVipInstRows = new Array();//삭제한 vip instance 정보
	var delListenerRows = new Array();//삭제한 Listener 정보
	var delListnerSvrRows = new Array();//삭제한 Listener Server List 정보
	
	var unregSvrInfo  = null;//미등록된 서버 정보 list
	
	var selGlobalInfo = null; //선택하여 불러온 global 정보
    var selVipInstanceList = null; //선택하여 불러온 vip instance 정보
    var selProxyListenerList = null; // proxy listener 정보
    var selVipInstancePeerList = null; //선택하여 불러온 vip instance Peer 정보
    var selProxyListenerPeerList = null; // proxy listener Peer 정보
	var selAgentConnect = null;//선택한 서버의  Agent 연결 여부 
	var selAgentInterface = new Array();//선택한 서버의  Agent 연결 여부 
    
	function fn_init() {
		proxyServerTable = $('#proxyServer').DataTable({
			scrollY : "330px",
			scrollX: true,	
			bDestroy: true,
			paging : true,
			processing : true,
			searching : false,	
			deferRender : true,
			bSort: false,
			columns : [ 
			            {data : "rownum", className : "dt-center", defaultContent : "", orderable : false,},
			            {data : "status", defaultContent : "",
			            	render: function (data, type, full){
			            		var html = "";
								//TC001501 실행
								//TC001501 중지
								html += '<div class="onoffswitch">';
								if (!(full.exe_status == "TC001502" || full.kal_exe_status == "TC001502")) {
									html += '<input type="checkbox" class="onoffswitch-checkbox" id="pry_svr_activeYn'+ full.pry_svr_id +'" onclick="fn_prySvrActivation_click()" checked>';
								}else{ 
									html += '<input type="checkbox" class="onoffswitch-checkbox" id="pry_svr_activeYn'+ full.pry_svr_id +'" onclick="fn_prySvrActivation_click()">';
								}
								html += '<label class="onoffswitch-label" for="pry_svr_activeYn'+ full.pry_svr_id +'">';
								html += '<span class="onoffswitch-inner"></span>';
								html += '<span class="onoffswitch-switch"></span></label>';
								html += '</div>';

								return html;
							},
			            className : "dt-center"
			            },//마스터 구분
			            {data : "pry_svr_nm", defaultContent : ""}, //서버명
			            {data : "ipadr", defaultContent : ""},//서버 IP
			            {data : "use_yn",
		            	render: function (data, type, full){
							var html = "";
							if (full.use_yn == "Y") {
								html += "<div class='badge badge-pill badge-info' style='color: #fff;margin-top:-5px;margin-bottom:-5px;'>";
								html += "<i class='fa fa-spin fa-spinner mr-2'></i>";
								html += "<spring:message code='dbms_information.use' />";
								html += "</div>";
							} else {
								html += "<div class='badge badge-pill badge-danger' style='margin-top:-5px;margin-bottom:-5px;'>";
								html += "<i class='fa fa-times-circle mr-2'></i>";
								html += "<spring:message code='dbms_information.unuse' />";
								html += "</div>";
							}
							return html;
							},
						className : "dt-center",
						defaultContent : "" 	
						, visible: false},//서버 사용여부
			            {data : "pry_pth", defaultContent : "", visible: false},//haproxy 파일 경로
			            {data : "kal_pth", defaultContent : "", visible: false},//keepalived 파일 경로
			            {data : "master_gbn", defaultContent : "",
			            	render: function (data, type, full){
			            		var html = "";
								if (full.master_gbn == "M") {
									html += "<div class='badge badge-pill badge-mb'>Master</div>";
								} else {
									html += "<div class='badge badge-pill badge-mb-reverse'>Backup</div>";
								}
								return html;
							},
			            className : "dt-center"
			            },//마스터 구분
			            {data : "master_svr_id", defaultContent : "", visible: false},//마스터 Server ID
						{data : "day_data_del_term", defaultContent : "", visible: false},//일별 데이터 삭제 기간
			            {data : "min_data_del_term", defaultContent : "", visible: false},//분별 데이터 삭제 기간
			            {data : "lst_mdfr_id", defaultContent : "", visible: false},//최종 수정자
			            {data : "lst_mdf_dtm", defaultContent : "", visible: false},//최종 수정일
			            {data : "agt_sn", defaultContent : "", visible: false},//agent 일련번호
			            {data : "pry_svr_id", defaultContent : "", visible: false},//서버 ID
			            {data : "exe_status", className : "dt-center",defaultContent : "", visible: false },//서버 상태
						{data : "kal_exe_status", className : "dt-center", defaultContent : "", visible: false }//keepalived 상태
				]
		});
        proxyServerTable.tables().header().to$().find('th:eq(0)').css('min-width', '40px');//checkbox
		proxyServerTable.tables().header().to$().find('th:eq(1)').css('min-width', '60px');//활성화
		proxyServerTable.tables().header().to$().find('th:eq(2)').css('min-width', '100px');//서버명
		proxyServerTable.tables().header().to$().find('th:eq(3)').css('min-width', '100px');//ip
		proxyServerTable.tables().header().to$().find('th:eq(4)').css('min-width', '60px');//사용여부
		proxyServerTable.tables().header().to$().find('th:eq(5)').css('min-width', '0px');//haproxy 파일 경로
		proxyServerTable.tables().header().to$().find('th:eq(6)').css('min-width', '0px');//keepalived 파일 경로
		proxyServerTable.tables().header().to$().find('th:eq(7)').css('min-width', '0px');//마스커 구분
		proxyServerTable.tables().header().to$().find('th:eq(8)').css('min-width', '0px');//마스터 server id 
		proxyServerTable.tables().header().to$().find('th:eq(9)').css('min-width', '0px');//일별데이터삭제기간
		proxyServerTable.tables().header().to$().find('th:eq(10)').css('min-width', '0px');//분별데이터삭제기간
		proxyServerTable.tables().header().to$().find('th:eq(11)').css('min-width', '0px');//최종 수정자
		proxyServerTable.tables().header().to$().find('th:eq(12)').css('min-width', '0px');//최종 수정일
		proxyServerTable.tables().header().to$().find('th:eq(13)').css('min-width', '0px');//agent 일련번호
		proxyServerTable.tables().header().to$().find('th:eq(14)').css('min-width', '0px');//서버 ID
		proxyServerTable.tables().header().to$().find('th:eq(15)').css('min-width', '0px');//EXE_STATUS
		proxyServerTable.tables().header().to$().find('th:eq(16)').css('min-width', '0px');//kal_EXE_STATUS
		
		$('#proxyServer tbody').on('dblclick','tr',function() {
			if (!$(this).hasClass('selected')){	        	
				proxyServerTable.$('tr.selected').removeClass('selected');
	           	$(this).addClass('selected');	    
			}
			fn_proxy_update('mod');
		});
		
		$('#proxyServer tbody').on('click','tr',function() {
			
			if($('#modYn').val()!= "N"){
				//수정 사항이 있으면 확인 창 - 서버에 적용되지 않은 수정된 정보가 있습니다. 수정 전으로 초기화되는 데 계속 진행하시겠습니까?
				selPrySvrRow = this;
				fn_multiConfirmModal("click_svr_list");
				
			}else{
				selPrySvrRow = this;
				click_serverList_row(this);
			}
		});
		
		
		
		vipInstTable = $('#vipInstance').DataTable({
			scrollY : "100px",
			scrollX: true,	
			searching : false,
			paging : false,
			deferRender : true,
			bSort: false,
			columns : [ 
			            {data : "state_nm", className : "dt-center", defaultContent : ""}, //State
			            {data : "v_ip", className : "dt-center", defaultContent : ""},//가상 IP
			            {data : "v_rot_id", className : "dt-center", defaultContent : ""},//가상 라우터 id
			            {data : "v_if_nm", className : "dt-center", defaultContent : ""},//가상 인터페이스 명
			            {data : "priority", className : "dt-center", defaultContent : ""},//우선순위
			            {data : "chk_tm", className : "dt-center", defaultContent : ""},//체크 시간
			            {data : "lst_mdfr_id", defaultContent : "", visible: false},//최종 수정자
			            {data : "lst_mdf_dtm", defaultContent : "", visible: false},//최종 수정일
			            {data : "vip_cng_id", defaultContent : "", visible: false},//VIP 설정 ID
			            {data : "pry_svr_id", defaultContent : "", visible: false}//서버 ID
			            ]
		});
		
		vipInstTable.tables().header().to$().find('th:eq(0)').css('min-width', '80px');//State
		vipInstTable.tables().header().to$().find('th:eq(1)').css('min-width', '100px');//가상 IP
		vipInstTable.tables().header().to$().find('th:eq(2)').css('min-width', '100px');//가상 라우터 id
		vipInstTable.tables().header().to$().find('th:eq(3)').css('min-width', '100px');//가상 인터페이스 명
		vipInstTable.tables().header().to$().find('th:eq(4)').css('min-width', '50px');//우선순위
		vipInstTable.tables().header().to$().find('th:eq(5)').css('min-width', '50px');//체크 시간
		vipInstTable.tables().header().to$().find('th:eq(6)').css('min-width', '0px');//최종 수정자
		vipInstTable.tables().header().to$().find('th:eq(7)').css('min-width', '0px');//최종 수정일
		vipInstTable.tables().header().to$().find('th:eq(8)').css('min-width', '0px');//VIP 설정 ID
		vipInstTable.tables().header().to$().find('th:eq(9)').css('min-width', '0px');//서버 ID
		
		$('#vipInstance tbody').on('click','tr',function() {
			if ( !$(this).hasClass('selected') ){	        	
				vipInstTable.$('tr.selected').removeClass('selected');
	            $(this).addClass('selected');	            
	        } 
			var selRowLen = vipInstTable.rows('.selected').data().length;
				
			if(selRowLen != 0){		
				//정보 불러오기
				selConfInfo = vipInstTable.row('.selected').data();
			}
		});
		
		$('#vipInstance tbody').on('dblclick','tr',function() {
			if (!$(this).hasClass('selected')){	        	
				vipInstTable.$('tr.selected').removeClass('selected');
	           	$(this).addClass('selected');	    
			}
			fn_proxy_instance_popup('mod');
		});
		
		proxyListenTable = $('#proxyListener').DataTable({
			scrollY : "100px",
			scrollX: true,	
			searching : false,
			paging : false,
			deferRender : true,
			bSort: false,
			columns : [ 
			            {data : "lsn_nm", defaultContent : ""}, //Listen
			            {data : "con_bind_port", defaultContent : ""},//bind
			            {data : "lsn_desc", defaultContent : ""},//설명
			            {data : "db_usr_id", defaultContent : "", visible: false},//db 사용자 id
			            {data : "db_id", defaultContent : "", visible: false},//db id
			            {data : "db_nm", defaultContent : "", visible: false},//db 명
			            {data : "con_sim_query", defaultContent : "", visible: false},//전송 쿼리
			            {data : "field_val", defaultContent : "", visible: false},//필드 값
			            {data : "field_nm", defaultContent : "", visible: false},//필드 명
			            {data : "lst_mdfr_id", defaultContent : "", visible: false},//최종 수정자
			            {data : "lst_mdf_dtm", defaultContent : "", visible: false},//최종 수정일
			            {data : "ipadr", defaultContent : "", visible: false},//proxy 서버 ip
			            {data : "pry_svr_id", defaultContent : "", visible: false},//proxy 서버 ID
			            {data : "lsn_id", defaultContent : "", visible: false},//리스너 ID
			            {data : "lsn_svr_list", defaultContent : "", visible: false}//서버리스트 data
			            ]
		});
		
		proxyListenTable.tables().header().to$().find('th:eq(0)').css('min-width', '150px');//Listen
		proxyListenTable.tables().header().to$().find('th:eq(1)').css('min-width', '150px');//bind
		proxyListenTable.tables().header().to$().find('th:eq(2)').css('min-width', '60px');//설명
		proxyListenTable.tables().header().to$().find('th:eq(3)').css('min-width', '0px');//db 사용자 id
		proxyListenTable.tables().header().to$().find('th:eq(4)').css('min-width', '0px');//db id
		proxyListenTable.tables().header().to$().find('th:eq(5)').css('min-width', '0px');//db 명
		proxyListenTable.tables().header().to$().find('th:eq(6)').css('min-width', '0px');//전송 쿼리
		proxyListenTable.tables().header().to$().find('th:eq(7)').css('min-width', '0px');//필드 값
		proxyListenTable.tables().header().to$().find('th:eq(8)').css('min-width', '0px');//필드 명
		proxyListenTable.tables().header().to$().find('th:eq(9)').css('min-width', '0px');//최종 수정자
		proxyListenTable.tables().header().to$().find('th:eq(10)').css('min-width', '0px');//최종 수정일
		proxyListenTable.tables().header().to$().find('th:eq(11)').css('min-width', '0px');//proxy 서버 ip
		proxyListenTable.tables().header().to$().find('th:eq(12)').css('min-width', '0px');//proxy 서버 id
		proxyListenTable.tables().header().to$().find('th:eq(13)').css('min-width', '0px');//리스너 id
		proxyListenTable.tables().header().to$().find('th:eq(14)').css('min-width', '0px');//서버리스트 Data
		
		$('#proxyListener tbody').on('click','tr',function() {
			if ( !$(this).hasClass('selected') ){	        	
				proxyListenTable.$('tr.selected').removeClass('selected');
	            $(this).addClass('selected');	            
	        } 
			var selRowLen = proxyListenTable.rows('.selected').data().length;
				
			if(selRowLen != 0){		
				//정보 불러오기
				selListenerInfo = proxyListenTable.row('.selected').data();
			}
		});
		
		$('#proxyListener tbody').on('dblclick','tr',function() {
			if (!$(this).hasClass('selected')){	        	
				proxyListenTable.$('tr.selected').removeClass('selected');
	           	$(this).addClass('selected');	    
			}
			fn_proxy_listener_popup('mod');
		});
		
		
		setTimeout(function(){
			if(proxyServerTable != null){
				proxyServerTable.columns.adjust().draw();
			}
		},500);  
	}
		
	/* ********************************************************
     * TAB 선택 이벤트 
    ******************************************************** */		
	function selectTab(tab){	
		if(tab == "global"){
			$(".globalSettingDiv").show();
			$(".detailSettingDiv").hide();
			$("#server-tab-1").addClass("active");
			$("#server-tab-2").removeClass("active");
			
		}else{
			$(".globalSettingDiv").hide();
			$(".detailSettingDiv").show();
			$("#server-tab-2").addClass("active");
			$("#server-tab-1").removeClass("active");
			
			setTimeout(function(){
				if(vipInstTable != null){
					vipInstTable.columns.adjust().draw();
				}
				if(proxyListenTable != null){
					proxyListenTable.columns.adjust().draw();
				}
			},10);  
		}
	}
	/* ********************************************************
     * Proxy Server List Click Event
    ******************************************************** */	
	function click_serverList_row(obj){
		
		selectTab('global');
		
		if (!$(obj).hasClass('selected') ){	        	
			proxyServerTable.$('tr.selected').removeClass('selected');
           	$(obj).addClass('selected');	            
      	} 
		var selRowLen = proxyServerTable.rows('.selected').data().length;
		
		fn_init_global_value();
	
		if(selRowLen != 0){		
			//정보 불러오기
			var selRow = proxyServerTable.row('.selected').data();
			selPrySvrId = selRow.pry_svr_id;
			
			//설정 정보 불러오기
			fn_server_conf_info();
		}
	}
	/* ********************************************************
     * Global 설정 수정 시 이벤트
    ******************************************************** */		
	function fn_change_global_info(){
		if(selPrySvrId != null){
			$("#modYn").val("Y");
			$("#warning_init_detail_info").html('&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code="eXperDB_proxy.msg5"/>');
		}else{
			var temp = '<spring:message code="eXperDB_proxy.server" />';//Proxy 서버
			showSwalIcon('<spring:message code="eXperDB_proxy.msg1" arguments="'+temp+'" />', '<spring:message code="common.close" />', '', 'error');
		}
	}
	/* ********************************************************
     * Proxy Server List 검색 전 수정 여부 확인
    ******************************************************** */		
 	function fn_before_search(){
 		if($("#modYn").val() == "N"){
 			fn_serverList_search();
		}else{
			fn_multiConfirmModal("search_svr_list");
		}
	}
	/* ********************************************************
     * Proxy Server List 검색
    ******************************************************** */		
 	function fn_serverList_search(){
		
		var temp_search = $("#serverList_search").val();
		if(temp_search != ""){
			temp_search = "%" + temp_search + "%";
		}
 		$.ajax({
 			url : "/selectPoxyServerTable.do",
 			data : {
 				search : temp_search,
 				svr_use_yn : "Y"
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
 				proxyServerTable.rows({selected: true}).deselect();
				proxyServerTable.clear().draw();
				
				if (result != null) {
					proxyServerTable.rows.add(result).draw();
				}
				selectTab('global');
				//첫번째 로우 자동 선택 후 상세 정보 불러오기
				setTimeout(function(){
					if(proxyServerTable.rows().data().length > 0){
						proxyServerTable.row(0).select();
						var selRowLen = proxyServerTable.rows('.selected').data().length;
						fn_init_global_value();
					
						if(selRowLen != 0){		
							//정보 불러오기
							var selRow = proxyServerTable.row('.selected').data();
							selPrySvrId = selRow.pry_svr_id;
							
							//설정 정보 불러오기
							fn_server_conf_info();
						}
					}
				},500);  
 			}
 		});
 		$('#loading').hide();
 	} 	
	
	/* ********************************************************
     * 화면 초기 셋팅 
    ******************************************************** */		
	$(window.document).ready(function() {
		fn_init();
		
		if("${wrt_aut_yn}" == "Y"){
			fn_btn_setEnable("");
		 } else {
			 fn_btn_setEnable("disabled");
		 }
		
		if("${read_aut_yn}" == "Y"){
			fn_serverList_search();
		} else {
			fn_btn_setEnable("disabled");
			 /* $("#serverList_search").prop("disabled", "disabled");
			 $("#btnSearch").prop("disabled", "disabled"); */
		 }
		
		
		$.validator.addMethod("validatorIpFormat", function (str, element, param) {
			var ipformat = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
			if (ipformat.test(str)) {
				return true;
			}
			return false;
		});
		
		$("#globalInfoForm").validate({
	        rules: {
	        	glb_obj_ip: {
					required:true,
					validatorIpFormat :true
				},
				glb_if_nm: {
					required: true
				},
				glb_peer_server_ip: {
					required: true,
					validatorIpFormat :true
				},
				glb_max_con_cnt: {
					required: true
				},
				glb_cl_con_max_tm_num: {
					required:true
				},
				glb_con_del_tm_num: {
					required: true
				},
				glb_svr_con_max_tm_num: {
					required: true
				},
				glb_chk_tm_num: {
					required: true
				}
	        },
	        messages: {
	        	glb_obj_ip: {
					required: '<spring:message code="eXperDB_proxy.msg2" />',
					validatorIpFormat : '<spring:message code="errors.format" arguments="'+ 'IP' +'" />'
				},
				glb_if_nm: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				},
				glb_peer_server_ip: {
					required: '<spring:message code="eXperDB_proxy.msg2" />',
					validatorIpFormat : '<spring:message code="errors.format" arguments="'+ 'IP' +'" />'
				},
				glb_max_con_cnt: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				},
				glb_cl_con_max_tm_num: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				},
				glb_con_del_tm_num: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				},
				glb_svr_con_max_tm_num: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				},
				glb_chk_tm_num: {
					required: '<spring:message code="eXperDB_proxy.msg2" />'
				}
	        },
			submitHandler: function(form) { //모든 항목이 통과되면 호출됨 ★showError 와 함께 쓰면 실행하지않는다★
				//instReg_add_vip_instance();
			},
	        errorPlacement: function(label, element) {
	          label.addClass('mt-2 text-danger');
	          label.insertAfter(element);
	        },
	        highlight: function(element, errorClass) {
	          $(element).parent().addClass('has-danger');
	          $(element).addClass('form-control-danger');
	        }
		});
		
		$('[data-toggle="tooltip"]').tooltip({
			template: '<div class="tooltip tooltip-info" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
		});
		
	});
	
	/**********************************************************
     * Proxy Server List 선택 시 상세 정보 불러오기
    **********************************************************/
    function fn_server_conf_info(){
 		if(selPrySvrId != null){
			$.ajax({
	 			url : "/getPoxyServerConf.do",
	 			data : {
	 				pry_svr_id : selPrySvrId
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
	 				if(result.errcd==0){
		 				//전역변수로 저장
		 				selAgentConnect = true;
	 					selGlobalInfo = result.global_info;
	 					selVipInstanceList = result.vipconfig_list;
	 					selProxyListenerList = result.listener_list;
	 					selVipInstancePeerList = result.peer_vipconfig_list;
	 					selProxyListenerPeerList = result.peer_listener_list;
	 					selAgentInterface = result.interface_items;
	 					
		 				if(result.vipconfig_list.length ==0 || result.listener_list.length ==0 || result.global_info == null){
		 					$("#warning_init_detail_info").html('&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code="eXperDB_proxy.msg12" />');
						}
		 				//Global 설정 불러오기
	 					load_global_info(result.global_info);
		 				//vip Instance 관리 Table Data set
						vipInstTable.rows({selected: true}).deselect();
						vipInstTable.clear().draw();
						vipInstTable.rows.add(result.vipconfig_list).draw();
	
						//Listener 관리 Table Data set
						proxyListenTable.rows({selected: true}).deselect();
						proxyListenTable.clear().draw();
						proxyListenTable.rows.add(result.listener_list).draw();
						
						//Linstener database select 동적 생성
						$("#lstnReg_db_nm", "#insProxyListenForm").children().remove();
						if(result.db_sel_list.length > 0){
							for(var i=0; i<result.db_sel_list.length; i++){
								$("#lstnReg_db_nm", "#insProxyListenForm").append("<option value='"+result.db_sel_list[i].db_nm+"'>"+result.db_sel_list[i].db_nm+"</option>");	
							}									
						}
		 			}else if(result.errcd==-2){
		 				selAgentConnect = false;
		 				showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'error');
		 			}else{
		 				showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'error');
		 			}
	 			}
	 		});
 		}
 	} 	
	
 	/* ********************************************************
     * Global 설정 불러오기
    ******************************************************** */		
    function load_global_info(data){
    	if(data !=null){
	    	$("#glb_pry_glb_id", "#globalInfoForm").val(data.pry_glb_id);
	    	$("#glb_obj_ip", "#globalInfoForm").val(data.obj_ip);
	    	$("#glb_if_nm", "#globalInfoForm").val(data.if_nm);
	    	$("#glb_peer_server_ip", "#globalInfoForm").val(data.peer_server_ip);
	    	$("#glb_max_con_cnt", "#globalInfoForm").val(data.max_con_cnt);
	    	
	    	setTimeOutData("glb_cl_con_max_tm", data.cl_con_max_tm);
	    	setTimeOutData("glb_con_del_tm", data.con_del_tm);
	    	setTimeOutData("glb_svr_con_max_tm", data.svr_con_max_tm);
	    	setTimeOutData("glb_chk_tm", data.chk_tm);
    	}else{
    		$("#glb_pry_glb_id", "#globalInfoForm").val("");
	    	$("#glb_obj_ip", "#globalInfoForm").val(proxyServerTable.row('.selected').data().ipadr);
	    	$("#glb_if_nm", "#globalInfoForm").val("");
	    	$("#glb_peer_server_ip", "#globalInfoForm").val("");
	    	$("#glb_max_con_cnt", "#globalInfoForm").val("1000");
	    	
	    	setTimeOutData("glb_cl_con_max_tm", "30m");
	    	setTimeOutData("glb_con_del_tm", "4s");
	    	setTimeOutData("glb_svr_con_max_tm", "30m");
	    	setTimeOutData("glb_chk_tm", "5s");
    	}
    	//validate 초기화
    	$("#globalInfoForm").validate().resetForm();
    	
 	}
	//숫자+[m,s] 형태로 데이터 저장 필요
 	function setTimeOutData(id, tVal){
 		var len = tVal.length;
 	 	
 		$("#"+id+"_num", "#globalInfoForm").val(tVal.substr(0, len-1));
    	$("#"+id+"_tm", "#globalInfoForm").val(tVal.substr(-1, 1));
 	}
 	function getTimeOutData(id){
 		
 		return $("#"+id+"_num", "#globalInfoForm").val() + $("#"+id+"_tm", "#globalInfoForm").val();
 		
 	}
 	/* ********************************************************
     * Proxy Server 등록 버튼 클릭 시 이벤트
    ******************************************************** */		
 	function fn_proxy_update(mode){
 		$.ajax({
			url : "/popup/proxySvrRegForm.do",
			data : {},
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
				//초기화
				fn_pop_svr_info(mode);
			}
		});
 	}
 	/* ********************************************************
	 * Proxy 서버 등록 팝업 초기화
	 ******************************************************** */
	function fn_pop_svr_info(gbn) {
		$("#svrReg_mode", "#svrRegProxyServerForm").val(gbn); 
		if ($("#svrReg_mode", "#svrRegProxyServerForm").val() == "reg") {
			//등록 모드라면 agent 설치 시 테이블에 등록되어있는 서버 정보 불러오기
			$.ajax({
				url : "/selectPoxyAgentSvrList.do",
	 			data : { svr_use_yn : "N"},
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
	 				unregSvrInfo = result;
	 				if(unregSvrInfo.length ==0){
	 					showSwalIcon("Proxy Agent가 설치된 서버 중 \n미등록된 서버가 없습니다.", '<spring:message code="common.close" />', '', 'error');
	 					$('#pop_layer_svr_reg').modal("hide");
	 				}else{
	 					//ip select 동적 생성
	 					fn_create_unregSvr_select($("#svrReg_mode", "#svrRegProxyServerForm").val());
	 					
	 					$('#pop_layer_svr_reg').modal("show");
	 					
	 					setTimeout(function(){
	 						if(mgmtDbmsTable != null){
	 							mgmtDbmsTable.columns.adjust().draw();
	 						}
	 					},200);  
	 				}
	 			}
	 		});
		}else{
			//수정 모드라면 선택되어있는 Grid 항목의 ID값 갖고 오기
			if(proxyServerTable.rows('.selected').data().length==0){
				showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
				return;
			}else{
				var prySvrID = proxyServerTable.row('.selected').data().pry_svr_id;
				$("#svrReg_pry_svr_id", "#svrRegProxyServerForm" ).val(prySvrID);
				$.ajax({
					url : "/selectPoxyServerTable.do",
		 			data : { svr_use_yn : "Y", 
		 					pry_svr_id : prySvrID
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
		 				fn_changeSvrId();
	 					
	 					$('#pop_layer_svr_reg').modal("show");
	 					
	 					setTimeout(function(){
	 						if(mgmtDbmsTable != null){
	 							mgmtDbmsTable.columns.adjust().draw();
	 						}
	 					},200);  
		 				
		 			}
		 		});
			}
		}
		
		
	}
	/* ********************************************************
	 * Proxy 미등록 서버 select 생성
	 ******************************************************** */
	function fn_create_unregSvr_select(mode){
		var tempUnregSvrList = unregSvrInfo;
		var unregSvrHtml ="";
		var unregLen = unregSvrInfo.length;
		$( "#svrReg_ipadr > option", "#svrRegProxyServerForm" ).remove();
		
		for(var i=0; i<unregLen; i++){
			var id = tempUnregSvrList[i].pry_svr_id;
			var ip = tempUnregSvrList[i].ipadr;
			unregSvrHtml += '<option value='+ip+'>'+ip+'</option>';
		}

		$("#svrReg_ipadr", "#svrRegProxyServerForm" ).append(unregSvrHtml);
		//$("#svrReg_pry_svr_id", "#svrRegProxyServerForm" ).val(tempUnregSvrList[0].pry_svr_id);
		//$("#svrReg_ipadr", "#svrRegProxyServerForm").val(tempUnregSvrList[0].pry_svr_id);//ipadr
		$("#svrReg_pry_svr_id", "#svrRegProxyServerForm" ).val("");
		$("#svrReg_ipadr", "#svrRegProxyServerForm").val("");//ipadr
		
		if (unregLen > 0) {
			$("#svrReg_ipadr option:eq(0)").prop("selected", true);
		}
		
		fn_changeSvrId();
	}
	/* ********************************************************
	 * Proxy IP 주소 변경 시 이벤트
	 ******************************************************** */
	function fn_changeSvrId(){
		
		var prySvrID;
		if($("#svrReg_mode", "#svrRegProxyServerForm").val()=="reg") {
		//	prySvrID= $("#svrReg_ipadr", "#svrRegProxyServerForm" ).val();
		}else{
			prySvrID =$("#svrReg_pry_svr_id", "#svrRegProxyServerForm" ).val();
			$("#svrMod_ipadr", "#svrRegProxyServerForm" ).val(prySvrID);
		}
		
		$.ajax({
				url : "/createSelPrySvrReg.do",
	 			data : { pry_svr_id : prySvrID},
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
	 				if($("#svrReg_mode", "#svrRegProxyServerForm").val()=="reg"){
	 					var index = 0; 
		 			
	 					fn_create_dbms_select(result.dbms_sel_list, "");
	 					fn_create_mstSvr_select(result.mstSvr_sel_list, "");

		 				//수정 막기
		 				$( "#svrReg_db_svr_id", "#svrRegProxyServerForm" ).removeAttr('disabled');
		 				
	 					set_svr_info_start(unregSvrInfo[index], $("#svrReg_mode", "#svrRegProxyServerForm").val());
	 				}else{
	 					var selSvrInfo = proxyServerTable.row('.selected').data();
	 					
	 					fn_create_mstSvr_select(result.mstSvr_sel_list, selSvrInfo.master_svr_id);
		 				fn_create_dbms_select(result.dbms_sel_list, selSvrInfo.db_svr_id);
		 				
		 				//수정 막기
		 				$( "#svrReg_db_svr_id", "#svrRegProxyServerForm" ).attr("disabled", "disabled");

		 				set_svr_info(selSvrInfo, $("#svrReg_mode", "#svrRegProxyServerForm").val());
	 				}
	 				
	 			}
	 		});
	}

	/* ********************************************************
	 * Proxy 정보 setting
	 ******************************************************** */
	function set_svr_info_start(listData, mode){
		var tempSetData = listData;
		var ServerNm = "";

		//hidden 정보
		$("#svrReg_pry_svr_id", "#svrRegProxyServerForm").val("");
		$("#svrReg_master_svr_id_val", "#svrRegProxyServerForm").val("");
		$("#svrReg_db_svr_id_val", "#svrRegProxyServerForm").val($( "#svrReg_db_svr_id", "#svrRegProxyServerForm" ).val());
		$("#svrReg_agt_sn", "#svrRegProxyServerForm").val("");
			
		ServerNm = $("#svrReg_db_svr_id option:checked", "#svrRegProxyServerForm").text() + "-Proxy_";

		$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").val(ServerNm); //서버명
		$("#svrReg_use_yn", "#svrRegProxyServerForm").val("Y");
		
		$("#svrReg_exe_status", "#svrRegProxyServerForm" ).val("TC001502");
		$("#svrReg_kal_exe_status", "#svrRegProxyServerForm" ).val("TC001502");

		$("#ModalProxyServer").text('<spring:message code="eXperDB_proxy.server_reg"/>');
		$("#svrReg_conn_result", "#svrRegProxyServerForm").val("false");	
		$("#svrReg_conn_test", "#svrRegProxyServerForm").show();

		$("#svrReg_ipadr", "#svrRegProxyServerForm").show();
		$("#svrMod_ipadr", "#svrRegProxyServerForm").hide();//ipadr
		$("#svrMod_ipadr", "#svrRegProxyServerForm").val($("#svrReg_ipadr", "#svrRegProxyServerForm").val());//ipadr

		$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").removeAttr("disabled");
		$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").removeAttr("readonly");
		$("#svrMod_ipadr", "#svrRegProxyServerForm").removeAttr("disabled");
		$("#svrMod_ipadr", "#svrRegProxyServerForm").removeAttr("readonly");
		
		$("#svrReg_day_data_del_term", "#svrRegProxyServerForm").val("30"); //일별 데이터 보관 기간
		$("#svrReg_min_data_del_term", "#svrRegProxyServerForm").val("7"); //분별 데이터 보관 기간
		
		$("#svrReg_master_gbn", "#svrRegProxyServerForm").val("M"); //마스터 구분 
		
		fn_changeMasterGbn();

		//list 불러오기
		fn_svr_dbms_list_search();
		
		fn_dbmsChange_ServerNm();
	}
	/* ********************************************************
	 * Proxy 정보 setting
	 ******************************************************** */
	function set_svr_info(listData, mode){
		var tempSetData = listData;
		//hidden 정보
		$("#svrReg_pry_svr_id", "#svrRegProxyServerForm").val(tempSetData.pry_svr_id);
		$("#svrReg_master_svr_id_val", "#svrRegProxyServerForm").val(tempSetData.master_svr_id);
		$("#svrReg_db_svr_id_val", "#svrRegProxyServerForm").val(tempSetData.db_svr_id);
		$("#svrReg_agt_sn", "#svrRegProxyServerForm").val(tempSetData.agt_sn);
		
		$("#svrReg_ipadr", "#svrRegProxyServerForm").val(tempSetData.pry_svr_id);//ipadr
		$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").val(tempSetData.pry_svr_nm); //서버명
		
		if(tempSetData.use_yn == "Y"){
			$("#svrReg_use_yn", "#svrRegProxyServerForm").prop("checked", true); 
		}else{
			$("#svrReg_use_yn", "#svrRegProxyServerForm").prop("checked", false); 
		}
		
		if(mode=="reg"){//등록
			$("#svrReg_exe_status", "#svrRegProxyServerForm" ).val("TC001502");
			$("#svrReg_kal_exe_status", "#svrRegProxyServerForm" ).val("TC001502");
			$("#ModalProxyServer").text('<spring:message code="eXperDB_proxy.server_reg"/>');
			$("#svrReg_conn_result", "#svrRegProxyServerForm").val("false");	
			$("#svrReg_conn_test", "#svrRegProxyServerForm").show();
			$("#svrReg_ipadr", "#svrRegProxyServerForm").val(tempSetData.pry_svr_id);//ipadr
			$("#svrReg_ipadr", "#svrRegProxyServerForm").show();
			$("#svrMod_ipadr", "#svrRegProxyServerForm").hide();//ipadr
			$("#svrMod_ipadr", "#svrRegProxyServerForm").val(tempSetData.ipadr);//ipadr
			
			$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").removeAttr("disabled");
			$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").removeAttr("readonly");
			$("#svrMod_ipadr", "#svrRegProxyServerForm").removeAttr("disabled");
			$("#svrMod_ipadr", "#svrRegProxyServerForm").removeAttr("readonly");
		}else{//수정
			$("#svrReg_exe_status", "#svrRegProxyServerForm" ).val(tempSetData.exe_status);
			$("#svrReg_kal_exe_status", "#svrRegProxyServerForm" ).val(tempSetData.kal_exe_status);
			$("#ModalProxyServer").text('<spring:message code="eXperDB_proxy.server_modify"/>');
			$("#svrReg_conn_result", "#svrRegProxyServerForm").val("true");	
			$("#svrReg_conn_test", "#svrRegProxyServerForm").hide();//연결테스트 버튼
			$("#svrReg_ipadr", "#svrRegProxyServerForm").val(tempSetData.pry_svr_id);//ipadr
			$("#svrReg_ipadr", "#svrRegProxyServerForm").hide();//ipadr
			$("#svrMod_ipadr", "#svrRegProxyServerForm").val(tempSetData.ipadr);//ipadr
			$("#svrMod_ipadr", "#svrRegProxyServerForm").show();
			
			$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").attr("disabled",true);
			$("#svrReg_pry_svr_nm", "#svrRegProxyServerForm").attr("readonly",true);
			$("#svrMod_ipadr", "#svrRegProxyServerForm").attr("disabled",true);
			$("#svrMod_ipadr", "#svrRegProxyServerForm").attr("readonly",true);
		}
		
		$("#svrReg_day_data_del_term", "#svrRegProxyServerForm").val(tempSetData.day_data_del_term); //일별 데이터 보관 기간
		$("#svrReg_min_data_del_term", "#svrRegProxyServerForm").val(tempSetData.min_data_del_term); //분별 데이터 보관 기간
		
		$("#svrReg_master_gbn", "#svrRegProxyServerForm").val(tempSetData.master_gbn); //마스터 구분
		fn_changeMasterGbn();
	
		//list 불러오기
		fn_svr_dbms_list_search();
 	}
	/* ********************************************************
	 * confirm modal open
	 ******************************************************** */
	function fn_multiConfirmModal(gbn) {
		/* if (gbn == "conn_test") {
			confirm_title = 'Proxy Agent 연결 테스트';
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="message.msg89"/>'));
		}else  */if (gbn == "pry_svr_reg") {
			confirm_title =  '<spring:message code="eXperDB_proxy.server_reg" />';//Proxy 등록
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="message.msg143"/>'));
		}else if (gbn == "pry_svr_mod") {
			confirm_title = '<spring:message code="eXperDB_proxy.server_modify" />';//'Proxy 수정';
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="message.msg147"/>'));
		}else if (gbn == "pry_svr_del") {
			confirm_title =  '<spring:message code="eXperDB_proxy.server_del" />';//'Proxy 삭제'; 
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="eXperDB_proxy.msg14" />'+'<spring:message code="message.msg162"/>'));
		}else if (gbn == "stop") {
			confirm_title = '<spring:message code="eXperDB_proxy.act_stop" />';//'Proxy 중지';
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="eXperDB_proxy.msg15" />'));
		}else if (gbn == "start") {
			confirm_title = '<spring:message code="eXperDB_proxy.act_start" />';//'Proxy 실행';
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="eXperDB_proxy.msg16" />'));
		}else if (gbn == "click_svr_list" || gbn == "search_svr_list"){
			confirm_title = '<spring:message code="eXperDB_proxy.proxy_info" />';//Porxy 정보 조회
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="eXperDB_proxy.msg17" />'));
		}else if(gbn == "apply"){
			confirm_title = '<spring:message code="eXperDB_proxy.conf_apply" />';//'Proxy 설정 적용'
			$('#confirm_multi_msg').html(fn_strBrReplcae('<spring:message code="eXperDB_proxy.msg18" />'));
		}
		
		$('#con_multi_gbn', '#findConfirmMulti').val(gbn);
		$('#confirm_multi_tlt').html(confirm_title);
		$('#pop_confirm_multi_md').modal("show");
	}
	/* ********************************************************
	 * confirm result
	 ******************************************************** */
	function fnc_confirmMultiRst(gbn){
		
		if(gbn=="pry_svr_reg" || gbn=="pry_svr_mod"){
			fn_reg_svr();
		}else if(gbn=="pry_svr_del"){
			fn_proxy_del();
		}else if (gbn == "stop") {
			fn_proxy_active_set(proxyServerTable.row('.selected').data().pry_svr_id,"TC001502");
		}else if (gbn == "start") {
			fn_proxy_active_set(proxyServerTable.row('.selected').data().pry_svr_id,"TC001501");
		}else if(gbn == "click_svr_list"){
			click_serverList_row(selPrySvrRow);
		}else if(gbn == "apply"){
			fn_apply_conf_info();
		}else if(gbn == "search_svr_list"){
			fn_serverList_search();
		}
	}
	/* ********************************************************
	 * confirm cancel result
	 ******************************************************** */
	function fn_confirmCancelRst(gbn){
		if(gbn=="start"){
			$("input:checkbox[id=pry_svr_activeYn" + proxyServerTable.row('.selected').data().pry_svr_id + "]").prop("checked", false);
		}else if("stop"){
			$("input:checkbox[id=pry_svr_activeYn" + proxyServerTable.row('.selected').data().pry_svr_id + "]").prop("checked", true);
		}
	}
	/* ********************************************************
	 * Proxy 서버 구동/정지
	 ******************************************************** */
	function fn_proxy_active_set(prySvrId,status){
		$.ajax({
			url : "/runProxyService.do",
 			data : { 	pry_svr_id : prySvrId,
 						status : status
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
 				if(result.result){
 					showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'success');
 				}else{
 					showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'error');
	 			}
 				fn_init_global_value();
 				//검색
				fn_serverList_search();
 			}
 		});
		
	}
	
	/* ********************************************************
	 * Proxy Server 삭제 전 구동 상태 확인 
	 ******************************************************** */
	function fn_proxy_del_confirm(){
		
		if(proxyServerTable.rows('.selected').data().length==0){
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
			var selRow = proxyServerTable.row('.selected').data();
			if(selRow.exe_status=="TC001501"){
				//사용 및 구동 중지 후 삭제가 가능합니다.
				showSwalIcon('구동 중지 후 삭제가 가능합니다.', '<spring:message code="common.close" />', '', 'error');
			}else if(selRow.master_gbn=="M"){
				var rowLen = proxyServerTable.rows().data().length;
				var rowDatas = proxyServerTable.rows().data();
				for(var i=0; i < rowLen ; i++){
					if(selRow.pry_svr_id != rowDatas[i].pry_svr_id && rowDatas[i].master_svr_id == selRow.pry_svr_id){
						showSwalIcon('해당 서버와 연관된 Backup 서버가 존재합니다.\nBackup 서버를 먼저 삭제한 후 삭제 해주세요.', '<spring:message code="common.close" />', '', 'error');
						return;
					}
				}
				fn_multiConfirmModal("pry_svr_del");
			}else{
				fn_multiConfirmModal("pry_svr_del");
			}
		}
	}
	/* ********************************************************
	 * Proxy Server 삭제
	 ******************************************************** */
	function fn_proxy_del(){
		if(proxyServerTable.rows('.selected').data().length==0){
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
			var prySvrID = proxyServerTable.row('.selected').data().pry_svr_id;
			$("#svrReg_pry_svr_id", "#svrRegProxyServerForm" ).val(prySvrID);
			$.ajax({
				url : "/deletePrySvr.do",
	 			data : { pry_svr_id : prySvrID},
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
	 				if(result.result){
	 					showSwalIcon('<spring:message code="message.msg12"/>', '<spring:message code="common.close" />', '', 'success');
	 				}else{
	 					showSwalIcon('<spring:message code="migration.msg09"/> '+result.errMsg, '<spring:message code="common.close" />', '', 'error');
		 			}
	 				//검색
 					fn_serverList_search();
	 			}
	 		});
		}
	}
	
	function fn_prySvrActivation_click(){
		if(proxyServerTable.row('.selected').data().exe_status =="TC001502" || proxyServerTable.row('.selected').data().kal_exe_status =="TC001502"){
			fn_multiConfirmModal('start');	
		}else{
			fn_multiConfirmModal('stop');
		}
		
	}
	/* ********************************************************
	 * Vip Instance 관리 팝업
	 ******************************************************** */
	function fn_proxy_instance_popup(mode){
		if(selPrySvrId == null || (selConfInfo == null && mode == "mod")){//선택한 서버가 없다면 return
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
	
	 		$.ajax({
				url : "/popup/vipInstanceRegForm.do",
				data : {},
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
					//초기화
					fn_init_vip_instance(mode);
										
					$('#pop_layer_proxy_inst_reg').modal("show");

				}
			});
		}
 	}
 	
 	/* ********************************************************
	 * Vip Instance 등록/수정 화면
	 ******************************************************** */
	function fn_init_vip_instance(mode) {
		$("#instReg_mode", "#insVipInstForm").val(mode);
		$("#instReg_pry_svr_id", "#insVipInstForm").val(selPrySvrId);
		fn_create_vip_select(mode);
		fn_create_v_if_select(mode);
		if (mode == "reg") {
			
			/* $("#instReg_v_ip", "#insVipInstForm").removeAttr("disabled");
			$("#instReg_v_ip", "#insVipInstForm").removeAttr("readonly");*/
			
			$("#ModalVipInstance").text('<spring:message code="eXperDB_proxy.instance_reg"/>');
			$("#instReg_state_nm", "#insVipInstForm").removeAttr("disabled");
			$("#instReg_state_nm", "#insVipInstForm").removeAttr("readonly"); 
			
			$("#instReg_vip_cng_id", "#insVipInstForm").val("");
			$("#instReg_v_ip", "#insVipInstForm").val("");//virtual ip
			$("#instReg_v_if_nm", "#insVipInstForm").val(""); //virtual interface
			$("#instReg_v_rot_id", "#insVipInstForm").val(""); //virtual router id
			
			if(vipInstTable.rows().data().length == 0){
				$("#instReg_state_nm", "#insVipInstForm").val("MASTER"); //State
			}else{
				$("#instReg_state_nm", "#insVipInstForm").val("BACKUP"); //State
			}
			
			$("#instReg_priority", "#insVipInstForm").val("100"); //priority
			$("#instReg_chk_tm", "#insVipInstForm").val("1"); //체크간격
			
			/* $(".instReg_alert_div_1", "#insVipInstForm").hide();
			$(".instReg_alert_div_2", "#insVipInstForm").hide(); */
			
		} else {
			$("#ModalVipInstance").text('<spring:message code="eXperDB_proxy.instance_modify"/>');
			/* $("#instReg_v_ip", "#insVipInstForm").attr("disabled",true);
			$("#instReg_v_ip", "#insVipInstForm").attr("readonly",true);*/
			$("#instReg_state_nm", "#insVipInstForm").attr("disabled",true);
			$("#instReg_state_nm", "#insVipInstForm").attr("readonly",true); 
			
			$("#instReg_vip_cng_id", "#insVipInstForm").val(selConfInfo.vip_cng_id);//vip config id
			$("#instReg_v_ip", "#insVipInstForm").val(selConfInfo.v_ip);//virtual ip
			$("#instReg_v_if_nm", "#insVipInstForm").val(selConfInfo.v_if_nm); //virtual interface
			$("#instReg_v_rot_id", "#insVipInstForm").val(selConfInfo.v_rot_id); //virtual router id
			
			$("#instReg_state_nm", "#insVipInstForm").val(selConfInfo.state_nm); //State
			$("#instReg_priority", "#insVipInstForm").val(selConfInfo.priority); //priority
			$("#instReg_chk_tm", "#insVipInstForm").val(selConfInfo.chk_tm); //체크간격
			
			/* $(".instReg_alert_div_1", "#insVipInstForm").hide();
			$(".instReg_alert_div_2", "#insVipInstForm").hide(); */
		}
	}
	/* ********************************************************
	 * Vip select 박스 생성
	 ******************************************************** */
	function fn_create_vip_select(mode){
		var tempPeerVipList = selVipInstancePeerList;
		var tempHtml ="";
		var vipLen = tempPeerVipList.length;
		$( "#instReg_v_ip_sel > option", "#insVipInstForm" ).remove();
		tempHtml += '<option value=""><spring:message code="eXperDB_proxy.direct_input"/></option>';
		for(var i=0; i<vipLen; i++){
			var id = tempPeerVipList[i].v_ip;
			if(mode=="reg"){
				var vipDatas = vipInstTable.rows().data();
				var vipDataLen = vipDatas.length;
				var cnt =0;
				for(var j=0; j<vipDataLen ; j++){
					if(tempPeerVipList[i].v_ip==vipDatas[j].v_ip) cnt ++;	
				}
				if(cnt==0)	tempHtml += '<option value='+id+'>'+id+'</option>';
			}else{
				tempHtml += '<option value='+id+'>'+id+'</option>';	
			}
		}

		$("#instReg_v_ip_sel", "#insVipInstForm" ).append(tempHtml);
		$("#instReg_v_ip", "#insVipInstForm").val("");
		
		if (tempHtml > 0) {
			$("#instReg_v_ip_sel option:eq(0)").prop("selected", true);
		}
	}
	/* ********************************************************
	 * V interface select 박스 생성
	 ******************************************************** */
	function fn_create_v_if_select(mode){
		var tempVInterfNmList = selAgentInterface;
		var tempHtml ="";
		
		var vIfLen = tempVInterfNmList.length;
		
		$( "#instReg_v_if_nm_sel > option", "#insVipInstForm" ).remove();
		
		tempHtml += '<option value=""><spring:message code="eXperDB_proxy.direct_input"/></option>';
		for(var i=0; i<vIfLen; i++){
			var id = tempVInterfNmList[i];
			tempHtml += '<option value='+id+'>'+id+'</option>';
		}
		
		$("#instReg_v_if_nm_sel", "#insVipInstForm" ).append(tempHtml);
		
		if (tempHtml > 0) {
			$("#instReg_v_if_nm option:eq(0)").prop("selected", true);
		}
	}
	/* ********************************************************
	 * Vip Instance 삭제
	 ******************************************************** */
	function instReg_del_vip_instance(){
		if(vipInstTable.rows('.selected').data().length==0){
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
			$("#modYn").val("Y");
			$("#warning_init_detail_info").html('&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code="eXperDB_proxy.msg5"/>');
			//showSwalIcon('상단의 [적용]을 실행해야 \n변경 사항에 대해 저장/적용 됩니다.', '<spring:message code="common.close" />', '', 'success');
			delVipInstRows[delVipInstRows.length] = vipInstTable.row('.selected').data();
			vipInstTable.row('.selected').remove().draw();
		}
	}
	/* ********************************************************
	 * Proxy Listener 삭제
	 ******************************************************** */
	function lstnReg_del_listener(){
		if(proxyListenTable.rows('.selected').data().length==0){
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
			$("#modYn").val("Y");
			$("#warning_init_detail_info").html('&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code="eXperDB_proxy.msg5"/>');
			//showSwalIcon('상단의 [적용]을 실행해야 \n변경 사항에 대해 저장/적용 됩니다.', '<spring:message code="common.close" />', '', 'success');
			delListenerRows[delListenerRows.length] = proxyListenTable.row('.selected').data();
			proxyListenTable.row('.selected').remove().draw();
		}
	}
	/* ********************************************************
	 * Vip Listener 관리 팝업
	 ******************************************************** */
	function fn_proxy_listener_popup(mode){
		if(selPrySvrId == null || (selListenerInfo == null && mode == "mod")){//선택한 서버가 없다면 return
			showSwalIcon('<spring:message code="message.msg35" />', '<spring:message code="common.close" />', '', 'error');
			return;
		}else{
	 		$.ajax({
				url : "/popup/proxyListenRegForm.do",
				data : {},
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
					//초기화
					fn_init_proxy_listen(mode);
						
					$('#pop_layer_proxy_listen_reg').modal("show");
					
					setTimeout(function(){
						if(serverListTable != null){
							serverListTable.columns.adjust().draw();
						}
					},200);  
				}
			});
		}
 	}
	/* ********************************************************
	 * Proxy Listen 등록 화면 초기화
	 ******************************************************** */
	function fn_init_proxy_listen(mode) {
		$("#lstnReg_mode", "#insProxyListenForm").val(mode);
		$("#lstnReg_pry_svr_id", "#insProxyListenForm").val(selPrySvrId);
		fn_create_bind_ip_select();
		
		$("#lstnReg_con_sim_query", "#insProxyListenForm").attr("disabled",true);
		$("#lstnReg_con_sim_query", "#insProxyListenForm").attr("readonly",true); 
		
		if (mode == "reg") {
			$("#ModalProxyListen").text('<spring:message code="eXperDB_proxy.listener_reg"/>');
			
			$("#lstnReg_lsn_nm", "#insProxyListenForm").val(""); //리스너명
			$("#lstnReg_lsn_nm", "#insProxyListenForm").hide();
			$("#lstnReg_lsn_nm_sel", "#insProxyListenForm").show();
			
			//$("#lstnReg_con_bind_ip", "#insProxyListenForm").val(""); //접속IP
			$("#lstnReg_con_bind_ip option:eq(0)").prop("selected", true);
			$("#lstnReg_con_bind_port", "#insProxyListenForm").val(""); //접속포트
			$("#lstnReg_lsn_desc", "#insProxyListenForm").val(""); //리스너 설명
			$("#lstnReg_db_usr_id", "#insProxyListenForm").val("reqmgr"); //DB 사용자 ID
			/* $("#lstnReg_db_nm", "#insProxyListenForm").val(""); //DB 명 */
			$("#lstnReg_db_nm option:eq(0)").prop("selected", true);
			$("#lstnReg_con_sim_query", "#insProxyListenForm").val(""); //전송 쿼리
			$("#lstnReg_field_nm", "#insProxyListenForm").val(""); //필드명
			$("#lstnReg_field_val", "#insProxyListenForm").val(""); //필드값
			$("#lstnReg_lsn_id", "#insProxyListenForm").val(""); //리스너 ID
			serverListTable.clear().draw();
		
		} else {
			if(isNaN(selListenerInfo.lsn_id)) selListenerInfo.lsn_id = "";
			$("#ModalProxyListen").text('<spring:message code="eXperDB_proxy.listener_modify"/>');
			$("#lstnReg_lsn_nm", "#insProxyListenForm").val(selListenerInfo.lsn_nm); //리스너명
			$("#lstnReg_lsn_nm", "#insProxyListenForm").attr("disabled",true);
			$("#lstnReg_lsn_nm", "#insProxyListenForm").attr("readonly",true); 
			$("#lstnReg_lsn_nm", "#insProxyListenForm").show();
			$("#lstnReg_lsn_nm_sel", "#insProxyListenForm").hide();
			
			var bind = selListenerInfo.con_bind_port;
			$("#lstnReg_con_bind_ip", "#insProxyListenForm").val(bind.substring(0,bind.indexOf(":"))); //접속IP
			$("#lstnReg_con_bind_port", "#insProxyListenForm").val(bind.substring(bind.indexOf(":")+1)); //접속포트
			
			$("#lstnReg_lsn_desc", "#insProxyListenForm").val(selListenerInfo.lsn_desc); //리스너 설명
			$("#lstnReg_db_usr_id", "#insProxyListenForm").val("reqmgr");
			//$("#lstnReg_db_usr_id", "#insProxyListenForm").val(selListenerInfo.db_usr_id); //DB 사용자 ID
			$("#lstnReg_db_nm", "#insProxyListenForm").val(selListenerInfo.db_nm); //DB 명
			$("#lstnReg_con_sim_query", "#insProxyListenForm").val(selListenerInfo.con_sim_query); //전송 쿼리
			$("#lstnReg_field_nm", "#insProxyListenForm").val(selListenerInfo.field_nm); //필드명
			$("#lstnReg_field_val", "#insProxyListenForm").val(selListenerInfo.field_val); //필드값
			$("#lstnReg_lsn_id", "#insProxyListenForm").val(selListenerInfo.lsn_id); //리스너 ID
			$("#lstnReg_db_id", "#insProxyListenForm").val(selListenerInfo.db_id);//??
			console.log(selListenerInfo.lsn_id);
			if(selListenerInfo.lsn_id != ""){
				fn_listener_svr_list_search();
			}else{
				var tempData = selListenerInfo.lsn_svr_edit_list;
				serverListTable.clear().draw();
				serverListTable.rows.add(tempData).draw();
			}
		}
	}
	/* ********************************************************
	 * bind ip select 박스 생성
	 ******************************************************** */
	function fn_create_bind_ip_select(){
		var tempVipList = vipInstTable.rows().data();
		var tempHtml ="";
		var vipLen = tempVipList.length;
		$( "#lstnReg_con_bind_ip > option", "#insProxyListenForm" ).remove();
		tempHtml += '<option value="*">*</option>';
		for(var i=0; i<vipLen; i++){
			var vip = tempVipList[i].v_ip;
			vip = vip.substr(0, vip.indexOf("/"));
			tempHtml += '<option value='+vip+'>'+vip+'</option>';
		}

		$("#lstnReg_con_bind_ip", "#insProxyListenForm" ).append(tempHtml);
		
		if (tempHtml > 0) {
			$("#lstnReg_con_bind_ip option:eq(0)").prop("selected", true);
		}
	}
	/* ********************************************************
     * 적용 버튼 클릭 시 수정 여부 확인 
    ******************************************************** */		
	function fn_before_apply(){
		if($("#globalInfoForm").validate().form()){
			if($("#modYn").val() == "N"){
				showSwalIcon('<spring:message code="eXperDB_proxy.msg6"/>', '<spring:message code="common.close" />', '', 'error');
			}else{
				fn_multiConfirmModal("apply");
			}
		}
	}
	function fn_btn_setEnable(disable){
		$("#btnInsert_svr").prop("disabled", disable);
		$("#btnUpdate_svr").prop("disabled", disable);
		$("#btnDelete_svr").prop("disabled", disable);
		
		$("#btnInsert_vip").prop("disabled", disable);
		$("#btnUpdate_vip").prop("disabled", disable);
		$("#btnDelete_vip").prop("disabled", disable);
		
		$("#btnInsert_lsn").prop("disabled", disable);
		$("#btnUpdate_lsn").prop("disabled", disable);
		$("#btnDelete_lsn").prop("disabled", disable);
		
		$("#btnApply").prop("disabled", disable);
		
	}
	
	/* ********************************************************
     * 상세 정보 수정 사항 서버에 적용
    ******************************************************** */
	function fn_apply_conf_info(){
		showDangerToast('top-right', '<spring:message code="eXperDB_proxy.msg7"/>', '<spring:message code="eXperDB_proxy.apply_msg_title"/>');
		fn_btn_setEnable("disabled");
		
		//data 생성
		var tempVipInstance = new Array();
		var tempListener = new Array();
		
		var vipInstLen = vipInstTable.rows().data().length;
		var listenLen =  proxyListenTable.rows().data().length;
		for(var i=0; i < vipInstLen; i++){
			tempVipInstance[tempVipInstance.length] = vipInstTable.row(i).data();
		}
		for(var j=0; j < listenLen; j++){
			tempListener[tempListener.length] = proxyListenTable.row(j).data();
		}
		
		var param = {
			pry_svr_id : selPrySvrId,
			pry_glb_id : parseInt($("#glb_pry_glb_id", "#globalInfoForm").val()),
			max_con_cnt : parseInt($("#glb_max_con_cnt", "#globalInfoForm").val()),
			cl_con_max_tm : $("#glb_cl_con_max_tm_num", "#globalInfoForm").val()+$("#glb_cl_con_max_tm_tm", "#globalInfoForm").val(),
			con_del_tm : $("#glb_con_del_tm_num", "#globalInfoForm").val()+$("#glb_con_del_tm_tm", "#globalInfoForm").val(),
			svr_con_max_tm : $("#glb_svr_con_max_tm_num", "#globalInfoForm").val()+$("#glb_svr_con_max_tm_tm", "#globalInfoForm").val(),
			chk_tm : $("#glb_chk_tm_num", "#globalInfoForm").val()+$("#glb_chk_tm_tm", "#globalInfoForm").val(),
			if_nm : $("#glb_if_nm", "#globalInfoForm").val(),
			obj_ip : $("#glb_obj_ip", "#globalInfoForm").val(),
			peer_server_ip : $("#glb_peer_server_ip", "#globalInfoForm").val(),
			vipcng : tempVipInstance,
			delVipcng : delVipInstRows,
			listener: tempListener,
			delListener: delListenerRows
		};
		
		$.ajax({
 			url : "/applyProxyConf.do",
 			data : {confData : JSON.stringify(param)},
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
 				//작업이 완료 되었습니다.
 				if(result.result){
 					fn_init_global_value();
 					fn_btn_setEnable("");
 					showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'success');
 					fn_serverList_search();
 				}else{
 					fn_btn_setEnable("");
 					showSwalIcon(result.errMsg, '<spring:message code="common.close" />', '', 'error');
 					$("input:checkbox[id=pry_svr_activeYn" + proxyServerTable.row('.selected').data().pry_svr_id + "]").prop("checked", false);
 				}
 			}
 		});
		
	}
	
	/* ********************************************************
     * 전역 변수 초기화
    ******************************************************** */
	function fn_init_global_value(){
		//수정상테 관련 변수 초기화
			$('#modYn').val("N");
			$("#warning_init_detail_info").html('');
			//전역변수 초기화
			selConfInfo = null; //선택한 상세 정보 초기화
			selListenerInfo = null; //선택한 Listener 목록
			delVipInstRows = new Array();//삭제한 Vip Instance 목록
			delListenerRows = new Array();//삭제한 Listener 목록
			delListnerSvrRows = new Array();//삭제한 Listener Server List 목록 
	}
</script>
<body>
<%@include file="./../../popup/confirmMultiForm.jsp"%>

<%@include file="./../popup/proxyServerRegForm.jsp"%>
<%@include file="./../popup/vipInstRegForm.jsp"%>
<%@include file="./../popup/proxyListenRegForm.jsp"%>
<div class="content-wrapper main_scroll" id="contentsDiv" style="min-height: calc(100vh);">
	<input type="hidden" id="modYn" name="modYn" value="N"/>
	<div class="row">
		<div class="col-12 div-form-margin-srn stretch-card">
			<div class="card">
				<div class="card-body">
					<!-- title start -->
					<div class="accordion_main accordion-multi-colored" id="accordion" role="tablist">
						<div class="card" style="margin-bottom:0px;">
							<div class="card-header" role="tab" id="page_header_div">
								<div class="row">
									<div class="col-5" style="padding-top:3px;">
										<h6 class="mb-0">
											<a data-toggle="collapse" href="#page_header_sub" aria-expanded="false" aria-controls="page_header_sub" onclick="fn_profileChk('titleText')">
												<i class="ti-desktop menu-icon"></i>
												<span class="menu-title"><spring:message code="menu.proxy_config" /></span>
												<i class="menu-arrow_user" id="titleText" ></i>
											</a>
										</h6>
									</div>
									<div class="col-7">
					 					<ol class="mb-0 breadcrumb_main justify-content-end bg-info" >
					 						<li class="breadcrumb-item_main" style="font-size: 0.875rem;"><spring:message code="menu.proxy" /></li>
					 						<li class="breadcrumb-item_main" style="font-size: 0.875rem;" aria-current="page"><spring:message code="menu.proxy_mgmt" /></li>
											<li class="breadcrumb-item_main active" style="font-size: 0.875rem;" aria-current="page"><spring:message code="menu.proxy_config"/></li>
										</ol>
									</div>
								</div>
							</div>
							<div id="page_header_sub" class="collapse" role="tabpanel" aria-labelledby="page_header_div" data-parent="#accordion">
								<div class="card-body">
									<div class="row">
										<div class="col-12">
											<p class="mb-0">
												<spring:message code="help.proxy_settings" />
											</p>
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

		<div class="col-lg-5 grid-margin stretch-card">
			<div class="card">
				<div class="card-body" style=" height: 100%;">
					<h4 class="card-title">
						<i class="item-icon fa fa-dot-circle-o"></i>
						<spring:message code="eXperDB_proxy.server_mgt" />
					</h4>
					<div class="row" >
						<div class="col-12">
							<div class="template-demo">	
								<form class="form-inline" style="float: right;">
									<input hidden="hidden" />
									<input type="text" class="form-control" style="width:250px;" id="serverList_search">
									&nbsp;&nbsp;
									<button type="button" class="btn btn-inverse-primary btn-icon-text btn-search-disable" id="btnSearch" onClick="fn_before_search()">
										<i class="ti-search btn-icon-prepend "></i><spring:message code="button.search" />
									</button>
								</form>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-12">
							<div class="template-demo">			
								<button type="button" class="btn btn-outline-primary btn-icon-text float-right" id="btnDelete_svr" onClick="fn_proxy_del_confirm();" >
									<i class="ti-trash btn-icon-prepend "></i><spring:message code="common.delete" />
								</button>
								<button type="button" class="btn btn-outline-primary btn-icon-text float-right" id="btnUpdate_svr" onClick="fn_proxy_update('mod');" data-toggle="modal">
									<i class="ti-pencil-alt btn-icon-prepend "></i><spring:message code="common.modify" />
								</button>
								<button type="button" class="btn btn-outline-primary btn-icon-text float-right" id="btnInsert_svr" onClick="fn_proxy_update('reg');" data-toggle="modal">
									<i class="ti-pencil btn-icon-prepend "></i><spring:message code="common.registory" />
								</button>
							</div>
						</div>
					</div>
					<table id="proxyServer" class="table table-hover table-striped" style="width:100%;">
						<thead>
							<tr class="bg-info text-white">
								<th width="40"><spring:message code="common.no"/></th>
								<th width="60"><spring:message code="eXperDB_proxy.act_status"/></th>
								<th width="100"><spring:message code="eXperDB_proxy.server_name"/></th>
								<th width="100"><spring:message code="eXperDB_proxy.ip"/></th>
								<th width="0">상태</th>
								<th width="0">haproxy 파일 경로</th>
								<th width="0">keepalived 파일 경로</th>
								<th width="0">마스터 구분</th>
								<th width="0">마스터 server id</th>
								<th width="0">일별데이터삭제기간</th>
								<th width="0">분별데이터삭제기간</th>
								<th width="0">최종 수정자</th>
								<th width="0">최종 수정일</th>
								<th width="0">agent 일련번호</th>
								<th width="0">서버 id</th>
								<th width="0">EXE_STATUS</th>
								<th width="0">KAL_EXE_STATUS</th>
							</tr>
						</thead>
					</table>
				</div>
			</div>
		</div>
            
		<div class="col-lg-7 grid-margin stretch-card">
			<div class="card">
				<div class="card-body">
					<div class="table-responsive" style="overflow:hidden;">
						<div id="wrt_button" style="float: right;">
							<button type="button" class="btn btn-inverse-primary btn-icon-text mb-2 btn-search-disable" id="btnApply" onClick="fn_before_apply()">
								<i class="ti-control-play btn-icon-prepend "></i>적용
							</button>
						</div>
						<h4 class="card-title">
							<i class="item-icon fa fa-dot-circle-o"></i>
							<spring:message code="menu.proxy_config" />
						</h4>
						<h4 class="text-danger" id="warning_init_detail_info" style="font-size: 0.875rem;">
						</h4>
					</div>
				    <ul class="nav nav-pills nav-pills-setting nav-justified" id="server-tab" role="tablist" style="border:none;">
						<li class="nav-item">
							<a class="nav-link active" id="server-tab-1" data-toggle="pill" href="#subTab-1" role="tab" aria-controls="subTab-1" aria-selected="true" onclick="javascript:selectTab('global');" >
								<spring:message code="eXperDB_proxy.global_conf" />
							</a>
						</li>
						<li class="nav-item">
							<a class="nav-link" id="server-tab-2" data-toggle="pill" href="#subTab-2" role="tab" aria-controls="subTab-2" aria-selected="false" onclick="javascript:selectTab('detail');">
								<spring:message code="eXperDB_proxy.pry_vip_conf" />
							</a>
						</li>
					</ul>
					<div class="card globalSettingDiv" style="display:block;">
						<form class="cmxform" id="globalInfoForm">
							<input type="hidden" id="glb_pry_glb_id" name="glb_pry_glb_id"/>
							<div class="card-body card-body-border">
								<div class="form-group row">
									<label for="glb_obj_ip" class="col-sm-2_5 col-form-label pop-label-index">
										<i class="item-icon fa fa-angle-double-right"></i>
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.svr_ip_tooltip" />'>	
										<spring:message code="eXperDB_proxy.svr_ip" />(*)
										</span>
									</label>
									<div class="col-sm-2_27">
										<input type="text" class="form-control form-control-sm glb_obj_ip" maxlength="15" id="glb_obj_ip" name="glb_obj_ip" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<label for="glb_if_nm" class="col-sm-2_5 col-form-label pop-label-index">
										<i class="item-icon fa fa-angle-double-right"></i>	
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.interface_tooltip" />'>	
										<spring:message code="eXperDB_proxy.interface" />(*)
										</span>
									</label>
									<div class="col-sm-2_27">
										<input type="text" class="form-control form-control-sm glb_if_nm" maxlength="20" id="glb_if_nm" name="glb_if_nm" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
								</div>
								<div class="form-group row">
									<label for="glb_peer_server_ip" class="col-sm-2_5 col-form-label pop-label-index">
										<i class="item-icon fa fa-angle-double-right"></i>	
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.peer_ip_tooltip" />'>
											<spring:message code="eXperDB_proxy.peer_ip" />(*)
										</span>
										<%-- <spring:message code="eXperDB_proxy.peer_ip" />(*) --%>
									</label> 
									<div class="col-sm-2_27">
										<input type="text" class="form-control form-control-sm glb_peer_server_ip" maxlength="15" id="glb_peer_server_ip" name="glb_peer_server_ip" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-6">
									</div>
								</div>
								<div class="form-group row">
									<label for="glb_max_con_cnt" class="col-sm-2_5 col-form-label pop-label-index">
										<i class="item-icon fa fa-angle-double-right"></i>
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.max_con_cnt_tooltip" />'>	
										<spring:message code="eXperDB_proxy.max_con_cnt" />(*)
										</span>
									</label>
									<div class="col-sm-2">
										<input type="number" class="form-control form-control-sm glb_max_con_cnt" maxlength="10" id="glb_max_con_cnt" name="glb_max_con_cnt" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-auto">
									</div>
								</div>
								<div class="form-group row" style="margin-bottom:-5px;">
									<label for="glb_cl_con_max_tm_num" class="col-sm-12 col-form-label pop-label-index">
										<i class="item-icon fa fa-angle-double-right"></i>	
										<spring:message code="eXperDB_proxy.timeout_conf" />(*)
									</label>
								</div>
								<div class="form-group row" style="margin-bottom: 0px !important;">
									<label for="glb_cl_con_max_tm_num" class="col-sm-3 col-form-label pop-label-index">
										&nbsp;&nbsp;&nbsp;
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.cl_con_max_tm_tooltip" />'>	
										<spring:message code="eXperDB_proxy.cl_con_max_tm" />
										</span>
									</label>
									<div class="col-sm-1_5">
										<input type="number" class="form-control form-control-sm glb_cl_con_max_tm_num" maxlength="5" id="glb_cl_con_max_tm_num" name="glb_cl_con_max_tm_num" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-1_5">
										<select class="form-control form-control-sm" name="glb_cl_con_max_tm_tm" id="glb_cl_con_max_tm_tm" onchange="fn_change_global_info();">
											<option value="s"><spring:message code="eXperDB_proxy.sec" /></option>
											<option value="m"><spring:message code="eXperDB_proxy.min" /></option>
										</select>
									</div>
									<label for="glb_con_del_tm_num" class="col-sm-3 col-form-label pop-label-index">
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.con_del_tm_tooltip" />'>	
										<spring:message code="eXperDB_proxy.con_del_tm" />(*)
										</span>
									</label>
									<div class="col-sm-1_5">
										<input type="number" class="form-control form-control-sm glb_con_del_tm_num" maxlength="5" id="glb_con_del_tm_num" name="glb_con_del_tm_num" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-1_5">
										<select class="form-control form-control-sm" name="glb_con_del_tm_tm" id="glb_con_del_tm_tm" onchange="fn_change_global_info();">
											<option value="s"><spring:message code="eXperDB_proxy.sec" /></option>
											<option value="m"><spring:message code="eXperDB_proxy.min" /></option>
										</select>
									</div>
								</div>
								<div class="form-group row" style="margin-bottom:-17px !important;">
									<label for="glb_svr_con_max_tm_num" class="col-sm-3 col-form-label pop-label-index">
										&nbsp;&nbsp;&nbsp;
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.svr_con_max_tm_tooltip" />'>	
										<spring:message code="eXperDB_proxy.svr_con_max_tm" />(*)
										</span>
									</label>
									<div class="col-sm-1_5">
										<input type="number" class="form-control form-control-sm glb_svr_con_max_tm_num" maxlength="5" id="glb_svr_con_max_tm_num" name="glb_svr_con_max_tm_num" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-1_5">
										<select class="form-control form-control-sm" name="glb_svr_con_max_tm_tm" id="glb_svr_con_max_tm_tm" onchange="fn_change_global_info();">
											<option value="s"><spring:message code="eXperDB_proxy.sec" /></option>
											<option value="m"><spring:message code="eXperDB_proxy.min" /></option>
										</select>
									</div>
									<label for="glb_chk_tm_num" class="col-sm-3 col-form-label pop-label-index">
										<span data-toggle="tooltip" data-html="true" data-placement="bottom" title='<spring:message code="eXperDB_proxy.chk_tm_tooltip" />'>	
										<spring:message code="eXperDB_proxy.chk_tm" />(*)
										</span>
									</label>
									<div class="col-sm-1_5">
										<input type="number" class="form-control form-control-sm glb_chk_tm_num" maxlength="5" id="glb_chk_tm_num" name="glb_chk_tm_num" onkeyup="fn_checkWord(this,20);" onkeydown="fn_change_global_info();" onblur="this.value=this.value.trim()" placeholder="" />
									</div>
									<div class="col-sm-1_5">
										<select class="form-control form-control-sm" name="glb_chk_tm_tm" id="glb_chk_tm_tm" onchange="fn_change_global_info();">
											<option value="s"><spring:message code="eXperDB_proxy.sec" /></option>
											<option value="m"><spring:message code="eXperDB_proxy.min" /></option>
										</select>
									</div>
								</div>
							</div>
						</form>
					</div>
					
					<div class="card detailSettingDiv" style="display:none;">
						<div class="card-body card-body-border">
							<div class="table-responsive">
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnDelete_vip" onClick="instReg_del_vip_instance();" >
									<i class="ti-trash btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.delete" />
								</button>
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnUpdate_vip" onClick="fn_proxy_instance_popup('mod');" data-toggle="modal">
									<i class="ti-pencil-alt btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.modify" />
								</button>
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnInsert_vip" onClick="fn_proxy_instance_popup('reg');" data-toggle="modal">
									<i class="ti-pencil btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.registory" />
								</button>
								<h4 class="card-title">
									<i class="item-icon fa fa-dot-circle-o"></i>
									<spring:message code="eXperDB_proxy.instance_mgmt" />
								</h4>
							</div>
							<table id="vipInstance" class="table table-hover table-striped" style="width:100%;">
								<thead>
									<tr class="bg-info text-white">
										<th width="80"><spring:message code="eXperDB_proxy.vip_state" /></th>
										<th width="100"><spring:message code="eXperDB_proxy.vip" /></th>
										<th width="100"><spring:message code="eXperDB_proxy.vip_router" /></th>
										<th width="100"><spring:message code="eXperDB_proxy.vip_interface" /></th>
										<th width="50"><spring:message code="eXperDB_proxy.vip_priority" /></th>
										<th width="50"><spring:message code="eXperDB_proxy.vip_check_tm" /></th>
										<th width="0">최종 수정자</th>
										<th width="0">최종 수정일</th>
										<th width="0">VIP ID</th>
										<th width="0">Proxy Server ID</th>
									</tr>
								</thead>
							</table>
						</div>
					</div>
					<br/>
					<div class="card detailSettingDiv" style="display:none;">
						<div class="card-body card-body-border">
							<div class="table-responsive">
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnDelete_lsn" onClick="lstnReg_del_listener();" >
									<i class="ti-trash btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.delete" />
								</button>
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnUpdate_lsn" onClick="fn_proxy_listener_popup('mod');" data-toggle="modal">
									<i class="ti-pencil-alt btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.modify" />
								</button>
								<button type="button" class="icon_text_btn btn-outline-primary btn-icon-text float-right" id="btnInsert_lsn" onClick="fn_proxy_listener_popup('reg');" data-toggle="modal">
									<i class="ti-pencil btn-icon-prepend "></i>&nbsp;&nbsp;<spring:message code="common.registory" />
								</button>
								<h4 class="card-title">
									<i class="item-icon fa fa-dot-circle-o"></i>
									<spring:message code="eXperDB_proxy.listener_mgmt" />
								</h4>
							</div>
							<table id="proxyListener" class="table table-hover table-striped" style="width:100%;">
								<thead>
									<tr class="bg-info text-white">
										<th width="90"><spring:message code="eXperDB_proxy.listener_nm" /></th>
										<th width="150"><spring:message code="eXperDB_proxy.bind_ip_port" /></th>
										<th width="150"><spring:message code="eXperDB_proxy.desc" /></th>
										<th width="0">db 사용자 ID</th>
										<th width="0">db id</th>
										<th width="0">db 명</th>
										<th width="0">전송 쿼리</th>
										<th width="0">필드 값</th>
										<th width="0">필드 명</th>
										<th width="0">최종 수정자</th>
										<th width="0">최종 수정일</th>
										<th width="0">proxy ip</th>
										<th width="0">proxy id</th>
										<th width="0">listener id</th>
										<th width="0">Server List Data</th>
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