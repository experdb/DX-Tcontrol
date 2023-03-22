package com.experdb.management.proxy.web;

import java.io.FileInputStream;
import java.net.ConnectException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.util.ResourceUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.experdb.management.proxy.service.ProxyListenerServerVO;
import com.experdb.management.proxy.service.ProxyRestService;
import com.k4m.dx.tcontrol.scale.service.InstanceScaleService;

/**
 * CDC와 연동 컨트롤러 클래스를 정의한다.
 *
 * @author 김민정
 * @see
 * 
 *      <pre>
 * == 개정이력(Modification Information) ==
 *
 *     수정일                 수정자           수정내용
 *  ------------     --------    ---------------------------
 *  2021.08.24         김민정           최초 생성
 *      </pre>
 */
@RestController
public class ProxyRestController {
	@Autowired
	private MessageSource msg;
	
	@Autowired
	private ProxyRestService proxyRestService;

	@Autowired
	private InstanceScaleService instanceScaleService;

	/**
	 * ScaleIn 발생 시 HAProxy.cfg 설정 중 db_svr_list 해당 항목 delete 후 agent에 cfg 파일 수정 후 reload 처리  
	 * 
	 * @param JSONObject
	 * @return JSONObject
	 * @throws Exception
	 */
	@RequestMapping(value = "/experdb/rest/proxy/setProxyScaleInTest.do", method = RequestMethod.POST)
	public  @ResponseBody JSONObject setProxyScaleInTest(@RequestBody JSONObject  param) {
		System.out.println("##########################  setProxyScaleInTest  ###########################");
		
		try{
			JSONParser jParser = new JSONParser();
			JSONObject paramObj = (JSONObject)jParser.parse(param.toString());
			
			JSONArray instanceArray = (JSONArray)paramObj.get("instance");
			
			for(int i=0; i<instanceArray.size(); i++){
				JSONObject jObj = (JSONObject) instanceArray.get(i);
				
				System.out.println(jObj.get("ip")+":"+jObj.get("port"));
			}
		}catch(Exception e){
			System.out.println("error :: " + e.toString());
		}
		
		return param;
	}
	
