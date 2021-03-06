@Participant_inline_class_added = (row) ->
  update_every_line(row)

@Participant_inline_class_removed = (row) ->
  if (typeof console == "object")
    console.log 'removed'

@CompanyParticipant_inline_class_added = (row) ->
  update_every_line(row)


set_typeahead_action = (item) ->
  $(item).on "click", ->
      ev = $.Event("keydown")
      ev.keyCode = ev.which = 40
      $(this).trigger(ev)
      return true

  $(item).on 'typeahead:selected', (e, datum) ->
    parent = $(item).parents('.item')
    if datum.country
      $("select[name$='country']", parent).val(datum.country).change()

    if datum.gender
      $("select[name$='gender']", parent).val(datum.gender).change()
    else
      last_char = datum.first_name.slice(-1).toLowerCase()
      if last_char == 'a' or last_char == 'e'
        $("select[name$='gender']", parent).val('F')
      else
        $("select[name$='gender']", parent).val('M')

    $("input[name$='first_name']", parent).typeahead('val',datum.first_name)
    $("input[name$='last_name']", parent).typeahead('val',datum.last_name)
    $("input[name$='bike_brand2']", parent).typeahead('val',datum.bike_brand2)

    $("input[name$='birthday']", parent).val(datum.birthday).change()
    $("input[name$='ssn']", parent).val(datum.ssn).change()

    if $("input[name$='team_name']", parent).length
      $("input[name$='team_name']", parent).typeahead('val',datum.team_name)
    $("input[name$='phone_number']", parent).val(datum.phone_number).change()
    $("input[name$='email']", parent).val(datum.email).change()



teams = null
participantSearch = null
bikeBrandSearch = null

parseDate = (input) ->
  parts = input.split('-')
  return new Date(parts[0], parts[1]-1, parts[2])

get_age = (dt) ->
  now = new Date()
  delta = now - dt
  years = delta / 1000 / 60 / 60 / 24 / 365
  return parseInt(years)

show_hide_ssn = (parent_item, hide) ->
  if hide
    $("input[name$='ssn']", parent_item).parents('.form-group').hide()
  else
    $("input[name$='ssn']", parent_item).parents('.form-group').show()

show_hide_birthday = (parent_item, hide) ->
  if hide
    $("input[name$='birthday']", parent_item).parents('.form-group').hide()
  else
    $("input[name$='birthday']", parent_item).parents('.form-group').show()


application_maskedssn = (field) ->
    field.mask("999999-99999",{
        completed: ->
            value = validateSSN this.val()
            if not value
                this.parents(".form-group").addClass("has-error")
            else
                this.parents(".form-group").removeClass("has-error")
                year = if value[6] == "1" then "19" else "20"
                $("input[name$='birthday']", this.parents('.item')).val("#{year}#{value.substr(4,2)}-#{value.substr(2,2)}-#{value.substr(0,2)}").change()
    })
    false

check_price = (row) ->
  distance = $("select[name$='distance']", row).val()
  birthday = $("input[name$='birthday']", row).val()
  insurance = $("select[name$='insurance']", row).val()
  csrf = document.getElementsByName('csrfmiddlewaretoken')[0].value

  url = $("select[name$='distance']", row).data('url')

  $.ajax
    url: url
    type: 'POST'
    data:
      csrfmiddlewaretoken: csrf
      distance: distance
      birthday: birthday
      insurance: insurance
    dataType: 'json'
    success: (data) ->
      $('.participant_calculation', row).html(data.message)
    error: ->
      $('.participant_calculation', row).html('Please enter all details')

