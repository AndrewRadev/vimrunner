module Vimrunner
  module Driver
    class Abstract
      attr_reader :executable

      def initialize(executable)
        @executable = executable
      end

      def spawn(name)
        raise NotImplementedError, "must be defined in a subclass."
      end

      def ==(other)
        other.is_a?(Driver::Abstract) && executable == other.executable
      end

      private

      # The path to a vimrc file containing some required vimscript. The server
      # is started with no settings or a vimrc, apart from this one.
      def vimrc_path
        File.join(File.expand_path('../../../..', __FILE__), 'vim', 'vimrc')
      end
    end
  end
end
