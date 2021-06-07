package com.experdb.management.proxy.web;

import java.net.ConnectException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.experdb.management.proxy.service.ProxyHistoryService;
import com.experdb.management.proxy.service.ProxyServerVO;
import com.experdb.management.proxy.service.ProxySettingService;
import com.k4m.dx.tcontrol.admin.menuauthority.service.MenuAuthorityService;
import com.k4m.dx.tcontrol.cmmn.CmmnUtils;
import com.k4m.dx.tcontrol.common.service.CmmnCodeDtlService;
import com.k4m.dx.tcontrol.common.service.CmmnCodeVO;
import com.k4m.dx.tcontrol.common.service.HistoryVO;
import com.k4m.dx.tcontrol.common.service.PageVO;
import com.k4m.dx.tcontrol.login.service.LoginVO;

/**
 *Proxy 설정이력 관리
 *
 * @author 김민정
 * @see
 * 
 *      <pre>
 * == 개정이력(Modification Information) ==
 *
 *   수정일       수정자           수정내용
 *  -------     --------    ---------------------------
 *  2021.03.03   김민정 최초 생성
 *      </pre>
 */
@Controller
public class ProxyHistoryController {
	
	@Autowired
	private MenuAuthorityService menuAuthorityService;
	
	@Autowired
	private ProxySettingService proxySettingService;
	
	@Autowired
	private ProxyHistoryService proxyHistoryService;
	
	@Autowired
	private CmmnCodeDtlService cmmnCodeDtlService;
	
	@Autowired
	private MessageSource msg;
	
	private List<Map<String, Object>> menuAut;
	
	private String show_menu_id = "46";
	
	/**
	 * Proxy 상태 이력 관리
	 * 
	 * @param historyVO
	 * @param request
	 * @return ModelAndView mv
	 * @throws 
	 */
	@RequestMapping(value = "/proxyStatusHistory.do")
	public ModelAndView proxyStatusHistory(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request) {
		
		//해당메뉴 권한 조회 (공통메소드호출),
		CmmnUtils cu = new CmmnUtils();
		menuAut = cu.selectMenuAut(menuAuthorityService, "MN0001803");
				
		ModelAndView mv = new ModelAndView();
		try {
			//읽기 권한이 없는경우 에러페이지 호출 [추후 Exception 처리예정]
			if(menuAut.get(0).get("read_aut_yn").equals("N")){
				mv.setViewName("error/autError");
			}else{
				// 화면접근이력 이력 남기기 - Proxy 이력 관리 화면 
				proxySettingService.accessSaveHistory(request, historyVO, "DX-T0167", show_menu_id);
				HttpSession session = request.getSession();
				LoginVO loginVo = (LoginVO) session.getAttribute("session");
				
				mv.addObject("usr_id", loginVo.getUsr_id());

				List<CmmnCodeVO> cmmnCodeVO =  null;
				PageVO pageVO = new PageVO();
				
				pageVO.setGrp_cd("TC0040");
				pageVO.setSearchCondition("0");
				cmmnCodeVO = cmmnCodeDtlService.cmmnDtlCodeSearch(pageVO);
				mv.addObject("actExeTypeCd",cmmnCodeVO);
				
				//Listener Nm Code Search
				PageVO pageVO_2 = new PageVO();
				
				pageVO_2.setGrp_cd("TC0015");
				pageVO_2.setSearchCondition("0");
				cmmnCodeVO = cmmnCodeDtlService.cmmnDtlCodeSearch(pageVO_2);
				mv.addObject("exeRsltCd", cmmnCodeVO);
				
				Map<String, Object> param = new HashMap<String, Object>();
				param.put("svr_use_yn", "Y");
				List<ProxyServerVO> prySvrList = proxySettingService.selectProxyServerList(param);
			
				mv.addObject("prySvrList", prySvrList);
				
				mv.addObject("read_aut_yn", menuAut.get(0).get("read_aut_yn"));
				mv.addObject("wrt_aut_yn", menuAut.get(0).get("wrt_aut_yn"));	

				mv.setViewName("proxy/history/proxyHistory");
			}	
		} catch (Exception e) {
			e.printStackTrace();
		}
		return mv;
	}

