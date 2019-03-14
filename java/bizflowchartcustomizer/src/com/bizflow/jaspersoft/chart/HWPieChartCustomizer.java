package com.bizflow.jaspersoft.chart;

import java.awt.Color;
import java.awt.Font;
import java.util.HashMap;
import java.util.Map;
import net.sf.jasperreports.engine.JRChart;
import net.sf.jasperreports.engine.JRChartCustomizer;
import net.sf.jasperreports.engine.JRPropertiesMap;
import net.sf.jasperreports.engine.util.JRColorUtil;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.MeterPlot;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.Plot;

/**
 *
 * <h1>BizFlow Pie Chart Customizer</h1>
 *
 * @version 1.0
 *
 * <p>
 * This chart customizer allows to set the following new custom JFreeChart properties:
 * </p>
 *
 * <ul>
 *    <li>Label Font</li>
 *    <li>Interior Gap</li>
 *    <li>Maximum Label Width</li>
 *    <li>Defining a pie slice's color based on key
 *    (default behavior of JFreeChart is setting it based on the order they appear in)</li>
 * </ul>
 *
 * <p>
 * This property applies only to <b>Pie plots</b>.<br/>
 * The properties should be set using the <b>"Properties expressions"</b> field in iReport.<br/>
 * .jrxml will look like the following:<br/>
 * </p>
 *
 * <p>
 *   <xmp style="color:green;font-size:12px;">
 *      <property name="LabelFontName" value="Arial"/>
 *      <property name="LabelFontStyle" value="0"/>
 *      <propertyExpression name="LabelFontStyle"><![CDATA[java.awt.Font.PLAIN]]></propertyExpression>
 *      <property name="LabelFontSize" value="8"/>
 *      <property name="InteriorGap" value="0.02"/>
 *      <property name="MaximumLabelWidth" value="0.28"/>
 *      <property name="PredefinedColors" value="Apple:#015A84;Orange:red;Strawberry:#0085B0;Pear:#F8EB33"/><br/>
 *   </xmp>
 * </p>
 *
 * <p>
 *      For LabelFontStyle
 *      <a href="https://docs.oracle.com/javase/7/docs/api/java/awt/Font.html">
 *          Click here to see details of Field Summary of java.awt.Font
 *      </a>
 * </p>
 *
 * <table border="1">
 * <tr>
 * <td>
 *
 *   <p>
 *   The property PredefinedColors must be in this form with Delimiter "<b style="color:red">;</b>":
 *   </p>
 *
 *   <p style="font-weight:bold;">
 *   	key-expression1:color1<span style="color:red">;</span>key-expression2:color2
 *      <br/><br/>
 *      e.g Apple:#015A84;Orange:red;Strawberry:#0085B0;Pear:#F8EB33
 *   </p>
 *
 *   <p>
 *   The color must be in the form #000000 representing an RGB value of 3 hex values preceded by the hash sign,<br/>
 *   	or it may be one of JasperReports's predefined colors listed here:<br/>
 * 		<a href="http://jasperreports.sourceforge.net/api/net/sf/jasperreports/engine/type/ColorEnum.html">http://jasperreports.sourceforge.net/api/net/sf/jasperreports/engine/type/ColorEnum.html</a><br/>
 *   	black, blue, cyan, darkGray, gray, green, lightGray, magenta, orange, pink, red, white, yellow<br/>
 *   </p>
 *
 * </td>
 * </tr>
 * </table>
 *
 * <hr/>
 *
 * <h1>BizFlow Metaplot Chart Customizer</h1>
 *
 * <h3>Tick Label Font</h3>
 *
 * <p>
 * This property applies only to MeterPlot plots.<br/>
 * The properties should be set using the <b>"Properties expressions"</b> field in iReport.<br/>
 * .jrxml will look like the following:<br/>
 * </p>
 *
 * <p>
 *   <xmp style="color:green;font-size:12px;">
 *      <property name="TickLabelFontName" value="Arial"/>
 *      <property name="TickLabelFontStyle" value="Font.PLAIN"/>
 *      <property name="TickLabelFontSize" value="8"/>
 *   </xmp>
 * </p>
 *
 * source: mdahlman
 */

public class HWPieChartCustomizer implements JRChartCustomizer {

    private static Log log = LogFactory.getLog(HWPieChartCustomizer.class);

    public HWPieChartCustomizer() {

    }

