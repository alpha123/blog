<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" indent="yes" />
	<xsl:variable name="baseUrl">
		<xsl:text>https://alpha123.github.io/blog</xsl:text>
	</xsl:variable>
	<xsl:template match="/">
		<html>
			<head>
				<meta charset="utf-8" />
				<title>
					<xsl:choose>
						<xsl:when test="/post">
							<xsl:value-of select="/post/title" />
						</xsl:when>
						<xsl:when test="/archive">
							Archive
						</xsl:when>
						<xsl:otherwise>
							unknown page
						</xsl:otherwise>
					</xsl:choose> - pecan’s blog
				</title>
				<!--
				<link rel="stylesheet" href="/theme/combined.min.css" />
				<link rel="stylesheet" href="/theme/skins/2000.css" />
				-->
				<link rel="stylesheet" href="/98.css" />
				<link rel="stylesheet" href="/blog.css" />
			</head>
			<body>
				<xsl:apply-templates select="post" />
				<xsl:apply-templates select="archive" />
			</body>
		</html>
	</xsl:template>
	<xsl:template name="browserchrome">
		<xsl:param name="title" />
		<xsl:param name="url" />
		<header class="title-bar">
			<div class="title-bar-text"><h1><xsl:value-of select="$title" /> - Microsoft Internet Explorer</h1></div>
			<div class="title-bar-controls">
				<button aria-label="Minimize"></button>
				<button aria-label="Maximize"></button>
				<button aria-label="Close"></button>
			</div>
		</header>
		<section class="toolbar menubar">
			<div class="menu-item"><span class="hotunderline">F</span>ile</div>
			<div class="menu-item"><span class="hotunderline">E</span>dit</div>
			<div class="menu-item"><span class="hotunderline">V</span>iew</div>
			<div class="menu-item">F<span class="hotunderline">a</span>vorites</div>
			<div class="menu-item"><span class="hotunderline">T</span>ools</div>
			<div class="menu-item"><span class="hotunderline">H</span>elp</div>
		</section>
		<section class="toolbar buttonsbar">
			<button aria-label="Back">Back</button>
			<button aria-label="Forward">Forward</button>
			<button aria-label="Stop">Stop</button>
			<a aria-label="Refresh">
				<xsl:attribute name="href">
					<xsl:value-of select="$url" />
				</xsl:attribute>
				<span>Refresh</span>
			</a>
			<a href="/" aria-label="Home"><span>Home</span></a>
			<div class="separator"></div>
			<button aria-label="Search">Search</button>
			<button aria-label="Favorites">Favorites</button>
			<button aria-label="History">History</button>
			<div class="separator"></div>
			<a aria-label="Mail">
				<xsl:attribute name="href">
					<xsl:value-of select="concat('mailto:?subject=Link to ', /post/title, '&amp;body=Hi, I found this page and thought you might like it ', $baseUrl, $url)" />
				</xsl:attribute>
				<span>Mail</span>
			</a>
			<button aria-label="Print">Print</button>
		</section>
		<section class="toolbar addressbar">
			<label for="address">A<span class="hotunderline">d</span>dress</label>
			<img src="/ie.png" />
			<input type="text" id="address">
				<xsl:attribute name="value">
					<xsl:value-of select="concat($baseUrl, $url)" />
				</xsl:attribute>
			</input>
		</section>
	</xsl:template>
	<xsl:template name="urlForPost">
		<xsl:param name="slug" />
		<xsl:param name="date" />
		<xsl:value-of select="concat('/media/', substring-before($date,'-'), '/', substring-before(substring-after($date,'-'),'-'), '/', $slug, '.xhtml')" />
	</xsl:template>
	<xsl:template match="post">
		<xsl:variable name="slug" select="/post/@slug" />
		<xsl:variable name="published" select="/post/@published" />
		<!--<xsl:variable name="fullLink" select="concat('https://alpha123.github.io/blog/think/', $slug, '.xhtml')" />-->
		<xsl:variable name="fullLink">
			<xsl:call-template name="urlForPost">
				<xsl:with-param name="slug">
					<xsl:value-of select="$slug" />
				</xsl:with-param>
				<xsl:with-param name="date">
					<xsl:value-of select="$published" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<article class="window active">
			<xsl:call-template name="browserchrome">
				<xsl:with-param name="title">
					<xsl:value-of select="title" />
				</xsl:with-param>
				<xsl:with-param name="url">
					<xsl:value-of select="$fullLink" />
				</xsl:with-param>
			</xsl:call-template>
			<section class="content">
				<xsl:for-each select="contents/*">
					<xsl:copy-of select="." />
				</xsl:for-each>
			</section>
			<footer class="status-bar">
				<p class="status-bar-field">
					Published:
					<time>
						<xsl:attribute name="datetime">
							<xsl:value-of select="$published" />
						</xsl:attribute>
						<xsl:value-of select="$published" />
					</time>
				</p>
				<p class="status-bar-field">
					Author:
					<xsl:value-of select="/post/author" />
				</p>
			</footer>
		</article>
	</xsl:template>
	<xsl:template match="archive">
		<article class="window active">
			<xsl:call-template name="browserchrome">
				<xsl:with-param name="title">Archive</xsl:with-param>
				<xsl:with-param name="url">/media/archive.xhtml</xsl:with-param>
			</xsl:call-template>
			<section class="content">
				<h2>Posts</h2>
				<ul>
					<xsl:apply-templates select="document(@posts)//posttitle" />
				</ul>
			</section>
			<footer class="status-bar">
			</footer>
		</article>
	</xsl:template>
	<xsl:template match="posttitle">
		<li>
			<a>
				<xsl:attribute name="href">
					<xsl:call-template name="urlForPost">
						<xsl:with-param name="slug">
							<xsl:value-of select="@slug" />
						</xsl:with-param>
						<xsl:with-param name="date">
							<xsl:value-of select="@published_at" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:value-of select="@published_at" /> – <xsl:value-of select="text()" />
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>
