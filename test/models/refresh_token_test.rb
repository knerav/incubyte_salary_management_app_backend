require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  # — generate_for —————————————————————————————————————————————————————————

  test "generate_for creates a refresh token record for the user" do
    assert_difference "RefreshToken.count", 1 do
      RefreshToken.generate_for(users(:hr_manager))
    end
  end

  test "generate_for returns the raw token string" do
    raw = RefreshToken.generate_for(users(:hr_manager))
    assert_kind_of String, raw
    assert raw.length >= 32
  end

  test "generate_for sets expires_at 7 days from now" do
    RefreshToken.generate_for(users(:hr_manager))
    assert_in_delta 7.days.from_now, RefreshToken.last.expires_at, 5.seconds
  end

  test "stores a digest rather than the raw token" do
    raw = RefreshToken.generate_for(users(:hr_manager))
    assert_not_equal raw, RefreshToken.last.token_digest
  end

  # — find_active_by_token —————————————————————————————————————————————————

  test "find_active_by_token returns the record for a valid token" do
    raw = RefreshToken.generate_for(users(:hr_manager))
    record = RefreshToken.find_active_by_token(raw)
    assert_not_nil record
    assert_equal users(:hr_manager), record.user
  end

  test "find_active_by_token returns nil for an unknown token" do
    assert_nil RefreshToken.find_active_by_token("not-a-real-token")
  end

  test "find_active_by_token returns nil for an expired token" do
    raw = RefreshToken.generate_for(users(:hr_manager))
    RefreshToken.last.update_columns(expires_at: 1.day.ago)
    assert_nil RefreshToken.find_active_by_token(raw)
  end

  # — Validations ——————————————————————————————————————————————————————————

  test "is invalid without a user" do
    token = RefreshToken.new(token_digest: "abc", expires_at: 7.days.from_now)
    assert_not token.valid?
  end

  test "is invalid without a token_digest" do
    token = RefreshToken.new(user: users(:hr_manager), expires_at: 7.days.from_now)
    assert_not token.valid?
  end

  test "is invalid without expires_at" do
    token = RefreshToken.new(user: users(:hr_manager), token_digest: "abc")
    assert_not token.valid?
  end

  test "token_digest must be unique" do
    RefreshToken.create!(
      user: users(:hr_manager),
      token_digest: "duplicate",
      expires_at: 7.days.from_now
    )
    duplicate = RefreshToken.new(
      user: users(:hr_manager_two),
      token_digest: "duplicate",
      expires_at: 7.days.from_now
    )
    assert_not duplicate.valid?
  end
end
