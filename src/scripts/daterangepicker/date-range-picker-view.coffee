class DateRangePickerView
  constructor: (options = {}) ->
    @config = new Config(options)
    @_extend(@config)

    @startCalendar = new CalendarView(@, @startDate, 'start')
    @endCalendar = new CalendarView(@, @endDate, 'end', @startDate)

    @startDateInput = @startCalendar.inputDate
    @endDateInput = @endCalendar.inputDate
    @dateRange = ko.observable([@startDate(), @endDate()])

    @startDate.subscribe (newValue) =>
      @endDate(newValue.clone().endOf(@period())) if @single()

    @style = ko.observable({})

  periodProxy: Period

  calendars: () ->
    if @single()
      [@startCalendar]
    else
      [@startCalendar, @endCalendar]

  updateDateRange: () ->
    @dateRange([@startDate(), @endDate()])

  cssClasses: () ->
    obj = {
      single: @single()
      opened: @opened()
      expanded: @single() || @expanded()
      'opens-left': @opens() == 'left'
      'opens-right': @opens() == 'right'
    }
    for period in Period.allPeriods
      obj["#{period}-period"] = period == @period()
    obj

  isActivePeriod: (period) ->
    @period() == period

  isActiveDateRange: (dateRange) ->
    if dateRange.constructor == CustomDateRange
      for dr in @ranges
        if dr.constructor != CustomDateRange && @isActiveDateRange(dr)
          return false
      true
    else
      @startDate().isSame(dateRange.startDate, 'day') && @endDate().isSame(dateRange.endDate, 'day')

  inputFocus: () ->
    @expanded(true)

  setPeriod: (period) ->
    @period(period)
    @expanded(true)

  setDateRange: (dateRange) =>
    if dateRange.constructor == CustomDateRange
      @expanded(true)
    else
      @period('day')
      @expanded(false)
      @startDate(dateRange.startDate)
      @endDate(dateRange.endDate)
      @updateDateRange()

  applyChanges: () ->
    @close()
    @updateDateRange()

  cancelChanges: () ->
    @close()

  open: () ->
    @opened(true)

  close: () ->
    @opened(false)

  toggle: () ->
    @opened(!@opened())

  _extend: (obj) ->
    @[k] = v for k, v of obj when obj.hasOwnProperty(k) && k[0] != '_'
