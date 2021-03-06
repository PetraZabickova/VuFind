<h2>{translate text='add_favorite_prefix'} {$record.title|escape:"html"} {translate text='add_favorite_suffix'}</h2>
<form class="std" onSubmit="saveRecord('{$id|escape}', this, {literal}{{/literal}add: '{translate text='Add to favorites'}', error: '{translate text='add_favorite_fail'}', load_error: '{translate text='load_tag_error'}'{literal}}{/literal}); return false;">
<input type="hidden" name="submit" value="1" />
{if !empty($containingLists)}
  <p>
  {translate text='This item is already part of the following list/lists'}:<br>
  {foreach from=$containingLists item="list"}
    <a href="{$url}/MyResearch/MyList/{$list.id}">{$list.title|escape:"html"}</a><br>
  {/foreach}
  </p>
{/if}

{* Only display the list drop-down if the user has lists that do not contain
 this item OR if they have no lists at all and need to create a default list *}
{if (!empty($nonContainingLists) || (empty($containingLists) && empty($nonContainingLists))) }
  {assign var="showLists" value="true"}
{/if}

<table>
  
  <tr>
    {if $showLists}
	<td>
      <label for="list">{translate text='Choose a List'}</label>
    </td>
	{/if}
	<td>
      {if $showLists}
      <select name="list" id="list">
        {foreach from=$nonContainingLists item="list"}
        <option value="{$list.id}"{if $list.id==$lastListUsed} selected="selected"{/if}>{$list.title|escape:"html"}</option>
        {foreachelse}
        <option value="">{translate text='My Favorites'}</option>
        {/foreach}
      </select>
      {/if}
      <a href="{$url}/MyResearch/ListEdit?id={$id|escape:"url"}"
         onClick="getLightbox('MyResearch', 'ListEdit', '{$id|escape}', '', '{translate text='Create new list'}', 'Record', 'Save', '{$id|escape}'); return false;">{translate text="or create a new list"}</a>
    </td>
  </tr>
  {if $showLists}
	<tr>
		<td><label for="mytags">{translate text='Add Tags'}</label></td>
		<td><input type="text" class="text" name="mytags" id="mytags" value="" size="50"></td>
	</tr>
  <!--<tr><td colspan="2">{translate text='add_tag_note'}</td></tr>-->
  <tr>
	<td><label for="notes">{translate text='Add a Note'}</label></td>
    <td><textarea name="notes" class="textarea" id="notes" rows="3" cols="50"></textarea></td>
  </tr>
  <tr><td>&nbsp;</td><td><input type="submit" class="form-submit" value="{translate text='Save'}"></td></tr>
  {/if}
</table>
</form>