    public void customize(JFreeChart chart, JRChart jasperChart) {
        if (log.isDebugEnabled()) {
            log.debug("################## DEBUG info from HWPieChartCustomizer ##################");
        }

        //ChartLabel
        String labelFontName = null;
        int    labelFontStyle = -1;
        int    labelFontSize = -1;
        double interiorGap = -1.0;
        double maximumLabelWidth= -1.0;
        String predefinedColors = null;

        //TickerLabel
        String tickLabelFontName  = "";
        int    tickLabelFontStyle = -1;
        int    tickLabelFontSize  = -1;

        // Gather all of the new properties set on the chart object
        // Font default information:
        //   If the font name is null then this chart customizer makes no change to the default font choice.
        //   If the font name is not valid, then the font system will map the Font instance to "Dialog"
        //   If unspecified, the font style will be PLAIN
        //   If unspecified, the font size will be 8 (we assume these labels should generally be quite small)
        JRPropertiesMap pm = jasperChart.getPropertiesMap();
        if (pm != null) {
            labelFontName     = pm.getProperty("LabelFontName");
            labelFontStyle    = (pm.getProperty("LabelFontStyle") == null) ? Font.PLAIN : Integer.parseInt(pm.getProperty("LabelFontStyle"));
            labelFontSize     = (pm.getProperty("LabelFontSize") == null) ? 8 : Integer.parseInt(pm.getProperty("LabelFontSize"));
            interiorGap       = (pm.getProperty("InteriorGap") == null) ? -1.0 : Double.parseDouble(pm.getProperty("InteriorGap"));
            maximumLabelWidth = (pm.getProperty("MaximumLabelWidth") == null) ? -1.0 : Double.parseDouble(pm.getProperty("MaximumLabelWidth"));
            predefinedColors  = pm.getProperty("PredefinedColors");
        }

        if (log.isDebugEnabled()) {
            log.debug(pm);
            log.debug("----------");
            log.debug("labelFontName: " + labelFontName);
            log.debug("labelFontStyle: " + labelFontStyle);
            log.debug("labelFontSize: " + labelFontSize);
            log.debug("interiorGap: " + interiorGap);
            log.debug("maximumLabelWidth: " + maximumLabelWidth);
            log.debug("----------");
            log.debug("tickLabelFontName: " + tickLabelFontName);
            log.debug("tickLabelFontStyle: " + tickLabelFontStyle);
            log.debug("tickLabelFontSize: " + tickLabelFontSize);
        }

        // This chart customizer requires that the PredefinedColors string is well formatted.
        // First split the string into an array of strings of the form "Pie Piece Key:Color"
        String[] entries = predefinedColors.split(";");
        Map<String, Color> pieSections = new HashMap<String, Color>();
        for (int i=0; i<entries.length; i++) {
            String value = entries[i];
            if (value != null) {
                // For each value we split it into its 2 constituent parts. The first is only required to be String, so there is no risk.
                // The second part is the color. We rely on JRColorUtil to deal with any badly defined colors.
                String[] pair = entries[i].split(":");
                if (pair[0] != null && pair[1] != null) {
                    pieSections.put(pair[0], JRColorUtil.getColor(pair[1], null));
                }
            }
        }

        //--------------------------------------------------------------------------------------------------------------
        // This customizer works only with Pie Charts.
        // It silently ignores all other chart types.
        Plot plot = chart.getPlot();
        if (plot instanceof PiePlot) {
            if (log.isDebugEnabled())
                log.debug("PiePlot-----");
            PiePlot piePlot = (PiePlot)plot;
            Font labelFont = null;
            try {
                labelFont = new Font(labelFontName, labelFontStyle, labelFontSize);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            if (labelFontName != null) {
                piePlot.setLabelFont(labelFont);
            }

            if (interiorGap != -1.0) {
                piePlot.setInteriorGap(interiorGap);
            }
            if (maximumLabelWidth != -1.0) {
                piePlot.setMaximumLabelWidth(maximumLabelWidth);
            }

            if (predefinedColors != null) {
                for (String key : pieSections.keySet()) {
                    if (log.isDebugEnabled())
                        log.debug("key=" + key + ", value=" + pieSections.get(key));
                    piePlot.setSectionPaint(key, pieSections.get(key));
                }
            }
        }


        //--------------------------------------------------------------------------------------------------------------
        // This customizer works only with Meter Charts.
        // It silently ignores all other chart types.
        if (plot instanceof MeterPlot) {
            if (log.isDebugEnabled())
                log.debug("MeterPlot-----");
            MeterPlot meterPlot = (MeterPlot)plot;
            Font labelFont = null;
            try {
                labelFont = new Font(tickLabelFontName, tickLabelFontStyle, tickLabelFontSize);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            if (labelFont != null) {
                if (log.isDebugEnabled())
                    log.debug("labelFont=" + labelFont.toString());
                meterPlot.setTickLabelFont(labelFont);
            }
        }
    }
}
