require "test_helper"

class UserTest < ActiveSupport::TestCase
  # — Validity —————————————————————————————————————————————————————————————

  test "is valid with valid attributes" do
    user = User.new(email: "new@example.com", password: "Password1!", password_confirmation: "Password1!")
    assert user.valid?
  end

  # — Email validations ————————————————————————————————————————————————————

  test "is invalid without an email" do
    user = User.new(password: "Password1!")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "is invalid with a malformed email" do
    user = User.new(email: "not-an-email", password: "Password1!")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "is invalid with a duplicate email" do
    user = User.new(email: users(:hr_manager).email, password: "Password1!")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  # — Password validations —————————————————————————————————————————————————

  test "is invalid without a password" do
    user = User.new(email: "new@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "is invalid with a password shorter than 8 characters" do
    user = User.new(email: "new@example.com", password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  # — JTI ——————————————————————————————————————————————————————————————————

  test "generates a jti on creation" do
    user = User.create!(email: "new@example.com", password: "Password1!")
    assert_not_nil user.jti
  end

  test "jti is unique across users" do
    assert_not_equal users(:hr_manager).jti, users(:hr_manager_two).jti
  end
end
