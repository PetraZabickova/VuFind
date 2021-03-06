{* Display Title *}
{literal}
  <script language="JavaScript" type="text/javascript">
    // <!-- avoid HTML validation errors by including everything in a comment.
    function subjectHighlightOn(subjNum, partNum)
    {
        // Create shortcut to YUI library for readability:
        var yui = YAHOO.util.Dom;

        for (var i = 0; i < partNum; i++) {
            var targetId = "subjectLink_" + subjNum + "_" + i;
            var o = document.getElementById(targetId);
            if (o) {
                yui.addClass(o, "hoverLink");
            }
        }
    }

    function subjectHighlightOff(subjNum, partNum)
    {
        // Create shortcut to YUI library for readability:
        var yui = YAHOO.util.Dom;

        for (var i = 0; i < partNum; i++) {
            var targetId = "subjectLink_" + subjNum + "_" + i;
            var o = document.getElementById(targetId);
            if (o) {
                yui.removeClass(o, "hoverLink");
            }
        }
    }
    // -->
  </script>
{/literal}

{* Begin of modifications for Obalky knih *}
      <script>
        $(document).ready(function() {ldelim}
          obalky.process("obalky_display_cover", "obalka_{$id}", "{$obalkyknih_permalink}", {$obalkyknih_bibinfo});
        {rdelim});
         $(document).ready(function() {ldelim}addthis.init(){rdelim});
      </script>

      <div class="alignright">
        <table align="left">
          <tr>
            <td id="obalka_{$id}">{image id="obalka_`$id`_format" src="formats/$recordFormat[0].png" align="left" title="$recordFormat[0]"|translate}</td>
          </tr>
          <tr>
            <td class="format">{translate text=$recordFormat[0]}</td>
          </tr>
          <tr>
            <td id="obalka_{$id}_toc"></td>
          </tr>
        </table>
      </div>
{* End of modifications for Obalky knih *}

{* Display Title *}
<div itemscope itemtype="http://schema.org/Book">
<h1 itemprop="name">{$coreShortTitle|escape}
{if $coreSubtitle} : {$coreSubtitle|escape}{/if}
&nbsp;{if $coreTitleSection}{$coreTitleSection|escape}{/if}
{* {if $coreTitleStatement}{$coreTitleStatement|escape}{/if} *}
</h1>
{* End Title *}

{if $coreSummary}<p>{$coreSummary|truncate:300:"..."|escape}.&nbsp;<a href='{$url}/Record/{$id|escape:"url"}/Description#tabnav'>{translate text='Full description'}</a></p>{/if}

