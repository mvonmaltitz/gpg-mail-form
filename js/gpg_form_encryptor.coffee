class GPGFormEncryptor
  @pubkey = null
  constructor: (armored_key) ->
    @load_key(armored_key)

  setup: ->
      $("form[data-encrypted-form]").each (index, element) =>
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
    names_to_encrypt = @find_names_for(form, "*[data-encrypt]")
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
    elements = $("*[data-encrypt-source]")
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
    target_name = $("*[data-encrypt-target]").attr("name")
    if target_name
      @encrypt(buffer, (result_string) ->
        for element in data
          if element.name == target_name
            element.value = result_string.toString()
        callback(data)
      )
    else
      console.error("No target defined")


armored_key = '''
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

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
=MPsJ
-----END PGP PUBLIC KEY BLOCK-----'''
ready = ->
  encryptor = new GPGFormEncryptor(armored_key)
  encryptor.setup()
$(document).ready(ready)
$(document).on('page:load',ready)
