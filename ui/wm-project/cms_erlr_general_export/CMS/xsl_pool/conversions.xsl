<?xml version="1.0"?>
<!--
/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on ‘How do I override or clone Hyfinity webapp files such as CSS & javascript?’, please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index.php?solution_id=1113
==================================================================================================== */
/*-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="date">

    <!-- The filename of this stylesheet.  This is needed due to an apparent bug in xalan
         that causes the document('') function to refer to the principal stylesheet (ie the
         one that imported this one) not this stylesheet when used within a for-each tag.
         Therefore, as a workaround, we use the name of this stylesheet in the document function
         instead of an empty string. -->
    <xsl:variable name="stylesheet-filename">conversions.xsl</xsl:variable>

    <date:months>
        <date:month length="31" abbr="Jan">January</date:month>
        <date:month length="28" abbr="Feb">February</date:month>
        <date:month length="31" abbr="Mar">March</date:month>
        <date:month length="30" abbr="Apr">April</date:month>
        <date:month length="31" abbr="May">May</date:month>
        <date:month length="30" abbr="Jun">June</date:month>
        <date:month length="31" abbr="Jul">July</date:month>
        <date:month length="31" abbr="Aug">August</date:month>
        <date:month length="30" abbr="Sep">September</date:month>
        <date:month length="31" abbr="Oct">October</date:month>
        <date:month length="30" abbr="Nov">November</date:month>
        <date:month length="31" abbr="Dec">December</date:month>
    </date:months>

    <date:days>
        <date:day abbr="Sun">Sunday</date:day>
        <date:day abbr="Mon">Monday</date:day>
        <date:day abbr="Tue">Tuesday</date:day>
        <date:day abbr="Wed">Wednesday</date:day>
        <date:day abbr="Thu">Thursday</date:day>
        <date:day abbr="Fri">Friday</date:day>
        <date:day abbr="Sat">Saturday</date:day>
    </date:days>

    <xsl:variable name="patternCharacters">GyMNdhHmsSEDFwWakKz'</xsl:variable>
    <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

    <!-- Performs whitespace conversions on the given string.
         @param toconvert The string value to convert
         @param conversion The type of conversion to perform - 'collapse', 'remove', or 'preserve'-->
    <xsl:template name="convert-whitespace">
        <xsl:param name="toconvert" />
        <xsl:param name="conversion" />

        <xsl:choose>
            <xsl:when test='$conversion="collapse"'>
                <xsl:value-of select="normalize-space($toconvert)"/>
            </xsl:when>
            <xsl:when test='$conversion="remove"'>
                <xsl:value-of select="translate($toconvert, ' ', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$toconvert" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Performs case conversions on the given string.
         @param toconvert The string value to convert.
         @param conversion The type of conversion to perform - 'lower', 'upper', 'title', 'sentence', or 'preserve'-->
    <xsl:template name="convert-case">
        <xsl:param name="toconvert" />
        <xsl:param name="conversion" />

        <xsl:choose>
            <xsl:when test='$conversion="lower"'>
                <xsl:value-of select="translate($toconvert,$ucletters,$lcletters)"/>
            </xsl:when>
            <xsl:when test='$conversion="upper"'>
                <xsl:value-of select="translate($toconvert,$lcletters,$ucletters)"/>
            </xsl:when>
            <xsl:when test='$conversion="title"'>
                <xsl:call-template name="converttitlecase">
                    <xsl:with-param name="toconvert">
                        <xsl:value-of select="translate($toconvert,$ucletters,$lcletters)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test='$conversion="sentence"'>
                <xsl:call-template name="convertsentencecase">
                    <xsl:with-param name="toconvert">
                        <xsl:value-of select="translate($toconvert,$ucletters,$lcletters)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$toconvert" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- converts the given string to title case -->
    <xsl:template name="converttitlecase">
        <xsl:param name="toconvert" />

        <xsl:if test="string-length($toconvert) > 0">
            <xsl:variable name="f" select="substring($toconvert, 1, 1)" />
            <xsl:variable name="s" select="substring($toconvert, 2)" />

            <xsl:call-template name="convert-case">
                <xsl:with-param name="toconvert" select="$f" />
                <xsl:with-param name="conversion">upper</xsl:with-param>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="contains($s,' ')">
                    <xsl:value-of select='substring-before($s," ")'/>
                    <!--&#160;-->
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="converttitlecase">
                        <xsl:with-param name="toconvert" select='substring-after($s," ")' />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$s"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- converts the given string to sentence case -->
    <xsl:template name="convertsentencecase">
        <xsl:param name="toconvert" />

        <xsl:if test="string-length($toconvert) > 0">
            <xsl:variable name="f" select="substring($toconvert, 1, 1)" />
            <xsl:variable name="s" select="substring($toconvert, 2)" />

            <xsl:choose>
                <xsl:when test="$f = ' '">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="convertsentencecase">
                        <xsl:with-param name="toconvert" select='$s' />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="convert-case">
                        <xsl:with-param name="toconvert" select="$f" />
                        <xsl:with-param name="conversion">upper</xsl:with-param>
                    </xsl:call-template>

                    <!-- TODO: need to handle other forms of sentence ending, eg ! ? -->
                    <xsl:choose>
                        <xsl:when test="contains($s,'.')">
                            <xsl:value-of select='substring-before($s,".")'/>
                            <!--&#160;-->
                            <xsl:text>.</xsl:text>
                            <xsl:call-template name="convertsentencecase">
                                <xsl:with-param name="toconvert" select='substring-after($s,".")' />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$s"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:if>
    </xsl:template>

    <!-- template to take in a date string in a given source_pattern, and output it in the given target_pattern -->
    <xsl:template name="parse-format-date">
        <xsl:param name="source_string" select="''" />
        <xsl:param name="source_pattern" select="''" />
        <xsl:param name="target_pattern" select="''" />
        <xsl:if test="normalize-space($source_string) != ''">
            <xsl:call-template name="_parse-format-date">
                <xsl:with-param name="source_string" select="$source_string"/>
                <xsl:with-param name="source_pattern" select="$source_pattern"/>
                <xsl:with-param name="target_pattern" select="$target_pattern"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="_parse-format-date">
        <xsl:param name="year" />
        <xsl:param name="month" select="1" />
        <xsl:param name="day" select="1" />
        <xsl:param name="hour" select="0" />
        <xsl:param name="minute" select="0" />
        <xsl:param name="second" select="0" />
        <xsl:param name="timezone" select="'Z'" />

        <xsl:param name="source_string" select="''" />
        <xsl:param name="source_pattern" select="''" />
        <xsl:param name="target_pattern" select="''" />

        <xsl:variable name="char" select="substring($source_pattern, 1, 1)" />

        <xsl:choose>
            <!-- when we have reached the end of the source pattern, format the date values using the target pattern -->
            <xsl:when test="not($source_string) or (normalize-space($source_string) = '') or not($source_pattern) or (normalize-space($source_pattern) = '')">
                <xsl:call-template name="_format-date">
                    <xsl:with-param name="year" select="$year" />
                    <xsl:with-param name="month" select="$month" />
                    <xsl:with-param name="day" select="$day" />
                    <xsl:with-param name="hour" select="$hour" />
                    <xsl:with-param name="minute" select="$minute" />
                    <xsl:with-param name="second" select="$second" />
                    <xsl:with-param name="timezone" select="$timezone" />
                    <xsl:with-param name="pattern" select="$target_pattern" />
                </xsl:call-template>
            </xsl:when>
            <!-- the next character in the source pattern is not a specific character so just ignore -->
            <xsl:when test="not(contains($patternCharacters, $char))">
                <xsl:call-template name="_parse-format-date">
                    <xsl:with-param name="year" select="$year" />
                    <xsl:with-param name="month" select="$month" />
                    <xsl:with-param name="day" select="$day" />
                    <xsl:with-param name="hour" select="$hour" />
                    <xsl:with-param name="minute" select="$minute" />
                    <xsl:with-param name="second" select="$second" />
                    <xsl:with-param name="timezone" select="$timezone" />
                    <xsl:with-param name="source_pattern" select="substring($source_pattern, 2)" />
                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                    <xsl:with-param name="source_string" select="substring($source_string, 2)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="next-different-char" select="substring(translate($source_pattern, $char, ''), 1, 1)" />
                <xsl:variable name="pattern-length">
                    <xsl:choose>
                        <xsl:when test="$next-different-char">
                            <xsl:value-of select="string-length(substring-before($source_pattern, $next-different-char))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string-length($source_pattern)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test='$char = "&apos;"'>
                        <xsl:choose>
                            <xsl:when test='substring($source_pattern, 2, 1) = "&apos;"'>
                                <!-- check if the next character in the source string is an apostraphe and if so just remove it and continue-->
                                <xsl:choose>
                                    <xsl:when test='substring($source_string, 1, 1) = "&apos;"' >
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="$month" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select="substring($source_pattern, 3)" />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="substring($source_string, 2)" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="$month" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select="substring($source_pattern, 3)" />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="$source_string" />
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="literal-value" select='substring-before(substring($source_pattern, 2), "&apos;")' />
                                <!-- remove the literal value from the source string and then continue -->
                                <xsl:choose>
                                    <xsl:when test="substring($source_string, 1, string-length($literal-value)) = $literal-value" >
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="$month" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select='substring-after(substring($source_pattern, 2), "&apos;")' />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="substring-after($source_string, $literal-value)" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="$month" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select='substring-after(substring($source_pattern, 2), "&apos;")' />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="$source_string" />
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$char = 'd'"><!-- day of month -->
                        <xsl:choose>
                            <!-- if the next character is a format character, take exactly the number of digits from the pattern length -->
                            <xsl:when test="contains($patternCharacters, $next-different-char)">
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="substring($source_string, 1, $pattern-length)" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, ($pattern-length + 1))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise> <!-- take all the digits before the next character, regardless of the pattern length -->
                                <xsl:variable name="newDay">
                                    <xsl:choose>
                                        <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                            <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_string"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="normalize-space($newDay)" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, (string-length($newDay) + 1))" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$char = 'M' or $char = 'N'"> <!-- month -->
                        <xsl:choose>
                            <xsl:when test="$char = 'M' and $pattern-length = 4"> <!-- full month name -->
                                <xsl:variable name="monthNumber">
                                    <xsl:for-each select="document($stylesheet-filename)/*/date:months/date:month">
                                        <xsl:if test="starts-with(translate($source_string,$lcletters,$ucletters), translate(.,$lcletters,$ucletters))">
                                            <xsl:value-of select="position()"/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$monthNumber" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, (string-length(document('')/*/date:months/date:month[position() = $monthNumber]) + 1))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$char = 'N' or $pattern-length = 3"> <!-- abbreviated month name -->
                                <xsl:variable name="monthNumber">
                                    <xsl:for-each select="document($stylesheet-filename)/*/date:months/date:month">
                                        <xsl:if test="starts-with(translate($source_string,$lcletters,$ucletters), translate(@abbr,$lcletters,$ucletters))">
                                            <xsl:value-of select="position()"/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$monthNumber" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, (string-length(document('')/*/date:months/date:month[position() = $monthNumber]/@abbr) + 1))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise> <!-- month number -->
                                <xsl:choose>
                                    <!-- if the next character is a format character, take exactly the number of digits from the pattern length -->
                                    <xsl:when test="contains($patternCharacters, $next-different-char)">
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="substring($source_string, 1, $pattern-length)" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="substring($source_string, ($pattern-length + 1))" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise> <!-- take all the digits before the next character, regardless of the pattern length -->
                                        <xsl:variable name="newMonth">
                                            <xsl:choose>
                                                <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                                    <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$source_string"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:call-template name="_parse-format-date">
                                            <xsl:with-param name="year" select="$year" />
                                            <xsl:with-param name="month" select="normalize-space($newMonth)" />
                                            <xsl:with-param name="day" select="$day" />
                                            <xsl:with-param name="hour" select="$hour" />
                                            <xsl:with-param name="minute" select="$minute" />
                                            <xsl:with-param name="second" select="$second" />
                                            <xsl:with-param name="timezone" select="$timezone" />
                                            <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                                            <xsl:with-param name="source_string" select="substring($source_string, (string-length($newMonth) + 1))" />
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$char = 'y'"> <!-- year -->
                        <xsl:variable name="parsedYear">
                            <xsl:choose>
                                <xsl:when test="contains($patternCharacters, $next-different-char)">
                                    <xsl:value-of select="substring($source_string, 1, $pattern-length)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                            <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_string"/>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:variable name="fullYear">
                            <xsl:choose>
                                <xsl:when test="($pattern-length = 4) or (string-length($parsedYear) != 2)">
                                    <xsl:value-of select="$parsedYear"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$parsedYear &gt; 60">
                                            <xsl:text>19</xsl:text>
                                            <xsl:value-of select="$parsedYear"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>20</xsl:text>
                                            <xsl:value-of select="$parsedYear"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="year" select="$fullYear" />
                            <xsl:with-param name="month" select="$month" />
                            <xsl:with-param name="day" select="$day" />
                            <xsl:with-param name="hour" select="$hour" />
                            <xsl:with-param name="minute" select="$minute" />
                            <xsl:with-param name="second" select="$second" />
                            <xsl:with-param name="timezone" select="$timezone" />
                            <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                            <xsl:with-param name="source_string" select="substring($source_string, (string-length($parsedYear) + 1))" />
                        </xsl:call-template>
                    </xsl:when>

                    <xsl:when test="$char = 'm'" > <!-- minutes -->
                        <xsl:choose>
                            <!-- if the next character is a format character, take exactly the number of digits from the pattern length -->
                            <xsl:when test="contains($patternCharacters, $next-different-char)">
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="substring($source_string, 1, $pattern-length)" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, ($pattern-length + 1))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise> <!-- take all the digits before the next character, regardless of the pattern length -->
                                <xsl:variable name="newMin">
                                    <xsl:choose>
                                        <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                            <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_string"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="normalize-space($newMin)" />
                                    <xsl:with-param name="second" select="$second" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, (string-length($newMin) + 1))" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$char ='s'"> <!-- seconds -->
                        <xsl:choose>
                            <!-- if the next character is a format character, take exactly the number of digits from the pattern length -->
                            <xsl:when test="contains($patternCharacters, $next-different-char)">
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="substring($source_string, 1, $pattern-length)" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, ($pattern-length + 1))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise> <!-- take all the digits before the next character, regardless of the pattern length -->
                                <xsl:variable name="newSec">
                                    <xsl:choose>
                                        <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                            <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_string"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:call-template name="_parse-format-date">
                                    <xsl:with-param name="year" select="$year" />
                                    <xsl:with-param name="month" select="$month" />
                                    <xsl:with-param name="day" select="$day" />
                                    <xsl:with-param name="hour" select="$hour" />
                                    <xsl:with-param name="minute" select="$minute" />
                                    <xsl:with-param name="second" select="normalize-space($newSec)" />
                                    <xsl:with-param name="timezone" select="$timezone" />
                                    <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                                    <xsl:with-param name="target_pattern" select="$target_pattern" />
                                    <xsl:with-param name="source_string" select="substring($source_string, (string-length($newSec) + 1))" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$char ='a'"> <!-- AM/PM indicator -->
                        <xsl:variable name="indicator">
                            <xsl:value-of select="substring($source_string, 1, 2)"/>
                        </xsl:variable>
                        <!-- QUESTION: what happens if this indicator is given before the hour value??? -->
                        <xsl:variable name="newHour">
                            <xsl:choose>
                                <xsl:when test="translate($indicator,$lcletters,$ucletters) = 'PM'">
                                    <xsl:value-of select="$hour + 12"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$hour"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month" select="$month" />
                            <xsl:with-param name="day" select="$day" />
                            <xsl:with-param name="hour" select="$newHour" />
                            <xsl:with-param name="minute" select="$minute" />
                            <xsl:with-param name="second" select="$second" />
                            <xsl:with-param name="timezone" select="$timezone" />
                            <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                            <xsl:with-param name="source_string" select="substring($source_string, 3)" />
                        </xsl:call-template>
                    </xsl:when>


                    <xsl:when test="$char = 'h' or $char = 'H' or $char = 'k' or $char = 'K'" > <!-- hours -->
                        <xsl:variable name="source_value" >
                            <xsl:choose>
                                <!-- if the next character is a format character, take exactly the number of digits from the pattern length -->
                                <xsl:when test="contains($patternCharacters, $next-different-char)">
                                    <xsl:value-of select="substring($source_string, 1, $pattern-length)"/>
                                </xsl:when>
                                <xsl:otherwise> <!-- take all the digits before the next character, regardless of the pattern length -->
                                    <xsl:choose>
                                        <xsl:when test="$next-different-char and contains($source_string, $next-different-char)">
                                            <xsl:value-of select="substring-before($source_string, $next-different-char)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_string"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:variable name="newHour">
                            <xsl:choose>
                                <xsl:when test="$char = 'k'" >
                                    <xsl:choose>
                                        <xsl:when test="$source_value = 24" >
                                            <xsl:text>0</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_value"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$char = 'h'" >
                                    <xsl:choose>
                                        <xsl:when test="$source_value = 12" >
                                            <xsl:text>0</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$source_value"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$source_value"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month" select="$month" />
                            <xsl:with-param name="day" select="$day" />
                            <xsl:with-param name="hour" select="$newHour" />
                            <xsl:with-param name="minute" select="$minute" />
                            <xsl:with-param name="second" select="$second" />
                            <xsl:with-param name="timezone" select="$timezone" />
                            <xsl:with-param name="source_pattern" select="substring($source_pattern, ($pattern-length + 1))" />
                            <xsl:with-param name="target_pattern" select="$target_pattern" />
                            <xsl:with-param name="source_string" select="substring($source_string, (string-length($source_value) + 1))" />
                        </xsl:call-template>

                    </xsl:when>


                </xsl:choose>
            </xsl:otherwise>

        </xsl:choose>


    </xsl:template>

    <!-- A template that outputs a list of options for use in a input select contruct -->
    <xsl:template name="create-date-options">
        <xsl:param name="source_string" select="''" />
        <xsl:param name="source_pattern" select="''" />
        <xsl:param name="target_pattern" select="''" />
        <xsl:param name="placeholder" select="''" />

        <xsl:choose>
            <xsl:when test="$target_pattern='dd' or $target_pattern='d'">
                <xsl:variable name="sourceDay">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="totalNumber" select="31"/>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceDay"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='M' or $target_pattern='MM'">
                <xsl:variable name="sourceMonth">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="totalNumber">12</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceMonth"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='MMM' or $target_pattern='NNN'">
                <xsl:variable name="sourceMonth">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:for-each select="document($stylesheet-filename)/*/date:months/date:month">
                    <option value="{./@abbr}">
                        <xsl:if test="./@abbr = $sourceMonth">
                            <xsl:attribute name="selected">true</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="./@abbr"/>
                    </option>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$target_pattern='MMMM'">
                <xsl:variable name="sourceMonth">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:for-each select="document($stylesheet-filename)/*/date:months/date:month">
                    <option value="{.}">
                        <xsl:if test=". = $sourceMonth">
                            <xsl:attribute name="selected">true</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </option>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$target_pattern='E'">
                <xsl:variable name="sourceDayOfWeek">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:for-each select="document($stylesheet-filename)/*/date:days/date:day">
                    <option value="{@abbr}">
                        <xsl:if test="@abbr = $sourceDayOfWeek">
                            <xsl:attribute name="selected">true</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="@abbr"/>
                    </option>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$target_pattern='EE'">
                <xsl:variable name="sourceDayOfWeek">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:for-each select="document($stylesheet-filename)/*/date:days/date:day">
                    <option value="{.}">
                        <xsl:if test=". = $sourceDayOfWeek">
                            <xsl:attribute name="selected">true</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </option>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$target_pattern='h' or $target_pattern='hh'">
                <xsl:variable name="sourceHour">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="totalNumber">12</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceHour"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='H' or $target_pattern='HH'">
                <xsl:variable name="sourceHour">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter">0</xsl:with-param>
                    <xsl:with-param name="totalNumber">23</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceHour"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='K' or $target_pattern='KK'">
                <xsl:variable name="sourceHour">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter">0</xsl:with-param>
                    <xsl:with-param name="totalNumber">11</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceHour"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='k' or $target_pattern='kk'">
                <xsl:variable name="sourceHour">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="totalNumber">24</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceHour"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='m' or $target_pattern='mm'">
                <xsl:variable name="sourceMinute">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter">0</xsl:with-param>
                    <xsl:with-param name="totalNumber">59</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceMinute"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='s' or $target_pattern='ss'">
                <xsl:variable name="sourceSecond">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter">0</xsl:with-param>
                    <xsl:with-param name="totalNumber">59</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceSecond"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='a'">
                <xsl:variable name="sourceAMPM">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <option>
                    <xsl:attribute name="value"><xsl:text>AM</xsl:text></xsl:attribute>
                    <xsl:if test="$sourceAMPM = 'AM'">
                        <xsl:attribute name="selected">true</xsl:attribute>
                    </xsl:if>
                    <xsl:text>AM</xsl:text>
                </option>
                <option>
                    <xsl:attribute name="value"><xsl:text>PM</xsl:text></xsl:attribute>
                    <xsl:if test="$sourceAMPM = 'PM'">
                        <xsl:attribute name="selected">true</xsl:attribute>
                    </xsl:if>
                    <xsl:text>PM</xsl:text>
                </option>
            </xsl:when>

            <xsl:when test="$target_pattern='yyyy'">
                <xsl:variable name="sourceYear">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>

                <xsl:variable name="midYear">
                    <xsl:choose>
                        <xsl:when test="$sourceYear != ''">
                            <xsl:value-of select="$sourceYear"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="date:year()" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter" select="number($midYear) - 100"></xsl:with-param>
                    <xsl:with-param name="totalNumber" select="number($midYear) + 100"></xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceYear"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$target_pattern='yy'">
                <xsl:variable name="sourceYear">
                    <xsl:if test="$source_string!=''">
                        <xsl:call-template name="_parse-format-date">
                            <xsl:with-param name="source_string" select="$source_string"/>
                            <xsl:with-param name="source_pattern" select="$source_pattern"/>
                            <xsl:with-param name="target_pattern" select="$target_pattern"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <option value="">
                    <xsl:value-of select="$placeholder"/>
                </option>
                <xsl:call-template name="numberedOptionOutput">
                    <xsl:with-param name="counter">0</xsl:with-param>
                    <xsl:with-param name="totalNumber">99</xsl:with-param>
                    <xsl:with-param name="target_pattern" select="$target_pattern"/>
                    <xsl:with-param name="selectedNumber" select="$sourceYear"/>
                </xsl:call-template>
            </xsl:when>

        </xsl:choose>
    </xsl:template>

    <!-- Template that outputs a number of days/months in option format -->
    <xsl:template name="numberedOptionOutput">
        <xsl:param name="totalNumber"/>
        <xsl:param name="selectedNumber"/>
        <xsl:param name="counter">1</xsl:param>
        <xsl:param name="target_pattern"/>
        <xsl:if test="number($counter) &lt;= number($totalNumber)">
            <!-- formats the day number correctly -->
            <xsl:variable name="formattedDay">
                <xsl:choose>
                    <xsl:when test="string-length($target_pattern) = 2">
                        <xsl:choose>
                            <xsl:when test="string-length($counter) = 1">
                                    <xsl:value-of select="concat('0',$counter)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$counter"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$counter"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- output the option tags -->
            <option value="{$formattedDay}">
                <xsl:if test="number($counter) = number($selectedNumber)">
                    <xsl:attribute name="selected">true</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$formattedDay"/>
            </option>
            <xsl:call-template name="numberedOptionOutput">
                <xsl:with-param name="totalNumber" select="$totalNumber"/>
                <xsl:with-param name="selectedNumber" select="$selectedNumber"/>
                <xsl:with-param name="counter" select="number($counter)+1"/>
                <xsl:with-param name="target_pattern" select="$target_pattern"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Output the given date values using the specified format pattern -->
    <xsl:template name="_format-date">
        <xsl:param name="year" />
        <xsl:param name="month" select="1" />
        <xsl:param name="day" select="1" />
        <xsl:param name="hour" select="0" />
        <xsl:param name="minute" select="0" />
        <xsl:param name="second" select="0" />
        <xsl:param name="timezone" select="'Z'" />
        <xsl:param name="pattern" select="''" />
        <xsl:variable name="char" select="substring($pattern, 1, 1)" />
        <xsl:choose>
            <xsl:when test="not($pattern)" />
            <xsl:when test='$char = "&apos;"'>
                <xsl:choose>
                    <xsl:when test='substring($pattern, 2, 1) = "&apos;"'>
                        <xsl:text>&apos;</xsl:text>
                        <xsl:call-template name="_format-date">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month" select="$month" />
                            <xsl:with-param name="day" select="$day" />
                            <xsl:with-param name="hour" select="$hour" />
                            <xsl:with-param name="minute" select="$minute" />
                            <xsl:with-param name="second" select="$second" />
                            <xsl:with-param name="timezone" select="$timezone" />
                            <xsl:with-param name="pattern" select="substring($pattern, 3)" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="literal-value" select='substring-before(substring($pattern, 2), "&apos;")' />
                        <xsl:value-of select="$literal-value" />
                        <xsl:call-template name="_format-date">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month" select="$month" />
                            <xsl:with-param name="day" select="$day" />
                            <xsl:with-param name="hour" select="$hour" />
                            <xsl:with-param name="minute" select="$minute" />
                            <xsl:with-param name="second" select="$second" />
                            <xsl:with-param name="timezone" select="$timezone" />
                            <xsl:with-param name="pattern" select="substring($pattern, string-length($literal-value) + 2)" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="not(contains('abcdefghjiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', $char))">
                <xsl:value-of select="$char" />
                <xsl:call-template name="_format-date">
                    <xsl:with-param name="year" select="$year" />
                    <xsl:with-param name="month" select="$month" />
                    <xsl:with-param name="day" select="$day" />
                    <xsl:with-param name="hour" select="$hour" />
                    <xsl:with-param name="minute" select="$minute" />
                    <xsl:with-param name="second" select="$second" />
                    <xsl:with-param name="timezone" select="$timezone" />
                    <xsl:with-param name="pattern" select="substring($pattern, 2)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(contains($patternCharacters, $char))">
                <xsl:message>
                    Invalid token in format string: <xsl:value-of select="$char" />
                </xsl:message>
                <xsl:call-template name="_format-date">
                    <xsl:with-param name="year" select="$year" />
                    <xsl:with-param name="month" select="$month" />
                    <xsl:with-param name="day" select="$day" />
                    <xsl:with-param name="hour" select="$hour" />
                    <xsl:with-param name="minute" select="$minute" />
                    <xsl:with-param name="second" select="$second" />
                    <xsl:with-param name="timezone" select="$timezone" />
                    <xsl:with-param name="pattern" select="substring($pattern, 2)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="next-different-char" select="substring(translate($pattern, $char, ''), 1, 1)" />
                <xsl:variable name="pattern-length">
                    <xsl:choose>
                        <xsl:when test="$next-different-char">
                            <xsl:value-of select="string-length(substring-before($pattern, $next-different-char))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string-length($pattern)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$char = 'G'">
                        <xsl:choose>
                            <xsl:when test="string($year) = 'NaN'" />
                            <xsl:when test="$year > 0">AD</xsl:when>
                            <xsl:otherwise>BC</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$char = 'M' or $char = 'N'">
                        <xsl:choose>
                            <xsl:when test="string($month) = 'NaN'" />
                            <xsl:when test="$pattern-length >= 3">
                                <xsl:variable name="month-node" select="document('')/*/date:months/date:month[number($month)]" />
                                <xsl:choose>
                                    <xsl:when test="$pattern-length >= 4">
                                        <xsl:value-of select="$month-node" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$month-node/@abbr" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$pattern-length = 2">
                                <xsl:value-of select="format-number($month, '00')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$month" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$char = 'E'">
                        <xsl:choose>
                            <xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'" />
                            <xsl:otherwise>
                                <xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)" />
                                <xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month > 2)" />
                                <xsl:variable name="y-1" select="$year - 1" />
                                <xsl:variable name="dow"
                                        select="(($y-1 + floor($y-1 div 4) - floor($y-1 div 100) + floor($y-1 div 400) + $days) mod 7) + 1" />
                                <xsl:variable name="day-node" select="document('')/*/date:days/date:day[number($dow)]" />
                                <xsl:choose>
                                    <xsl:when test="$pattern-length >= 2">
                                        <xsl:value-of select="$day-node" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$day-node/@abbr" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$char = 'a'">
                        <xsl:choose>
                            <xsl:when test="string($hour) = 'NaN'" />
                            <xsl:when test="$hour >= 12">PM</xsl:when>
                            <xsl:otherwise>AM</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$char = 'z'">
                        <xsl:choose>
                            <xsl:when test="$timezone = 'Z'">UTC</xsl:when>
                            <xsl:otherwise>UTC<xsl:value-of select="$timezone" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="padding">
                            <xsl:value-of select="substring('000000000000000', 1, $pattern-length)" />
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$char = 'y'">
                                <xsl:choose>
                                    <xsl:when test="string($year) = 'NaN'" />
                                    <xsl:when test="$pattern-length > 2">
                                        <xsl:value-of select="format-number($year, $padding)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number(substring($year, string-length($year) - 1), $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'd'">
                                <xsl:choose>
                                    <xsl:when test="string($day) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number($day, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'h'">
                                <xsl:variable name="h" select="$hour mod 12" />
                                <xsl:choose>
                                    <xsl:when test="string($hour) = 'NaN'"></xsl:when>
                                    <xsl:when test="$h">
                                        <xsl:value-of select="format-number($h, $padding)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number(12, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'H'">
                                <xsl:choose>
                                    <xsl:when test="string($hour) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number($hour, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'k'">
                                <xsl:choose>
                                    <xsl:when test="string($hour) = 'NaN'" />
                                    <xsl:when test="$hour">
                                        <xsl:value-of select="format-number($hour, $padding)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number(24, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'K'">
                                <xsl:choose>
                                    <xsl:when test="string($hour) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number($hour mod 12, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'm'">
                                <xsl:choose>
                                    <xsl:when test="string($minute) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number($minute, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 's'">
                                <xsl:choose>
                                    <xsl:when test="string($second) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number($second, $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'S'">
                                <xsl:choose>
                                    <xsl:when test="string($second) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="format-number(substring-after($second, '.'), $padding)" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$char = 'F'">
                                <xsl:choose>
                                    <xsl:when test="string($day) = 'NaN'" />
                                    <xsl:otherwise>
                                        <xsl:value-of select="floor($day div 7) + 1" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="string($year) = 'NaN' or string($month) = 'NaN' or string($day) = 'NaN'" />
                            <xsl:otherwise>
                                <xsl:variable name="month-days" select="sum(document('')/*/date:months/date:month[position() &lt; $month]/@length)" />
                                <xsl:variable name="days" select="$month-days + $day + boolean(((not($year mod 4) and $year mod 100) or not($year mod 400)) and $month > 2)" />
                                <xsl:choose>
                                    <xsl:when test="$char = 'D'">
                                        <xsl:value-of select="format-number($days, $padding)" />
                                    </xsl:when>
                                    <xsl:when test="$char = 'w'">
                                        <xsl:call-template name="_week-in-year">
                                            <xsl:with-param name="days" select="$days" />
                                            <xsl:with-param name="year" select="$year" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$char = 'W'">
                                        <xsl:variable name="y-1" select="$year - 1" />
                                        <xsl:variable name="day-of-week"
                                                select="(($y-1 + floor($y-1 div 4) - floor($y-1 div 100) + floor($y-1 div 400) + $days) mod 7) + 1" />
                                        <xsl:choose>
                                            <xsl:when test="($day - $day-of-week) mod 7">
                                                <xsl:value-of select="floor(($day - $day-of-week) div 7) + 2" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="floor(($day - $day-of-week) div 7) + 1" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="_format-date">
                    <xsl:with-param name="year" select="$year" />
                    <xsl:with-param name="month" select="$month" />
                    <xsl:with-param name="day" select="$day" />
                    <xsl:with-param name="hour" select="$hour" />
                    <xsl:with-param name="minute" select="$minute" />
                    <xsl:with-param name="second" select="$second" />
                    <xsl:with-param name="timezone" select="$timezone" />
                    <xsl:with-param name="pattern" select="substring($pattern, $pattern-length + 1)" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="_week-in-year">
        <xsl:param name="days" />
        <xsl:param name="year" />
        <xsl:variable name="y-1" select="$year - 1" />
        <!-- this gives the day of the week, counting from Sunday = 0 -->
        <xsl:variable name="day-of-week"
                select="($y-1 + floor($y-1 div 4) - floor($y-1 div 100) + floor($y-1 div 400) + $days) mod 7" />
        <!-- this gives the day of the week, counting from Monday = 1 -->
        <xsl:variable name="dow">
            <xsl:choose>
                <xsl:when test="$day-of-week">
                    <xsl:value-of select="$day-of-week" />
                </xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="start-day" select="($days - $dow + 7) mod 7" />
        <xsl:variable name="week-number" select="floor(($days - $dow + 7) div 7)" />
        <xsl:choose>
            <xsl:when test="$start-day >= 4">
                <xsl:value-of select="$week-number + 1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not($week-number)">
                        <xsl:call-template name="_week-in-year">
                            <xsl:with-param name="days" select="365 + ((not($y-1 mod 4) and $y-1 mod 100) or not($y-1 mod 400))" />
                            <xsl:with-param name="year" select="$y-1" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$week-number" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>