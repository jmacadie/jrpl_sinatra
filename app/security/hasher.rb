module Security
  class Hasher
    def hash(password)
      BCrypt::Password.create(password).to_s
    end

    def matches?(password, digest)
      BCrypt::Password.new(digest) == password
    end
  end
end
