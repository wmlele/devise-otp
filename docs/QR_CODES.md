# QR code rendering

By default, Devise OTP assumes that you use [Sprockets](https://github.com/rails/sprockets) to render assets and so will use the ([qrcode.js](/app/assets/javascripts/qrcode.js)) embeded library to render the QR code.

To do that, add the the following line to your `application.js` file:

    //= require devise-otp

You can change this behavior by overriding the `otp_authenticator_token_image` method in your view helper to call `otp_authenticator_token_image_google`:

```ruby
def otp_authenticator_token_image(resource)
  otp_authenticator_token_image_google(resource.otp_provisioning_uri)
end
```

This will call [Google API](https://github.com/wmlele/devise-otp/tree/master/lib/devise_otp_authenticatable/controllers/helpers.rb#L160) to render the QR code.

If your application is configured to use CSP policies, you'll need to authorize `chart.googleapis.com`. Here's an example with [secure_headers](https://github.com/github/secure_headers)):

```ruby
config.csp[:img_src] << 'chart.googleapis.com'
```

A third option consists in installing [jquery-qrcode]https://github.com/jeromeetienne/jquery-qrcode with Yarn or [shakapacker](https://github.com/shakacode/shakapacker) and overriding `otp_authenticator_token_image` to render some HTML :

```ruby
def otp_authenticator_token_image(resource)
  tag(:span, data: { toggle: 'qrcode', otp_url: resource.otp_provisioning_uri, width: 192, height: 192, render: 'canvas' })
end
```
The QR code is then rendered by `jquery-qrcode` by setting a JS listener in your `application.js` :

```js
  $(document).on('turbo:load', function() {
    return $('[data-toggle=qrcode]').each(function() {
      var data;
      data = $(this).data();
      return $(this).qrcode({
        text: data['otpUrl'],
        width: data['width'],
        height: data['height'],
        render: data['render']
      });
    });
  });
```
This way you don't rely on external services to render the QR codes.