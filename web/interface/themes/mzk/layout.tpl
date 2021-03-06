<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="{$userLang}">

{* We should hide the top search bar and breadcrumbs in some contexts: *}
{if ($module=="Search" || $module=="Summon" || $module=="WorldCat" || $module=="Authority") && $pageTemplate == "home.tpl"}
    {assign var="showTopSearchBox" value=0}
    {assign var="showBreadcrumbs" value=0}
{else}
    {assign var="showTopSearchBox" value=1}
    {assign var="showBreadcrumbs" value=1}
{/if}

  <head>
    <title>{$pageTitle|truncate:64:"..."}</title>
    {if $addHeader}{$addHeader}{/if}
    <link rel="search" type="application/opensearchdescription+xml" title="{translate text='MZK catalogue search'}" href="{$url}/Search/OpenSearch?method=describe">
    {css media="screen" filename="styles.css"}
    {css media="print" filename="print.css"}
    {css media="screen" filename="mzk.css"}
    {css media="screen" filename="thickbox.css"}
    {if $module == 'EBSCO' || $module == 'Discover'}
    {css media="screen" filename="discover.css"}
    {css media="screen" filename="ebsco.css"}
    {css media="screen" filename="pubtype-icons.css"}
    {/if}
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <script language="JavaScript" type="text/javascript">
      path = '{$url}';
      var vufindString = {ldelim}{rdelim};
      var cover_text = "{translate text='Cover'}";
      var content_text = "{translate text='TOC'}";
    </script>

    {js filename="yui/yahoo-dom-event.js"}
    {js filename="yui/connection-min.js"}
    {js filename="yui/datasource-min.js"}
    {js filename="yui/autocomplete-min.js"}
    {js filename="yui/dragdrop-min.js"}
    {js filename="scripts.js"}
    {js filename="rc4.js"}
    {js filename="calendar-min.js"}
    {js filename="calendar.js"}
    
    {js filename="obalkyknih/functions.js"}
    {js filename="obalkyknih/custom.js"}
    {js filename="jquery-1.7.min.js"}
    {js filename="jquery.cookie.js"}
    {js filename="europeana.js"}
    {js filename="ajax.yui.js"}
    {js filename="thickbox-compressed.js"}
    {js filename="jquery.cluetip.min.js"}
    {js filename="common.js"}
    {js filename="lightbox.js"}
    {if $module == 'EBSCO'}
    {js filename="ebsco.js"}
    {js filename="element-min.js "}
    {js filename="event-delegate-min.js"}
    {js filename="selector-min.js"}
    {js filename="slider-min.js"}
    {/if}
    {if $bookBag}
       {js filename="cart.js"}
       {assign var=bookBagItems value=$bookBag->getItems()}
    {/if}
    <script language="JavaScript" type="text/javascript">
    {literal}
    $(document).ready(function() {       
      $('a.jt').cluetip({cluetipClass: 'jtip', dropShadow: true, hoverIntent: false, delayedClose: 5000, mouseOutClose: false });
      $('span.jt').cluetip({cluetipClass: 'jtip', dropShadow: true, hoverIntent: false, delayedClose: 5000, mouseOutClose: false });
      $('span.jt_ebsco').cluetip({cluetipClass: 'jtip', dropShadow: true, hoverIntent: false, delayedClose: 0, mouseOutClose: false, splitTitle: '|' });
      $('a.jt_sticky').cluetip({cluetipClass: 'jtip', dropShadow: true, hoverIntent: false, sticky: true,  closePosition: 'bottom'});
    });
    function switch_lang(lang) {
      document.langForm.mylang.value = lang;
      document.langForm.submit() ;
    }
    {/literal}
    </script>
    {if $googleAnalytics}
    <script type="text/javascript">
      var _gaq = _gaq || [];
      {foreach from=$googleAnalytics key=key item=value}
      _gaq.push(['{$key}', {$value}]);
      {/foreach}
      {foreach from=$googleAnalyticsVariables key=key item=val}
      _gaq.push(['_setCustomVar', {$val.index}, '{$key}', '{$val.value}', {$val.type}]);
      {/foreach}
      {foreach from=$googleAnalyticsEvents key=key item=val}
      _gaq.push(['_trackEvent', '{$key}', '{$val.action}', '{$val.label}', '{$val.value}']);
      {/foreach}
      {if $pageTemplate == 'list-none.tpl'}
        _gaq.push(['_trackEvent','Search','No results','{$lookfor}', 0]);
      {/if}
      {if $subTemplate == 'extended-hold-status.tpl'}
        {if $error}
          _gaq.push(['_trackEvent', 'Request', 'Failed', '{$error_str}', 0]);
        {else}
          _gaq.push(['_trackEvent', 'Request', 'Success', '{$coreMainAuthor|escape}: {$coreShortTitle|escape} ({$id})', 0]);
        {/if}
      {/if}
      _gaq.push(['_trackPageview']);
      {literal}
      (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
      {/literal}
    </script>
    {/if}
  </head>

  <body onLoadDisabled="document.searchForm.lookfor.focus();">

    {* LightBox *}
    <div id="lightboxLoading" style="display: none;">{translate text="Loading"}...</div>
    <div id="lightboxError" style="display: none;">{translate text="lightbox_error"}</div>
    <div id="lightbox" onClick="hideLightbox(); return false;"></div>
    <div id="popupbox" class="popupBox"><b class="btop"><b></b></b></div>
    {* End LightBox *}
    {if $showTopSearchBox}
	<div class="searchheader">
      <div class="searchcontent">
        <!--{if $showTopSearchBox}-->
          <div class="top-search-box">
			  <div class="logo">
				<a href="http://www.mzk.cz/">{image src="logo-mzk.png" alt="MZK" class="alignleft"}</a>
			  </div>
			  {if $pageTemplate != 'advanced.tpl'}
				{if $module=="Summon" || $module=="WorldCat" || $module=="Authority" || $module=="EBSCOHost" || $module=="PCI" || $module=="EBSCO"}
				  {include file="`$module`/searchbox.tpl"}
				{else}
				  {include file="Search/searchbox.tpl"}
				{/if}
			  {/if}
		  </div>
        <!--{/if}-->

		<div class="login-box">
	{if is_array($allLangs) && count($allLangs) > 1}
		<form method="post" name="langForm" action="">
			<input type="hidden" name="mylang" id="mylang" />
		</form>
                {foreach from=$allLangs key=langCode item=langName}
                  {if $userLang != $langCode}
                     <a href="javascript:switch_lang('{$langCode}')">{image src="$langCode.png"}{$langName}</a>
                  {else}
                     {image src="$langCode.png"}{translate text=$langName}
                  {/if}
                {/foreach}
 	{/if}
          <div id="logoutOptions"{if !$user} style="display: none;"{/if}>
            <a class="register" href="{$path}/MyResearch/Home">{translate text="Your Account"}</a> |
            <a class="login" href="{$path}/MyResearch/Logout">{translate text="Log Out"}</a>
          </div>
          <div id="loginOptions"{if $user} style="display: none;"{/if}>
            {if $authMethod == 'Shibboleth'}
              <a class="register" href="https://www.mzk.cz/registration_mzk">{translate text="Registration"}</a>
              <a class="login" href="{$sessionInitiator}">{translate text="Login"}</a>
            {else}
              <a href="{$path}/MyResearch/Home">{translate text="Login"}</a>
            {/if}
          </div>
          {if $bookBag}
          <div id="cartSummary" class="cartSummary">
            <a id="cartItems" title="{translate text='View Book Bag'}" class="bookbag" href="{$url}/Cart/Home"><strong><span>{$bookBagItems|@count}</span></strong> {translate text='items'}{if $bookBag->isFull()}({translate text='bookbag_full'}){/if}</a>
            <a id="viewCart" title="{translate text='View Book Bag'}" class="viewCart bookbag offscreen" href="{$url}/Cart/Home">{translate text='Number of items in book bag'}: <strong><span id="cartSize">{$bookBagItems|@count}</span></strong> {if $bookBag->isFull()}<span id="cartStatus">({translate text='bookbag_full'}){else}</span>{/if}</a>
          </div>
          {/if}
        </div> <!-- class="login-box" -->
        <br clear="all">
      </div>
    </div>
	{/if}


    {if $showBreadcrumbs}
    <div class="breadcrumbs">
      <div class="breadcrumbinner">
      	{if $module == "EBSCO"}
      		<a href="{$url}/EBSCO/Search">{translate text="Ebsco Home Breadcrumb"}</a> <span>&gt;</span>
      	{else}
        	<a href="{$url}">{translate text="Home"}</a> <span>&gt;</span>
        {/if}
        {include file="$module/breadcrumbs.tpl"}
      </div>
    </div>
    {/if}
    <div id="doc2" class="yui-t4"> {* Change id for page width, class for menu layout. *}

      {if $useSolr || $useWorldcat || $useSummon}
      <div id="toptab">
        <ul>
          {if $useSolr}
          <li{if $module != "WorldCat" && $module != "Summon"} class="active"{/if}><a href="{$url}/Search/Results?lookfor={$lookfor|escape:"url"}">{translate text="University Library"}</a></li>
          {/if}
          {if $useWorldcat}
          <li{if $module == "WorldCat"} class="active"{/if}><a href="{$url}/WorldCat/Search?lookfor={$lookfor|escape:"url"}">{translate text="Other Libraries"}</a></li>
          {/if}
          {if $useSummon}
          <li{if $module == "Summon"} class="active"{/if}><a href="{$url}/Summon/Search?lookfor={$lookfor|escape:"url"}">{translate text="Journal Articles"}</a></li>
          {/if}
        </ul>
      </div>
      <div style="clear: left;"></div>
      {/if}

      {include file="$module/$pageTemplate"}

      <div id="ft">
      {include file="footer.tpl"}
      </div> {* End ft *}

    </div> {* End doc *}
    
  </body>
</html>

