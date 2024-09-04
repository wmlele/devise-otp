# QR code rendering

By default, Devise OTP assumes that you use [Sprockets](https://github.com/rails/sprockets) to render assets and so will use the ([qrcode.js](/app/assets/javascripts/qrcode.js)) embeded library to render the QR code.

To do that, add the the following line to your `application.js` file:

    //= require devise-otp

You can change this behavior by overriding the `otp_authenticator_token_image` method in your view helper.