update_every_line = (row) ->
  $('.dateinput', row).datepicker
    format: 'yyyy-mm-dd'
    autoclose: true
    weekStart: 1

  if !row.hasClass("noadd")
    $("select[name$='distance'], input[name$='birthday'], select[name$='insurance']", row).change ->
      if $('.participant_calculation', row).length
        check_price(row)
      ""
    if $('.participant_calculation', row).length
      check_price(row)

  if $("select[name$='country']", row).val() == 'LV'
    application_maskedssn $("input[name$='ssn']", row)


  $("select[name$='country']", row).on 'change', (e) ->
    element = if e.srcElement then e.srcElement else e.target
    element = $(element)
    value = element.val()
    if value == 'LV'
      application_maskedssn $("input[name$='ssn']", element.parents('.item'))
    else
      field = $("input[name$='ssn']", element.parents('.item'))
      field.unmask()
      field.parents(".control-group").removeClass("error")

  if $("select[name$='country']", row).val() == 'LV'
    show_hide_ssn(row, false)
    show_hide_birthday(row, true)
  else
    show_hide_ssn(row, true)
    show_hide_birthday(row, false)

  $("select[name$='country']", row).on 'change', (e) ->
    element = if e.srcElement then e.srcElement else e.target
    if element.value == 'LV'
      show_hide_ssn(row, false)
      show_hide_birthday(row, true)
    else
      show_hide_ssn(row, true)
      show_hide_birthday(row, false)


  $("input[name$='first_name']", row).on 'change', (e) ->
    element = if e.srcElement then e.srcElement else e.target
    last_char = element.value.slice(-1).toLowerCase()
    if not $("select[name$='gender']", row).val()
      if last_char == 'a' or last_char == 'e'
        $("select[name$='gender']", row).val('F')
      else
        $("select[name$='gender']", row).val('M')

  if teams
    $('.team-typeahead', row).typeahead(null, {
      name: 'team-name',
      displayKey: 'team_name',
      source: teams.ttAdapter()
    })

  if !row.hasClass('noadd')
    $("input[name$='first_name']", row).typeahead
      minLength: 0,

       displayKey: 'first_name'
       source: participantSearch.ttAdapter()
       templates:
         suggestion: Handlebars.compile('<p><strong>{{full_name}}</strong></p>')

    set_typeahead_action $("input[name$='first_name']", row)

    $("input[name$='last_name']", row).typeahead
      minLength: 0,

       displayKey: 'last_name'
       source: participantSearch.ttAdapter()
       templates:
         suggestion: Handlebars.compile('<p><strong>{{full_name}}</strong></p>')

    set_typeahead_action $("input[name$='last_name']", row)


  bike_brand2 = $("input[name$='bike_brand2']", row)
  if not bike_brand2.prop('readonly')
    bike_brand2.typeahead
      minLength: 0,

       displayKey: 'bike_brand2'
       source: bikeBrandSearch.ttAdapter()
       templates:
         suggestion: Handlebars.compile('<p><strong>{{bike_brand2}}</strong></p>')

    bike_brand2.on "click", ->
        ev = $.Event("keydown")
        ev.keyCode = ev.which = 40
        $(this).trigger(ev)
        return true
    $('.bike-brand-dropdown', row).on 'click', ->
        $(this).parents('.input-group').find("input[name$='bike_brand2']").click()
  else
    $('.bike-brand-dropdown', row).addClass('disabled')


  ""




$ ->
  participantSearch = new Bloodhound
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace(d.val)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch: '/lv/sacensibas/participant/search.json'
    remote:
      url: '/lv/sacensibas/participant/search.json?search=%QUERY'

  participantSearch.initialize();

  bikeBrandSearch = new Bloodhound
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace(d.val)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 10
    prefetch: '/lv/sacensibas/bike_brands.json'
    remote:
      url: '/lv/sacensibas/bike_brands.json?search=%QUERY'

  bikeBrandSearch.initialize();

  if $('#id_team_search').length
    teams = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('team_name')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      prefetch: $('#id_team_search').val()
  #    remote: $('#id_team_search_term').val()

    teams.initialize()


  for container in $('.item:not(.template)')
    update_every_line($(container))

  $('#id_email').mailgun_validator
    api_key: 'pubkey-7049tobos-x721ipc8b3dp68qzxo3ri5'
    success: (data) ->
      $('#id_email').parents(".controls").find('span').remove()
      if not data.is_valid
        $('#id_email').parents(".form-group").addClass("has-error")
        button = if data.did_you_mean then "<button onclick='replaceemail(this);return false;'>#{data.did_you_mean}</button> ?" else ""
        $('#id_email').after("<span class='help-block'><strong>Invalid. #{button}</strong></span>");
      else
        $('#id_email').parents(".form-group").removeClass("has-error")