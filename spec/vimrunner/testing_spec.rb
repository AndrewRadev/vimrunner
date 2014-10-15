require 'spec_helper'
require 'vimrunner'
require 'vimrunner/testing'

module Vimrunner
  RSpec.describe Testing do
    include Testing

    specify "#normalize_string_indent" do
      sample = normalize_string_indent(<<-EOF)
        def foo
          bar
        end
      EOF

      expect(sample).to eq("def foo\n  bar\nend")
    end

    specify "#write_file" do
      Vimrunner.start do |vim|
        write_file 'written_by_ruby.txt', <<-EOF
          def one
            two
          end
        EOF

        vim.edit 'written_by_vim.txt'
        vim.insert 'def one<cr>  two<cr>end'
        vim.write

        expect(IO.read('written_by_ruby.txt')).to eq(IO.read('written_by_vim.txt'))
      end
    end
  end
end
