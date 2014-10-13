module Precious
  module Views
    class AdminPage < Layout
      def title
        "Weaki administration page"
      end
      def content
        "Teste"
      end
      def users
        u = @users.map {|e| e.first }
        u.sort_by {|x| x.downcase }
      end

      def roles
        @roles.map {|r| r.first }
      end

      def selected
        @selected_user
      end

      def has_user?
        !@selected_user.nil?
      end

      def user_roles
        @user_roles.map {|r| r.first }
      end

      def selected_role
        @selected_role
      end

      def has_role?
        !@selected_role.nil?
      end

      def role_perms
        @role_perms
      end

      def success
        @success
      end
    end
  end
end
