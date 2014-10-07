module Precious
  module Views
    class AdminPage < Layout
      def content
        "Teste"
      end
      def emails
        em = @emails.map {|e| e.first }
        em.sort_by {|x| x.downcase }
      end

      def roles
        @roles.map {|r| r.first }
      end

      def selected
        @selected_email
      end

      def has_email?
        !@selected_email.nil?
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