{* Display Main Details *}
<table cellpadding="2" cellspacing="0" border="0" class="citation" summary="{translate text='Bibliographic Details'}" id="bibliographic_details">
  {if !empty($coreNextTitles)}
  <tr valign="top">
    <th>{translate text='New Title'}: </th>
    <td>
      {foreach from=$coreNextTitles item=field name=loop}
        <a href="{$url}/Search/Results?lookfor=%22{$field|escape:"url"}%22&amp;type=Title">{$field|escape}</a><br>
      {/foreach}
    </td>
  </tr>
  {/if}

  {if !empty($corePrevTitles)}
  <tr valign="top">
    <th>{translate text='Previous Title'}: </th>
    <td>
      {foreach from=$corePrevTitles item=field name=loop}
        <a href="{$url}/Search/Results?lookfor=%22{$field|escape:"url"}%22&amp;type=Title">{$field|escape}</a><br>
      {/foreach}
    </td>
  </tr>
  {/if}

  {if !empty($coreMainAuthor)}
  <tr valign="top">
    <th>{translate text='Main Author'}: </th>
    <td><a itemprop="author" href="{$url}/Author/Home?author={$coreMainAuthor|escape:"url"}">{$coreMainAuthor|escape}</a></td>
  </tr>
  {/if}

  {if !empty($coreCorporateAuthor)}
  <tr valign="top">
    <th>{translate text='Corporate Author'}: </th>
    <td><a itemprop="author" href="{$url}/Author/Home?author={$coreCorporateAuthor|escape:"url"}">{$coreCorporateAuthor|escape}</a></td>
  </tr>
  {/if}

  {if !empty($coreContributors)}
  <tr valign="top">
    <th>{translate text='Other Authors'}: </th>
    <td>
      {foreach from=$coreContributors item=field name=loop}
        <a itemprop="contributor" href="{$url}/Author/Home?author={$field|escape:"url"}">{$field|escape}</a>{if !$smarty.foreach.loop.last}, {/if}
      {/foreach}
    </td>
  </tr>
  {/if}

  <tr valign="top">
    <th>{translate text='Language'}: </th>
    <td>{foreach from=$recordLanguage item=lang}{$lang|translate|escape}<br>{/foreach}</td>
  </tr>

  {if !empty($corePublications)}
  <tr valign="top">
    <th>{translate text='Published'}: </th>
    <td>
      {foreach from=$corePublications item=field name=loop}
        {$field|escape}<br>
      {/foreach}
    </td>
  </tr>
  {/if}

  {if !empty($coreEdition)}
  <tr valign="top">
    <th>{translate text='Edition'}: </th>
    <td itemprop="bookEdition">
      {$coreEdition|escape}
    </td>
  </tr>
  {/if}

  {* Display series section if at least one series exists. *}
  {if !empty($coreSeries)}
  <tr valign="top">
    <th>{translate text='Series'}: </th>
    <td>
      {foreach from=$coreSeries item=field name=loop}
        {* Depending on the record driver, $field may either be an array with
           "name" and "number" keys or a flat string containing only the series
           name.  We should account for both cases to maximize compatibility. *}
        {if is_array($field)}
          {if !empty($field.name)}
            <a href="{$url}/Search/Results?lookfor=%22{$field.name|escape:"url"}%22&amp;type=Series{$appendtoLinks|escape:"url"}">{$field.name|escape}</a>
            {if !empty($field.number)}
              {$field.number|escape}
            {/if}
            <br>
          {/if}
        {else}
          <a href="{$url}/Search/Results?lookfor=%22{$field|escape:"url"}%22&amp;type=Series{$appendtoLinks|escape:"url"}">{$field|escape}</a><br>
        {/if}
      {/foreach}
    </td>
  </tr>
  {/if}

  {if !empty($coreSubjects)}
  <tr valign="top">
    <th>{translate text='Subjects'}: </th>
    <td>
      {foreach from=$coreSubjects item=field name=loop}
        {assign var=subject value=""}
        {foreach from=$field item=subfield name=subloop}
          {if !$smarty.foreach.subloop.first} &gt; {/if}
          {assign var=subject value="$subject $subfield"}
          <a itemprop="keywords" id="subjectLink_{$smarty.foreach.loop.index}_{$smarty.foreach.subloop.index}"
            href="{$url}/Search/Results?lookfor=%22{$subject|escape:"url"}%22&amp;type=Subject"
          onmouseover="subjectHighlightOn({$smarty.foreach.loop.index}, {$smarty.foreach.subloop.index});"
          onmouseout="subjectHighlightOff({$smarty.foreach.loop.index}, {$smarty.foreach.subloop.index});">{$subfield|escape}</a>
        {/foreach}
        <br>
      {/foreach}
    </td>
  </tr>
  {/if}
  
  {if !empty($provenience)}
  <tr valign="top">
    <th>{translate text='Provenience'}: </th>
    <td>
      {foreach from=$provenience item=field name=loop}
        {$field|escape}<br>
      {/foreach}
    </td>
  </tr>
  {/if}

  {if !empty($coreURLs) || $coreOpenURL}
  <tr valign="top">
    <th>{translate text='Online Access'}: </th>
    <td>
      {foreach from=$coreURLs item=desc key=currentUrl name=loop}
        <a href="{if $proxy}{$proxy}/login?qurl={$currentUrl|escape:"url"}{else}{$currentUrl|escape}{/if}" target="blank">{$desc|escape}</a><br/>
      {/foreach}
      {if $coreOpenURL}
        {include file="Search/openurl.tpl" openUrl=$coreOpenURL}<br/>
      {/if}
    </td>
  </tr>
  {/if}

  {if !empty($coreRecordLinks)}
  {foreach from=$coreRecordLinks item=coreRecordLink}
  <tr valign="top">
    <th>{translate text=$coreRecordLink.title}: </th>
    <td><a href="{$coreRecordLink.link|escape}">{$coreRecordLink.value|escape}</a></td>
  </tr>
  {/foreach}
  {/if}

  <tr valign="top">
    <th>{translate text='Tags'}: </th>
    <td>
      <span style="float:right;">
        <a href="{$url}/Record/{$id|escape:"url"}/AddTag" class="tool add"
           onClickDisabled="getLightbox('Record', 'AddTag', '{$id|escape}', null, '{translate text="Add Tag"}'); return false;">{translate text="Add"}</a>
      </span>
      <div id="tagList">
        {if $tagList}
          {foreach from=$tagList item=tag name=tagLoop}
        <a href="{$url}/Search/Results?tag={$tag->tag|escape:"url"}">{$tag->tag|escape:"html"}</a> ({$tag->cnt}){if !$smarty.foreach.tagLoop.last}, {/if}
          {/foreach}
        {else}
          {translate text='No Tags'}, {translate text='Be the first to tag this record'}!
        {/if}
      </div>
    </td>
  </tr>

  {if $physical}
    <tr valign="top">
      <th>{translate text='Physical Description'}: </th>
      <td>
        {foreach from=$physical item=field name=loop}
          {$field|escape}<br>
        {/foreach}
      </td>
    </tr>
  {/if}

  <!-- end of costumization for MZK -->
</table>

<!-- <br />  -->
<div id="links">
   {if $EOD}
           <table>
              <tr>
                 <td>
                    <a href="{$EODLink}" target="blank">
                       {image src="eod_button_`$userLang`.gif"}
                    </a>
                 </td>
                 <td>&nbsp;&nbsp;</td>
                 <td><span style="color: #EC9136; font-size: 120%;">{translate text='EOD'}</span></td>
              </tr>
           </table>
   {/if}
</div>

</div>

{* End Main Details *}
