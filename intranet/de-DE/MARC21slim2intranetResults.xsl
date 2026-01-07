<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<!DOCTYPE stylesheet>
<xsl:stylesheet version="1.0"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                exclude-result-prefixes="marc str">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">

        <!-- Option: Display Alternate Graphic Representation (MARC 880) -->
        <xsl:variable name="display880" select="boolean(marc:datafield[@tag=880])"/>
        <xsl:variable name="UseControlNumber" select="marc:sysprefs/marc:syspref[@name='UseControlNumber']"/>

        <xsl:variable name="URLLinkText" select="marc:sysprefs/marc:syspref[@name='URLLinkText']"/>
        <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='Display856uAsImage']"/>
        <xsl:variable name="AlternateHoldingsField"
                      select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 1, 3)"/>
        <xsl:variable name="AlternateHoldingsSubfields"
                      select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 4)"/>
        <xsl:variable name="AlternateHoldingsSeparator"
                      select="marc:sysprefs/marc:syspref[@name='AlternateHoldingsSeparator']"/>
        <xsl:variable name="UseAuthoritiesForTracings"
                      select="marc:sysprefs/marc:syspref[@name='UseAuthoritiesForTracings']"/>
        <xsl:variable name="AuthorLinkSortBy" select="marc:sysprefs/marc:syspref[@name='AuthorLinkSortBy']"/>
        <xsl:variable name="AuthorLinkSortOrder" select="marc:sysprefs/marc:syspref[@name='AuthorLinkSortOrder']"/>
        <xsl:variable name="DisplayIconsXSLT" select="marc:sysprefs/marc:syspref[@name='DisplayIconsXSLT']"/>
        <xsl:variable name="IntranetBiblioDefaultView"
                      select="marc:sysprefs/marc:syspref[@name='IntranetBiblioDefaultView']"/>
        <xsl:variable name="OpacSuppression" select="marc:sysprefs/marc:syspref[@name='OpacSuppression']"/>
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="leader19" select="substring($leader,20,1)"/>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="typeOf008">
            <xsl:choose>
                <xsl:when test="$leader19='a'">ST</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">CR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='o' or $leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='i' or $leader6='j'">MU</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">PR</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
        <xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"/>
        <xsl:variable name="controlField008-22" select="substring($controlField008,23,1)"/>
        <xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"/>
        <xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"/>
        <xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
        <xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"/>
        <xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
        <xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"/>

        <xsl:variable name="physicalDescription">
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
                digital umformatiert
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
                Digitalisierter Mikrofilm
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
                Anderes digitalisiertes analoges Medium
            </xsl:if>

            <xsl:variable name="check008-23">
                <xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='CR' or $typeOf008='MX'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="check008-29">
                <xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when
                        test="($check008-23 and $controlField008-23='f') or ($check008-29 and $controlField008-29='f')">
                    Braille
                </xsl:when>
                <xsl:when
                        test="($controlField008-23=' ' and ($leader6='c' or $leader6='d')) or (($typeOf008='BK' or $typeOf008='CR') and ($controlField008-23=' ' or $controlField008='r'))">
                    Druck
                </xsl:when>
                <xsl:when
                        test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
                    elektronisch
                </xsl:when>
                <xsl:when
                        test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
                    Mikrofiche
                </xsl:when>
                <xsl:when
                        test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
                    Mikrofilm
                </xsl:when>
                <xsl:when test="($controlField008-23='d' and ($typeOf008='BK' or $typeOf008='CR'))">
                    Großdruck
                </xsl:when>
            </xsl:choose>

            <xsl:variable name="controlField007" select="marc:controlfield[@tag=007]"/>
            <xsl:variable name="cf007ss11" select="substring($controlField007,1,1)"/>
            <xsl:variable name="cf007ss21" select="substring($controlField007,2,1)"/>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'b'">
                Chipkarte
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'j'">
                Magnetplatte
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'm'">
                Magneto Optical Disk
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'r'">
                online verfügbar
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'a'">
                Bandkassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'f'">
                Magnetbandkassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'c' and $cf007ss21 = 'f'">
                Bandspule
            </xsl:if>

            <xsl:if test="$cf007ss11 = 'o' and $cf007ss21 = 'o'">
                kit
            </xsl:if>

            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'd'">
                Atlas
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'g'">
                Diagramm
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'j'">
                Karte
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'q'">
                Modell
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'k'">
                Profil
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'r'">
                Fernaufnahme
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 's'">
                Ausschnitt
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'a' and $cf007ss21 = 'y'">
                Sicht
            </xsl:if>

            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'a'">
                Mikrofilmlochkarte
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'e'">
                Mikrofiche
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'f'">
                Mikrofiche in Kasette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'b'">
                Mikrofilm-Cartridge
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'c'">
                Mikrofilm in Kassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'd'">
                Mikrofilm auf Spule
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'h' and $cf007ss21 = 'g'">
                Mikrokarte
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'm' and $cf007ss21 = 'c'">
                Filmkartusche
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'm' and $cf007ss21 = 'f'">
                Filmkasette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'm' and $cf007ss21 = 'r'">
                Filmrolle
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'c'">
                Kollage
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'f'">
                Fotomechanischer Druck
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'g'">
                Fotonegativ
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'h'">
                Fotomechanischer Druck
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'j'">
                Druck
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'k' and $cf007ss21 = 'l'">
                Technische Zeichnung
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'g' and $cf007ss21 = 'd'">
                Filmstreifen
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'g' and $cf007ss21 = 'c'">
                Filmstreifen-Kartusche
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'g' and $cf007ss21 = 'o'">
                Filmstreifenrolle
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'g' and $cf007ss21 = 'f'">
                anderer Typ von Filmstreifen
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'g' and $cf007ss21 = 't'">
                Folie
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'r' and $cf007ss21 = 'r'">
                Fernaufnahme
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 'e'">
                Zylinder
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 'q'">
                Rolle
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 'g'">
                Endlostonbandkassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 's'">
                Tonkassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 't'">
                Tonbandspule
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 'i'">
                Tonfilm
            </xsl:if>
            <xsl:if test="$cf007ss11 = 's' and $cf007ss21 = 'w'">
                Drahtaufzeichnung
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'f' and $cf007ss21 = 'c'">
                Kombination
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'f' and $cf007ss21 = 'b'">
                Braille
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'f' and $cf007ss21 = 'a'">
                Mond
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'f' and $cf007ss21 = 'd'">
                taktil, ohne Schreibsystem
            </xsl:if>
            <xsl:if test="$cf007ss11 = 't' and $cf007ss21 = 'c'">
                Braille
            </xsl:if>
            <xsl:if test="$cf007ss11 = 't' and $cf007ss21 = 'a'">
                regulärer Druck
            </xsl:if>
            <xsl:if test="$cf007ss11 = 't' and $cf007ss21 = 'd'">
                Text im Loseblatthefter
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'v' and $cf007ss21 = 'c'">
                Videokartusche
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'v' and $cf007ss21 = 'f'">
                Videokassette
            </xsl:if>
            <xsl:if test="$cf007ss11 = 'v' and $cf007ss21 = 'r'">
                Videospule
            </xsl:if>
            <!--
             <xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q'][string-length(.)>1]">
             <xsl:value-of select="."></xsl:value-of>
             </xsl:for-each>
             <xsl:for-each select="marc:datafield[@tag=300]">
             <xsl:call-template name="subfieldSelect">
             <xsl:with-param name="codes">abce</xsl:with-param>
             </xsl:call-template>
             </xsl:for-each>
            -->
        </xsl:variable>

        <!-- Title Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">245</xsl:with-param>
                <xsl:with-param name="codes">abhfgknps</xsl:with-param>
                <xsl:with-param name="bibno">
                    <xsl:value-of select="$biblionumber"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <a>
            <xsl:attribute name="href">
                <xsl:call-template name="buildBiblioDefaultViewURL">
                    <xsl:with-param name="IntranetBiblioDefaultView">
                        <xsl:value-of select="$IntranetBiblioDefaultView"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:value-of select="str:encode-uri($biblionumber, true())"/>
            </xsl:attribute>
            <xsl:attribute name="class">title</xsl:attribute>

            <xsl:if test="marc:datafield[@tag=245]">
                <xsl:for-each select="marc:datafield[@tag=245]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <!-- 13381 add additional subfields-->
                    <!-- bz 17625 adding subfields f and g -->
                    <xsl:for-each select="marc:subfield[contains('bcfghknps', @code)]">
                        <xsl:choose>
                            <xsl:when test="@code='h'">
                                <!-- 13381 Span class around subfield h so it can be suppressed via css -->
                                <span class="title_medium">
                                    <xsl:apply-templates/>
                                    <xsl:text> </xsl:text>
                                </span>
                            </xsl:when>
                            <xsl:when test="@code='c'">
                                <!-- 13381 Span class around subfield c so it can be suppressed via css -->
                                <span class="title_resp_stmt">
                                    <xsl:apply-templates/>
                                    <xsl:text> </xsl:text>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> : </xsl:text>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:if>
        </a>

        <!-- Author Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">100,110,111,700,710,711</xsl:with-param>
                <xsl:with-param name="codes">abc</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:choose>
            <xsl:when
                    test="marc:datafield[@tag=100] or marc:datafield[@tag=110] or marc:datafield[@tag=111] or marc:datafield[@tag=700] or marc:datafield[@tag=710] or marc:datafield[@tag=711]">
                <p class="author">
                    <span class="byAuthor">von </span>

                    <xsl:for-each
                            select="marc:datafield[(@tag=100 or @tag=700 or @tag=110 or @tag=710 or @tag=111 or @tag=711) and @ind1!='z']">
                        <a>
                            <xsl:choose>
                                <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                                    <xsl:attribute name="href">
                                        <xsl:text>/cgi-bin/koha/catalogue/search.pl?q=an:</xsl:text>
                                        <xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/>
                                        <xsl:if test="$AuthorLinkSortBy!='default'">
                                            <xsl:text>&amp;sort_by=</xsl:text>
                                            <xsl:value-of select="$AuthorLinkSortBy"/>
                                            <xsl:text>_</xsl:text>
                                            <xsl:value-of select="$AuthorLinkSortOrder"/>
                                        </xsl:if>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href">
                                        <xsl:text>/cgi-bin/koha/catalogue/search.pl?q=au:"</xsl:text>
                                        <xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>
                                        <xsl:text>"</xsl:text>
                                        <xsl:if test="$AuthorLinkSortBy!='default'">
                                            <xsl:text>&amp;sort_by=</xsl:text>
                                            <xsl:value-of select="$AuthorLinkSortBy"/>
                                            <xsl:text>_</xsl:text>
                                            <xsl:value-of select="$AuthorLinkSortOrder"/>
                                        </xsl:if>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="chopPunctuation">
                                <xsl:with-param name="chopString">
                                    <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">
                                            <xsl:choose>
                                                <!-- #13383 include subfield e for field 111 -->
                                                <xsl:when test="@tag=111 or @tag=711">aeq</xsl:when>
                                                <xsl:when test="@tag=110 or @tag=710">ab</xsl:when>
                                                <xsl:otherwise>abcjq</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="punctuation">
                                    <xsl:text>:,;/ </xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                            <!-- Display title portion for 110 and 710 fields -->
                            <xsl:if test="(@tag=110 or @tag=710) and boolean(marc:subfield[@code='c' or @code='d' or @code='n' or @code='t'])">
                                <span class="titleportion">
                                    <xsl:choose>
                                        <xsl:when
                                                test="marc:subfield[@code='c' or @code='d' or @code='n'][not(marc:subfield[@code='t'])]">
                                            <xsl:text> </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>. </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:call-template name="chopPunctuation">
                                        <xsl:with-param name="chopString">
                                            <xsl:call-template name="subfieldSelect">
                                                <xsl:with-param name="codes">cdnt</xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </span>
                            </xsl:if>
                            <!-- Display title portion for 111 and 711 fields -->
                            <xsl:if test="(@tag=111 or @tag=711) and boolean(marc:subfield[@code='c' or @code='d' or @code='g' or @code='n' or @code='t'])">
                                <span class="titleportion">
                                    <xsl:choose>
                                        <xsl:when
                                                test="marc:subfield[@code='c' or @code='d' or @code='g' or @code='n'][not(marc:subfield[@code='t'])]">
                                            <xsl:text> </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>. </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <xsl:call-template name="chopPunctuation">
                                        <xsl:with-param name="chopString">
                                            <xsl:call-template name="subfieldSelect">
                                                <xsl:with-param name="codes">cdgnt</xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </span>
                            </xsl:if>
                            <!-- Display dates for 100 and 700 fields -->
                            <xsl:if test="(@tag=100 or @tag=700) and marc:subfield[@code='d']">
                                <span class="authordates">
                                    <xsl:text>, </xsl:text>
                                    <xsl:call-template name="chopPunctuation">
                                        <xsl:with-param name="chopString">
                                            <xsl:call-template name="subfieldSelect">
                                                <xsl:with-param name="codes">d</xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </span>
                            </xsl:if>
                            <!-- Display title portion for 100 and 700 fields -->
                            <xsl:if test="@tag=700 and marc:subfield[@code='t']">
                                <span class="titleportion">
                                    <xsl:text>. </xsl:text>
                                    <xsl:call-template name="chopPunctuation">
                                        <xsl:with-param name="chopString">
                                            <xsl:call-template name="subfieldSelect">
                                                <xsl:with-param name="codes">t</xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </span>
                            </xsl:if>
                        </a>
                        <!-- Display relators for 1XX and 7XX fields -->
                        <xsl:if test="marc:subfield[@code='4' or @code='e'][not(parent::*[@tag=111])] or (self::*[@tag=111] and marc:subfield[@code='4' or @code='j'][. != ''])">
                            <span class="relatorcode">
                                <xsl:text> [</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="@tag=111 or @tag=711">
                                        <xsl:choose>
                                            <!-- Prefer j over 4 -->
                                            <xsl:when test="marc:subfield[@code='j']">
                                                <xsl:for-each select="marc:subfield[@code='j']">
                                                    <xsl:value-of select="."/>
                                                    <xsl:if test="position() != last()">,</xsl:if>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:for-each select="marc:subfield[@code=4]">
                                                    <xsl:value-of select="."/>
                                                    <xsl:if test="position() != last()">,</xsl:if>
                                                </xsl:for-each>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <!-- Prefer e over 4 -->
                                    <xsl:when test="marc:subfield[@code='e']">
                                        <xsl:for-each select="marc:subfield[@code='e'][not(@tag=111) or not(@tag=711)]">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">,</xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="marc:subfield[@code=4]">
                                            <xsl:value-of select="."/>
                                            <xsl:if test="position() != last()">,</xsl:if>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>]</xsl:text>
                            </span>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="position()=last()">
                                <xsl:text>.</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="separator">
                                    <xsl:text> | </xsl:text>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </p>
            </xsl:when>
        </xsl:choose>

        <xsl:if test="$DisplayIconsXSLT!='0'">
            <span class="results_summary">
                <xsl:if test="$typeOf008!=''">
                    <span class="results_material_type">
                        <span class="label">Materialtyp:</span>
                        <xsl:choose>
                            <xsl:when test="$leader19='a'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/book_link.png" alt="book" title="book"
                                     class="materialtype"/>
                                Gesamtaufnahme
                            </xsl:when>
                            <xsl:when test="$leader6='a'">
                                <xsl:choose>
                                    <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'">
                                        <img src="/intranet-tmpl/prog/img/famfamfam/silk/book.png" alt="book"
                                             title="book" class="materialtype mt_icon_BK"/>
                                        Text
                                    </xsl:when>
                                    <xsl:when test="$leader7='i' or $leader7='s'">
                                        <img alt="Zeitschrift" class="materialtype mt_icon_CR"
                                             src="/intranet-tmpl/prog/img/famfamfam/silk/newspaper.png"
                                             title="Zeitschrift"/>
                                        Fortlaufende Ressource
                                    </xsl:when>
                                    <xsl:when test="$leader7='a' or $leader7='b'">
                                        <img src="/intranet-tmpl/prog/img/famfamfam/silk/book_open.png" alt=""
                                             class="materialtype mt_icon_AR"/>
                                        Aufsatz
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$leader6='t'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/book.png" alt=""
                                     class="materialtype mt_icon_BK"/>
                                Text
                            </xsl:when>
                            <xsl:when test="$leader6='o'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/report_disk.png" alt=""
                                     class="materialtype mt_icon_MX"/>
                                Medienkombination
                            </xsl:when>
                            <xsl:when test="$leader6='p'"><img
                                    src="/intranet-tmpl/prog/img/famfamfam/silk/report_disk.png" alt=""
                                    class="materialtype mt_icon_MX"/>Medienkombination
                            </xsl:when>
                            <xsl:when test="$leader6='m'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/computer_link.png" alt=""
                                     class="materialtype mt_icon_CF"/>
                                Computerdatei
                            </xsl:when>
                            <xsl:when test="$leader6='e' or $leader6='f'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/map.png" alt=""
                                     class="materialtype mt_icon_MP"/>
                                Karte
                            </xsl:when>
                            <xsl:when test="$leader6='g'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/film.png" alt=""
                                     class="materialtype mt_icon_VM"/>
                                Film
                            </xsl:when>
                            <xsl:when test="$leader6='k'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/picture.png" alt=""
                                     class="materialtype mt_icon_GR"/>
                                Bild
                            </xsl:when>
                            <xsl:when test="$leader6='r'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/object.png" alt=""
                                     class="materialtype mt_icon_OB"/>
                                Objekt
                            </xsl:when>
                            <xsl:when test="$leader6='c' or $leader6='d'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/music.png" alt=""
                                     class="materialtype mt_icon_PR"/>
                                Noten
                            </xsl:when>
                            <xsl:when test="$leader6='i'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/sound.png" alt=""
                                     class="materialtype mt_icon_MU"/>
                                Ton
                            </xsl:when>
                            <xsl:when test="$leader6='j'">
                                <img src="/intranet-tmpl/prog/img/famfamfam/silk/sound.png" alt=""
                                     class="materialtype mt_icon_MU"/>
                                Musik
                            </xsl:when>
                        </xsl:choose>
                    </span>
                </xsl:if>

                <xsl:if test="string-length(normalize-space($physicalDescription))">
                    <span class="results_format">
                        <span class="label">; Format:</span>
                        <xsl:copy-of select="$physicalDescription"></xsl:copy-of>
                    </span>
                </xsl:if>

                <xsl:if test="$controlField008-21 or $controlField008-22 or $controlField008-24 or $controlField008-26 or $controlField008-29 or $controlField008-34 or $controlField008-33 or $controlField008-30-31 or $controlField008-33">

                    <xsl:if test="$typeOf008='CR'">
                        <span class="results_typeofcontinueing">
                            <xsl:if test="$controlField008-21 and $controlField008-21 !='|' and $controlField008-21 !=' '">
                                <span class="label">; Art der fortlaufenden Ressource:</span>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-21='l'">
                                    Loseblattsammlung
                                </xsl:when>
                                <xsl:when test="$controlField008-21='m'">
                                    Reihen
                                </xsl:when>
                                <xsl:when test="$controlField008-21='n'">
                                    Zeitung
                                </xsl:when>
                                <xsl:when test="$controlField008-21='p'">
                                    Periodika
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='BK' or $typeOf008='CR'">
                        <xsl:if test="contains($controlField008-24,'abcdefghijklmnopqrstvwxyz')">
                            <span class="results_natureofcontents">
                                <span class="label">; Inhaltstyp:</span>
                                <xsl:choose>
                                    <xsl:when test="contains($controlField008-24,'a')">
                                        Kurzfassung oder Zusammenfassung
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'b')">
                                        Bibliographie
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'c')">
                                        Katalog
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'d')">
                                        Wörterbuch
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'e')">
                                        Enzyklopädie
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'f')">
                                        Handbuch
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'g')">
                                        Rechtsartikel
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'i')">
                                        Index
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'k')">
                                        Diskographie
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'l')">
                                        Gesetze
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'m')">
                                        Hochschulschriften
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'n')">
                                        Literaturübersicht
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'o')">
                                        Besprechung
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'p')">
                                        Programme
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'q')">
                                        Filmographie
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'r')">
                                        Verzeichnis
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'s')">
                                        Statistiken
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'v')">
                                        Rechtsfall oder Fallbeschreibung
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'w')">
                                        Entscheidungsbericht oder -sammlung
                                    </xsl:when>
                                    <xsl:when test="contains($controlField008-24,'z')">
                                        Vertrag
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="$controlField008-29='1'">
                                        Konferenzschrift
                                    </xsl:when>
                                </xsl:choose>
                            </span>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$typeOf008='CF'">
                        <span class="results_typeofcomp">
                            <xsl:if test="$controlField008-26='a' or $controlField008-26='e' or $controlField008-26='f' or $controlField008-26='g'">
                                <span class="label">; Art der Computerdatei:</span>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-26='a'">
                                    numerische Daten
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='BK'">
                        <span class="results_contents_literary">
                            <xsl:if test="(substring($controlField008,25,1)='j') or (substring($controlField008,25,1)='1') or ($controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d')">
                                <span class="label">; Inhaltstyp:</span>
                            </xsl:if>
                            <xsl:if test="substring($controlField008,25,1)='j'">
                                Patent
                            </xsl:if>
                            <xsl:if test="substring($controlField008,31,1)='1'">
                                Festschrift
                            </xsl:if>

                            <xsl:if test="$controlField008-33 and $controlField008-33!='|' and $controlField008-33!='u' and $controlField008-33!=' '">
                                <span class="label">; Literarische Form:</span>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$controlField008-33='0'">
                                    Sachliteratur
                                </xsl:when>
                                <xsl:when test="$controlField008-33='1'">
                                    Belletristik
                                </xsl:when>
                                <xsl:when test="$controlField008-33='d'">
                                    Dramen
                                </xsl:when>
                                <xsl:when test="$controlField008-33='e'">
                                    Essays
                                </xsl:when>
                                <xsl:when test="$controlField008-33='f'">
                                    Novellen
                                </xsl:when>
                                <xsl:when test="$controlField008-33='h'">
                                    Humor, Satiren, usw.
                                </xsl:when>
                                <xsl:when test="$controlField008-33='i'">
                                    Briefe
                                </xsl:when>
                                <xsl:when test="$controlField008-33='j'">
                                    Kurzgeschichten
                                </xsl:when>
                                <xsl:when test="$controlField008-33='m'">
                                    Verschiedene Formen
                                </xsl:when>
                                <xsl:when test="$controlField008-33='p'">
                                    Poesie
                                </xsl:when>
                                <xsl:when test="$controlField008-33='s'">
                                    Reden
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='MU' and $controlField008-30-31 and $controlField008-30-31!='||' and $controlField008-30-31!='  '">
                        <span class="results_literaryform">
                            <span class="label">; Literarische Form:</span> <!-- Literary text for sound recordings -->
                            <xsl:if test="contains($controlField008-30-31,'b')">
                                Biographie
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'c')">
                                Konferenzschrift
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'d')">
                                Drama
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'e')">
                                Essay
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'f')">
                                Belletristik
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'o')">
                                Volkssage
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'h')">
                                Geschichte
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'k')">
                                Humor, Satire
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'m')">
                                Memoiren
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'p')">
                                Poesie
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'r')">
                                Probe
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'g')">
                                Reportagen
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'s')">
                                Ton
                            </xsl:if>
                            <xsl:if test="contains($controlField008-30-31,'l')">
                                Rede
                            </xsl:if>
                        </span>
                    </xsl:if>
                    <xsl:if test="$typeOf008='VM'">
                        <span class="results_typeofvisual">
                            <span class="label">; Art des visuellen Materials:</span>
                            <xsl:choose>
                                <xsl:when test="$controlField008-33='a'">
                                    Kunst-Original
                                </xsl:when>
                                <xsl:when test="$controlField008-33='b'">
                                    kit
                                </xsl:when>
                                <xsl:when test="$controlField008-33='c'">
                                    Kunst-Reproduktion
                                </xsl:when>
                                <xsl:when test="$controlField008-33='d'">
                                    Diorama
                                </xsl:when>
                                <xsl:when test="$controlField008-33='f'">
                                    Filmstreifen
                                </xsl:when>
                                <xsl:when test="$controlField008-33='g'">
                                    Spiel
                                </xsl:when>
                                <xsl:when test="$controlField008-33='i'">
                                    Bild
                                </xsl:when>
                                <xsl:when test="$controlField008-33='k'">
                                    Graphik
                                </xsl:when>
                                <xsl:when test="$controlField008-33='l'">
                                    Technische Zeichnung
                                </xsl:when>
                                <xsl:when test="$controlField008-33='m'">
                                    Film
                                </xsl:when>
                                <xsl:when test="$controlField008-33='n'">
                                    Tabelle
                                </xsl:when>
                                <xsl:when test="$controlField008-33='o'">
                                    Speicherkarte
                                </xsl:when>
                                <xsl:when test="$controlField008-33='p'">
                                    Objektträger
                                </xsl:when>
                                <xsl:when
                                        test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                                    Modell
                                </xsl:when>
                                <xsl:when test="$controlField008-33='r'">
                                    Gegenstand
                                </xsl:when>
                                <xsl:when test="$controlField008-33='s'">
                                    Dia
                                </xsl:when>
                                <xsl:when test="$controlField008-33='t'">
                                    Folie
                                </xsl:when>
                                <xsl:when test="$controlField008-33='v'">
                                    Videoaufnahme
                                </xsl:when>
                                <xsl:when test="$controlField008-33='w'">
                                    Spielzeug
                                </xsl:when>
                            </xsl:choose>
                        </span>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="($typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM') and ($controlField008-22='a' or $controlField008-22='b' or $controlField008-22='c' or $controlField008-22='d' or $controlField008-22='e' or $controlField008-22='g' or $controlField008-22='j' or $controlField008-22='f')">
                    <span class="results_audience">
                        <span class="label">; Zielgruppe:</span>
                        <xsl:choose>
                            <xsl:when test="$controlField008-22='a'">
                                Vorschule;
                            </xsl:when>
                            <xsl:when test="$controlField008-22='b'">
                                Primär;
                            </xsl:when>
                            <xsl:when test="$controlField008-22='c'">
                                Kind (10-12 Jahre);
                            </xsl:when>
                            <xsl:when test="$controlField008-22='d'">
                                Kind (13-17 Jahre);
                            </xsl:when>
                            <xsl:when test="$controlField008-22='e'">
                                Erwachsener;
                            </xsl:when>
                            <xsl:when test="$controlField008-22='g'">
                                Allgemein;
                            </xsl:when>
                            <xsl:when test="$controlField008-22='j'">
                                Jugendliche;
                            </xsl:when>
                            <xsl:when test="$controlField008-22='f'">
                                Spezialisiert;
                            </xsl:when>
                        </xsl:choose>
                    </span>
                </xsl:if>
                <xsl:text> </xsl:text> <!-- added blank space to fix font display problem, see Bug 3671 -->
            </span>
        </xsl:if> <!-- DisplayIconsXSLT -->

        <xsl:call-template name="show-lang-041"/>

        <!-- Publisher Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">260</xsl:with-param>
                <xsl:with-param name="codes">abcg</xsl:with-param>
                <xsl:with-param name="class">results_summary publisher</xsl:with-param>
                <xsl:with-param name="label">Veröffentlichungsangaben:</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:call-template name="show-series">
            <xsl:with-param name="searchurl">/cgi-bin/koha/catalogue/search.pl</xsl:with-param>
            <xsl:with-param name="UseControlNumber" select="$UseControlNumber"/>
            <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
        </xsl:call-template>

        <!-- Publisher info and RDA related info from tags 260, 264 -->
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag=264]">
                <xsl:call-template name="showRDAtag264"/>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag=260]">
                <span class="results_summary publisher">
                    <span class="label">Veröffentlichungsangaben:</span>
                    <xsl:for-each select="marc:datafield[@tag=260]">
                        <xsl:if test="marc:subfield[@code='a']">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                        <xsl:if test="marc:subfield[@code='b']">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">b</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">cg</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="position()=last()">
                                <xsl:text></xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>; </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:when>
        </xsl:choose>

        <!-- Publisher or Distributor Number -->
        <xsl:if test="marc:datafield[@tag=028]">
            <span class="results_summary publisher_number ">
                <span class="label">Verlagsnummer:</span>
                <xsl:for-each select="marc:datafield[@tag=028]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abq</xsl:with-param>
                        <xsl:with-param name="delimeter">
                            <xsl:text> | </xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- Dissertation note -->
        <xsl:if test="marc:datafield[@tag=502]">
            <span class="results_summary diss_note">
                <span class="label">Hochschulschriftenvermerk:</span>
                <xsl:for-each select="marc:datafield[@tag=502]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdgo</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="position()=last()">
                        <xsl:text></xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=300]">
            <span class="results_summary description">
                <span class="label">Beschreibung:</span>
                <xsl:for-each select="marc:datafield[@tag=300]">
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abcefg</xsl:with-param>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="position()=last()">
                            <xsl:text>.</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>; </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:call-template name="showISBNISSN"/>

        <xsl:if test="marc:datafield[@tag=250]">
            <span class="results_summary edition">
                <span class="label">Auflage:</span>
                <xsl:for-each select="marc:datafield[@tag=250]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- Other Title Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">246</xsl:with-param>
                <xsl:with-param name="codes">ab</xsl:with-param>
                <xsl:with-param name="class">results_summary other_title</xsl:with-param>
                <xsl:with-param name="label">Weitere Titel:</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=246]">
            <span class="results_summary other_title">
                <span class="label">Weitere Titel:</span>
                <xsl:for-each select="marc:datafield[@tag=246]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
                    <!-- #13386 added separator | -->
                    <xsl:choose>
                        <xsl:when test="position()=last()">
                            <xsl:text>.</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="separator">
                                <xsl:text> | </xsl:text>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:call-template name="host-item-entries">
            <xsl:with-param name="UseControlNumber" select="$UseControlNumber"/>
        </xsl:call-template>

        <xsl:if test="marc:datafield[@tag=856]">
            <xsl:if test="marc:datafield[@tag=856]/marc:subfield[@code='u']">
                <span class="results_summary online_resources">
                    <span class="label">Online-Ressourcen:</span>
                    <xsl:for-each select="marc:datafield[@tag=856 and marc:subfield[@code='u']]">
                        <xsl:variable name="SubqText">
                            <xsl:value-of select="marc:subfield[@code='q']"/>
                        </xsl:variable>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:call-template name="AddMissingProtocol">
                                    <xsl:with-param name="resourceLocation" select="marc:subfield[@code='u']"/>
                                    <xsl:with-param name="indicator1" select="@ind1"/>
                                    <xsl:with-param name="accessMethod" select="marc:subfield[@code='2']"/>
                                </xsl:call-template>
                                <xsl:value-of select="marc:subfield[@code='u']"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                        test="($Show856uAsImage='Results' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                                    <xsl:element name="img">
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="marc:subfield[@code='u']"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="alt">
                                            <xsl:value-of select="marc:subfield[@code='y']"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="height">100</xsl:attribute>
                                    </xsl:element>
                                    <xsl:text></xsl:text>
                                </xsl:when>
                                <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                                    <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">y3z</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when
                                        test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
                                    <xsl:choose>
                                        <xsl:when test="$URLLinkText!=''">
                                            <xsl:value-of select="$URLLinkText"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>Online-Zugang</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </a>
                        <xsl:choose>
                            <xsl:when test="position()=last()">
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>|</xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:if>
        </xsl:if>

        <!-- Content Warning -->
        <xsl:variable name="ContentWarningField" select="marc:sysprefs/marc:syspref[@name='ContentWarningField']"/>
        <xsl:call-template name="content-warning">
            <xsl:with-param name="tag" select="$ContentWarningField"/>
        </xsl:call-template>

        <!-- Indicate if record is suppressed in OPAC -->
        <xsl:if test="$OpacSuppression = 1">
            <xsl:if test="marc:datafield[@tag=942][marc:subfield[@code='n'] = '1']">
                <span class="results_summary suppressed_opac">Keine Anzeige im OPAC</span>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <xsl:template name="nameABCQ">
        <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abcq</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="punctuation">
                <xsl:text>:,;/ </xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="nameABCDN">
        <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abcdn</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="punctuation">
                <xsl:text>:,;/ </xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameACDEQ">
        <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">acdeq</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameDate">
        <xsl:for-each select="marc:subfield[@code='d']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="role">
        <xsl:for-each select="marc:subfield[@code='e']">
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='4']">
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="specialSubfieldSelect">
        <xsl:param name="anyCodes"/>
        <xsl:param name="axis"/>
        <xsl:param name="beforeCodes"/>
        <xsl:param name="afterCodes"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis]) or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
                    <xsl:value-of select="text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
    </xsl:template>

    <xsl:template name="subtitle">
        <xsl:if test="marc:subfield[@code='b']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:value-of select="marc:subfield[@code='b']"/>

                    <!--<xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">b</xsl:with-param>
                    </xsl:call-template>-->
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template name="chopBrackets">
        <xsl:param name="chopString"></xsl:param>
        <xsl:variable name="string">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="$chopString"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="substring($string, 1,1)='['">
            <xsl:value-of select="substring($string,2, string-length($string)-2)"></xsl:value-of>
        </xsl:if>
        <xsl:if test="substring($string, 1,1)!='['">
            <xsl:value-of select="$string"></xsl:value-of>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
