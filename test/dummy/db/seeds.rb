Admin.create(
  name: "Test Admin",
  email: "admin@devise-otp.local",
  password: "Pass1234"
)

User.create(
  name: "Test User",
  email: "user@devise-otp.local",
  password: "Pass1234"
)

NonOtpUser.create(
  name: "Non OTP User",
  email: "non-otp-user@devise-otp.local",
  password: "Pass1234"
)

5.times do |n|
  Post.create(
    title: "Post #{n + 1}",
    body: "This is post #{n + 1}."
  )
end