	/**
	 * Proxy 기동 상태 변경 이력 리스트를 조회한다.
	 * 
	 * @param request, historyVO, response
	 * @return List<Map<String, Object>>
	 * @throws 
	 */
	@RequestMapping(value = "/selectProxyActStateHistory.do")
	public @ResponseBody List<Map<String, Object>> selectProxyActStateHistory(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request, HttpServletResponse response) {
		//해당메뉴 권한 조회 (공통메소드호출),
		CmmnUtils cu = new CmmnUtils();
		menuAut = cu.selectMenuAut(menuAuthorityService, "MN0001803");
				
		List<Map<String, Object>> resultSet = null;
		Map<String, Object> param = new HashMap<String, Object>();

		try {	
			//읽기 권한이 없는경우 에러페이지 호출 [추후 Exception 처리예정]
			if(menuAut.get(0).get("read_aut_yn").equals("N")){
				response.sendRedirect("/autError.do");
				return resultSet;
			}else{
				// 화면접근이력 이력 남기기 - Proxy 설정관리 - Proxy Listen 관리 팝업
				proxySettingService.accessSaveHistory(request, historyVO, "DX-T0167_03", show_menu_id);		

				param.put("wlk_dtm_start", request.getParameter("wlk_dtm_start")==null ? "" : request.getParameter("wlk_dtm_start").toString());
				param.put("wlk_dtm_end", request.getParameter("wlk_dtm_end")==null ? "" : request.getParameter("wlk_dtm_end").toString());
				param.put("pry_svr_id", (request.getParameter("pry_svr_id") ==null || "".equals(request.getParameter("pry_svr_id").toString())) ? "" : Integer.parseInt(request.getParameter("pry_svr_id").toString()));
			    
				param.put("sys_type", request.getParameter("sys_type")==null ? "" : request.getParameter("sys_type").toString());
				param.put("act_type", request.getParameter("act_type")==null ? "" : request.getParameter("act_type").toString());
				param.put("act_exe_type", request.getParameter("act_exe_type")==null ? "" : request.getParameter("act_exe_type").toString());
				param.put("exe_rslt_cd", request.getParameter("exe_rslt_cd")==null ? "" : request.getParameter("exe_rslt_cd").toString());
				//param.put("lst_mdfr_id", request.getParameter("lst_mdfr_id")==null ? "" : request.getParameter("lst_mdfr_id").toString());
				  
				resultSet = proxyHistoryService.selectProxyActStateHistoryList(param);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return resultSet;

	}
	
	/**
	 * Proxy 설정 변경 이력 리스트를 조회한다.
	 * 
	 * @param historyVO, request, response
	 * @return List<Map<String, Object>>
	 * @throws
	 */
	@RequestMapping(value = "/selectProxySettingChgHistory.do")
	public @ResponseBody List<Map<String, Object>> selectProxySettingChgHistory(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request, HttpServletResponse response) {
		//해당메뉴 권한 조회 (공통메소드호출),
		CmmnUtils cu = new CmmnUtils();
		menuAut = cu.selectMenuAut(menuAuthorityService, "MN0001803");
				
		List<Map<String, Object>> resultSet = null;
		Map<String, Object> param = new HashMap<String, Object>();

		try {	
			//읽기 권한이 없는경우 에러페이지 호출 [추후 Exception 처리예정]
			if(menuAut.get(0).get("read_aut_yn").equals("N")){
				response.sendRedirect("/autError.do");
				return resultSet;
			}else{
				// 화면접근이력 이력 남기기 - Proxy 설정관리 - Proxy Listen 관리 팝업
				proxySettingService.accessSaveHistory(request, historyVO, "DX-T0167_02", show_menu_id);		

				param.put("lst_dtm_start", request.getParameter("lst_dtm_start")==null ? "" : request.getParameter("lst_dtm_start").toString());
				param.put("lst_dtm_end", request.getParameter("lst_dtm_end")==null ? "" : request.getParameter("lst_dtm_end").toString());
				param.put("pry_svr_id", (request.getParameter("pry_svr_id") ==null || "".equals(request.getParameter("pry_svr_id").toString())) ? "" : Integer.parseInt(request.getParameter("pry_svr_id").toString()));
			    param.put("exe_rst_cd", request.getParameter("exe_rst_cd")==null ? "" : request.getParameter("exe_rst_cd").toString());
				//param.put("lst_mdfr_id", request.getParameter("lst_mdfr_id")==null ? "" : request.getParameter("lst_mdfr_id").toString());
				  
				resultSet = proxyHistoryService.selectProxySettingChgHistoryList(param);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return resultSet;
	}

	/**
	 * Proxy Conf 파일 확인 팝업 
	 * 
	 * @param request, historyVO
	 * @return ModelAndView mv
	 * @throws
	 */
	@RequestMapping(value = "/popup/proxyBackupConfForm.do")
	public ModelAndView proxyListenRegForm(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request) {
		ModelAndView mv = new ModelAndView("jsonView");

		try {
			CmmnUtils cu = new CmmnUtils();
			menuAut = cu.selectMenuAut(menuAuthorityService, "MN0001803");

			if (menuAut.get(0).get("wrt_aut_yn").equals("N")) {
				mv.setViewName("error/autError");
			} else {
				// 화면접근이력 이력 남기기 - Proxy 설정관리 - Proxy Listen 관리 팝업
				proxySettingService.accessSaveHistory(request, historyVO, "DX-T0167_01", show_menu_id);				
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return mv;
	}
	
	/**
	 * Proxy Conf 파일 읽어오기
	 * 
	 * @param historyVO, request, response
	 * @return JSONObject
	 * @throws 
	 */
	@RequestMapping(value = "/getBackupConfFile.do")
	public @ResponseBody JSONObject getBackupConfFile(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request, HttpServletResponse response) {
		CmmnUtils cu = new CmmnUtils();		
		Map<String, Object> param = new HashMap<String, Object>();
		JSONObject resultObj = new JSONObject();
		Map<String, Object> confFileStrMap = new HashMap();
		try {	
			param.put("sys_type", cu.getStringWithoutNull(request.getParameter("sys_type")));
			param.put("pry_svr_id", "".equals(cu.getStringWithoutNull(request.getParameter("pry_svr_id"))) ? 0 : Integer.parseInt(request.getParameter("pry_svr_id").toString()));
			param.put("pry_svr_nm", cu.getStringWithoutNull(request.getParameter("pry_svr_nm")));
			param.put("pry_cng_sn", "".equals(cu.getStringWithoutNull(request.getParameter("pry_cng_sn"))) ? 0 : Integer.parseInt(request.getParameter("pry_cng_sn").toString()));
			
		
			
			try{
				confFileStrMap = proxyHistoryService.getProxyConfFileContent(param);
			}catch(ConnectException e){
				e.printStackTrace();
				resultObj.put("errcd", 1);
				resultObj.put("errmsg",msg.getMessage("eXperDB_proxy.msg47", null, LocaleContextHolder.getLocale()));
			}catch(Exception e){
				e.printStackTrace();
				resultObj.put("errcd", 2);
				resultObj.put("errmsg",msg.getMessage("eXperDB_proxy.msg48", null, LocaleContextHolder.getLocale()));
			}
			resultObj.put("pry_svr_id", param.get("pry_svr_id").toString());
			resultObj.put("pry_svr_nm", param.get("pry_svr_nm").toString());
			
			if( confFileStrMap.get("RESULT_CODE") != null &&   "0".equals(confFileStrMap.get("RESULT_CODE").toString())){
				if(confFileStrMap.get("BACKUP_CONF") != null) resultObj.put("backupConf", confFileStrMap.get("BACKUP_CONF").toString());
				else resultObj.put("backupConf", msg.getMessage("eXperDB_proxy.msg44", null, LocaleContextHolder.getLocale()));
				if(confFileStrMap.get("PRESENT_CONF") != null) resultObj.put("presentConf",confFileStrMap.get("PRESENT_CONF").toString());
				else resultObj.put("presentConf", msg.getMessage("eXperDB_proxy.msg44", null, LocaleContextHolder.getLocale()));
				
				resultObj.put("errcd", 0);
				resultObj.put("errmsg",msg.getMessage("eXperDB_proxy.msg45", null, LocaleContextHolder.getLocale()));
			}else{
				resultObj.put("errcd", -1);
				resultObj.put("errmsg",msg.getMessage("eXperDB_proxy.msg46", null, LocaleContextHolder.getLocale()));
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			resultObj.put("errcd", -1);
			resultObj.put("errmsg",msg.getMessage("eXperDB_proxy.msg46", null, LocaleContextHolder.getLocale()));
		}
		return resultObj;
	}
}