package com.k4m.dx.tcontrol.socket.listener;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Properties;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.ResourceUtils;

import com.experdb.proxy.server.PsP001;
import com.experdb.proxy.server.PsP002;
import com.experdb.proxy.server.PsP003;
import com.experdb.proxy.server.PsP004;
import com.experdb.proxy.server.PsP006;
import com.experdb.proxy.server.PsP007;
import com.experdb.proxy.server.PsP008;
import com.experdb.proxy.server.PsP009;
import com.experdb.proxy.server.PsP010;
import com.experdb.proxy.server.PsP012;
import com.experdb.proxy.server.PsP014;
import com.k4m.dx.tcontrol.server.DxT001;
import com.k4m.dx.tcontrol.server.DxT002;
import com.k4m.dx.tcontrol.server.DxT003;
import com.k4m.dx.tcontrol.server.DxT005;
import com.k4m.dx.tcontrol.server.DxT006;
import com.k4m.dx.tcontrol.server.DxT007;
import com.k4m.dx.tcontrol.server.DxT008;
import com.k4m.dx.tcontrol.server.DxT010;
import com.k4m.dx.tcontrol.server.DxT011;
import com.k4m.dx.tcontrol.server.DxT012;
import com.k4m.dx.tcontrol.server.DxT013;
import com.k4m.dx.tcontrol.server.DxT014;
import com.k4m.dx.tcontrol.server.DxT015;
import com.k4m.dx.tcontrol.server.DxT016;
import com.k4m.dx.tcontrol.server.DxT017;
import com.k4m.dx.tcontrol.server.DxT018;
import com.k4m.dx.tcontrol.server.DxT019;
import com.k4m.dx.tcontrol.server.DxT020;
import com.k4m.dx.tcontrol.server.DxT021;
import com.k4m.dx.tcontrol.server.DxT022;
import com.k4m.dx.tcontrol.server.DxT023;
import com.k4m.dx.tcontrol.server.DxT024;
import com.k4m.dx.tcontrol.server.DxT025;
import com.k4m.dx.tcontrol.server.DxT026;
import com.k4m.dx.tcontrol.server.DxT027;
import com.k4m.dx.tcontrol.server.DxT028;
import com.k4m.dx.tcontrol.server.DxT029;
import com.k4m.dx.tcontrol.server.DxT030;
import com.k4m.dx.tcontrol.server.DxT031;
import com.k4m.dx.tcontrol.server.DxT032;
import com.k4m.dx.tcontrol.server.DxT033;
import com.k4m.dx.tcontrol.server.DxT034;
import com.k4m.dx.tcontrol.server.DxT036;
import com.k4m.dx.tcontrol.server.DxT037;
import com.k4m.dx.tcontrol.server.DxT038;
import com.k4m.dx.tcontrol.server.DxT039;
import com.k4m.dx.tcontrol.server.DxT040;
import com.k4m.dx.tcontrol.server.DxT041;
import com.k4m.dx.tcontrol.server.DxT042;
import com.k4m.dx.tcontrol.server.DxT043;
import com.k4m.dx.tcontrol.server.DxT044;
import com.k4m.dx.tcontrol.server.DxT045;
import com.k4m.dx.tcontrol.server.DxT046;
import com.k4m.dx.tcontrol.server.DxT047;
import com.k4m.dx.tcontrol.server.DxT048;
import com.k4m.dx.tcontrol.server.DxT049;
import com.k4m.dx.tcontrol.server.DxT050;
import com.k4m.dx.tcontrol.server.DxT051;
import com.k4m.dx.tcontrol.server.DxT052;
import com.k4m.dx.tcontrol.server.DxT053;
import com.k4m.dx.tcontrol.server.DxT054;
import com.k4m.dx.tcontrol.server.DxT055;
import com.k4m.dx.tcontrol.server.DxT056;
import com.k4m.dx.tcontrol.socket.ProtocolID;
import com.k4m.dx.tcontrol.socket.SocketCtl;
import com.k4m.dx.tcontrol.socket.TranCodeType;

