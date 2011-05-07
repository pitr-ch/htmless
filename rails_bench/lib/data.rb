OBJECTS_COUNT = 50

User = Struct.new(:id, :login, :password, :age)
USERS = Array.new(OBJECTS_COUNT) do |i|
  User.new i, rand(10000000).to_s(36), rand(10000000).to_s(16), rand(60)+10
end

Comment = Struct.new(:id, :subject, :content)
COMMENTS = Array.new(OBJECTS_COUNT) do |i|
  Comment.new i, rand(10000000).to_s(36), rand(10000000).to_s(36)*50
end