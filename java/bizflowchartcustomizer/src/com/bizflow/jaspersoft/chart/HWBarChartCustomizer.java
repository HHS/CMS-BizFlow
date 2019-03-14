package com.bizflow.jaspersoft.chart;

import net.sf.jasperreports.engine.JRAbstractChartCustomizer;
import net.sf.jasperreports.engine.JRChart;
import net.sf.jasperreports.engine.JRChartCustomizer;
import net.sf.jasperreports.engine.JRPropertiesMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.plot.*;
import org.jfree.chart.renderer.category.BarRenderer;

/**
 *
 * <h1>BizFlow Line/Bar Chart Customizer</h1>
 *
 * @version 1.0
 *
 * <p>
 * This chart customizer allows to set the following new custom JFreeChart properties:
 * </p>
 *
 * <ul>
 *   <li>UpperMargin
 *   <li>MaximumCategoryLabelWidthRatio
 *   <li>MaximumCategoryLabelLines
 *   <li>ItemMargin
 *   <li>IntegerTickUnits
 * </ul>
 *
 * <p>
 * These properties apply only to <b>Category plots (e.g. line charts and bar charts)</b>.<br/>
 * The properties needs be set using the "Properties expressions" field in iReport. <br/>
 * .jrxml will look like the following:<br/>
 * </p>
 *
 * <p>
 *   <xmp style="color:green;font-size:12px;">
 *   <property name="MaximumCategoryLabelWidthRatio" value="1.5f"/>
 *   <property name="ItemMargin" value="0.0f"/>
 *   <property name="MaximumCategoryLabelLines" value="2"/>
 *   <property name="UpperMargin" value="0.40"/>
 *   </xmp>
 * </p>
 *
 * source: mdahlman
 */

public class HWBarChartCustomizer extends JRAbstractChartCustomizer implements JRChartCustomizer {

    private static Log log = LogFactory.getLog(HWBarChartCustomizer.class);

    public HWBarChartCustomizer() {

    }

    public void customize(JFreeChart chart, JRChart jasperChart) {
        if (log.isDebugEnabled()) {
            log.debug("HWBarChartCustomizer customizing...");
        }

        // Gather all of the properties set on the chart object
        JRPropertiesMap pm = jasperChart.getPropertiesMap();
        double upperMargin = (pm.getProperty("UpperMargin") == null) ? -1 : Double.parseDouble(pm.getProperty("UpperMargin"));
        float maximumCategoryLabelWidthRatio = (pm.getProperty("MaximumCategoryLabelWidthRatio") == null) ? -1 : Float.parseFloat(pm.getProperty("MaximumCategoryLabelWidthRatio"));
        float itemMargin = (pm.getProperty("ItemMargin") == null) ? -1 : Float.parseFloat(pm.getProperty("ItemMargin"));
        int maximumCategoryLabelLines = (pm.getProperty("MaximumCategoryLabelLines") == null) ? -1 : Integer.parseInt(pm.getProperty("MaximumCategoryLabelLines"));
        boolean useIntegerTickUnits = (pm.getProperty("IntegerTickUnits") == null || !pm.getProperty("IntegerTickUnits").equals("true")) ? false : true;
        if (log.isDebugEnabled())
            log.debug(pm);

        // This customizer works only with Category Plots
        // (like Line Charts and Bar Charts).
        Plot plot = chart.getPlot();
        if (plot instanceof CategoryPlot) {
            if (log.isDebugEnabled())
                log.debug("CategoryPlot-----");
            CategoryPlot categoryPlot = (CategoryPlot)plot;
            ValueAxis valueAxis = categoryPlot.getRangeAxis();
            CategoryAxis categoryAxis = categoryPlot.getDomainAxis();

            if (useIntegerTickUnits) {
                valueAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
            }

            // The default upper margin is 5%.
            // This is not good if labels are displayed.
            // The value must be a percentage between 0 and 1.
            if ( upperMargin >= 0 && upperMargin <= 1 ) {
                valueAxis.setUpperMargin(upperMargin);
            }

            // The default MaximumCategoryLabelWidthRatio is too small in many cases.
            if ( maximumCategoryLabelWidthRatio > 0 ) {
                categoryAxis.setMaximumCategoryLabelWidthRatio(maximumCategoryLabelWidthRatio);
            }

            // The ItemMargin is the space between bars within a single category.
            // The default value is 10% (0.10).
            // It's common to want this smaller.
            if (categoryPlot.getRenderer() instanceof BarRenderer) {
                BarRenderer barRenderer = (BarRenderer)categoryPlot.getRenderer();
                if (itemMargin >= 0 && itemMargin <= 1) {
                    barRenderer.setItemMargin(itemMargin);
                }
            }

            // By default category labels are a single line.
            if ( maximumCategoryLabelLines > 0 ) {
                categoryAxis.setMaximumCategoryLabelLines(maximumCategoryLabelLines);
            }

        }

    }

}
