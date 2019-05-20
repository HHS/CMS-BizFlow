package com.bizflow.jaspersoft.chart;

import net.sf.jasperreports.engine.util.JRColorUtil;
import org.jfree.chart.*;
import org.jfree.chart.axis.SubCategoryAxis;
import org.jfree.chart.block.BlockBorder;
import org.jfree.chart.block.ColumnArrangement;
import org.jfree.chart.block.FlowArrangement;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.GroupedStackedBarRenderer;
import org.jfree.chart.title.LegendTitle;
import org.jfree.data.KeyToGroupMap;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.ui.*;

import java.awt.*;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

/**
 * A simple demonstration application showing how to create a stacked bar chart
 * using data from a {@link CategoryDataset}.
 */
public class StackedGroupBarChartDemo extends ApplicationFrame {

    /**
     * Creates a new demo.
     *
     * @param title  the frame title.
     */
    public StackedGroupBarChartDemo(final String title) {
        super(title);
        final CategoryDataset dataset = createDataset();
        final JFreeChart chart = createChart(dataset);
        final ChartPanel chartPanel = new ChartPanel(chart);
        chartPanel.setPreferredSize(new Dimension(590, 350));
        setContentPane(chartPanel);
    }

    /**
     * Creates a sample dataset.
     *
     * @return A sample dataset.
     */
    private CategoryDataset createDataset() {
        DefaultCategoryDataset result = new DefaultCategoryDataset();

        result.addValue(10, "Product 1 (US)", "January 2019");
        result.addValue(10, "Product 1 (US)", "February 2019");
        result.addValue(10, "Product 1 (US)", "March 2019");
        result.addValue(20, "Product 1 (Europe)", "January 2019");
        result.addValue(20, "Product 1 (Europe)", "February 2019");
        result.addValue(20, "Product 1 (Europe)", "March 2019");
        result.addValue(30, "Product 1 (Asia)", "January 2019");
        result.addValue(30, "Product 1 (Asia)", "February 2019");
        result.addValue(30, "Product 1 (Asia)", "March 2019");
        result.addValue(40, "Product 1 (Middle East)", "January 2019");
        result.addValue(40, "Product 1 (Middle East)", "February 2019");
        result.addValue(40, "Product 1 (Middle East)", "March 2019");

        result.addValue(40, "Product 2 (Middle East)", "January 2019");
        result.addValue(40, "Product 2 (Middle East)", "February 2019");
        result.addValue(40, "Product 2 (Middle East)", "March 2019");
        result.addValue(10, "Product 2 (US)", "January 2019");
        result.addValue(10, "Product 2 (US)", "February 2019");
        result.addValue(10, "Product 2 (US)", "March 2019");
        result.addValue(20, "Product 2 (Europe)", "January 2019");
        result.addValue(20, "Product 2 (Europe)", "February 2019");
        result.addValue(20, "Product 2 (Europe)", "March 2019");
        result.addValue(30, "Product 2 (Asia)", "January 2019");
        result.addValue(30, "Product 2 (Asia)", "February 2019");
        result.addValue(30, "Product 2 (Asia)", "March 2019");


        result.addValue(10, "Product 3 (US)", "January 2019");
        result.addValue(10, "Product 3 (US)", "February 2019");
        result.addValue(10, "Product 3 (US)", "March 2019");
        result.addValue(20, "Product 3 (Europe)", "January 2019");
        result.addValue(20, "Product 3 (Europe)", "February 2019");
        result.addValue(20, "Product 3 (Europe)", "March 2019");
        result.addValue(30, "Product 3 (Asia)", "January 2019");
        result.addValue(30, "Product 3 (Asia)", "February 2019");
        result.addValue(30, "Product 3 (Asia)", "March 2019");
        result.addValue(40, "Product 3 (Middle East)", "January 2019");
        result.addValue(40, "Product 3 (Middle East)", "February 2019");
        result.addValue(40, "Product 3 (Middle East)", "March 2019");

        return result;
    }

