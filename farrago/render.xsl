<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" indent="yes" />
	<xsl:variable name="baseUrl">
		<xsl:text>https://alpha123.github.io</xsl:text>
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
						<xsl:when test="/page">
							<xsl:value-of select="/page/title" />
						</xsl:when>
						<xsl:otherwise>
							unknown page
						</xsl:otherwise>
					</xsl:choose> - pecan’s blog
				</title>
				<link rel="stylesheet" href="/blog/98.css" />
				<link rel="stylesheet" href="/blog/blog.css" />
			</head>
			<body>
				<a href="#main" id="skipnav">Skip to main content</a>
				<header id="banner">
					<h1><a href="/blog/farrago/index.xhtml">pecan’s blog</a></h1>
				</header>
				<xsl:apply-templates select="post" />
				<xsl:apply-templates select="page" />
				<button id="minimizedbar" onclick="restore()"><img src="/blog/ie.png" /><span></span></button>
				<script><![CDATA[
				function minimize() {
					var win = document.querySelector('.window'), bar = document.getElementById('minimizedbar');
					win.style.display = 'none';
					bar.lastElementChild.textContent = win.querySelector('h1').textContent;
					bar.style.display = 'flex';
				}
				function restore() {
					document.querySelector('.window').style.display = 'block';
					document.getElementById('minimizedbar').style.display = 'none';
				}
				function toggleMaximize(e) {
					document.querySelector('.window').classList.toggle('maximized');
					var btn = e.target;
					btn.setAttribute('aria-label', btn.getAttribute('aria-label') == 'Maximize' ? 'Restore' : 'Maximize');
				}
				function close_() {
					document.querySelector('.window').style.display = 'none';
				}
				]]></script>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="urlForPost">
		<xsl:param name="slug" />
		<xsl:param name="date" />
		<xsl:value-of select="concat('/blog/farrago/', translate($date, '-', '/'), '/', $slug, '.xhtml')" />
	</xsl:template>
	<xsl:template name="browserchrome">
		<xsl:param name="title" />
		<xsl:param name="slug" />
		<xsl:param name="url" />
		<header class="title-bar">
			<div class="title-bar-text">
				<img src="/blog/ie.png" />
				<h1><xsl:value-of select="$title" /> - Microsoft Internet Explorer</h1>
			</div>
			<div class="title-bar-controls">
				<button aria-label="Minimize" onclick="minimize()"></button>
				<button aria-label="Maximize" onclick="toggleMaximize(event)"></button>
				<button aria-label="Close" onclick="close_()"></button>
			</div>
		</header>
		<div class="toolbar menubar">
			<div class="menu-item"><span class="hotunderline">F</span>ile</div>
			<div class="menu-item"><span class="hotunderline">E</span>dit</div>
			<div class="menu-item"><span class="hotunderline">V</span>iew</div>
			<div class="menu-item">F<span class="hotunderline">a</span>vorites</div>
			<div class="menu-item"><span class="hotunderline">T</span>ools</div>
			<div class="menu-item"><span class="hotunderline">H</span>elp</div>
		</div>
		<nav class="toolbar buttonsbar">
			<xsl:choose>
				<xsl:when test="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/following-sibling::posttitle[1]">
					<a aria-label="Back">
						<xsl:attribute name="href">
							<xsl:call-template name="urlForPost">
								<xsl:with-param name="slug" select="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/following-sibling::posttitle[1]/@slug" />
								<xsl:with-param name="date" select="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/following-sibling::posttitle[1]/@published" />
							</xsl:call-template>
						</xsl:attribute>
						<span>Back</span>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<button aria-label="Back" disabled="disabled">Back</button>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/preceding-sibling::posttitle[1]">
					<a aria-label="Forward">
						<xsl:attribute name="href">
							<xsl:call-template name="urlForPost">
								<xsl:with-param name="slug" select="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/preceding-sibling::posttitle[1]/@slug" />
								<xsl:with-param name="date" select="document('/blog/farrago/posts.xml')//posttitle[@slug=$slug]/preceding-sibling::posttitle[1]/@published" />
							</xsl:call-template>
						</xsl:attribute>
						<span>Forward</span>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<button aria-label="Forward" disabled="disabled">Forward</button>
				</xsl:otherwise>
			</xsl:choose>
			<button aria-label="Stop">Stop</button>
			<a aria-label="Refresh">
				<xsl:attribute name="href">
					<xsl:value-of select="$url" />
				</xsl:attribute>
				<span>Refresh</span>
			</a>
			<a href="/blog/farrago/index.xhtml" aria-label="Home"><span>Home</span></a>
			<div class="separator"></div>
			<a href="https://www.google.com/search?q=site%3Aalpha123.github.io+inurl%3Ablog%2Ffarrago" aria-label="Search">Search</a>
			<a href="/blog/farrago/favorites.xhtml" aria-label="Favorites">Favorites</a>
			<a href="/blog/farrago/archive.xhtml" aria-label="History">History</a>
			<div class="separator"></div>
			<a aria-label="Mail">
				<xsl:attribute name="href">
					<xsl:value-of select="concat('mailto:?subject=Link to ', /post/title, '&amp;body=Hi, I found this blog post and thought you might like it ', $baseUrl, $url)" />
				</xsl:attribute>
				<span>Mail</span>
			</a>
			<button aria-label="Print" onclick="print()">Print</button>
		</nav>
		<div class="toolbar addressbar">
			<label for="address">A<span class="hotunderline">d</span>dress</label>
			<img src="/blog/ie.png" />
			<input type="text" id="address">
				<xsl:attribute name="value">
					<xsl:value-of select="concat($baseUrl, $url)" />
				</xsl:attribute>
			</input>
		</div>
	</xsl:template>
	<xsl:template match="post">
		<xsl:variable name="slug" select="/post/@slug" />
		<xsl:variable name="published" select="/post/@published" />
		<xsl:variable name="fullLink">
			<xsl:call-template name="urlForPost">
				<xsl:with-param name="slug" select="$slug" />
				<xsl:with-param name="date" select="$published" />
			</xsl:call-template>
		</xsl:variable>
		<div class="window active">
			<xsl:call-template name="browserchrome">
				<xsl:with-param name="title" select="title" />
				<xsl:with-param name="slug" select="$slug" />
				<xsl:with-param name="url" select="$fullLink" />
			</xsl:call-template>
			<main id="main">
				<article>
					<header class="post-header">
						<h1><xsl:value-of select="title" /></h1>
						<time>
							<xsl:attribute name="datetime">
								<xsl:value-of select="$published" />
							</xsl:attribute>
							<xsl:value-of select="$published" />
						</time>
					</header>
					<xsl:copy-of select="content/*" />
				</article>
			</main>
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
		</div>
	</xsl:template>
	<xsl:template match="page">
		<xsl:variable name="postsxml" select="/page/@posts" />
		<div class="window active">
			<xsl:call-template name="browserchrome">
				<xsl:with-param name="title" select="title" />
				<xsl:with-param name="slug" select="@slug" />
				<xsl:with-param name="url" select="concat('/blog/farrago/', @slug, '.xhtml')" />
			</xsl:call-template>
			<main id="main">
				<xsl:apply-templates select="content/node()">
					<xsl:with-param name="posts" select="$postsxml" />
				</xsl:apply-templates>
			</main>
			<footer class="status-bar">
				<p class="status-bar-field">&#160;</p>
			</footer>
		</div>
	</xsl:template>
	<xsl:template match="node()|@*">
		<xsl:param name="posts" />
		<xsl:copy>
			<xsl:apply-templates select="node()|@*">
				<xsl:with-param name="posts" select="$posts" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="postlist[@recent='all']">
		<xsl:param name="posts" />
		<ul>
			<xsl:apply-templates select="document($posts)//posttitle" />
		</ul>
	</xsl:template>
	<xsl:template match="postlist">
		<xsl:param name="posts" />
		<xsl:variable name="recent" select="@recent" />
		<ul>
			<xsl:apply-templates select="document($posts)//posttitle[position() &lt;= $recent]" />
		</ul>
	</xsl:template>
	<xsl:template match="posttitle">
		<li>
			<a>
				<xsl:attribute name="href">
					<xsl:call-template name="urlForPost">
						<xsl:with-param name="slug" select="@slug" />
						<xsl:with-param name="date" select="@published" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:value-of select="@published" /> – <xsl:value-of select="text()" />
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>
