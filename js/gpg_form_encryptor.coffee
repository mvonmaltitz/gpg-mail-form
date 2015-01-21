class this.GPGFormEncryptor
  selectors : {
    form_selector: "form[data-encrypted-form]"
    single_selector: "*[data-encrypt]"
    group_source_selector: "*[data-encrypt-source]"
    group_target_selector: "*[data-encrypt-target]"
  }

  constructor: (armored_key, user_defined_selectors = {}) ->
    $.each(user_defined_selectors, (key, value) =>
      @selectors[key] = value
    )
    @load_key(armored_key)

  setup: ->
    $(@selectors.form_selector).each (index, element) =>
      $(element).submit((e)=>
        @submit_handler(e, element)
      )
  load_key: (armored_key)->
    kbpgp.KeyManager.import_from_armored_pgp {
      armored: armored_key
    }, (err, key) ->
      @pubkey = key
      if err
        console.error "could not load key", err
      else
        #console.log "key is loaded"

  submit_handler: (e, form) ->
    e.preventDefault()
    form_data = @get_values(form)
    single_defer = $.Deferred()
    group_defer = $.Deferred()
    @single_encryption(form, form_data, (result) ->
      single_defer.resolve()
    )
    $.when(single_defer).done(() =>
      @group_encryption(form, form_data, (result) ->
        group_defer.resolve()
      )
    )
    $.when(single_defer, group_defer).done(() =>
      @reinsert_values form_data
      form.submit()
    )

  get_values: (form) ->
    return $(form).serializeArray()

  single_encryption: (form, form_data, callback) ->
    names_to_encrypt = @find_names_for(form, @selectors.single_selector)
    defers = []
    @encrypt_requested_fields(form_data, names_to_encrypt, defers)
    $.when.apply($, defers).done(() -> # Spat defers to param list with apply
      callback(form_data)
    )

  find_names_for: (root, selector) ->
    names = []
    $(root).find(selector).each (index, element) ->
      n = $(element).attr("name")
      names.push n
    return names

  encrypt_requested_fields: (form_data, names_to_encrypt, defers) ->
    for element in form_data
      if @contains(element.name, names_to_encrypt)
        d = $.Deferred()
        defers.push d
        @encrypt(element.value, (result_string)->
          element.value = result_string.toString()
          d.resolve()
        )

  contains: (element, array) ->
    $.inArray(element, array) >= 0

  encrypt: (plaintext, callback) ->
    params =
      msg: plaintext
      encrypt_for: pubkey
    kbpgp.box params, (err, result_string, result_buffer) ->
      if err
        console.log err
      else
        callback(result_string)

  reinsert_values: (form_data) ->
    for i in [0..form_data.length-1]
      $("*[name='#{form_data[i].name}']").val(form_data[i].value)

  group_encryption: (form, form_data, callback) ->
    elements = $(@selectors.group_source_selector)
    encryption_source_names = @find_names_for(form, elements)
    if encryption_source_names.length
      buffer = @collect_sources(elements)
      @wipe_source_fields(form_data, encryption_source_names)
      @write_target(buffer, form_data, callback)
    else
      callback()

  collect_sources: (elements)->
    buffer = ""
    elements.each (index,element ) =>
      buffer += "#{@find_label(element)}: #{$(element).val()}\n"
    return buffer

  find_label: (element) ->
    id = element.id
    placeholder = $(element).attr("placeholder")
    name = $(element).attr("name")
    label = $("label[for='#{id}']").text()
    if label
      return label
    else if placeholder
      return placeholder
    else
      return name

  wipe_source_fields: (data, encryption_source_names) ->
    for element in data
      if @contains(element.name, encryption_source_names)
        element.value = ""

  write_target: (buffer, data, callback)->
    target_name = $(@selectors.group_target_selector).attr("name")
    if target_name
      @encrypt(buffer, (result_string) ->
        for element in data
          if element.name == target_name
            element.value = result_string.toString()
        callback(data)
      )
    else
      console.error("No target defined")