    /**
     * Creates a sample chart.
     *
     * @param dataset  the dataset for the chart.
     *
     * @return A sample chart.
     */
    private JFreeChart createChart(final CategoryDataset dataset) {

        final JFreeChart chart = ChartFactory.createStackedBarChart(
                "CMS Research Spike - Stacked Bar Chart",  // chart title
                "Category",                  // domain axis label
                "Sales",                     // range axis label
                dataset,                     // data
                PlotOrientation.VERTICAL,    // the plot orientation
                true,                        // legend
                true,                        // tooltips
                false                        // urls
        );

        GroupedStackedBarRenderer renderer = new GroupedStackedBarRenderer();
        KeyToGroupMap map = new KeyToGroupMap("G1");
        map.mapKeyToGroup("Product 1 (US)", "G1");
        map.mapKeyToGroup("Product 1 (Europe)", "G1");
        map.mapKeyToGroup("Product 1 (Asia)", "G1");
        map.mapKeyToGroup("Product 1 (Middle East)", "G1");
        map.mapKeyToGroup("Product 2 (US)", "G2");
        map.mapKeyToGroup("Product 2 (Europe)", "G2");
        map.mapKeyToGroup("Product 2 (Asia)", "G2");
        map.mapKeyToGroup("Product 2 (Middle East)", "G2");
        map.mapKeyToGroup("Product 3 (US)", "G3");
        map.mapKeyToGroup("Product 3 (Europe)", "G3");
        map.mapKeyToGroup("Product 3 (Asia)", "G3");
        map.mapKeyToGroup("Product 3 (Middle East)", "G3");
        renderer.setSeriesToGroupMap(map);

        renderer.setItemMargin(0.05); //CONFIGURABLE

        renderer.setGradientPaintTransformer(
                new StandardGradientPaintTransformer(GradientPaintTransformType.HORIZONTAL)
        );

        CategoryPlot plot = (CategoryPlot) chart.getPlot();


        //-------------------------
        //BarRenderer r = (BarRenderer)chart.getCategoryPlot().getRenderer();
        //   renderer.setSeriesPaint(0, Color.PINK);
        //   renderer.setSeriesPaint(1, Color.BLACK);

        //-------------------------------------------------------------
        // Set color by series name
        //-------------------------------------------------------------
        String predefinedColors = "Product 1 (US):#015A84;Product 1 (Europe):#0085B0;Product 1 (Asia):#F8EB33;Product 1 (Middle East):#CCCCCC;"
                                + "Product 2 (US):#015A84;Product 2 (Europe):#0085B0;Product 2 (Asia):#F8EB33;Product 2 (Middle East):#CCCCCC;"
                                + "Product 3 (US):#015A84;Product 3 (Europe):#0085B0;Product 3 (Asia):#F8EB33;Product 3 (Middle East):#CCCCCC;";

        String[] entries = predefinedColors.split(";");
        Map<String, Color> seriesColorMap = new HashMap<String, Color>();
        Map<String, Color> seriesColorMap2 = new HashMap<String, Color>();
        for (int i=0; i<entries.length; i++) {
            String value = entries[i];
            if (value != null) {
                String[] pair = entries[i].split(":");
                if (pair[0] != null && pair[1] != null) {
                    seriesColorMap.put(pair[0], JRColorUtil.getColor(pair[1], null));
                    seriesColorMap2.put(Integer.toString(seriesColorMap.size()), JRColorUtil.getColor(pair[1], null));
                }
            }
        }

        System.out.println(seriesColorMap.toString());

        int rowCount = dataset.getRowCount();
        for (int i=0; i<rowCount; i++) {
            System.out.println(">>" + dataset.getValue(i, 0));
            String rowkey = (String)dataset.getRowKey(i);
            if (rowkey.contains("(Middle East)")) {
                renderer.setSeriesPaint(i, Color.BLACK);
            } else if (rowkey.contains("(Asia)")) {
                renderer.setSeriesPaint(i, Color.YELLOW);
            } else if (rowkey.contains("(Europe)")) {
                renderer.setSeriesPaint(i, Color.BLUE);
            } else if (rowkey.contains("(US)")) {
                renderer.setSeriesPaint(i, Color.RED);
            }
        }

        /*
        for (int i=0; i<4; i++) {
            renderer.setSeriesPaint(i, seriesColorMap.get(Integer.toString(i)));
        }
        */

        //piePlot.setSectionPaint(key, pieSections.get(key));
        //renderer.setSeriesPaint(i, (Color)seriesColorMap.get(Integer.toString(idx))); //!!!!!!!!!!
        //---------------------------

        SubCategoryAxis subCategoryAxis = new SubCategoryAxis("Product / Month");
        subCategoryAxis.setMaximumCategoryLabelLines(2);
        //sub categories
        subCategoryAxis.setCategoryMargin(0.4);
        subCategoryAxis.addSubCategory("P1");
        subCategoryAxis.addSubCategory("P2");
        subCategoryAxis.addSubCategory("P3");
        subCategoryAxis.setMaximumCategoryLabelWidthRatio(0.5f);
        subCategoryAxis.setMaximumCategoryLabelLines(2);
        //formatting sub label
        //subCateogryAxis.setLabelAngle(90); -- main label
        Font ft = new Font("TimesRoman", Font.ITALIC, 8);
        subCategoryAxis.setSubLabelFont(ft);
        subCategoryAxis.setSubLabelPaint(Color.RED);
        //subCategoryAxis.setCategoryLabelPositions(CategoryLabelPositions.DOWN_45);
        subCategoryAxis.setMaximumCategoryLabelLines(2);


        plot.setDomainAxis(subCategoryAxis);

        plot.setRenderer(renderer);

        plot.setFixedLegendItems(createLegendItems());

        LegendTitle legend = chart.getLegend();
        legend.setFrame(BlockBorder.NONE);
        legend.setPosition(RectangleEdge.BOTTOM);
        legend.setVerticalAlignment(VerticalAlignment.TOP);

        legend.setHeight(legend.getHeight()*2);
        legend.setWidth(legend.getWidth()*2);
        //legend.setWrapper();

        legend.setBackgroundPaint(Color.pink);
        return chart;

    }

