<div class="searchform yui-skin-sam">
  {if $searchType == 'advanced'}
    <a href="{$path}/Search/Advanced?edit={$searchId}" class="small">{translate text="Edit this Advanced Search"}</a> |
    <a href="{$path}/Search/Advanced" class="small">{translate text="Start a new Advanced Search"}</a> |
    <a href="{$path}/" class="small">{translate text="Start a new Basic Search"}</a>
    <br>{translate text="Your search terms"} : "<b>{$lookfor|escape:"html"}</b>"
  {else}
    {if $module == 'Discover'}
      <form method="GET" action="{$path}/Discover/EBSCO" name="searchForm" id="searchForm" class="search">
    {else}
      <form method="GET" action="{$path}/Search/Results" name="searchForm" id="searchForm" class="search">
    {/if}
      {* Only activate autocomplete if it is configured to be turned on: *}
      <div class="form-holder">
		  <div class="hiddenLabel"><label for="lookfor">{translate text="Search For"}:</label></div>
		  {if $autocomplete}
			<div  id="autoCompleteContainer">
			  <input class="input-text" id="lookfor" type="text" name="lookfor" size="30" value="{$lookfor|escape:"html"}" lang="{$userLang}" speech x-webkit-speech>
			  <div id="suggestions" style="width:490px;"></div>
			</div>
			<script language="JavaScript" type="text/javascript">
			  initAutocomplete("lookfor", "suggestions", "type");
			</script>
		  {else}
			<input class="input-text" id="lookfor" type="text" name="lookfor" size="30" value="{$lookfor|escape:"html"}">
		  {/if}
		  <div class="hiddenLabel"><label for="type">{translate text="in"}:</label></div>
		  <select id="type" name="type" class="select">
		  {foreach from=$basicSearchTypes item=searchDesc key=searchVal}
			<option value="{$searchVal}"{if $searchIndex == $searchVal} selected{/if}>{translate text=$searchDesc}</option>
		  {/foreach}
		  </select>
		  <input type="submit" name="submit" class="form-submit" value="{translate text="Find"}">
	  </div>
      <a href="{$path}/Search/Advanced" class="advanced small">{translate text="Advanced Search"}</a>
      <a href="{$path}/EBSCO/Search" class="advanced small">{translate text="EBSCO search"}</a>
      {* Do we have any checkbox filters? *}
      {assign var="hasCheckboxFilters" value="0"}
      {if isset($checkboxFilters) && count($checkboxFilters) > 0}
        {foreach from=$checkboxFilters item=current}
          {if $current.filter and $current.filter != "source:ALL"}
            {assign var="hasCheckboxFilters" value="1"}
          {/if}
        {/foreach}
      {/if}
      {if $shards}
        <br />
        {foreach from=$shards key=shard item=isSelected}
          <input type="checkbox" {if $isSelected}checked="checked" {/if}name="shard[]" value='{$shard|escape}' /> {$shard|translate}
        {/foreach}
      {/if}
      {if $filterList || $hasCheckboxFilters}
        <div class="keepFilters">
          <input id="retainAll" type="checkbox" {if $retainFiltersByDefault}checked="checked" {/if} onclick="filterAll(this);" />
          <label for="retainAll">{translate text="basic_search_keep_filters"}</label>
          <div style="display:none;">
            {foreach from=$filterList item=data key=field}
              {foreach from=$data item=value}
                <input type="checkbox" {if $retainFiltersByDefault}checked="checked" {/if} name="filter[]" value='{$value.field|escape}:&quot;{$value.value|escape}&quot;' />
              {/foreach}
            {/foreach}
            {foreach from=$checkboxFilters item=current}
              {if $current.selected}
                <input type="checkbox" {if $retainFiltersByDefault}checked="checked" {/if} name="filter[]" value="{$current.filter|escape}" />
              {/if}
            {/foreach}
          </div>
        </div>
      {/if}
      {* Load hidden limit preference from Session *}
      {if $lastLimit}<input type="hidden" name="limit" value="{$lastLimit|escape}" />{/if}
      {if $lastSort}<input type="hidden" name="sort" value="{$lastSort|escape}" />{/if}
    </form>
  {/if}
</div>
