package com.bizflow.webmaker;

import com.hyfinity.utils.xml.DOMSerializer;
import com.hyfinity.utils.xml.DOMUtils;
import com.hyfinity.utils.xml.XDocument;
import com.hyfinity.xpath.XPath;
import com.hyfinity.xpath.XPathFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.util.HashMap;
import java.util.Map;

public class LookupManager {
    private static Node data = null;
    private static Node activeData = null;
    private static XPathFactory xpf = XPathFactory.newInstance();
    private static DOMSerializer ds =  createDOMSerializer();
    private static boolean initialized = false;

    static {
        data = new XDocument("<lookup>no_data</lookup>").getDocument();
        activeData = new XDocument("<lookup>no_data</lookup>").getDocument();
    }

    public static String isInitialized(){
        return Boolean.toString(initialized);
    }
    /**
     * Return data
     * @param includeInactiveData If true, return active and inactive data
     * @return
     */
    public static Node get(boolean includeInactiveData) {
        return includeInactiveData ? data : activeData;
    }

    /**
     * @param types example: "payplan,grade"
     */
    public static Node getByLtype(String types, boolean includeInactiveData)  throws Exception{
        String list[] = types.split(",");
        String xpath = "//record[";
        for (int i = 0; i < list.length; i++) {
            xpath += " LTYPE='" + list[i] +"' or";
        }
        xpath = xpath.substring(0, xpath.length()-2);
        xpath += "]";

        return getByXPath(xpath, includeInactiveData);
    }

    /**
     * @param categories example: "CMS,NF"
     */
    public static Node getByCategory(String categories, boolean includeInactiveData)  throws Exception{
        String list[] = categories.split(",");
        String xpath = "//record[";
        for (int i = 0; i < list.length; i++) {
            xpath += " CATEGORY='" + list[i] +"' or";
        }
        xpath = xpath.substring(0, xpath.length()-2);
        xpath += "]";
        return getByXPath(xpath, includeInactiveData);
    }

    /**
     * @param xpath //record[LTYPE='Grade' or LTYPE='PayPlan']
     */
    public static Node getByXPath(String xpath, boolean includeInactiveData)  throws Exception{
        XPath xp = xpf.newXPath(xpath);
        NodeList list = xp.selectNodeList(get(includeInactiveData));
        Document doc = new XDocument("<lookup></lookup>").getDocument();
        Node node = doc.getDocumentElement();
        for (int i = 0; i < list.getLength(); i++) {
            Node record = list.item(i);
            Node newRecord = doc.importNode(record, true);
            node.appendChild(newRecord);
        }
        return node;
    }

    private static Node getByXPath(Node nodeData, String xpath) throws Exception{
        XPath xp = xpf.newXPath(xpath);
        NodeList list = xp.selectNodeList(nodeData);
        Document doc = new XDocument("<lookup></lookup>").getDocument();
        Node node = doc.getDocumentElement();
        for (int i = 0; i < list.getLength(); i++) {
            Node record = list.item(i);
            Node newRecord = doc.importNode(record, true);
            node.appendChild(newRecord);
        }
        return node;
    }

    public static String getByXPathAsString(String xpath, boolean includeInactiveData){
        try{
            Node node = getByXPath(xpath, includeInactiveData);
            return ds.serialize(node);
        }catch(Exception e){
            return e.getMessage();
        }
    }

    public static String getByLtypeAsString(String types, boolean includeInactiveData){
        try{
            Node node = getByLtype(types, includeInactiveData);
            return ds.serialize(node);
        }catch(Exception e){
            return e.getMessage();
        }
    }

    public static String getByCategoryAsString(String categories, boolean includeInactiveData){
        try{
            Node node = getByCategory(categories, includeInactiveData);
            return ds.serialize(node);
        }catch(Exception e){
            return e.getMessage();
        }
    }

    public static synchronized String put(Node xml) {
        try{
            data = xml;
            activeData = getByXPath(xml, "//record[ACTIVE=1]");
            initialized = true;
            return "saved";
        }catch (Exception e){
            return "not_saved: " + e.getMessage();
        }
    }

    public static String remove() {
        try{
            data = new XDocument("<lookup>no_data</lookup>").getDocument();
            initialized = false;
            return "removed";
        }catch (Exception e){
            return "not_removed: " + e.getMessage();
        }
    }

    private static DOMSerializer createDOMSerializer() {
        DOMSerializer ds = DOMUtils.getSpecificSerializer();
        Map entities = new HashMap();
        entities.put("<", "&lt;");
        entities.put(">", "&gt;");
        entities.put("'", "&apos;");
        entities.put("\"", "&quot;");
        entities.put("&", "&amp;");
        ds.setEntities(entities);
        ds.setDoOutputEscaping(false);
        ds.setDoRootDefaultNamespace(true);
        ds.setPrettyPrint(false);
        ds.setXmlDeclarationOutput(false);
        return ds;
    }


}
