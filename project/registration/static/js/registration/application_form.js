// Generated by CoffeeScript 1.9.0
(function() {
  var application_maskedssn, check_price, get_age, parseDate, participantSearch, set_typeahead_action, show_hide_birthday, show_hide_ssn, teams, update_every_line;

  this.Participant_inline_class_added = function(row) {
    return update_every_line(row);
  };

  this.Participant_inline_class_removed = function(row) {
    if (typeof console === "object") {
      return console.log('removed');
    }
  };

  set_typeahead_action = function(item) {
    $(item).on("click", function() {
      var ev;
      ev = $.Event("keydown");
      ev.keyCode = ev.which = 40;
      $(this).trigger(ev);
      return true;
    });
    return $(item).on('typeahead:selected', function(e, datum) {
      var last_char, parent;
      parent = $(item).parents('.item');
      if (datum.country) {
        $("select[name$='country']", parent).val(datum.country).change();
      }
      if (datum.gender) {
        $("select[name$='gender']", parent).val(datum.gender).change();
      } else {
        last_char = datum.first_name.slice(-1).toLowerCase();
        if (last_char === 'a' || last_char === 'e') {
          $("select[name$='gender']", parent).val('F');
        } else {
          $("select[name$='gender']", parent).val('M');
        }
      }
      $("input[name$='first_name']", parent).typeahead('val', datum.first_name);
      $("input[name$='last_name']", parent).typeahead('val', datum.last_name);
      $("input[name$='birthday']", parent).val(datum.birthday).change();
      $("input[name$='ssn']", parent).val(datum.ssn).change();
      $("input[name$='team_name']", parent).typeahead('val', datum.team_name);
      $("input[name$='phone_number']", parent).val(datum.phone_number).change();
      $("input[name$='email']", parent).val(datum.email).change();
      return $("select[name$='bike_brand']", parent).val(datum.bike_brand).change();
    });
  };

  teams = null;

  participantSearch = null;

  parseDate = function(input) {
    var parts;
    parts = input.split('-');
    return new Date(parts[0], parts[1] - 1, parts[2]);
  };

  get_age = function(dt) {
    var delta, now, years;
    now = new Date();
    delta = now - dt;
    years = delta / 1000 / 60 / 60 / 24 / 365;
    return parseInt(years);
  };

  show_hide_ssn = function(parent_item, hide) {
    if (hide) {
      return $("input[name$='ssn']", parent_item).parents('.form-group').hide();
    } else {
      return $("input[name$='ssn']", parent_item).parents('.form-group').show();
    }
  };

  show_hide_birthday = function(parent_item, hide) {
    if (hide) {
      return $("input[name$='birthday']", parent_item).parents('.form-group').hide();
    } else {
      return $("input[name$='birthday']", parent_item).parents('.form-group').show();
    }
  };

  application_maskedssn = function(field) {
    field.mask("999999-99999", {
      completed: function() {
        var value, year;
        value = validateSSN(this.val());
        if (!value) {
          return this.parents(".form-group").addClass("has-error");
        } else {
          this.parents(".form-group").removeClass("has-error");
          year = value[6] === "1" ? "19" : "20";
          return $("input[name$='birthday']", this.parents('.item')).val("" + year + (value.substr(4, 2)) + "-" + (value.substr(2, 2)) + "-" + (value.substr(0, 2))).change();
        }
      }
    });
    return false;
  };

  check_price = function(row) {
    var birthday, csrf, distance, insurance, url;
    distance = $("select[name$='distance']", row).val();
    birthday = $("input[name$='birthday']", row).val();
    insurance = $("select[name$='insurance']", row).val();
    csrf = document.getElementsByName('csrfmiddlewaretoken')[0].value;
    url = $("select[name$='distance']", row).data('url');
    return $.ajax({
      url: url,
      type: 'POST',
      data: {
        csrfmiddlewaretoken: csrf,
        distance: distance,
        birthday: birthday,
        insurance: insurance
      },
      dataType: 'json',
      success: function(data) {
        return $('.participant_calculation', row).html(data.message);
      },
      error: function() {
        return $('.participant_calculation', row).html('Please enter all details');
      }
    });
  };

  update_every_line = function(row) {
    $('.dateinput', row).datepicker({
      format: 'yyyy-mm-dd',
      autoclose: true,
      weekStart: 1
    });
    if (!row.hasClass("noadd")) {
      $("select[name$='distance'], input[name$='birthday'], select[name$='insurance']", row).change(function() {
        check_price(row);
        return "";
      });
      check_price(row);
    }
    if ($("select[name$='country']", row).val() === 'LV') {
      application_maskedssn($("input[name$='ssn']", row));
    }
    $("select[name$='country']", row).on('change', function(e) {
      var element, field, value;
      element = e.srcElement ? e.srcElement : e.target;
      element = $(element);
      value = element.val();
      if (value === 'LV') {
        return application_maskedssn($("input[name$='ssn']", element.parents('.item')));
      } else {
        field = $("input[name$='ssn']", element.parents('.item'));
        field.unmask();
        return field.parents(".control-group").removeClass("error");
      }
    });
    if ($("select[name$='country']", row).val() === 'LV') {
      show_hide_ssn(row, false);
      show_hide_birthday(row, true);
    } else {
      show_hide_ssn(row, true);
      show_hide_birthday(row, false);
    }
    $("select[name$='country']", row).on('change', function(e) {
      var element;
      element = e.srcElement ? e.srcElement : e.target;
      if (element.value === 'LV') {
        show_hide_ssn(row, false);
        return show_hide_birthday(row, true);
      } else {
        show_hide_ssn(row, true);
        return show_hide_birthday(row, false);
      }
    });
    $("input[name$='first_name']", row).on('change', function(e) {
      var element, last_char;
      element = e.srcElement ? e.srcElement : e.target;
      last_char = element.value.slice(-1).toLowerCase();
      if (!$("select[name$='gender']", row).val()) {
        if (last_char === 'a' || last_char === 'e') {
          return $("select[name$='gender']", row).val('F');
        } else {
          return $("select[name$='gender']", row).val('M');
        }
      }
    });
    $('.team-typeahead', row).typeahead(null, {
      name: 'team-name',
      displayKey: 'team_name',
      source: teams.ttAdapter()
    });
    $("input[name$='first_name']", row).typeahead({
      minLength: 0
    }, {
      displayKey: 'first_name',
      source: participantSearch.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile('<p><strong>{{full_name}}</strong></p>')
      }
    });
    set_typeahead_action($("input[name$='first_name']", row));
    $("input[name$='last_name']", row).typeahead({
      minLength: 0
    }, {
      displayKey: 'last_name',
      source: participantSearch.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile('<p><strong>{{full_name}}</strong></p>')
      }
    });
    set_typeahead_action($("input[name$='last_name']", row));
    return "";
  };

  $(function() {
    var container, _i, _len, _ref;
    participantSearch = new Bloodhound({
      datumTokenizer: function(d) {
        return Bloodhound.tokenizers.whitespace(d.val);
      },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: '/lv/sacensibas/participant/search.json',
      remote: {
        url: '/lv/sacensibas/participant/search.json?search=%QUERY'
      }
    });
    participantSearch.initialize();
    teams = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('team_name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: $('#id_team_search').val()
    });
    teams.initialize();
    _ref = $('.item:not(.template)');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      container = _ref[_i];
      update_every_line($(container));
    }
    return $('#id_email').mailgun_validator({
      api_key: 'pubkey-7049tobos-x721ipc8b3dp68qzxo3ri5',
      success: function(data) {
        var button;
        $('#id_email').parents(".controls").find('span').remove();
        if (!data.is_valid) {
          $('#id_email').parents(".form-group").addClass("has-error");
          button = data.did_you_mean ? "<button onclick='replaceemail(this);return false;'>" + data.did_you_mean + "</button> ?" : "";
          return $('#id_email').after("<span class='help-block'><strong>Invalid. " + button + "</strong></span>");
        } else {
          return $('#id_email').parents(".form-group").removeClass("has-error");
        }
      }
    });
  });

}).call(this);

//# sourceMappingURL=application_form.js.map