/**
* @author 박태혁
* @see
* 
*      <pre>
* == 개정이력(Modification Information) ==
*
*   수정일       수정자           수정내용
*  -------     --------    ---------------------------
*  2018.04.23   박태혁 		최초 생성
*  2022.12.22	강병석		에이전트 통합, 프록시 에이전트 기능 추가
*      </pre>
*/
public class DXTcontrolSocketExecute extends SocketCtl implements Runnable {
	private int	localport = 0;
	private Logger socketLogger = LoggerFactory.getLogger("socketLogger");
	private Logger errLogger = LoggerFactory.getLogger("errorToFile");
	
	public DXTcontrolSocketExecute(Socket socket) {
		client = socket;
		localport = client.getLocalPort();
	}
	
	public void run() {
		try {
			is = new BufferedInputStream(client.getInputStream());
			os = new BufferedOutputStream(client.getOutputStream());
			
			//while(true) {
				byte[] recvBuff = recv(TotalLengthBit, false);
				
				JSONParser parser=new JSONParser();
				Object obj=parser.parse(new String(recvBuff));
				
				recvBuff = null;
				
				JSONObject jObj = (JSONObject) obj;
				//JSONArray jArray=(JSONArray) jObj.get(ProtocolID._tran_req_data);
					
				String strDX_EX_CODE = (String) jObj.get(ProtocolID.DX_EX_CODE);
				
				JSONObject objSERVER_INFO = new JSONObject(); 

				//프로퍼티 조회
				Properties prop = new Properties();
				prop.load(new FileInputStream(ResourceUtils.getFile("../classes/context.properties")));	
				
				//MGMT, 하이브리드에서만 동작
				if("N".equals(prop.getProperty("proxy.global.serveryn"))){
					switch(strDX_EX_CODE) {
							//Database List
							case TranCodeType.DxT001 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								DxT001 dxT001 = new DxT001(client, is, os);
								dxT001.execute(strDX_EX_CODE, objSERVER_INFO);
								break;
								
							//table List
							case TranCodeType.DxT002 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								String strSchema = (String) jObj.get(ProtocolID.SCHEMA);
								DxT002 dxT002 = new DxT002(client, is, os);
								dxT002.execute(strDX_EX_CODE, objSERVER_INFO, strSchema);
								break;
								
							//connection Test
							case TranCodeType.DxT003 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								DxT003 dxT003 = new DxT003(client, is, os);
								dxT003.execute(strDX_EX_CODE, objSERVER_INFO);
								break;
								
							//backup management
							case TranCodeType.DxT005 :
								JSONArray arrCmd = (JSONArray) jObj.get(ProtocolID.ARR_CMD);
								DxT005 dxT005 = new DxT005(client, is, os);
								dxT005.execute(strDX_EX_CODE, arrCmd);
								break;
								
							//Authentication Management
							case TranCodeType.DxT006 :
								DxT006 dxT006 = new DxT006(client, is, os);
								dxT006.execute(strDX_EX_CODE, jObj);
								break;
								
							//Audit Log Setting
							case TranCodeType.DxT007 :
								DxT007 dxT007 = new DxT007(client, is, os);
								dxT007.execute(strDX_EX_CODE, jObj);
								break;	
								
							//Search Audit Log 
							case TranCodeType.DxT008 :
								DxT008 dxT008 = new DxT008(client, is, os);
								dxT008.execute(strDX_EX_CODE, jObj);
								break;	
								
							//Whether to install extension
							case TranCodeType.DxT010 :
								DxT010 dxT010 = new DxT010(client, is, os);
								dxT010.execute(strDX_EX_CODE, jObj);
								break;
								
							//Search role 
							case TranCodeType.DxT011 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								DxT011 dxT011 = new DxT011(client, is, os);
								dxT011.execute(strDX_EX_CODE, objSERVER_INFO);
								break;
								
							case TranCodeType.DxT012 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								DxT012 dxT012 = new DxT012(client, is, os);
								dxT012.execute(strDX_EX_CODE, objSERVER_INFO);
								break;
								
							case TranCodeType.DxT013 :
								DxT013 dxT013 = new DxT013(client, is, os);
								dxT013.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT014 :
								DxT014 dxT014 = new DxT014(client, is, os);
								dxT014.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT015 :
								DxT015 dxT015 = new DxT015(client, is, os);
								dxT015.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT015_DL :
								DxT015 dxT015_DL = new DxT015(client, is, os);
								dxT015_DL.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT016 :
								DxT016 dxT016 = new DxT016(client, is, os);
								dxT016.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT017 :
								DxT017 dxT017 = new DxT017(client, is, os);
								dxT017.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT018 :
								DxT018 dxT018 = new DxT018(client, is, os);
								dxT018.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT019 :
								DxT019 dxT019 = new DxT019(client, is, os);
								dxT019.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT020 :
								DxT020 dxT020 = new DxT020(client, is, os);
								dxT020.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT021 :
								DxT021 dxT021 = new DxT021(client, is, os);
								dxT021.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT022 :
								DxT022 dxT022 = new DxT022(client, is, os);
								dxT022.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT023 :
								DxT023 dxT023 = new DxT023(client, is, os);
								dxT023.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT024 :
								DxT024 dxT024 = new DxT024(client, is, os);
								dxT024.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT025 :
								DxT025 dxT025 = new DxT025(client, is, os);
								dxT025.execute(strDX_EX_CODE, jObj);
								break;
								
							//install extension pgAudit
							case TranCodeType.DxT026 :
								String strExtname = (String) jObj.get(ProtocolID.EXTENSION);
								DxT026 dxT026 = new DxT026(client, is, os);
								dxT026.execute(strDX_EX_CODE, jObj,strExtname);
								break;
								
							case TranCodeType.DxT027 :
								DxT027 dxT027 = new DxT027(client, is, os);
								dxT027.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT028 :
								DxT028 dxT028 = new DxT028(client, is, os);
								dxT028.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT029 :
								DxT029 dxT029 = new DxT029(client, is, os);
								dxT029.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT030 :
								socketLogger.info("TranCodeType : " + strDX_EX_CODE);
								DxT030 dxT030 = new DxT030(client, is, os);
								dxT030.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT031 :
								DxT031 dxT031 = new DxT031(client, is, os);
								dxT031.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT032 :
								DxT032 dxT032 = new DxT032(client, is, os);
								dxT032.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT033 :
								objSERVER_INFO = (JSONObject) jObj.get(ProtocolID.SERVER_INFO);
								DxT033 dxT033 = new DxT033(client, is, os);
								dxT033.execute(strDX_EX_CODE, objSERVER_INFO);
								break;
								
							case TranCodeType.DxT034 :
								DxT034 dxT034 = new DxT034(client, is, os);
								dxT034.execute(strDX_EX_CODE, jObj);
								break;
		
							case TranCodeType.DxT036 :
								DxT036 dxT036 = new DxT036(client, is, os);
								dxT036.execute(strDX_EX_CODE, jObj);
								break;
				
							
							case TranCodeType.DxT037 :
								DxT037 dxT037 = new DxT037(client, is, os);
								dxT037.execute(strDX_EX_CODE, jObj);
								break;
								
								
							case TranCodeType.DxT038 :
								DxT038 dxT038 = new DxT038(client, is, os);
								dxT038.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT039 :
								DxT039 dxT039 = new DxT039(client, is, os);
								dxT039.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT040 :
								DxT040 dxT040 = new DxT040(client, is, os);
								dxT040.execute(strDX_EX_CODE, jObj);
								break;
		
							case TranCodeType.DxT041 :
								DxT041 dxT041 = new DxT041(client, is, os);
								dxT041.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT042 :
								DxT042 dxT042 = new DxT042(client, is, os);
								dxT042.execute(strDX_EX_CODE, jObj);
								break;
							
							case TranCodeType.DxT043 :
								DxT043 dxT043 = new DxT043(client, is, os);
								dxT043.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT044 :
								DxT044 dxT044 = new DxT044(client, is, os);
								dxT044.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT045 :
								DxT045 dxT045 = new DxT045(client, is, os);
								dxT045.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT046 :
								DxT046 dxT046 = new DxT046(client, is, os);
								dxT046.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT047 :
								DxT047 dxT047 = new DxT047(client, is, os);
								dxT047.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT048 :
								DxT048 dxT048 = new DxT048(client, is, os);
								dxT048.execute(strDX_EX_CODE, jObj);
								break;		
							
							case TranCodeType.DxT049 :
								DxT049 dxT049 = new DxT049(client, is, os);
								dxT049.execute(strDX_EX_CODE, jObj);
								break;
							
							case TranCodeType.DxT050 :
								DxT050 dxT050 = new DxT050(client, is, os);
								dxT050.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT051 :
								DxT051 dxT051 = new DxT051(client, is, os);
								dxT051.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT052 :
								DxT052 dxT052 = new DxT052(client, is, os);
								dxT052.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT053 :
								DxT053 dxT053 = new DxT053(client, is, os);
								dxT053.execute(strDX_EX_CODE, jObj);
								break;
								
							case TranCodeType.DxT054 :
								DxT054 dxT054 = new DxT054(client, is, os);
								dxT054.execute(strDX_EX_CODE, jObj);
								break;
							
							case TranCodeType.DxT055 :
								DxT055 dxT055 = new DxT055(client, is, os);
								dxT055.execute(strDX_EX_CODE, jObj);
								break;
							
							case TranCodeType.DxT056 :
								DxT056 dxT056 = new DxT056(client, is, os);
								dxT056.execute(strDX_EX_CODE, jObj);
								break;
								
								
					}
				}
				
				//프록시, 통합
				if("Y".equals(prop.getProperty("agent.proxy_yn"))) {
					switch(strDX_EX_CODE) {
						//proxy 에이전트 setting
						case TranCodeType.PsP001 : 
							PsP001 psP001 = new PsP001(client, is, os);
							psP001.execute(strDX_EX_CODE, jObj);
							break;
							
						//proxy 에이전트 연결 Test
						case TranCodeType.PsP002 :
							PsP002 psP002 = new PsP002(client, is, os);
							psP002.execute(strDX_EX_CODE, jObj);
							break;
							
						// get config file
						case TranCodeType.PsP003 :
							PsP003 psP003 = new PsP003(client, is, os);
							psP003.execute(strDX_EX_CODE, jObj);
							break;
							
						//proxy conf 파일 백업 & 신규 생성 
						case TranCodeType.PsP004 : 
							PsP004 psP004 = new PsP004(client, is, os);
							psP004.execute(strDX_EX_CODE, jObj);
							break;
							
						//proxy service restart(비활성화)
						case TranCodeType.PsP005 : 
							//PsP005 psP005 = new PsP005(client, is, os);
							//psP005.execute(strDX_EX_CODE, jObj);
							break;
							
						//proxy service start/stop
						case TranCodeType.PsP006 : 
							PsP006 PsP006 = new PsP006(client, is, os);
							PsP006.execute(strDX_EX_CODE, jObj);
							break;
							
						//get network Interface search
						case TranCodeType.PsP007 : 
							PsP007 PsP007 = new PsP007(client, is, os);
							PsP007.execute(strDX_EX_CODE, jObj);
							break;
							
						// get log file search
						case TranCodeType.PsP008 :
							PsP008 PsP008 = new PsP008(client, is, os);
							PsP008.execute(strDX_EX_CODE, jObj);
							break;
							
						// proxy conf 파일 searh 후 데이터 입력 요청
						case TranCodeType.PsP009 : 
							PsP009 PsP009 = new PsP009(client, is, os);
							PsP009.execute(strDX_EX_CODE, jObj);
							break;
							
						// check installed keepalived
						case TranCodeType.PsP010 : 
							PsP010 PsP010 = new PsP010(client, is, os);
							PsP010.execute(strDX_EX_CODE, jObj);
							break;
							
						// 설정 백업 폴더 삭제(비활성화)
						case TranCodeType.PsP011 : 
	//						PsP011 PsP011 = new PsP011(client, is, os);
	//						PsP011.execute(strDX_EX_CODE, jObj);
							break;
							
						// check proxy server
						case TranCodeType.PsP012 : 
							PsP012 PsP012 = new PsP012(client, is, os);
							PsP012.execute(strDX_EX_CODE, jObj);
							break;
							
						// delete backup conf File(비활성화)
						case TranCodeType.PsP013 : 
	//						PsP013 PsP013 = new PsP013(client, is, os);
	//						PsP013.execute(strDX_EX_CODE, jObj);
							break;
							
						// Scale In
						case TranCodeType.PsP014 : 
							PsP014 PsP014 = new PsP014(client, is, os);
							PsP014.execute(strDX_EX_CODE, jObj);
							break;
					}
				}
				objSERVER_INFO = null;
			//}
			
		} catch(Exception e) {
			errLogger.error("{} {}", "experDB Socket Execute Error : ", e.toString());
		}finally{
			try{
				client.close();
			}catch(IOException e){
				errLogger.error("{} {}", "experDB Socket Close Error : ", e.toString());
			}
		}
		
	}
	

}
