package com.bizflow.jaspersoft.chart;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.awt.*;
import java.util.HashMap;
import java.util.Map;

import net.sf.jasperreports.engine.JRAbstractChartCustomizer;
import net.sf.jasperreports.engine.JRChart;
import net.sf.jasperreports.engine.JRChartCustomizer;
import net.sf.jasperreports.engine.JRPropertiesMap;
import net.sf.jasperreports.engine.util.JRColorUtil;

import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.*;
import org.jfree.chart.plot.*;
import org.jfree.chart.LegendItemCollection;
import org.jfree.chart.LegendItem;
import org.jfree.chart.block.BlockBorder;
import org.jfree.chart.renderer.category.GroupedStackedBarRenderer;
import org.jfree.chart.title.LegendTitle;
import org.jfree.data.KeyToGroupMap;
import org.jfree.data.category.CategoryDataset;
import org.jfree.ui.RectangleEdge;
import org.jfree.ui.VerticalAlignment;

/**
 *
 * <h1>BizFlow Stacked Group Bar Chart Customizer</h1>
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
 *   <li>CategoryMargin
 *   <li>Groups
 *   <li>SeriesGroups
 *   <li>SeriesColors
 *   <li>LegendColors
 *   <li>SubLabelFont
 *   <li>SubLabelFontSize
 *   <li>SubLabelFontColor
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
 *   <property name="UpperMargin" value="0.40"/>
 *   <property name="MaximumCategoryLabelWidthRatio" value="1.5f"/>
 *   <property name="MaximumCategoryLabelLines" value="2"/>
 *   <property name="ItemMargin" value="0.03"/>
 *   <property name="CategoryMargin" value="0.1"/>
 *   <property name="Groups" value="Product 1;Product 2;Product 3"/>
 *   <property name="SeriesGroups" value="Product 1 (US):G1;Product 1 (Europe):G1;Product 1 (Asia):G1;Product 2 (US):G1;Product 2 (Europe):G1;Product 2 (Asia):G1;Product 3 (US):G1;Product 3 (Europe):G1;Product 3 (Asia):G1"/>
 *   <property name="SeriesColors" value="Product 1 (US):#015A84;Product 1 (Europe):#0085B0;Product 1 (Asia):#F8EB33;Product 2 (US):#015A84;Product 2 (Europe):#0085B0;Product 2 (Asia):#F8EB33;Product 3 (US):#015A84;Product 3 (Europe):#0085B0;Product 3 (Asia):#F8EB33;"/>
 *   <property name="LegendColors" value="US:#015A84;Europe:#0085B0;Asia:#F8EB33;"/>
 *   <property name="SubLabelFont" value="Arial"/>
 *   <property name="SubLabelFontSize" value="Arial"/>
 *   <property name="SubLabelFontColor" value="#F8EB33"/>
 *   </xmp>
 * </p>
 *
 * source: mdahlman
 */


public class HWStackedBarChartCustomizer extends JRAbstractChartCustomizer implements JRChartCustomizer {
    private static Log log = LogFactory.getLog(HWStackedBarChartCustomizer.class);

    public HWStackedBarChartCustomizer() {

    }

