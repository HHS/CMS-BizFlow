package com.bizflow.ps.pdf.util;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.junit.*;

import static org.junit.Assert.*;

public class FileUtilityTest {
	private static File moFile;
	private static String moFileAbsolutePath;
	private static File moTempFile;
	private static String moTempFileAbsolutePath;




	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		moFile = new File("testresource/cmsfileutiltest.txt");
		moFile.createNewFile();
		moFileAbsolutePath = moFile.getAbsolutePath();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		if (moFileAbsolutePath != null){
			moFile = new File(moFileAbsolutePath);
			moFileAbsolutePath = null;
		}
		if (moFile != null && moFile.exists()){
			moFile.delete();
		}
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
		if (moTempFileAbsolutePath != null){
			moTempFile = new File(moTempFileAbsolutePath);
			moTempFileAbsolutePath = null;
		}
		if (moTempFile != null && moTempFile.exists()){
			moTempFile.delete();
		}
	}




	@Test
	public void testGetTempFileName() throws Exception {
		moTempFileAbsolutePath = FileUtility.getTempFileName();
		assertNotNull(moTempFileAbsolutePath);
		assertTrue("FileUtility.getTempFileName() should create a file whose name includes CMSPDF", moTempFileAbsolutePath.contains("CMSPDF"));
		assertTrue("FileUtility.getTempFileName() should create a file whose name ends with .pdf", moTempFileAbsolutePath.endsWith(".pdf"));

		moTempFile = new File(moTempFileAbsolutePath);
		assertNotNull(moTempFile);
		assertTrue(moTempFile.exists());
	}

	@Test
	public void testCopy() throws Exception {
		moTempFileAbsolutePath = "testresource/copiedfile.txt";
		FileUtility.copy(moFileAbsolutePath, moTempFileAbsolutePath);
		assertNotNull(moTempFileAbsolutePath);

		moTempFile = new File(moTempFileAbsolutePath);
		assertNotNull(moTempFile);
		assertTrue(moTempFile.exists());
	}

	@Test
	public void testRemoveFiles() throws Exception {
		List<String> loFileList = new ArrayList<String>();
		moTempFileAbsolutePath = "testresource/filetoberemoved.txt";
		moTempFile = new File(moTempFileAbsolutePath);
		moTempFile.createNewFile();
		assertNotNull(moTempFile);
		assertTrue(moTempFile.exists());
		loFileList.add(moTempFileAbsolutePath);

		FileUtility.removeFiles(loFileList);
		assertFalse(moTempFile.exists());
	}

	@Test
	public void testFileExist() throws Exception {
		assertTrue(FileUtility.fileExist(moFileAbsolutePath));
	}

	@Test
	public void testRemoveFile() throws Exception {
		moTempFileAbsolutePath = "testresource/filetoberemoved.txt";
		moTempFile = new File(moTempFileAbsolutePath);
		moTempFile.createNewFile();
		assertNotNull(moTempFile);
		assertTrue(moTempFile.exists());

		FileUtility.removeFile(moTempFileAbsolutePath);
		assertFalse(moTempFile.exists());
	}

	@Test
	public void testTranslatePath() throws Exception {
		String lsResult = null;
		String lsSubResult = null;
		String catalina_home_env = System.getenv("CATALINA_HOME");
		String catalina_home_prop = System.getProperty("catalina.home");
		if (catalina_home_env != null && catalina_home_env.length() > 1) {
			lsResult = FileUtility.translatePath("my/path/here");
			assertTrue(lsSubResult, lsResult.endsWith("/webapps/bizflowwebmaker/WEB-INF/my/path/here"));
		} else if (catalina_home_prop != null && catalina_home_prop.length() > 1) {
			lsResult = FileUtility.translatePath("my/path/here");
			assertTrue(lsSubResult, lsResult.endsWith("/webapps/bizflowwebmaker/WEB-INF/my/path/here"));
		} else {
			lsResult = FileUtility.translatePath("my/path/here");
			assertNull(lsSubResult);
		}
	}

}