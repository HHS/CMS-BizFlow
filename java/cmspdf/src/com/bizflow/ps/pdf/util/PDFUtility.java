package com.bizflow.ps.pdf.util;

import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import java.awt.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class PDFUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFUtility.class);

	static private Map<String, PDType1Font> _fontMap = new HashMap<String, PDType1Font>();

	static private void initFontMap() {
		StopWatch watch = new StopWatch(PDFUtility.class, "initFontMap");
		if (logger.isDebugEnabled())
		{
			logger.debug("initFontMap START");
		}

		_fontMap.clear();

		_fontMap.put("TIMES_ROMAN",				PDType1Font.TIMES_ROMAN);
		_fontMap.put("TIMES_BOLD",				PDType1Font.TIMES_BOLD);
		_fontMap.put("TIMES_ITALIC",			PDType1Font.TIMES_ITALIC);
		_fontMap.put("TIMES_BOLD_ITALIC",		PDType1Font.TIMES_BOLD_ITALIC);
		_fontMap.put("HELVETICA",				PDType1Font.HELVETICA);
		_fontMap.put("HELVETICA_BOLD",			PDType1Font.HELVETICA_BOLD);
		_fontMap.put("HELVETICA_OBLIQUE",		PDType1Font.HELVETICA_OBLIQUE);
		_fontMap.put("HELVETICA_BOLD_OBLIQUE",	PDType1Font.HELVETICA_BOLD_OBLIQUE);
		_fontMap.put("COURIER",					PDType1Font.COURIER);
		_fontMap.put("COURIER_BOLD",			PDType1Font.COURIER_BOLD);
		_fontMap.put("COURIER_OBLIQUE",			PDType1Font.COURIER_OBLIQUE);
		_fontMap.put("COURIER_BOLD_OBLIQUE",	PDType1Font.COURIER_BOLD_OBLIQUE);
		_fontMap.put("SYMBOL",					PDType1Font.SYMBOL);
		_fontMap.put("ZAPF_DINGBATS",			PDType1Font.ZAPF_DINGBATS);

		if (logger.isDebugEnabled())
		{
			logger.debug("initFontMap END");
		}
		watch.check();
	}

	static public float getMaxFontSize(PDFont font, String text, float initialFontSize, float maxFontSize, float width)
	{
		StopWatch watch = new StopWatch(PDFUtility.class, "getMaxFontSize");
		if (logger.isDebugEnabled())
		{
			logger.debug("getMaxFontSize START");
			logger.debug(" - font [" + LogUtility.getNullCheckString(font) + "]");
			logger.debug(" - text [" + text + "]");
			logger.debug(" - initialFontSize [" + Float.toString(initialFontSize) + "]");
			logger.debug(" - maxFontSize [" + Float.toString(maxFontSize) + "]");
			logger.debug(" - width [" + Float.toString(width) + "]");
		}

		float fontSize = initialFontSize;

		if (fontSize < 48.0f)
		{
			try
			{
				float indexFontSize = fontSize;
				while(indexFontSize < 48.0f)
				{
					if (((font.getStringWidth(text) / 1000) * indexFontSize) > width)
					{
						break;
					}
					indexFontSize = indexFontSize + 0.1f;
				}

				fontSize = indexFontSize - 0.1f;
				if (maxFontSize > 0 && fontSize > maxFontSize)
				{
					fontSize = maxFontSize;
				}
			}
			catch(IOException e)
			{
				logger.error("PDFont generated IOException", e);
				fontSize = initialFontSize;
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getMaxFontSize END [" + Float.toString(fontSize) + "]");
		}
		watch.check();
		return fontSize;
	}


	static private boolean isCharacterEncodable (PDFont font, char character) throws IOException {
		StopWatch watch = new StopWatch(PDFUtility.class, "isCharacterEncodable");
		if (logger.isDebugEnabled())
		{
//			logger.debug("isCharacterEncodable START");
//			logger.debug(" - font [" + font.getName() + "]");

//			Character charObject = new Character(character);
//			Integer charValue = (int)charObject.charValue();
//			logger.debug(" - character [0x" + Integer.toHexString(charValue)+ "]");
		}

		Boolean result = true;
		try {
			font.encode(Character.toString(character));
		} catch (IllegalArgumentException iae) {
			logger.debug("Character cannot be encoded. This character is excluded. Below stack trace can be ignored.", iae);
			result = false;
		}

		if (logger.isDebugEnabled())
		{
//			logger.debug("isCharacterEncodable END [" + result + "]");
		}
		watch.check();

		return result;
	}

	static public void drawText(PDPageContentStream contentStream, float x, float y, float width,
								String fontName, float fontSize, float maxFontSize, String text) throws IOException
	{
		StopWatch watch = new StopWatch(PDFUtility.class, "drawText");
		if (logger.isDebugEnabled())
		{
			logger.debug("drawText START");
			logger.debug(" - contentStream [" + LogUtility.getNullCheckString(contentStream) + "]");
			logger.debug(" - x [" + Float.toString(x) + "]");
			logger.debug(" - y [" + Float.toString(y) + "]");
			logger.debug(" - width [" + Float.toString(width) + "]");
			logger.debug(" - fontName [" + fontName + "]");
			logger.debug(" - fontSize [" + Float.toString(fontSize) + "]");
			logger.debug(" - maxFontSize [" + Float.toString(maxFontSize) + "]");
			logger.debug(" - text [" + text + "]");
		}

		if (text != null && text.length() > 0)
		{
			if (_fontMap.size() == 0)
			{
				initFontMap();
			}

			PDFont font = _fontMap.get(fontName);

			float finalFontSize = fontSize;
			// If width is greater than 0, then find max font size for the width.
			if (width > 0)
			{
				finalFontSize = PDFUtility.getMaxFontSize(font, text, fontSize, maxFontSize, width);
			}

			StringBuilder printableBuffer = new StringBuilder();
			for (char character: text.toCharArray()) {
				if (PDFUtility.isCharacterEncodable(font, character)) {
					printableBuffer.append(character);
				} else {
					printableBuffer.append(" ");
				}
			}

			String printableString = printableBuffer.toString();

			contentStream.setFont(font, finalFontSize);
			contentStream.setNonStrokingColor(0);
			contentStream.beginText();
			contentStream.newLineAtOffset(x, y);
			contentStream.showText(printableString);
			contentStream.endText();
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("drawText END");
		}
		watch.check();
	}

	static public void drawMultilineText(PDPageContentStream contentStream, float width, float height, float x, float y,
										 String fontName, float fontSize, String text) throws IOException
	{
		StopWatch watch = new StopWatch(PDFUtility.class, "drawMultilineText");
		if (logger.isDebugEnabled())
		{
			logger.debug("drawMultilineText START");
			logger.debug(" - contentStream [" + LogUtility.getNullCheckString(contentStream) + "]");
			logger.debug(" - width [" + Float.toString(width) + "]");
			logger.debug(" - height [" + Float.toString(height) + "]");
			logger.debug(" - x [" + Float.toString(x) + "]");
			logger.debug(" - y [" + Float.toString(y) + "]");
			logger.debug(" - fontName [" + fontName + "]");
			logger.debug(" - fontSize [" + Float.toString(fontSize) + "]");
			logger.debug(" - text [" + text + "]");
		}

		if (_fontMap.size() == 0)
		{
			initFontMap();
		}

		PDFont font = _fontMap.get(fontName);
		float lineLength = 0;
		boolean isFirstWordInLine = true;
		int lineCount = 0;
		float spaceWidth = font.getStringWidth(" ") / 1000 * fontSize;

		// #1. Tokenize the string with Space
		String[] tokens = text.split("\\s");
		if (tokens != null && tokens.length > 0)
		{
			for (int tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++)
			{
				// #2. Get 1 string from array
				//      - If there is no more string, exit
				String token = tokens[tokenIndex];
				// #3. Get length of the string
				float tokenLength = font.getStringWidth(token) / 1000 * fontSize;
				// #4. Add the string length to total string length
				if (lineLength + tokenLength <= width) {
					// #5. If total string length is less than or equal to max length, draw string
					//      - If the string is first word in the line, draw string
					//      - If the string is not first word in the line, add space at the begging
					//      - Go to #2.
					if (isFirstWordInLine == true) {
						isFirstWordInLine = false;
					} else {
						token = " " + token;
						lineLength += spaceWidth;
					}
					PDFUtility.drawText(contentStream, x + lineLength, y - lineCount * height, -1, fontName, fontSize, -1, token);
					lineLength += tokenLength;
				} else {
					// #6. If total string length is bigger than max length,
					//      - Change line
					//      - Draw string
					//      - Go to #3.
					lineLength = 0;
					lineCount++;
					PDFUtility.drawText(contentStream, x + lineLength, y - lineCount * height, -1, fontName, fontSize, -1, token);
					lineLength =+ tokenLength;
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("drawMultilineText END");
		}
		watch.check();
	}

	static public void drawLine(PDPageContentStream contentStream, float startX, float startY, float endX, float endY, int labelIndex)
	{
		StopWatch watch = new StopWatch(PDFUtility.class, "drawLine");
		if (logger.isDebugEnabled())
		{
			logger.debug("drawLine START");
			logger.debug(" - contentStream [" + LogUtility.getNullCheckString(contentStream) + "]");
			logger.debug(" - startX [" + Float.toString(startX) + "]");
			logger.debug(" - startY [" + Float.toString(startY) + "]");
			logger.debug(" - endX [" + Float.toString(endX) + "]");
			logger.debug(" - endY [" + Float.toString(endY) + "]");
			logger.debug(" - labelIndex [" + Integer.toString(labelIndex) + "]");
		}

		try
		{
			contentStream.moveTo(startX, startY);
			contentStream.lineTo(endX, endY);
			contentStream.stroke();
		}
		catch (IOException e)
		{
			logger.fatal("Failed to draw line.", e);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("drawLine END");
		}
		watch.check();
	}

	static public void drawGrid(PDPageContentStream contentStream, float width, float height, int gridSize) throws IOException
	{
		StopWatch watch = new StopWatch(PDFUtility.class, "drawGrid");
		if (logger.isDebugEnabled())
		{
			logger.debug("drawGrid START");
			logger.debug(" - contentStream [" + LogUtility.getNullCheckString(contentStream) + "]");
			logger.debug(" - width [" + Float.toString(width) + "]");
			logger.debug(" - height [" + Float.toString(height) + "]");
			logger.debug(" - gridSize [" + Integer.toString(gridSize) + "]");
		}

		PDFont font = PDType1Font.COURIER_OBLIQUE;

		contentStream.setFont(font, 4);

		if (gridSize > 0)
		{
			contentStream.setLineWidth(1);
			contentStream.setStrokingColor(Color.lightGray);
			contentStream.setLineDashPattern(new float[] {1,1}, 0);

			for (int index = 0; index < height; index += gridSize)
			{
				drawLine(contentStream, 0, index, width, index, index);

				String label = Integer.toString(index);
				contentStream.setNonStrokingColor(0);
				contentStream.beginText();
				contentStream.newLineAtOffset(0, index);
				contentStream.showText(label);
				contentStream.endText();

				contentStream.beginText();
				float labelWidth = font.getStringWidth(label) / 1000 * 4;
				contentStream.newLineAtOffset(width - labelWidth, index);
				contentStream.showText(label);
				contentStream.endText();
			}

			float labelHeight = font.getFontDescriptor().getFontBoundingBox().getHeight() / 1000 * 4;

			for (int index = 0; index < width; index += gridSize) {
				drawLine(contentStream, index, 0, index, height, index);

				String label = Integer.toString(index);
				contentStream.setNonStrokingColor(0);
				contentStream.beginText();
				contentStream.newLineAtOffset(index, 0);
				contentStream.showText(label);
				contentStream.endText();

				contentStream.beginText();
				contentStream.newLineAtOffset(index, height - labelHeight);
				contentStream.showText(label);
				contentStream.endText();
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("drawGrid END");
		}
		watch.check();
	}
}