    public void customize(JFreeChart chart, JRChart jasperChart) {
        if (log.isDebugEnabled()) {
            log.debug("HWStackedBarChartCustomizer customizing...");
        }

        //----------------------------------------------------------------------
        // Gather all of the properties set on the chart object
        //----------------------------------------------------------------------
		/*
            <reportElement x="60" y="10" width="470" height="360" uuid="9dbd723b-35c3-4bba-90b3-d17ee063e238">
                <property name="MaximumCategoryLabelWidthRatio" value="1.5f"/>
                <property name="ItemMargin" value="0.03"/>
                <property name="CategoryMargin" value="0.1"/>
                <property name="MaximumCategoryLabelLines" value="2"/>
                <property name="UpperMargin" value="0.40"/>
                <property name="CategoryTitle" value="Product/Month"/>
                <property name="Groups" value="Product 1;Product 2;Product 3"/>
                <property name="SeriesGroups" value="Product 1 (US):G1;Product 1 (Europe):G1;Product 1 (Asia):G1;Product 2 (US):G1;Product 2 (Europe):G1;Product 2 (Asia):G1;Product 3 (US):G1;Product 3 (Europe):G1;Product 3 (Asia):G1"/>
                <property name="SeriesColors" value="Product 1 (US):#015A84;Product 1 (Europe):#0085B0;Product 1 (Asia):#F8EB33;Product 2 (US):#015A84;Product 2 (Europe):#0085B0;Product 2 (Asia):#F8EB33;Product 3 (US):#015A84;Product 3 (Europe):#0085B0;Product 3 (Asia):#F8EB33;"/>
                <property name="LegendColors" value="US:#015A84;Europe:#0085B0;Asia:#F8EB33;"/>
                <property name="SubLabelFont" value="Arial"/>
                <property name="SubLabelFontSize" value="Arial"/>
                <property name="SubLabelFontColor" value="#F8EB33"/>
                <property name="LegendPosition" value="RIGHT"/>
            </reportElement>
        */

        JRPropertiesMap pm = jasperChart.getPropertiesMap();
        double upperMargin = (pm.getProperty("UpperMargin") == null) ? -1 : Double.parseDouble(pm.getProperty("UpperMargin"));
        float maximumCategoryLabelWidthRatio = (pm.getProperty("MaximumCategoryLabelWidthRatio") == null) ? -1 : Float.parseFloat(pm.getProperty("MaximumCategoryLabelWidthRatio"));
        float itemMargin = (pm.getProperty("ItemMargin") == null) ? -1 : Float.parseFloat(pm.getProperty("ItemMargin"));
        float categoryMargin = (pm.getProperty("CategoryMargin") == null) ? -1 : Float.parseFloat(pm.getProperty("CategoryMargin"));
        int maximumCategoryLabelLines = (pm.getProperty("MaximumCategoryLabelLines") == null) ? -1 : Integer.parseInt(pm.getProperty("MaximumCategoryLabelLines"));
        boolean useIntegerTickUnits = (pm.getProperty("IntegerTickUnits") == null || !pm.getProperty("IntegerTickUnits").equals("true")) ? false : true;


        String categoryTitle  = pm.getProperty("CategoryTitle");
        String groups  = pm.getProperty("Groups");
        String seriesGroups  = pm.getProperty("SeriesGroups");
        String seriesColors  = pm.getProperty("SeriesColors");
        String legendColors = pm.getProperty("LegendColors");
        //String backgroundColor = pm.getProperty("BackgroundColor");
        String subLabelFont  = pm.getProperty("SubLabelFont");
        int subLabelFontSize = (pm.getProperty("SubLabelFontSize") == null) ? -1 : Integer.parseInt(pm.getProperty("SubLabelFontSize"));
        String subLabelFontColor = pm.getProperty("SubLabelFontColor");
        String legendPosition = pm.getProperty("LegendPosition");

        //BarChart -----------------------------------------------
        // This customizer works only with Category Plots
        // (like Line Charts and Bar Charts).
        Plot plot = chart.getPlot();
        if (plot instanceof CategoryPlot) {
            if (log.isDebugEnabled())
                log.debug("CategoryPlot-----");

            jasperChart.setLegendBackgroundColor(Color.DARK_GRAY);
            if (pm != null)
                System.out.println(pm.toString());

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

            // By default category labels are a single line.
            if ( maximumCategoryLabelWidthRatio > 0 ) {
                categoryAxis.setMaximumCategoryLabelWidthRatio(maximumCategoryLabelWidthRatio);
            }

            //categoryPlot.setBackgroundPaint(SystemColor.GREEN); //CONFIGURABLE:change background color

            GroupedStackedBarRenderer renderer = new GroupedStackedBarRenderer();

            renderer.setItemMargin(itemMargin);

            //----------------------------------------------------------------------
            //Group series into Categories
            //----------------------------------------------------------------------
            KeyToGroupMap map = new KeyToGroupMap("G1");
            String[] items = seriesGroups.split(";");
            for (int i=0; i<items.length; i++) {
                String value = items[i];
                if (value != null) {
                    String[] pair = items[i].split(":");
                    if (pair[0] != null && pair[1] != null) {
                        map.mapKeyToGroup(pair[0], pair[1]);
                    }
                }
            }
            renderer.setSeriesToGroupMap(map);

            //----------------------------------------------------------------------
            //Sub Categories
            //----------------------------------------------------------------------
            SubCategoryAxis subCategoryAxis = new SubCategoryAxis(categoryTitle);

            subCategoryAxis.setCategoryMargin(categoryMargin); //CONFIGURABLE

            //Add SUB CATEGORIES
            items = groups.split(";");
            for (int i=0; i<items.length; i++) {
                subCategoryAxis.addSubCategory(items[i]);
            }

            //Set Sub Label style
            Font ft = new Font(subLabelFont, Font.PLAIN, subLabelFontSize);
            subCategoryAxis.setSubLabelFont(ft);
            subCategoryAxis.setSubLabelPaint( JRColorUtil.getColor(subLabelFontColor, null));
            //subCategoryAxis.setLabelAngle(90);
            subCategoryAxis.setMaximumCategoryLabelLines(maximumCategoryLabelLines);

            //-------------------------------------------------------------
            // Set color by series name
            //-------------------------------------------------------------
            items = seriesColors.split(";");
            Map<String, Color> seriesColorMap = new HashMap<String, Color>();
            Map<String, Color> seriesColorMap2 = new HashMap<String, Color>();
            for (int i=0; i<items.length; i++) {
                String value = items[i];
                if (value != null) {
                    String[] pair = items[i].split(":");
                    if (pair[0] != null && pair[1] != null) {
                        seriesColorMap.put(pair[0], JRColorUtil.getColor(pair[1], null));
                        seriesColorMap2.put(Integer.toString(seriesColorMap.size()), JRColorUtil.getColor(pair[1], null));
                    }
                }
            }
            System.out.println(seriesColorMap.toString());

            //--------------------------------------------------
            //Set color to each series
            //--------------------------------------------------
            CategoryDataset dataset = ((CategoryPlot) plot).getDataset();
            int rowCount = dataset.getRowCount();
            for (int i=0; i<rowCount; i++) {
                System.out.println(">>" + dataset.getValue(i, 0));
                String rowkey = (String)dataset.getRowKey(i);
                Color color = findColorBySeries(seriesColorMap, rowkey);
                if (color != null) {
                    renderer.setSeriesPaint(i, color);
                }
            }
            categoryPlot.setDomainAxis(subCategoryAxis);
            categoryPlot.setRenderer(renderer);

            if (legendColors != null) {
                LegendItemCollection legends = createLegendItems(legendColors);
                if (legends != null) {
                    categoryPlot.setFixedLegendItems(legends);
                }
            }

            LegendTitle legend = chart.getLegend();
            legend.setFrame(BlockBorder.NONE);
            legend.setVerticalAlignment(VerticalAlignment.TOP);
            if (legendPosition == null) {
                legend.setPosition(RectangleEdge.RIGHT);
            } else if ("RIGHT".equalsIgnoreCase(legendPosition)) {
                legend.setPosition(RectangleEdge.RIGHT);
            } else if ("LEFT".equalsIgnoreCase(legendPosition)) {
                legend.setPosition(RectangleEdge.LEFT);
            } else if ("TOP".equalsIgnoreCase(legendPosition)) {
                legend.setPosition(RectangleEdge.TOP);
            } else if ("BOTTOM".equalsIgnoreCase(legendPosition)) {
                legend.setPosition(RectangleEdge.BOTTOM);
            } else {
                legend.setPosition(RectangleEdge.RIGHT);
            }

        }


    }

    private Color findColorBySeries(Map<String, Color>colorMap, String series) {
        Color color = null;
        if (colorMap.size() > 0 && colorMap != null && !"".equals(series) && series != null) {
            color = (Color)colorMap.get(series);
        }
        return color;
    }

    /**
     * Creates the legend items for the chart.  In this case, we set them manually because we
     * only want legend items for a subset of the data series.
     *
     * @return The legend items.
     */
    private LegendItemCollection createLegendItems(String legendColors) {
        LegendItemCollection result = new LegendItemCollection();
        String[] entries = legendColors.split(";");
        for (int i=0; i<entries.length; i++) {
            String value = entries[i];
            if (value != null) {
                String[] pair = entries[i].split(":");
                if (pair[0] != null && pair[1] != null) {
                    LegendItem legend = new LegendItem(pair[0],  JRColorUtil.getColor(pair[1], null));
                    result.add(legend);
                }
            }
        }
        return result;
    }
}

