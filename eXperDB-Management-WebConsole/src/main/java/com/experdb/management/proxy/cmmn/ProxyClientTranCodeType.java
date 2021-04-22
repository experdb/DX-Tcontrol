package com.experdb.management.proxy.cmmn;

/**
* @author 박태혁
* @see
* 
*      <pre>
* == 개정이력(Modification Information) ==
*
*   수정일       수정자           수정내용
*  -------     --------    ---------------------------
*  
*      </pre>
*/
public class ProxyClientTranCodeType {
	public static final String PsP001 = "PsP001";	// proxy 에이전트 실행
	public static final String PsP002 = "PsP002"; 	// proxy 에이전트 연결 Test
	public static final String PsP003 = "PsP003"; 	// proxy, keepalived conf 파일 가져오기
	public static final String PsP004 = "PsP004"; 	// proxy conf 파일 백업 & 신규 생성 
	public static final String PsP005 = "PsP005"; 	// proxy service restart
	public static final String PsP006 = "PsP006"; 	// proxy service start/stop
	public static final String PsP007 = "PsP007"; 	// proxy agent interface
	public static final String PsP008 = "PsP008"; 	// proxy log 파일 가져오기
	
	public static final String STATUS = "STATUS";
	public static final String STOP = "STOP";
	public static final String CLOSE = "CLOSE";

	/**
	 * 결과
	 */
	public static final String RESULT = "RESULT";								  //결과
	
	
}