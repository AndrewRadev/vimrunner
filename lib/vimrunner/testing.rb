require 'tmpdir'

module Vimrunner

  # Public: Provides some utility helpers to assist in using Vimrunner for
  # testing purposes.
  module Testing

    # Public: Within the given block, switches to a temporary directory for
    # isolation purposes.
    #
    # Example:
    #
    #   tmpdir(vim) do
    #     puts vim.command('pwd')
    #   end
    #
    # vim - a Vimrunner::Client instance
    #
    # Returns nothing.
    # Yields nothing.
    def tmpdir(vim)
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          vim.command("cd #{dir}")
          yield
        end
      end
    end

    # Public: Writes the given string to the file identified by "filename".
    #
    # Uses #normalize_string_indent to ensure consistent indentation when given
    # a heredoc, and takes care to write it in the same way that Vim would.
    #
    # filename - a String, the name of the file to write
    # string   - a String, the contents of the file
    #
    # Returns nothing.
    def write_file(filename, string)
      string = normalize_string_indent(string)
      File.open(filename, 'w') { |f| f.write(string + "\n") }
    end

    # Public: Normalizes a string's indentation whitespace, so that heredocs
    # can be used more easily for testing.
    #
    # Example
    #
    #   foo = normalize_string_indent(<<-EOF)
    #     def foo
    #       bar
    #     end
    #   EOF
    #
    # In this case, the raw string would have a large chunk of indentation in
    # the beginning due to its location within the code. The helper removes all
    # whitespace in the beginning by taking the one of the first line.
    #
    # Note: #scan and #chop are being used instead of #split to avoid
    # discarding empty lines.
    #
    # string - a String, usually defined using a heredoc
    #
    # Returns a String with reduced indentation.
    def normalize_string_indent(string)
      if string.end_with?("\n")
        lines      = string.scan(/.*\n/).map(&:chop)
        whitespace = lines.grep(/\S/).first.scan(/^\s*/).first
      else
        lines      = [string]
        whitespace = string.scan(/^\s*/).first
      end

      lines.map do |line|
        line.gsub(/^#{whitespace}/, '') if line =~ /\S/
      end.join("\n")
    end
  end
end
