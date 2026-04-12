# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# — Default HR user ———————————————————————————————————————————————————————

User.find_or_create_by!(email: "hr@incubyte.co") do |user|
  user.password = "Password1!"
  user.password_confirmation = "Password1!"
end

puts "Seeded default HR user: hr@incubyte.co / Password1!"
