var Asset = {};

Asset.Upload = Behavior.create({
  onsubmit: function (e) {
    if (e) e.stop();
    var uuid = Asset.GenerateUUID();
    var ulframe = document.createElement('iframe');
    ulframe.setAttribute('name', uuid);   // this doesn't work on ie7: will need bodging
    $('upload_holders').insert(ulframe);

    var form = this.element;
    var title = form.down('input.textbox').value || form.down('input.file').value;
    var placeholder = Asset.AddPlaceholder(title);

    form.setAttribute('target', uuid);
    ulframe.observe('load', function (e) {
      if (e) e.stop();
      var response = ulframe.contentDocument.body.innerHTML;
      if (response && response != "") {
        placeholder.remove();
        Asset.AddToList(response);
        ulframe.remove();
      }
    });
    
    form.submit();
    $('upload_asset').closePopup();
    // form.down('input.textbox').clear();
    // form.down('input.file').clear();
  }
});

Asset.Attach = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var container = this.element.up('li.asset');
    var title = container.down('div.title').innerHTML;
    var image = container.down('img');
    var placeholder = Asset.AddPlaceholder(title, image);
    container.addClassName('waiting');
    new Ajax.Request(this.element.href, {
      asynchronous: true, 
      evalScripts: false, 
      method: 'get',
      onSuccess: function(transport) { 
        container.removeClassName('waiting');
        placeholder.remove();
        Asset.AddToList(transport.responseText); 
      }
    });
  }
});

Asset.Detach = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    Asset.RemoveFromList(this.element.up('li.asset'));
  }
});

Asset.Insert = Behavior.create({
  onclick: function(e) {
    if (e) e.stop();
    var part_name = TabControlBehavior.instances[0].controller.selected.caption;
    var textbox = $('part_' + part_name + '_content');
    var tag_parts = this.element.getAttribute('rel').split('_');
    var tag_name = tag_parts[0];
    var asset_size = tag_parts[1];
    var asset_id = tag_parts[2];
    var radius_tag = '<r:asset:' + tag_name;
    if (asset_size != '') radius_tag = radius_tag + ' size="' + asset_size + '"';
    radius_tag =  radius_tag +' id="' + asset_id + '" />';
    Asset.InsertAtCursor(textbox, radius_tag);
  }
});

// Asset-filter and search functions are available wherever the asset_table partial is displayed

Asset.DeselectFileTypes = Behavior.create({
  onclick: function(e){
    e.stop();
    var element = this.element;
    if(!element.hasClassName('pressed')) {
      $$('a.selective').each(function(el) { el.removeClassName('pressed'); });
      $$('input.selective').each(function(el) { el.removeAttribute('checked'); });
      element.addClassName('pressed');
      Asset.UpdateTable(true);
    }
  }
});

Asset.SelectFileType = Behavior.create({
  onclick: function(e){
    e.stop();
    var element = this.element;
    var type_id = element.readAttribute("rel");
    var type_check = $(type_id + '-check');
    if(element.hasClassName('pressed')) {
      element.removeClassName('pressed');
      type_check.removeAttribute('checked');
      if ($$('a.selective.pressed').length == 0) $('select_all').addClassName('pressed');
    } else {
      element.addClassName('pressed');
      $$('a.deselective').each(function(el) { el.removeClassName('pressed'); });
      type_check.setAttribute('checked', 'checked');
    }
    Asset.UpdateTable(true);
  }
});

Asset.SearchForm = Behavior.create({
  initialize: function () {
    this.observer = new Form.Element.Observer(this.element.down('input.search'), 2, Asset.UpdateTable);
  },
  onsubmit: function (e) {
    if (e) e.stop();
    Asset.UpdateTable(true);
  }
});

Asset.Pagination = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var url = this.element.readAttribute('href');
    var pagination = url.toQueryParams();
    var search_form = $('filesearchform');
    search_form.down('#p').value = pagination['p'];
    Asset.UpdateTable(false);
  }
});

// originally taken from phpMyAdmin
Asset.InsertAtCursor = function(field, insertion) {
  if (document.selection) {  // ie
    field.focus();
    var sel = document.selection.createRange();
    sel.text = insertion;
  }
  else if (field.selectionStart || field.selectionStart == '0') {  // moz
    var startPos = field.selectionStart;
    var endPos = field.selectionEnd;
    field.value = field.value.substring(0, startPos) + insertion + field.value.substring(endPos, field.value.length);
    field.selectionStart = field.selectionEnd = startPos + insertion.length;
  } else {
    field.value += value;
  }
}

Asset.GenerateUUID = function () {
  // http://www.ietf.org/rfc/rfc4122.txt
  var s = [];
  var hexDigits = "0123456789ABCDEF";
  for (var i = 0; i < 32; i++) { s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1); }
  s[12] = "4";                                       // bits 12-15 of the time_hi_and_version field to 0010
  s[16] = hexDigits.substr((s[16] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
  return s.join('');
};

Asset.UpdateTable = function (depaginate) {
  var search_form = $('filesearchform');
  if (depaginate && search_form.down('#p')) search_form.down('#p').value = 1;
  Asset.AllWaiting();
  new Ajax.Updater('assets_table', search_form.action, {
    asynchronous: true, 
    evalScripts: false, 
    parameters: Form.serialize(search_form),
    method: 'get'
  });
}

Asset.AddToList = function (html) {
  var list = $('attachment_fields');
  list.insert(html);
  Asset.ShowListIfHidden();
  Asset.Notify('Save page to commit changes');
  Event.addBehavior.reload();
}

Asset.RemoveFromList = function (container) {
  var el = null;
  if (!!(el = container.down('input.attacher'))) el.remove();
  if (!!(el = container.down('input.destroyer'))) el.value = 1;
  container.dropOut({afterFinish: Asset.HideListIfEmpty});
  container.addClassName('detached');
}

Asset.AddPlaceholder = function (title, image) {
  var placeholder = document.createElement('li').addClassName('asset').addClassName('waiting');
  var front = document.createElement('div').addClassName('front');
  if (image) front.insert(image.clone());
  placeholder.insert(front);
  var back = document.createElement('div').addClassName('back').insert(document.createElement('div').addClassName('title').update('please wait'));
  if (title) back.update(title);
  placeholder.insert(back);
  $('attachment_fields').insert(placeholder);
  Asset.ShowListIfHidden();
  return placeholder;
}

Asset.AllWaiting = function (container) {
  if (!container) container = $('assets_table');
  container.select('li.asset').each(function (el) { el.addClassName('waiting'); });
}

Asset.Notify = function (message) {
  $('attachment_list').down('span.message').update(message).addClassName('important');
}

Asset.ShowListIfHidden = function () {
  var list = $('attachment_fields');
  if (list.hasClassName('empty')) {
    list.removeClassName('empty');
    // list.slideDown();
  }
}

Asset.HideListIfEmpty = function () {
  var list = $('attachment_fields');
  if (!list.down('li.asset:not(.detached)')) {
    list.addClassName('empty');
    // list.slideUp();
    Asset.Notify('All assets detached. Save page to commit changes');
  } else {
    Asset.Notify('Assets detached. Save page to commit changes');
  }
}

Event.addBehavior({
  'form.upload_asset': Asset.Upload,
  'a.attach_asset': Asset.Attach,
  'a.detach_asset': Asset.Detach,
  'a.insert_asset': Asset.Insert,
  'a.copy_asset': Asset.Copy,
  'a.deselective': Asset.DeselectFileTypes,
  'a.selective': Asset.SelectFileType,
  'form.search': Asset.SearchForm,
  '#assets_table .pagination a': Asset.Pagination
});

