# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Pluck, :config do
  %w[map collect].each do |method|
    context 'when using Rails 5.0 or newer', :rails50 do
      context "when `#{method}` with symbol literal key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a[:foo] }
              ^{method}^^^^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { |a| a[:foo] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck(:foo)
          RUBY
        end
      end

      context "when `#{method}` with string literal key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a['foo'] }
              ^{method}^^^^^^^^^^^^^^^^^ Prefer `pluck('foo')` over `%{method} { |a| a['foo'] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck('foo')
          RUBY
        end
      end

      context "when `#{method}` with method call key can be replaced with `pluck`" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, method: method)
            x.%{method} { |a| a[obj.do_something] }
              ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `pluck(obj.do_something)` over `%{method} { |a| a[obj.do_something] }`.
          RUBY

          expect_correction(<<~RUBY)
            x.pluck(obj.do_something)
          RUBY
        end
      end

      context 'when the block argument is unused' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            x.#{method} { |a| b[:foo] }
          RUBY
        end
      end

      context 'when using Ruby 2.7 or newer', :ruby27 do
        context 'when using numbered parameter' do
          context "when `#{method}` can be replaced with `pluck`" do
            it 'registers an offense' do
              expect_offense(<<~RUBY, method: method)
                x.%{method} { _1[:foo] }
                  ^{method}^^^^^^^^^^^^^ Prefer `pluck(:foo)` over `%{method} { _1[:foo] }`.
              RUBY

              expect_correction(<<~RUBY)
                x.pluck(:foo)
              RUBY
            end
          end
        end
      end
    end

    context 'when using Rails 4.2 or older', :rails42 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          x.#{method} { |a| a[:foo] }
        RUBY
      end
    end
  end
end