    /*
    private List<LegendTitle> createLegendTitles() {
        List<LegendTitle> legendTitles = new LinkedList<LegendTitle>();
        LegendConfiguration legendConfiguration = plotInstance.getCurrentPlotConfigurationClone().getLegendConfiguration();

        LegendTitle legendTitle = new SmartLegendTitle(this, new FlowArrangement(HorizontalAlignment.CENTER, VerticalAlignment.CENTER, 30, 2), new ColumnArrangement(
                HorizontalAlignment.LEFT, VerticalAlignment.CENTER, 0, 2));
        legendTitle.setItemPaint(legendConfiguration.getLegendFontColor());

        RectangleEdge position = legendConfiguration.getLegendPosition().getPosition();
        if (position == null) {
            return legendTitles;
        }
        legendTitle.setPosition(position);

        if (legendConfiguration.isShowLegendFrame()) {
            legendTitle.setFrame(new BlockBorder(legendConfiguration.getLegendFrameColor()));
        }
        ColoredBlockContainer wrapper = new ColoredBlockContainer(legendConfiguration.getLegendBackgroundColor());
        wrapper.add(legendTitle.getItemContainer());
        wrapper.setPadding(3, 3, 3, 3);
        legendTitle.setWrapper(wrapper);

        legendTitles.add(legendTitle);
        return legendTitles;
    }
*/

    /**
     * Creates the legend items for the chart.  In this case, we set them manually because we
     * only want legend items for a subset of the data series.
     *
     * @return The legend items.
     */
    private LegendItemCollection createLegendItems() {
        LegendItemCollection result = new LegendItemCollection();
        LegendItem item1 = new LegendItem("US", Color.RED);
        LegendItem item2 = new LegendItem("Europe", Color.BLUE);
        LegendItem item3 = new LegendItem("Asia", Color.YELLOW);
        LegendItem item4 = new LegendItem("Middle East", Color.BLACK);

        result.add(item1);
        result.add(item2);
        result.add(item3);
        result.add(item4);
        result.add(new LegendItem("P1: Product 1", Color.WHITE));
        result.add(new LegendItem("P2: Product 2", Color.WHITE));
        result.add(new LegendItem("P3: Product 3", Color.WHITE));

        return result;
    }

    // ****************************************************************************
    // * JFREECHART DEVELOPER GUIDE                                               *
    // * The JFreeChart Developer Guide, written by David Gilbert, is available   *
    // * to purchase from Object Refinery Limited:                                *
    // *                                                                          *
    // * http://www.object-refinery.com/jfreechart/guide.html                     *
    // *                                                                          *
    // * Sales are used to provide funding for the JFreeChart project - please    *
    // * support us so that we can continue developing free software.             *
    // ****************************************************************************

    /**
     * Starting point for the demonstration application.
     *
     * @param args  ignored.
     */
    public static void main(final String[] args) {
        final StackedGroupBarChartDemo demo = new StackedGroupBarChartDemo("CMS Stacked Bar Chart Research Spike");
        demo.pack();
        RefineryUtilities.centerFrameOnScreen(demo);
        demo.setVisible(true);
    }

}