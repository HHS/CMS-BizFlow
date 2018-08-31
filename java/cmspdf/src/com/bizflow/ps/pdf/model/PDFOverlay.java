package com.bizflow.ps.pdf.model;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.bizflow.ps.pdf.util.FileUtility;
import com.bizflow.ps.pdf.util.PDFUtility;
import com.bizflow.ps.pdf.util.StopWatch;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;

import org.w3c.dom.*;

public class PDFOverlay
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFOverlay.class);

	private int gridSize = 0;
	private String templatePDF;
	private ArrayList<PDFOverlayItem> items = new ArrayList<PDFOverlayItem>();

	public PDFOverlay(Element element, int _gridSize) throws Exception
	{
		if (element != null) {
			gridSize = _gridSize;
			parse(element);
		} else {
			logger.fatal("Element is null.");
			throw new Exception("Element is null.");
		}
	}

	private void parse(Element element) throws Exception
	{
		StopWatch watch = new StopWatch(PDFOverlay.class, "parse");
		if (logger.isDebugEnabled())
		{
			logger.debug("parse START");
			logger.debug(" - element [" + (element != null ? "NOT NULL" : "NULL") + "]");
		}

		String relativePath = element.getAttribute("template");
		templatePDF = FileUtility.translatePath(relativePath);

		NodeList nodes = element.getElementsByTagName("item");

		for (int index = 0; index < nodes.getLength(); index++) {
			Element node = (Element)nodes.item(index);
			PDFOverlayItem item = new PDFOverlayItem(node);
			items.add(item);
		}
		if (logger.isDebugEnabled())
		{
			logger.debug("parse END");
		}
		watch.check();
	}

	public String generate(Map<String, String> valueMap) throws Exception, IOException
	{
		StopWatch watch = new StopWatch(PDFOverlay.class, "generate");
		if (logger.isDebugEnabled())
		{
			logger.debug("generate START");
			logger.debug(" - valueMap [" + (valueMap != null ? "NOT NULL" : "NULL") + "]");
		}

		String generatedPDFPath = null;
		PDDocument overlayDoc = null;
		PDDocument originalDoc = null;
		PDPageContentStream contentStream = null;

		try
		{
			int count = items.size();

			// Create overlay pdf file
			overlayDoc = new PDDocument();
			PDPage page = new PDPage();
			overlayDoc.addPage(page);
			org.apache.pdfbox.multipdf.Overlay overlayObj = new org.apache.pdfbox.multipdf.Overlay();
			float height = page.getMediaBox().getHeight();    // 792.0
			float width = page.getMediaBox().getWidth();    // 612.0

			contentStream = new PDPageContentStream(overlayDoc, page);
			PDFUtility.drawGrid(contentStream, width, height, gridSize);
			for (int index = 0; index < count; index++)
			{
				PDFOverlayItem item = items.get(index);
				String text = item.text;
				if (text.startsWith("#") == true) {
					text = valueMap.get(item.text);
				}

//				String tmpText = text.replaceAll("[\\u000d\\u000a\\u00a0]", " ");
//				text = tmpText;

				if ("true".compareToIgnoreCase(item.multipleLine) == 0)
				{
					PDFUtility.drawMultilineText(contentStream, item.width, item.height, item.x, item.y, item.font, item.fontSize, text);
				}
				else
				{
					PDFUtility.drawText(contentStream, item.x, item.y, item.width, item.font, item.fontSize, item.maxFontSize, text);
				}
			}
			contentStream.close();
			contentStream = null;

			originalDoc = PDDocument.load(new File(templatePDF));
			overlayObj.setOverlayPosition(org.apache.pdfbox.multipdf.Overlay.Position.FOREGROUND);
			overlayObj.setInputPDF(originalDoc);
			overlayObj.setAllPagesOverlayPDF(overlayDoc);

			Map<Integer, String> ovmap = new HashMap<Integer, String>();
			overlayObj.overlay(ovmap);

			File tempFilePath = File.createTempFile("bizflow_ps_pdf_", "pdf", null);
			try
			{
				originalDoc.save(tempFilePath);
				generatedPDFPath = tempFilePath.getAbsolutePath();

				overlayDoc.close();
				overlayDoc = null;

				originalDoc.close();
				originalDoc = null;
			}
			catch(Exception e)
			{
				logger.error("Failed to save PDF file [" + tempFilePath + "]", e);
				// File.createTempFile will create temporary file.
				// If something happens inside of try block, then we need to remove temporary file.
				tempFilePath.delete();
			}
		}
		finally
		{
			if (contentStream != null) {
				contentStream.close();
			}
			if (overlayDoc != null) {
				overlayDoc.close();
			}
			if (originalDoc != null) {
				originalDoc.close();
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("generate END [" + generatedPDFPath + "]");
		}
		watch.check();
		return generatedPDFPath;
	}
}
