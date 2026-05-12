module Api
  module V1
    class UserSerializer
      def self.call(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          permissions: user.permission_matrix,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
