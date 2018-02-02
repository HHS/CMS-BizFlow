package com.bizflow.ps.pdf.util;


import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.HashMap;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathFactory;

import org.junit.*;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;


import static org.junit.Assert.*;

public class XMLUtilityTest {

	private static DocumentBuilderFactory dbf;
	private static DocumentBuilder db;
	private static Document doc;
	private static String moXmlString;
	private static String moMapXmlString;




	@BeforeClass
	public static void setUpBeforeClass() throws Exception {

		dbf = DocumentBuilderFactory.newInstance();
		db = dbf.newDocumentBuilder();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {

		dbf = null;
		db = null;
		doc = null;
	}

	@Before
	public void setUp() throws Exception {

		moXmlString =
				"<docRoot>" +
					"<childOne priority=\"3\">" +
						"<grandChildOne resemblePercent=\"45.26\" gender=\"male\">" +
							"child 1-1" +
						"</grandChildOne>" +
						"child 1" +
					"</childOne>" +
					"<childTwo priority=\"2\">" +
						"child 2" +
					"</childTwo>" +
					"<childThree priority=\"6\"/>" +
				"</docRoot>";

		//doc = db.parse(new FileInputStream(new File("testresource/PDF_PDCoversheet.xml")));
		doc = db.parse(new ByteArrayInputStream(moXmlString.getBytes()));
	}

	@After
	public void tearDown() throws Exception {
	}




	@Test
	public void testGetIntAttribute() throws Exception {
		int returnInt = -1;
		boolean found = false;
		Element elem = null;
		Node loNode = null;
		NodeList loNodeList = doc.getChildNodes();
		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("docRoot")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<docRoot> element expected to be found.", found);

		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("childOne")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<childOne> element expected to be found.", found);
		assertNotNull(loNode);

		elem = (Element)loNode;
		returnInt = XMLUtility.getIntAttribute(elem, "priority");
		assertEquals(3, returnInt);
	}

	@Test
	public void testGetIntAttributeWithDefault() throws Exception {
		int returnInt = -1;
		boolean found = false;
		Element elem = null;
		Node loNode = null;
		NodeList loNodeList = doc.getChildNodes();
		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("docRoot")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<docRoot> element expected to be found.", found);
		assertNotNull(loNode);

		elem = (Element)loNode;
		returnInt = XMLUtility.getIntAttribute(elem, "priority", -200);
		assertEquals(-200, returnInt);
	}

	@Test
	public void testGetFloatAttribute() throws Exception {
		float returnFloat = 0f;
		boolean found = false;
		Element elem = null;
		Node loNode = null;
		NodeList loNodeList = doc.getChildNodes();
		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("docRoot")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<docRoot> element expected to be found.", found);

		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("childOne")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<childOne> element expected to be found.", found);

		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("grandChildOne")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<grandChildOne> element expected to be found.", found);
		assertNotNull(loNode);

		elem = (Element)loNode;
		returnFloat = XMLUtility.getFloatAttribute(elem, "resemblePercent");
		assertEquals(45.26f, returnFloat, 0.00001f);
	}

	@Test
	public void testGetFloatAttributeWithDefault() throws Exception {
		float returnFloat = 0f;
		boolean found = false;
		Element elem = null;
		Node loNode = null;
		NodeList loNodeList = doc.getChildNodes();
		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("docRoot")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<docRoot> element expected to be found.", found);

		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("childOne")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<childOne> element expected to be found.", found);

		for (int i = 0; i < loNodeList.getLength(); i++){
			loNode = loNodeList.item(i);
			if (loNode.getNodeType() == Node.ELEMENT_NODE && loNode.getNodeName().equals("grandChildOne")){
				loNodeList = loNode.getChildNodes();
				found = true;
				break;
			}
		}
		assertTrue("<grandChildOne> element expected to be found.", found);
		assertNotNull(loNode);

		elem = (Element)loNode;
		//TODO: getFloatAttribute with default value cannot distinguish the case where the attribute doesn't exist
		//      from the case where the attribute value is empty.  Enhance the method to handle those cases.
		returnFloat = XMLUtility.getFloatAttribute(elem, "gender", -100.1234f);
		assertEquals(-100.1234f, returnFloat, 0.00001f);
	}

	@Test
	public void testGenerateValueMap() throws Exception {

		File xmlFile2 = new File("testresource/TEST_LOOKUP.xml");
		DocumentBuilderFactory dbFactory2 = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder2 = dbFactory2.newDocumentBuilder();
		Document document2 = builder2.parse(xmlFile2);
		document2.getDocumentElement().normalize();
		LookupUtility.initialize(document2);
		String loXmlString = null;
		Map<String, String> expectedMap = null;
		Map<String, String> actualMap = null;

		loXmlString =
			"<docRoot>" +
				"<Employee>" +
					"<EmpId>1234567</EmpId>" +
					"<FirstName>Michael</FirstName>" +
					"<LastName>Jackson</LastName>" +
					"<Gender>M</Gender>" +
					"<IsActive>Y</IsActive>" +
					"<Department>Customer Relations</Department>" +
					"<PayPlan>45</PayPlan>" +
				"</Employee>" +
			"</docRoot>";
		doc = db.parse(new ByteArrayInputStream(loXmlString.getBytes()));

		expectedMap = new HashMap<String, String>();
		expectedMap.put("#EMP_ID", "1234567");
		expectedMap.put("#FIRST_NM", "Michael");
		expectedMap.put("#LAST_NM", "Jackson");
		expectedMap.put("#GENDER", "Male");
		expectedMap.put("#ACTIVE_FL", "Yes");
		expectedMap.put("#DEPT", "Customer Relations");
		expectedMap.put("#PAY_PLAN", "GS");

		actualMap = XMLUtility.generateValueMap("testresource/test_map.xml", doc);

		assertEquals(expectedMap, actualMap);

		//---------------------------------------------------------------------
		loXmlString =
			"<docRoot>" +
				"<Employee>" +
					"<EmpId>987654</EmpId>" +
					"<FirstName>Christina</FirstName>" +
					"<LastName>Agilera</LastName>" +
					"<Gender>F</Gender>" +
					"<IsActive>N</IsActive>" +
					"<Department>Medical Research</Department>" +
					"<PayPlan>36</PayPlan>" +
				"</Employee>" +
			"</docRoot>";
		doc = db.parse(new ByteArrayInputStream(loXmlString.getBytes()));

		expectedMap = new HashMap<String, String>();
		expectedMap.put("#EMP_ID", "987654");
		expectedMap.put("#FIRST_NM", "Christina");
		expectedMap.put("#LAST_NM", "Agilera");
		expectedMap.put("#GENDER", "Female");
		expectedMap.put("#ACTIVE_FL", "No");
		expectedMap.put("#DEPT", "Medical Research");
		expectedMap.put("#PAY_PLAN", "AD");

		actualMap = XMLUtility.generateValueMap("testresource/test_map.xml", doc);

		assertEquals(expectedMap, actualMap);
	}

	@Test
	public void testGetValue() throws Exception {
		XPathFactory xPathFactory = XPathFactory.newInstance();
		XPath xpath = xPathFactory.newXPath();
		String lsResult = null;

		lsResult  = XMLUtility.getValue(xpath, doc, "/docRoot/childOne/text()");
		assertEquals("child 1", lsResult);
		lsResult  = XMLUtility.getValue(xpath, doc, "/docRoot/childTwo");
		assertEquals("child 2", lsResult);
		lsResult  = XMLUtility.getValue(xpath, doc, "/docRoot/childThree");
		assertEquals("", lsResult);
	}

}