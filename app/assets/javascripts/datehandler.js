initDatepickerGen = function(startDate, endDate, submitButton, updateText) {
  var dp = $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd',
    dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    defaultDate: startDate.val(),
    minDate: 0,
    // showWeek: true,
    weekHeader: '',
    beforeShowDay: function(dateText) {
      var arrive = moment(startDate.val());
      var date = moment(dateText);

      var highlight = date.isSame(arrive) || (date.isBetween(arrive, moment(endDate.val()).add(1, 'd')));
      return [true, highlight ? 'highlight' : ''];
    },
    onSelect: function(dateText) {
      var startMom = moment(startDate.val());
      var endMom = moment(endDate.val());
      var dateMom = moment(dateText);
      var dateFormat = 'YYYY-MM-DD';

      if(!startMom.isValid() || endMom.isValid()) {
        startDate.val(dateMom.format(dateFormat));
        endDate.val('');
      }
      else if(dateMom.isSame(startMom)) {
        startDate.val('');
        endDate.val('');
      }
      else if(dateMom.isBefore(startMom)) {
        endDate.val(startMom.format(dateFormat));
        startDate.val(dateMom.format(dateFormat));
      }
      else {
        endDate.val(dateMom.format(dateFormat));
      }

      updateText(startDate, endDate);
    }
  });
  updateText(startDate, endDate);
  submitButton.submit(function(event) {
    if(startDate.val() && endDate.val() === '') {
      endDate.val(startDate.val());
    }
  });
};

updateDateText = function(startDate, endDate, actionText, leavingText) {
  var arrive = moment(startDate.val());
  var depart = moment(endDate.val());
  var newText = actionText + ' these nights';

  if(arrive.isValid()) {
    var departActual = depart.isValid() ? depart : arrive;
    var numDays = departActual.diff(arrive, 'days') + 1;
    if(numDays > 1) {
      newText = actionText + ' ' + numDays;
      newText += ' nights, ' + arrive.format('MMM Do') + ' through ';
      newText += departActual.format('MMM Do');
    } else {
      newText = actionText + ' 1 night, ' + arrive.format('MMM Do');
    }
    newText += leavingText + departActual.add(1, 'd').format('MMM Do');
  }

  $('.dateText').html(newText + '.');
};

visitsUpdateDateText = function(startDate, endDate) {
  return updateDateText(startDate, endDate, "Staying", ', leaving on ');
}

hostingsUpdateDateText = function(startDate, endDate) {
  return updateDateText(startDate, endDate, "Hosting", ', with any guests leaving on ');
}

initDatePicker = function() {
  if($('#visits').length) {
    initDatepickerGen($('#visit_start_date'), $('#visit_end_date'),
		      $('.new_visit, .edit_visit'), visitsUpdateDateText);
  }
  if($('#hostings').length) {
    initDatepickerGen($('#hosting_start_date'), $('#hosting_end_date'),
		      $('.new_hosting, .edit_hosting'), hostingsUpdateDateText);
  }
}
