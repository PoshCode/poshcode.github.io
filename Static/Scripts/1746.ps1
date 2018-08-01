<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:log4net="http://logging.apache.org/log4net/schemas/log4net-events-1.2"
               version="1.0">

   <xsl:output method="html" indent="yes" encoding="US-ASCII"/>
   

   <xsl:template match="log4net:events">
      <html><head><style>
      .FATAL { color: white; background: #ff0000;}
      .ERROR { background: #ee0000; }
      .WARN  { background: #ffffcc; }
      .DEBUG { color: white; background: #003300; }
      .INFO  { background: #eeffee; }
      </style></head><body>
      
      <table>
         <xsl:apply-templates/>
      </table>
      </body></html>
   </xsl:template>

   <xsl:template match="log4net:event">
        <tr class="{@level}">
            <td class="logger"><xsl:value-of select="@logger"/></td>
            <td class="timestamp"><xsl:value-of select="@timestamp"/></td>
            <td class="level"><xsl:value-of select="@level"/></td>
            <td class="thread"><xsl:value-of select="@thread"/></td>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="log4net:message">
        <td class="message">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="log4net:NDC">
        <td class="NDC">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="log4net:locationInfo">
        <td class="{@class}" method="{@method}" file="{@file}" line="{@line}"/>
    </xsl:template>

    <xsl:template match="log4net:properties">
        <td class="properties">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="log4net:data">
        <td class="data"><xsl:value-of select="@name"/>:  <xsl:value-of select="@value"/></td>
    </xsl:template>

    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*|text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}" namespace="{namespace-uri()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:transform>

