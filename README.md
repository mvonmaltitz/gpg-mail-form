# gpg-mail-form
A javascript module which transparently encrypts mail forms before submission.

##Use Case
Normally contact forms on webpages POST the form data to the server, which in turn transforms them into a mail which is afterwards sent to an address you have specified before. The data is processed in clear text on the server and also sent als such via e-mail.
Wouldn't it be nice, if you could encrypt the information even before POSTing so that only the sender and you are aware of the content?
This script transparently hooks into the submit action of a form, encrypts the fields you have specified with a given GPG key and POSTs the result to the server.
The user won't see the encryption, so she can go back after submitting to reedit or copy the form.

Please note: Due to the encryption, the user should not receive a copy of the mail sent, as she is not able to decrypt ist.

## Example
Given a form

    <form action='/post_form' data-encrypted-form method='post'>
    <label for='name'>Name</label>
    <input id='name' name='name' value='John Doe'>
    <label for='email'>e-Mail-Address</label>
    <input id='email' name='email' value='john.doe@example.com'>
    <label for='body'>Content</label>
    <textarea data-encrypt id='body' name='body'></textarea>
    <input type='submit'>
    </form>

gpg-mail-form will intercept the submit, encrypt the #body-field and send the the manipulated form data to /post_form.


##TODOs

 * Implement grouping of fields: Instead of encrypting every field on its own, group all fields to be encrypted and POST them as only one `name`.
 * Provide sensible setup method to provide GPG public key. Currently the key is hardcoded in the script.
 * Make configuration of forms possible of which the html cannot be changed directly (e.g. form autocreation of CMS)