	/**
	 * ScaleIn 발생 시 HAProxy.cfg 설정 중 db_svr_list 해당 항목 delete 후 agent에 cfg 파일 수정 후 reload 처리  
	 * 
	 * @param JSONObject
	 				{"instance": [{"ip": "192.168.50.182","port": "5432","master_ip":"192.168.50.181"},{"ip": "192.168.50.183","port": "5432","master_ip":"192.168.50.181"}]}
	 * @return JSONObject
	 * @throws Exception
	 */
	@RequestMapping(value = "/experdb/rest/proxy/setProxyScaleIn.do", method = RequestMethod.POST)
	public  @ResponseBody JSONObject setProxyScaleIn(@RequestBody JSONObject request) {
		System.out.println("##########################  setProxyScaleIn  ###########################");
		JSONObject resultObj = new JSONObject();
		try {			
			
			JSONParser jParser = new JSONParser();
			JSONObject paramObj = (JSONObject)jParser.parse(request.toString());
			
			JSONArray instanceArray = (JSONArray)paramObj.get("instance");
			
			Map<String, Object> param = new HashMap<String, Object>();
			List<String> dbConAddr = new ArrayList<String>();
			List<String> dbConIp = new ArrayList<String>();
			List<String> dbConPort = new ArrayList<String>();
			List<String> dbConMasterIp = new ArrayList<String>();

			Properties prop = new Properties();
			prop.load(new FileInputStream(ResourceUtils.getFile("classpath:egovframework/tcontrolProps/globals.properties")));		

			if(instanceArray != null){	
				for(int i=0; i<instanceArray.size(); i++){
					JSONObject jObj = (JSONObject) instanceArray.get(i);
					dbConAddr.add(jObj.get("ip")+":"+jObj.get("port"));
					dbConIp.add(jObj.get("ip").toString());
					dbConPort.add(jObj.get("port").toString());
					dbConMasterIp.add(jObj.get("master_ip").toString());
				}
				
				param.put("db_con_addr", dbConAddr);
				param.put("db_con_ip", dbConIp);
				param.put("db_con_port", dbConPort);
				param.put("master_ip", dbConMasterIp);
				param.put("scale_type", "1");
	
				//agent 서버 추가////////////////////////////////
				String resultDeleteData =instanceScaleService.setScaleResultProcess(param);
				/////////////////////////////////////////////////
	
				System.out.println("setProxyScaleIn : Delete Agent-Info Result :: "+resultDeleteData);
				
				if("Y".equals(prop.getProperty("proxy.useyn"))){
							
					//어떤 Proxy 서버와, Agent를 수정해야되는지 List 추출
					List<Map<String, Object>> pryScaleList = proxyRestService.selectScaleInProxyList(param);	
					
					//Delete T_PRY_LSN_SVR_I
					proxyRestService.scaleInProxyLsnSvrList(param);
						
					//Agent로 cfg 수정 후 반영 요청 
					resultObj= proxyRestService.setProxyConfScaleIn(pryScaleList);
					
				}
			}
		}catch(ConnectException ce){
			resultObj.put("resultCd", -4);
			resultObj.put("resultMsg", "Proxy Agent 연결 불가");
		}catch (Exception e) {
			System.out.println("setProxyScaleIn :: error : "+e.toString());
			resultObj.put("resultCd", -1);
			resultObj.put("resultMsg", msg.getMessage("eXperDB_proxy.msg48", null, LocaleContextHolder.getLocale()));
			e.printStackTrace();
		}
		System.out.println("setProxyScaleIn Result :: "+resultObj.toJSONString());
		return resultObj;
	}
	
	
	/**
	 * ScaleOut 발생 시 HAProxy.cfg 설정 중 db_svr_list 해당 항목 insert 후 agent에 cfg 파일 수정 후 reload 처리  
	 * 
	 * @param JSONObject
	 				{"instance": [{"ip": "192.168.50.182","port": "5432","master_ip":"192.168.50.181"},{"ip": "192.168.50.183","port": "5432","master_ip":"192.168.50.181"}]}
	 * @return JSONObject
	 * @throws Exception
	 */
	@RequestMapping(value = "/experdb/rest/proxy/setProxyScaleOut.do", method = RequestMethod.POST)
	public  @ResponseBody JSONObject setProxyScaleOut(@RequestBody JSONObject request) {
		System.out.println("##########################  setProxyScaleOut  ###########################");
		JSONObject resultObj = new JSONObject();
		
		try{
			JSONParser jParser = new JSONParser();
			JSONObject paramObj = (JSONObject)jParser.parse(request.toString());
			
			JSONArray instanceArray = (JSONArray)paramObj.get("instance");
			Map<String, Object> param = new HashMap<String, Object>();
			List<String> dbConIp = new ArrayList<String>();
			List<String> dbConPort = new ArrayList<String>();
			List<String> dbConMasterIp = new ArrayList<String>();

			Properties prop = new Properties();
			prop.load(new FileInputStream(ResourceUtils.getFile("classpath:egovframework/tcontrolProps/globals.properties")));			

			if(instanceArray != null){	
				ProxyListenerServerVO listnSvr[] = new ProxyListenerServerVO[instanceArray.size()];
				
				for(int i=0; i<instanceArray.size(); i++){
					JSONObject jObj = (JSONObject) instanceArray.get(i);
					listnSvr[i] = new ProxyListenerServerVO();
					listnSvr[i].setDb_con_addr(jObj.get("ip")+":"+jObj.get("port"));
					//listnSvr[i].setChk_portno(Integer.parseInt(jObj.get("port").toString()));
					int portLen = jObj.get("port").toString().length();
					listnSvr[i].setChk_portno(Integer.parseInt(jObj.get("port").toString().substring(0, portLen-2)));
					listnSvr[i].setBackup_yn("N");
					listnSvr[i].setLst_mdfr_id("system");
					
					dbConIp.add(jObj.get("ip").toString());
					dbConPort.add(jObj.get("port").toString().substring(0, portLen-2));
					dbConMasterIp.add(jObj.get("master_ip").toString());
				}
				
				param.put("ipadr", dbConIp);
				param.put("db_con_port", dbConPort);
				param.put("db_con_ip", dbConIp);
				param.put("master_ip", dbConMasterIp);
				param.put("scale_type", "2");

				//agent 서버 추가////////////////////////////////
				String resultInsertData = instanceScaleService.setScaleResultProcess(param);
				/////////////////////////////////////////////////

				if(!resultInsertData.equals("success")){
					resultObj.put("resultCd", -3);
					resultObj.put("resultMsg", "등록된 DBMS 정보에 "+dbConMasterIp+" IP를 갖는 DB가 없습니다.");
					System.out.println("setProxyScaleOut Result :: "+resultObj.toJSONString());
					return resultObj;
				}
				
				if("Y".equals(prop.getProperty("proxy.useyn"))){	
					System.out.println("Param :: "+param.toString());
					//어떤 Proxy 서버와, Agent를 수정해야되는지 List 추출
					List<Map<String, Object>> pryScaleList = proxyRestService.selectScaleOutProxyList(param);	
				
					//Insert T_PRY_LSN_SVR_I
					proxyRestService.scaleOutProxyLsnSvrList(listnSvr, pryScaleList);
					
					//Agent로 cfg 수정 후 반영 요청 
					resultObj= proxyRestService.setProxyConfScaleIn(pryScaleList);
				
				}
			}
		}catch(ConnectException ce){
			resultObj.put("resultCd", -4);
			resultObj.put("resultMsg", "Proxy Agent 연결 불가");
		}catch(Exception e){
			System.out.println("setProxyScaleOut :: error : "+e.toString());
			e.printStackTrace();
		}
		System.out.println("setProxyScaleOut Result :: "+resultObj.toJSONString());
		return resultObj;
	}
	
}
