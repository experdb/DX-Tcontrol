package com.k4m.dx.tcontrol.db2pg.history.service.impl;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Repository;

import com.k4m.dx.tcontrol.db2pg.history.service.Db2pgHistoryVO;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;

@Repository("db2pgHistoryDAO")
public class Db2pgHistoryDAO extends EgovAbstractMapper{

	public void insertMigExe(Map<String, Object> param) throws SQLException {
		insert("db2pgHistorySql.insertMigExe", param);
	}

	public void updateMigExe(Map<String, Object> param) {
		update("db2pgHistorySql.updateMigExe", param);
	}
	
	public List<Db2pgHistoryVO> selectDb2pgHistory(Db2pgHistoryVO db2pgHistoryVO) {
		List<Db2pgHistoryVO> result = null;
		result = (List<Db2pgHistoryVO>) list("db2pgHistorySql.selectDb2pgHistory", db2pgHistoryVO);
		return result;
	}

	public Db2pgHistoryVO selectDb2pgHistoryDetail(int imd_exe_sn) throws SQLException {
		return (Db2pgHistoryVO) selectOne("db2pgHistorySql.selectDb2pgHistoryDetail", imd_exe_sn);
	}

	public int lastMigExe() throws SQLException {
		return selectOne("db2pgHistorySql.selectLastMigExe");
	}

	public List<Db2pgHistoryVO> selectDb2pgDDLHistory(Db2pgHistoryVO db2pgHistoryVO) {
		List<Db2pgHistoryVO> result = null;
		result = (List<Db2pgHistoryVO>) list("db2pgHistorySql.selectDb2pgDDLHistory", db2pgHistoryVO);
		return result;
	}

	public List<Db2pgHistoryVO> selectDb2pgMigHistory(Db2pgHistoryVO db2pgHistoryVO) {
		List<Db2pgHistoryVO> result = null;
		result = (List<Db2pgHistoryVO>) list("db2pgHistorySql.selectDb2pgMigHistory", db2pgHistoryVO);
		return result;
	}
}
